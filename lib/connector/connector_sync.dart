part of 'meshcore_connector.dart';

/// Syncing with the radio, polling and persistence. Part of the connector so it
/// shares its private state; split out only to keep that file readable.
extension _ConnectorSync on MeshCoreConnector {
  void _armContactSyncWatchdog() {
    _contactSyncWatchdog?.cancel();
    _contactSyncWatchdog = Timer(
      MeshCoreConnector.contactSyncSilence,
      _onContactSyncSilent,
    );
  }

  void _onContactSyncSilent() {
    if (!_isLoadingContacts) return;
    if (isConnected && _contactSyncRetries == 0) {
      _contactSyncRetries++;
      appLogger.warn(
        'Contact sync silent for ${MeshCoreConnector.contactSyncSilence.inSeconds}s; asking again',
        tag: 'Connector',
      );
      _armContactSyncWatchdog();
      unawaited(
        sendFrame(buildGetContactsFrame(since: _contactSyncSince)).catchError((
          Object e,
        ) {
          appLogger.warn('Contact sync retry failed: $e', tag: 'Connector');
        }),
      );
      return;
    }
    appLogger.warn(
      'Contact sync gave up after no answer; keeping saved contacts',
      tag: 'Connector',
    );
    _finishContactSync(stalled: true);
  }

  /// Ends a contact sync, completed by END_OF_CONTACTS or abandoned after
  /// silence, and lets anything waiting on contacts continue.
  void _finishContactSync({required bool stalled}) {
    _contactSyncWatchdog?.cancel();
    _contactSyncWatchdog = null;
    // A complete full sync replaces the list: drop contacts the radio no
    // longer has. A stalled or partial sync keeps everything.
    if (!stalled &&
        !_preserveContactsOnRefresh &&
        !_contactSyncUsesSinceFilter &&
        _contactSyncSeen.isNotEmpty) {
      _contacts.removeWhere((c) => !_contactSyncSeen.contains(c.publicKeyHex));
    }
    _contactSyncSeen.clear();
    _contactSyncStalled = stalled;
    _isLoadingContacts = false;
    _hasLoadedContacts = true;
    _preserveContactsOnRefresh = false;
    _contactSyncUsesSinceFilter = false;
    unawaited(updateKnownDiscovered());
    _notifyFromPart();
    if (!stalled) unawaited(_persistContacts());
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth &&
        _isSyncingChannels &&
        !_channelSyncInFlight) {
      unawaited(_requestNextChannel());
    }
    if (_deferQueuedContactMessagesUntilContacts) {
      unawaited(_processDeferredQueuedContactMessages());
    } else if (_pendingQueueSync) {
      _pendingQueueSync = false;
      unawaited(syncQueuedMessages(force: true));
    }
  }

  Future<void> _loadMessagesForContact(String contactKeyHex) async {
    if (_loadedConversationKeys.contains(contactKeyHex)) return;
    _loadedConversationKeys.add(contactKeyHex);

    final allMessages = await _messageStore.loadMessages(contactKeyHex);
    if (allMessages.isNotEmpty) {
      // Keep only the most recent N messages in memory to bound memory usage
      final windowedMessages =
          allMessages.length > MeshCoreConnector._messageWindowSize
          ? allMessages.sublist(
              allMessages.length - MeshCoreConnector._messageWindowSize,
            )
          : allMessages;

      final currentMessages =
          _conversations[contactKeyHex] ?? const <Message>[];
      final mergedMessages = <Message>[...windowedMessages];
      final persistedKeyCounts = <String, int>{};
      for (final message in windowedMessages) {
        final key = _messageMergeKey(message);
        persistedKeyCounts[key] = (persistedKeyCounts[key] ?? 0) + 1;
      }
      final currentKeyCounts = <String, int>{};

      for (final message in currentMessages) {
        final key = _messageMergeKey(message);
        final currentCount = (currentKeyCounts[key] ?? 0) + 1;
        currentKeyCounts[key] = currentCount;
        final persistedCount = persistedKeyCounts[key] ?? 0;

        // Preserve distinct duplicates without IDs (for example same text
        // received multiple times in the same second) by only skipping the
        // overlapping occurrences that already exist in persisted storage.
        if (currentCount > persistedCount) {
          mergedMessages.add(message);
        }
      }

      // Re-sort after merging persisted and in-memory messages so the
      // conversation window remains stable after optimistic inserts.
      mergedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final windowedMergedMessages =
          mergedMessages.length > MeshCoreConnector._messageWindowSize
          ? mergedMessages.sublist(
              mergedMessages.length - MeshCoreConnector._messageWindowSize,
            )
          : mergedMessages;

      _conversations[contactKeyHex] = windowedMergedMessages;
      _notifyFromPart();
    }
  }

  /// Recalculates both cached unread totals from scratch.
  /// Called when unread state is first loaded.
  void _recalculateCachedUnreadTotals() {
    _recalculateCachedContactsUnreadTotal();
    _recalculateCachedChannelsUnreadTotal();
  }

  void _recalculateCachedContactsUnreadTotal() {
    int total = 0;
    _contactUnreadCount.forEach((contactKeyHex, count) {
      if (_shouldTrackUnreadForContactKey(contactKeyHex)) {
        total += count;
      }
    });
    _cachedContactsUnreadTotal = total;
  }

  void _recalculateCachedChannelsUnreadTotal() {
    final allChannels = _channels.isNotEmpty ? _channels : _cachedChannels;
    _cachedChannelsUnreadTotal = allChannels.fold(
      0,
      (total, ch) => total + ch.unreadCount,
    );
  }

  Future<void> _loadBundledRegionNames() async {
    try {
      final trees = parseRegionTrees(
        await rootBundle.loadString('assets/region_trees.json'),
      );
      _bundledRegionNames = {for (final t in trees) ...t.regions.keys};
    } catch (_) {
      // Tests and stripped builds have no asset; channel regions still work.
    }
  }

  Future<void> _loadChannelOrder() async {
    _channelOrder = await _channelOrderStore.loadChannelOrder();
    _applyChannelOrder();
    _notifyFromPart();
  }

  /// Load persisted channel messages for a specific channel
  Future<void> _loadChannelMessages(int channelIndex) async {
    var allMessages = await _channelMessageStore.loadChannelMessages(
      channelIndex,
    );
    final cutoff = _channelRetentionCutoff;
    if (cutoff != null) {
      final kept = keepChannelMessagesSince(allMessages, cutoff);
      if (kept.length != allMessages.length) {
        await _channelMessageStore.saveChannelMessages(channelIndex, kept);
        allMessages = kept;
      }
    }
    if (allMessages.isNotEmpty) {
      // Keep only the most recent N messages in memory to bound memory usage
      final windowedMessages =
          allMessages.length > MeshCoreConnector._messageWindowSize
          ? allMessages.sublist(
              allMessages.length - MeshCoreConnector._messageWindowSize,
            )
          : allMessages;

      _channelMessages[channelIndex] = windowedMessages;
      _notifyFromPart();
    }
  }

  Future<void> _loadDiscoveredContactCache() async {
    final cached = await _discoveryContactStore.loadContacts();
    // Trim a previously-saved oversized list down to the freshest entries so a
    // device that grew unbounded before the cap existed recovers on load.
    if (cached.length > MeshCoreConnector._maxDiscoveredContacts) {
      cached.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
      cached.removeRange(
        MeshCoreConnector._maxDiscoveredContacts,
        cached.length,
      );
      unawaited(_discoveryContactStore.saveContacts(cached));
    }
    _discoveredContacts
      ..clear()
      ..addAll(cached);
  }

  void _updateStoredContactMessage(
    String contactKeyHex,
    String messageId,
    Message Function(Message current) update,
  ) {
    final messages = _conversations[contactKeyHex];
    if (messages == null) {
      return;
    }
    final index = messages.indexWhere((entry) => entry.messageId == messageId);
    if (index < 0) {
      return;
    }
    messages[index] = update(messages[index]);
    _messageStore.saveMessages(contactKeyHex, messages);
    _notifyFromPart();
  }

  void _updateStoredChannelMessage(
    int channelIndex,
    String messageId,
    ChannelMessage Function(ChannelMessage current) update,
  ) {
    final messages = _channelMessages[channelIndex];
    if (messages == null) {
      return;
    }
    final index = messages.indexWhere((entry) => entry.messageId == messageId);
    if (index < 0) {
      return;
    }
    messages[index] = update(messages[index]);
    _channelMessageStore.saveChannelMessages(channelIndex, messages);
    _notifyFromPart();
  }

  void _resetSyncProgressState() {
    _pendingInitialChannelSync = false;
    _pendingInitialContactsSync = false;
    _pendingInitialQueuedMessageSync = false;
    _contactSyncTotal = null;
    _contactSyncReceived = 0;
    _contactSyncUsesSinceFilter = false;
    _contactSyncWatchdog?.cancel();
    _contactSyncWatchdog = null;
    _contactSyncSeen.clear();
    _isLoadingContacts = false;
    _hasLoadedContacts = false;
    _isLoadingChannels = false;
    _hasLoadedChannels = false;
    _isSyncingQueuedMessages = false;
    _deferQueuedContactMessagesUntilContacts = false;
    _isProcessingDeferredQueuedContactMessages = false;
    _queuedMessageSyncInFlight = false;
    _deferredQueuedContactMessageFrames.clear();
    _pendingQueueSync = false;
    _queueSyncTimeout?.cancel();
    _queueSyncTimeout = null;
    _queueSyncRetries = 0;
    _isSyncingChannels = false;
    _channelSyncInFlight = false;
    _channelSyncTimeout?.cancel();
    _channelSyncTimeout = null;
    _channelSyncRetries = 0;
    _nextChannelIndexToRequest = 0;
    _totalChannelsToRequest = 0;
    _previousChannelsCache.clear();
  }

  void _startBatteryPolling() {
    _batteryPollTimer?.cancel();
    _batteryPollTimer = Timer.periodic(batteryPollInterval, (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      unawaited(requestBatteryStatus(force: true));
    });
  }

  void _stopBatteryPolling() {
    _batteryPollTimer?.cancel();
    _batteryPollTimer = null;
  }

  /// Start polling the radio's GPS-backed self-info every minute.
  /// No-op if already running. Triggered when the radio reports `gps=1`.
  void _startGpsLocationPolling() {
    if (_gpsLocationPollTimer != null) return;
    _gpsLocationPollTimer = Timer.periodic(gpsLocationPollInterval, (timer) {
      if (!isConnected) {
        timer.cancel();
        _gpsLocationPollTimer = null;
        return;
      }
      unawaited(sendFrame(buildAppStartFrame()));
    });
  }

  void _stopGpsLocationPolling() {
    _gpsLocationPollTimer?.cancel();
    _gpsLocationPollTimer = null;
  }

  void _startRadioStatsPolling() {
    _radioStatsPollTimer?.cancel();
    _radioStatsPollTimer = Timer.periodic(radioStatsPollInterval, (_) {
      if (!isConnected) {
        _stopRadioStatsPolling();
        return;
      }
      unawaited(requestRadioStats());
    });
  }

  void _stopRadioStatsPolling() {
    _radioStatsPollTimer?.cancel();
    _radioStatsPollTimer = null;
  }

  Future<Contact?> _fetchContactSnapshotFromDevice(
    Uint8List pubKey, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isConnected) return null;
    final expectedKeyHex = pubKeyToHex(pubKey);
    final completer = Completer<Contact?>();

    void finish(Contact? result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty || frame[0] != respCodeContact) return;
      final parsed = Contact.fromFrame(frame);
      if (parsed == null || parsed.publicKeyHex != expectedKeyHex) return;
      finish(parsed);
    });

    final timer = Timer(timeout, () => finish(null));
    try {
      await getContactByKey(pubKey);
      return await completer.future;
    } finally {
      timer.cancel();
      await subscription.cancel();
    }
  }

  Future<void> _requestNextQueuedMessage() async {
    if (!isConnected) {
      _isSyncingQueuedMessages = false;
      _queuedMessageSyncInFlight = false;
      _queueSyncRetries = 0;
      return;
    }
    if (_queuedMessageSyncInFlight) return;
    _queuedMessageSyncInFlight = true;

    // Cancel any existing timeout
    _queueSyncTimeout?.cancel();

    // Set up timeout for this request
    _queueSyncTimeout = Timer(
      Duration(milliseconds: MeshCoreConnector._queueSyncTimeoutMs),
      () {
        _handleQueueSyncTimeout();
      },
    );

    debugPrint(
      '[QueueSync] Requesting next message (retry: $_queueSyncRetries/${MeshCoreConnector._maxQueueSyncRetries})',
    );

    try {
      await sendFrame(buildSyncNextMessageFrame());
    } catch (e) {
      debugPrint('[QueueSync] Error sending sync request: $e');
      _queuedMessageSyncInFlight = false;
      _isSyncingQueuedMessages = false;
      _queueSyncTimeout?.cancel();
      _queueSyncRetries = 0;
      _notifyFromPart();
      _continueAfterQueuedMessageSync();
    }
  }

  void _handleQueueSyncTimeout() {
    debugPrint(
      '[QueueSync] Timeout waiting for message (retry: $_queueSyncRetries/${MeshCoreConnector._maxQueueSyncRetries})',
    );

    if (_queueSyncRetries < MeshCoreConnector._maxQueueSyncRetries) {
      // Retry
      _queueSyncRetries++;
      _queuedMessageSyncInFlight = false;
      _requestNextQueuedMessage();
    } else {
      // Max retries reached, give up
      debugPrint('[QueueSync] Max retries reached, stopping sync');
      _queuedMessageSyncInFlight = false;
      _isSyncingQueuedMessages = false;
      _queueSyncRetries = 0;
      _notifyFromPart();
      _continueAfterQueuedMessageSync();
    }
  }

  void _handleChannelSyncTimeout(int channelIndex) {
    debugPrint(
      '[ChannelSync] Timeout waiting for channel $channelIndex (retry: $_channelSyncRetries/${MeshCoreConnector._maxChannelSyncRetries})',
    );

    if (_channelSyncRetries < MeshCoreConnector._maxChannelSyncRetries) {
      // Retry the same channel
      _channelSyncRetries++;
      _channelSyncInFlight = false;
      unawaited(_requestNextChannel());
    } else {
      // Max retries reached for this channel, restore from cache and move to next
      debugPrint(
        '[ChannelSync] Max retries reached for channel $channelIndex, attempting cache restore',
      );

      // Try to restore this channel from cache
      try {
        final cachedChannel = _previousChannelsCache.firstWhere(
          (c) => c.index == channelIndex,
        );
        if (!cachedChannel.isEmpty) {
          _channels.add(cachedChannel);
          debugPrint(
            '[ChannelSync] Restored channel $channelIndex (${cachedChannel.name}) from cache',
          );
        }
      } catch (e) {
        // No cached channel found, that's okay
      }

      // Move to next channel
      _nextChannelIndexToRequest++;
      _channelSyncRetries = 0;
      _channelSyncInFlight = false;
      _notifyFromPart();
      unawaited(_requestNextChannel());
    }
  }

  void _completeChannelSync() {
    _channelSyncTimeout?.cancel();

    debugPrint(
      '[ChannelSync] Sync complete: received ${_channels.length}/$_totalChannelsToRequest channels',
    );

    _cleanupChannelSync(completed: true);

    // Cache channels for offline use
    _cachedChannels = List<Channel>.from(_channels);
    unawaited(_channelStore.saveChannels(_channels));
    _recalculateCachedChannelsUnreadTotal();

    // Apply ordering and notify UI
    _applyChannelOrder();
    _notifyFromPart();
  }

  void _cleanupChannelSync({required bool completed}) {
    _isSyncingChannels = false;
    _channelSyncInFlight = false;
    _isLoadingChannels = false;
    _channelSyncTimeout?.cancel();
    _channelSyncRetries = 0;
    _nextChannelIndexToRequest = 0;
    _totalChannelsToRequest = 0;

    if (completed) {
      _hasLoadedChannels = true;
      _previousChannelsCache.clear();
    } else if (_channels.isEmpty && _previousChannelsCache.isNotEmpty) {
      // A failed initial sync should not leave the UI empty/spinning forever.
      // Restore the pre-sync list so cached channels remain usable.
      _channels.addAll(_previousChannelsCache);
      _applyChannelOrder();
      _recalculateCachedChannelsUnreadTotal();
    }

    if (isConnected) {
      _startPostChannelInitialQueuedMessageSync();
    }

    // Keep cache on failure/disconnection for future attempts
    if (!completed) {
      _notifyFromPart();
    }
  }

  void _startPostChannelInitialQueuedMessageSync() {
    if (_pendingInitialQueuedMessageSync || _pendingQueueSync) {
      _deferQueuedContactMessagesUntilContacts = _pendingInitialContactsSync;
      _pendingInitialQueuedMessageSync = false;
      _pendingQueueSync = false;
      unawaited(syncQueuedMessages(force: true));
    }
  }

  void _maybeStartInitialChannelSync() {
    if (!_pendingInitialChannelSync || !isConnected) {
      return;
    }
    if (_selfPublicKey == null ||
        (_shouldGateInitialChannelSync && !_hasReceivedDeviceInfo)) {
      return;
    }

    _pendingInitialChannelSync = false;
    unawaited(getChannels(maxChannels: _maxChannels, force: true));
  }

  bool _shouldDeferQueuedContactMessage(Uint8List frame) {
    if (!_deferQueuedContactMessagesUntilContacts ||
        !_isSyncingQueuedMessages) {
      return false;
    }
    if (frame.isEmpty) return false;
    return frame[0] == respCodeContactMsgRecv ||
        frame[0] == respCodeContactMsgRecvV3;
  }

  void _continueAfterQueuedMessageSync() {
    if (!_deferQueuedContactMessagesUntilContacts) return;
    if (_pendingInitialContactsSync && isConnected) {
      _pendingInitialContactsSync = false;
      unawaited(getContacts());
      return;
    }
    unawaited(_processDeferredQueuedContactMessages());
  }

  Future<void> _processDeferredQueuedContactMessages() async {
    if (!_deferQueuedContactMessagesUntilContacts ||
        _isProcessingDeferredQueuedContactMessages) {
      return;
    }
    if (_deferredQueuedContactMessageFrames.isEmpty) {
      _deferQueuedContactMessagesUntilContacts = false;
      _notifyFromPart();
      if (_pendingQueueSync && isConnected) {
        _pendingQueueSync = false;
        unawaited(syncQueuedMessages(force: true));
      }
      return;
    }

    _isProcessingDeferredQueuedContactMessages = true;
    _notifyFromPart();
    try {
      // Replay direct/room queued messages only after contacts are loaded, so
      // sender prefixes can be resolved against the current contact list.
      while (_deferredQueuedContactMessageFrames.isNotEmpty) {
        final frame = _deferredQueuedContactMessageFrames.removeAt(0);
        await _handleIncomingMessage(frame);
      }
    } finally {
      _deferQueuedContactMessagesUntilContacts = false;
      _isProcessingDeferredQueuedContactMessages = false;
      _notifyFromPart();
    }

    if (_pendingQueueSync && isConnected) {
      _pendingQueueSync = false;
      unawaited(syncQueuedMessages(force: true));
    }
  }

  Future<void> _persistContacts() async {
    await _contactStore.saveContacts(_contacts);
  }

  Future<void> _persistDiscoveredContacts() async {
    await _discoveryContactStore.saveContacts(_discoveredContacts);
  }

  void _ensureContactSmazSettingLoaded(String contactKeyHex) {
    if (_contactSmazEnabled.containsKey(contactKeyHex)) return;
    _contactSettingsStore.loadSmazEnabled(contactKeyHex).then((enabled) {
      if (_contactSmazEnabled[contactKeyHex] == enabled) return;
      _contactSmazEnabled[contactKeyHex] = enabled;
      _notifyFromPart();
    });
  }

  void _ensureContactCyr2LatSettingLoaded(String contactKeyHex) {
    if (_contactCyr2LatEnabled.containsKey(contactKeyHex)) return;
    _contactSettingsStore.loadCyr2LatEnabled(contactKeyHex).then((enabled) {
      if (_contactCyr2LatEnabled[contactKeyHex] == enabled) return;
      _contactCyr2LatEnabled[contactKeyHex] = enabled;
      _notifyFromPart();
    });
  }

  void _ensureContactUrlImagesSettingLoaded(String contactKeyHex) {
    if (_contactUrlImagesEnabled.containsKey(contactKeyHex)) return;
    _contactSettingsStore.loadUrlImagesEnabled(contactKeyHex).then((enabled) {
      if (_contactUrlImagesEnabled[contactKeyHex] == enabled) return;
      _contactUrlImagesEnabled[contactKeyHex] = enabled;
      _notifyFromPart();
    });
  }

  void _ensureContactCyr2LatProfileLoaded(String contactKeyHex) {
    if (_contactCyr2LatProfileId.containsKey(contactKeyHex)) return;
    _contactSettingsStore.loadCyr2LatProfileId(contactKeyHex).then((profileId) {
      if (_contactCyr2LatProfileId[contactKeyHex] == profileId) return;
      _contactCyr2LatProfileId[contactKeyHex] = profileId;
      _notifyFromPart();
    });
  }

  void _ensureChannelCyr2LatSettingLoaded(int channelIndex) {
    if (_channelCyr2LatEnabled.containsKey(channelIndex)) return;
    _channelSettingsStore.loadCyr2LatEnabled(channelIndex).then((enabled) {
      if (_channelCyr2LatEnabled[channelIndex] == enabled) return;
      _channelCyr2LatEnabled[channelIndex] = enabled;
      _notifyFromPart();
    });
  }

  void _ensureChannelCyr2LatProfileLoaded(int channelIndex) {
    if (_channelCyr2LatProfileId.containsKey(channelIndex)) return;
    _channelSettingsStore.loadCyr2LatProfileId(channelIndex).then((profileId) {
      if (_channelCyr2LatProfileId[channelIndex] == profileId) return;
      _channelCyr2LatProfileId[channelIndex] = profileId;
      _notifyFromPart();
    });
  }

  Uint8List? _decryptPayload(Uint8List psk, Uint8List encrypted) {
    if (encrypted.length <= _cipherMacSize) return null;
    final mac = encrypted.sublist(0, _cipherMacSize);
    final cipherText = encrypted.sublist(_cipherMacSize);

    final key32 = Uint8List(32);
    final copyLen = psk.length < 32 ? psk.length : 32;
    key32.setRange(0, copyLen, psk);

    final hmac = crypto.Hmac(crypto.sha256, key32).convert(cipherText).bytes;
    if (hmac[0] != mac[0] || hmac[1] != mac[1]) {
      return null;
    }

    if (cipherText.isEmpty || cipherText.length % 16 != 0) return null;
    final key16 = Uint8List(16);
    final keyLen = psk.length < 16 ? psk.length : 16;
    key16.setRange(0, keyLen, psk);

    final cipher = ECBBlockCipher(AESEngine());
    cipher.init(false, KeyParameter(key16));
    final out = Uint8List(cipherText.length);
    for (var i = 0; i < cipherText.length; i += 16) {
      cipher.processBlock(cipherText, i, out, i);
    }
    return out;
  }

  String _nextReactionSendQueueId() {
    _reactionSendQueueSequence++;
    return '${MeshCoreConnector._reactionSendQueuePrefix}$_reactionSendQueueSequence';
  }

  bool _isReactionSendQueueId(String queueId) {
    return queueId.startsWith(MeshCoreConnector._reactionSendQueuePrefix);
  }
}
