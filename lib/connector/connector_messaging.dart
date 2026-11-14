part of 'meshcore_connector.dart';

/// Sending, retries, and contact, channel and path upkeep. Part of the connector so it
/// shares its private state; split out only to keep that file readable.
extension _ConnectorMessaging on MeshCoreConnector {
  String _messageMergeKey(Message message) {
    final messageId = message.messageId;
    if (messageId.isNotEmpty) {
      return 'id:$messageId';
    }
    return 'fallback:${message.senderKeyHex}:${message.isOutgoing}:${message.isCli}:${message.timestamp.millisecondsSinceEpoch}:${message.text}';
  }

  /// After an incoming DM or channel message, wait before TX so we do not
  /// collide with mesh propagation. With companion stats, scale wait by RF
  /// conditions (up to [MeshCoreConnector._contactMsgBackoffMaxMs]); otherwise use
  /// [MeshCoreConnector._contactMsgBackoffFallbackMs].
  int _contactMessageBackoffTargetMs() {
    if (!supportsCompanionRadioStats || _latestRadioStats == null) {
      return MeshCoreConnector._contactMsgBackoffFallbackMs;
    }
    final stats = _latestRadioStats!;
    return txBackoffTargetMs(
      noiseFloorDbm: stats.noiseFloorDbm.toDouble(),
      lastSnrDb: stats.lastSnrDb,
      airBusy: _recentAirtimeBusyFraction(),
      minMs: MeshCoreConnector._contactMsgBackoffMinMs,
      maxMs: MeshCoreConnector._contactMsgBackoffMaxMs,
    );
  }

  /// Start of the post-inbound cool-down: the later of BLE message RX time and
  /// companion airtime bump ([_airtimeBumpStopwatch], same as the activity dot).
  DateTime _postTxBackoffAnchor(DateTime lastInboundRxTime) {
    if (!supportsCompanionRadioStats) return lastInboundRxTime;
    final sw = _airtimeBumpStopwatch;
    if (sw == null || !sw.isRunning) return lastInboundRxTime;
    final bumpAt = DateTime.now().subtract(sw.elapsed);
    return bumpAt.isAfter(lastInboundRxTime) ? bumpAt : lastInboundRxTime;
  }

  Future<bool> _sendMessageDirect(
    Contact contact,
    String text,
    int attempt,
    int timestampSeconds,
  ) async {
    if (!isConnected || text.isEmpty) return false;
    try {
      await _waitForRadioQuiet(lastInboundRxTime: _lastContactMsgRxTime);
      final outboundText = prepareContactOutboundText(contact, text);
      await sendFrame(
        buildSendTextMsgFrame(
          contact.publicKey,
          outboundText,
          attempt: attempt,
          timestampSeconds: timestampSeconds,
        ),
      );
      return true;
    } catch (e) {
      appLogger.error('Failed to send message: $e', tag: 'Connector');
      return false;
    }
  }

  void _updateMessage(Message message) {
    final contactKey = pubKeyToHex(message.senderKey);
    final messages = _conversations[contactKey];
    if (messages != null) {
      final index = messages.indexWhere(
        (m) => m.messageId == message.messageId,
      );
      if (index != -1) {
        messages[index] = message;
        _messageStore.saveMessages(contactKey, messages);
        _notifyFromPart();
      }
    }

    // If this is a reaction message, update the target message's reaction status
    final reactionInfo = ReactionHelper.parseReaction(message.text);
    if (reactionInfo != null &&
        (message.status == MessageStatus.delivered ||
            message.status == MessageStatus.failed)) {
      final contactKey2 = pubKeyToHex(message.senderKey);
      _setReactionStatus(contactKey2, reactionInfo, message.status);
      _messageStore.saveMessages(
        contactKey2,
        _conversations[contactKey2] ?? [],
      );
      _notifyFromPart();
    }
  }

  void _recordPathResult(
    String contactPubKeyHex,
    PathSelection selection,
    bool success,
    int? tripTimeMs,
  ) {
    if (_pathHistoryService == null) return;
    final settings = _appSettingsService?.settings;
    _pathHistoryService!.recordPathResult(
      contactPubKeyHex,
      selection,
      success: success,
      tripTimeMs: tripTimeMs,
      successIncrement: settings?.routeWeightSuccessIncrement ?? 0.2,
      failureDecrement: settings?.routeWeightFailureDecrement ?? 0.2,
      maxWeight: settings?.maxRouteWeight ?? 5.0,
    );

    // Flood path attribution: when a flood delivery succeeds, credit the
    // contact's current device path so the route the ACK traveled back
    // through gets a weight boost in the path history.
    if (selection.useFlood && success) {
      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c?.publicKeyHex == contactPubKeyHex,
        orElse: () => null,
      );
      if (contact != null &&
          contact.pathLength >= 0 &&
          contact.path.isNotEmpty) {
        _pathHistoryService!.recordFloodPathAttribution(
          contactPubKeyHex: contactPubKeyHex,
          pathBytes: contact.path,
          hopCount: contact.pathLength,
          tripTimeMs: tripTimeMs,
          successIncrement: settings?.routeWeightSuccessIncrement ?? 0.2,
          maxWeight: settings?.maxRouteWeight ?? 5.0,
        );
      }

      // Request a fresh contact from the device so the next flood
      // attribution uses the most up-to-date path.
      if (contact != null) {
        unawaited(getContactByKey(contact.publicKey));
      }
    }
  }

  PathSelection? _selectAutoPathForAttempt(
    String contactPubKeyHex, {
    required int attemptIndex,
    required int maxRetries,
    List<PathSelection> recentSelections = const [],
  }) {
    final hasKnownPaths =
        _pathHistoryService?.getRecentPaths(contactPubKeyHex).isNotEmpty ??
        false;
    if (!hasKnownPaths) {
      return null;
    }

    final selection = _pathHistoryService?.selectPathForAttempt(
      contactPubKeyHex,
      attemptIndex: attemptIndex,
      maxRetries: maxRetries,
      recentSelections: recentSelections,
    );
    if (selection != null) {
      _pathHistoryService?.recordPathAttempt(contactPubKeyHex, selection);
    }
    return selection;
  }

  bool _isPathLenValidForCurrentMode(int pathLen, List<int> pathBytes) {
    return _isPathLenValidForMode(pathLen, pathBytes, _pathHashByteWidth);
  }

  int? _encodePathLenForCurrentMode(int pathLen, List<int> pathBytes) {
    if (pathLen < 0 || pathLen == 0xFF) return pathLen;
    if (!_isPathLenValidForCurrentMode(pathLen, pathBytes)) {
      appLogger.warn(
        'Invalid path_len for mode: pathLen=$pathLen, '
        'bytesLen=${pathBytes.length}, width=$_pathHashByteWidth',
        tag: 'Connector',
      );
      return null;
    }
    final mode = (_pathHashByteWidth - 1) & 0x03;
    return (pathLen & 0x3F) | (mode << 6);
  }

  void _scheduleSelfInfoRetry() {
    _selfInfoRetryTimer?.cancel();
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth) {
      var attempts = 0;
      const maxAttempts = 3;
      _selfInfoRetryTimer = Timer.periodic(const Duration(seconds: 10), (
        timer,
      ) {
        if (!isConnected || !_awaitingSelfInfo) {
          timer.cancel();
          return;
        }
        if (_isLoadingContacts || _isSyncingChannels || _channelSyncInFlight) {
          return;
        }
        attempts += 1;
        unawaited(sendFrame(buildAppStartFrame()));
        if (attempts >= maxAttempts) {
          timer.cancel();
        }
      });
      return;
    }
    _selfInfoRetryTimer = Timer.periodic(const Duration(milliseconds: 3500), (
      timer,
    ) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      if (!_awaitingSelfInfo) {
        timer.cancel();
        return;
      }
      unawaited(sendFrame(buildAppStartFrame()));
    });
  }

  /// Replaces the message [messageId] on [channelIndex] with [change] of it
  /// and saves the channel.
  void _updateChannelMessage(
    int channelIndex,
    String messageId,
    ChannelMessage Function(ChannelMessage) change,
  ) {
    final messages = _channelMessages[channelIndex];
    if (messages == null) return;
    final i = messages.lastIndexWhere((m) => m.messageId == messageId);
    if (i < 0) return;
    messages[i] = change(messages[i]);
    unawaited(_channelMessageStore.saveChannelMessages(channelIndex, messages));
    _notifyFromPart();
  }

  Future<void> _runScopedChannelSend(
    Future<void> Function() action, {
    required String region,
  }) async {
    final prev = _channelScopedSendLock;
    final completer = Completer<void>();
    _channelScopedSendLock = completer.future;
    await prev;

    try {
      // Only touch the global flood scope for region-scoped channels. Plain
      // channels send exactly as before, which also stays compatible with
      // firmware that predates CMD_SET_FLOOD_SCOPE. The lock is still held so an
      // unscoped send can't interleave with (and inherit the scope of) a
      // concurrent scoped send.
      if (region.isEmpty) {
        await action();
        return;
      }
      await _sendFrameAndWaitForCommandAck(buildSetFloodScopeFrame(region));
      try {
        await action();
      } finally {
        if (isConnected) {
          await _sendFrameAndWaitForCommandAck(buildSetFloodScopeFrame(''));
        }
      }
    } finally {
      completer.complete();
    }
  }

  // Sends [data] and resolves once the device replies with RESP_CODE_OK.
  // SET_FLOOD_SCOPE, channel text sends and channel data sends all reply with
  // RESP_CODE_OK (writeOKFrame); only direct messages reply with RESP_CODE_SENT.
  // Waiting for the text send's ack before the scope is reset guarantees the
  // firmware has already built the packet with the active scope.
  Future<void> _sendFrameAndWaitForCommandAck(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
  }) async {
    final completer = Completer<void>();
    late final StreamSubscription<Uint8List> subscription;
    late final Timer timeout;

    void complete() {
      if (!completer.isCompleted) completer.complete();
    }

    void completeError(Object error) {
      if (!completer.isCompleted) completer.completeError(error);
    }

    subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      if (frame[0] == respCodeOk) {
        complete();
      } else if (frame[0] == respCodeErr) {
        final errCode = frame.length > 1 ? frame[1] : -1;
        completeError(Exception('Command failed with error code $errCode'));
      }
    });

    timeout = Timer(MeshCoreConnector._commandAckTimeout, () {
      completeError(TimeoutException('Command ACK timed out'));
    });

    try {
      await sendFrame(
        data,
        channelSendQueueId: channelSendQueueId,
        expectsGenericAck: expectsGenericAck,
      );
      await completer.future;
    } finally {
      timeout.cancel();
      await subscription.cancel();
    }
  }

  Future<void> _requestNextChannel() async {
    if (!isConnected) {
      _cleanupChannelSync(completed: false);
      return;
    }

    if (_channelSyncInFlight) return;

    // Check if we've requested all channels
    if (_nextChannelIndexToRequest >= _totalChannelsToRequest) {
      _completeChannelSync();
      return;
    }

    _channelSyncInFlight = true;
    final channelIndex = _nextChannelIndexToRequest;

    // Cancel any existing timeout
    _channelSyncTimeout?.cancel();

    // Set up timeout for this channel request
    _channelSyncTimeout = Timer(
      Duration(milliseconds: MeshCoreConnector._channelSyncTimeoutMs),
      () => _handleChannelSyncTimeout(channelIndex),
    );

    debugPrint(
      '[ChannelSync] Requesting channel $channelIndex/$_totalChannelsToRequest (retry: $_channelSyncRetries/${MeshCoreConnector._maxChannelSyncRetries})',
    );

    try {
      await sendFrame(buildGetChannelFrame(channelIndex));
    } catch (e) {
      debugPrint('[ChannelSync] Error sending channel request: $e');
      _channelSyncInFlight = false;
      _cleanupChannelSync(completed: false);
    }
  }

  void _checkManualAddContacts() async {
    // If manual add contacts is enabled, set auto add config and other params.
    // and disable it after
    if (_manualAddContacts) {
      await sendFrame(
        buildSetAutoAddConfigFrame(
          autoAddChat: true,
          autoAddRepeater: true,
          autoAddRoomServer: true,
          autoAddSensor: true,
          overwriteOldest: _overwriteOldest,
        ),
      );
      await sendFrame(
        buildSetOtherParamsFrame(
          (_telemetryModeEnv << 4) |
              (_telemetryModeLoc << 2) |
              (_telemetryModeBase),
          _advertLocPolicy,
          _multiAcks,
        ),
      );
      _manualAddContacts = false;
    }
  }

  /// Whether the radio would have room for a contact it auto-added from an
  /// advert, mirroring its table: when full it either replaces the oldest
  /// non-favorite (overwrite oldest on), which is dropped here too, or adds
  /// nothing. Without this the list here drifts from the radio's over a long
  /// session, keeping contacts the radio no longer has.
  bool _admitAutoAddedContact(Contact contact) {
    if (_contacts.length < _maxContacts) return true;
    if (!_overwriteOldest) {
      appLogger.info(
        'Contact table full ($_maxContacts); radio did not add ${contact.name}',
        tag: 'Connector',
      );
      return false;
    }
    Contact? oldest;
    for (final c in _contacts) {
      if (c.isFavorite) continue;
      if (oldest == null ||
          (c.lastModified ?? c.lastSeen).isBefore(
            oldest.lastModified ?? oldest.lastSeen,
          )) {
        oldest = c;
      }
    }
    if (oldest == null) return false;
    final evicted = oldest;
    _contacts.removeWhere((c) => c.publicKeyHex == evicted.publicKeyHex);
    _knownContactKeys.remove(evicted.publicKeyHex);
    appLogger.info(
      'Contact table full; radio replaced ${evicted.name} with ${contact.name}',
      tag: 'Connector',
    );
    return true;
  }

  int _latestContactLastmod() {
    if (_contacts.isEmpty) return 0;
    var latest = 0;
    for (final contact in _contacts) {
      // prefer lastmod per spec, fallback to lastseen
      final source = contact.lastModified ?? contact.lastSeen;
      final seconds = source.millisecondsSinceEpoch ~/ 1000;
      if (seconds > latest) {
        latest = seconds;
      }
    }
    return latest;
  }

  bool _setContactLastMessageAt(int index, DateTime timestamp) {
    final contact = _contacts[index];
    if (contact.type != advTypeChat) return false;
    if (!timestamp.isAfter(contact.lastMessageAt)) return false;
    _contacts[index] = contact.copyWith(lastMessageAt: timestamp);
    return true;
  }

  void _updateContactLastMessageAt(
    String contactKeyHex,
    DateTime timestamp, {
    bool notify = false,
  }) {
    final index = _contacts.indexWhere((c) => c.publicKeyHex == contactKeyHex);
    if (index < 0) return;
    if (!_setContactLastMessageAt(index, timestamp)) return;
    unawaited(_persistContacts());
    if (notify) {
      _notifyFromPart();
    }
  }

  void _updateContactLastMessageAtByName(
    String senderName,
    DateTime timestamp, {
    Uint8List? pathBytes,
    int? pathHashWidth,
    bool notify = false,
  }) {
    final normalized = senderName.trim().toLowerCase();
    final hasName = normalized.isNotEmpty && normalized != 'unknown';
    var updated = false;
    var matchedByName = false;

    if (hasName) {
      for (var i = 0; i < _contacts.length; i++) {
        final contact = _contacts[i];
        if (contact.type != advTypeChat) continue;
        if (contact.name.trim().toLowerCase() == normalized) {
          matchedByName = true;
          updated = _setContactLastMessageAt(i, timestamp) || updated;
        }
      }
    }

    if (!matchedByName && pathBytes != null && pathBytes.isNotEmpty) {
      final matches = <int>[];
      for (var i = 0; i < _contacts.length; i++) {
        final contact = _contacts[i];
        if (contact.type != advTypeChat) continue;
        if (_pathMatchesContact(
          pathBytes,
          contact.publicKey,
          pathHashWidth: pathHashWidth,
        )) {
          matches.add(i);
        }
      }
      if (matches.length == 1) {
        updated = _setContactLastMessageAt(matches.first, timestamp) || updated;
      }
    }

    if (updated) {
      unawaited(_persistContacts());
      if (notify) {
        _notifyFromPart();
      }
    }
  }

  bool _pathMatchesContact(
    Uint8List pathBytes,
    Uint8List publicKey, {
    int? pathHashWidth,
  }) {
    final w = pathHashWidth ?? _pathHashByteWidth;
    if (pathBytes.isEmpty || publicKey.length < w) return false;
    for (int i = 0; i + w <= pathBytes.length; i += w) {
      final prefix = pathBytes.sublist(i, i + w);
      if (_matchesPrefix(publicKey, prefix)) {
        return true;
      }
    }
    return false;
  }

  Uint8List? _extractSenderPrefix(Uint8List frame) {
    if (frame.isEmpty) return null;
    final code = frame[0];
    if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
      return null;
    }

    final prefixOffset = code == respCodeContactMsgRecvV3 ? 4 : 1;
    const prefixLen = 6;

    if (frame.length < prefixOffset + prefixLen) return null;

    return frame.sublist(prefixOffset, prefixOffset + prefixLen);
  }

  String _channelDisplayName(int channelIndex) {
    for (final channel in _channels) {
      if (channel.index != channelIndex) continue;
      return channel.name.isEmpty ? 'Channel $channelIndex' : channel.name;
    }
    return 'Channel $channelIndex';
  }

  void _maybeNotifyChannelMessage(
    ChannelMessage message, {
    String? channelName,
    TranslationResult? translationResult,
  }) {
    if (message.isOutgoing || _appSettingsService == null) return;
    final channelIndex = message.channelIndex;
    if (channelIndex == null) return;

    final label = channelName ?? _channelDisplayName(channelIndex);
    if (_appSettingsService!.isChannelMuted(label)) return;
    if (_isBlockedChannelSender(message)) return;
    if (!_receivedChannelMessagesController.isClosed) {
      _receivedChannelMessagesController.add(
        ReceivedChannelMessage(message, label),
      );
    }

    final settings = _appSettingsService!.settings;
    if (!settings.notificationsEnabled || !settings.notifyOnNewChannelMessage) {
      return;
    }

    // Reuse translation result only if completed and non-empty; else use original text
    final resolvedText =
        (translationResult != null &&
            translationResult.status == MessageTranslationStatus.completed &&
            translationResult.translatedText.trim().isNotEmpty)
        ? translationResult.translatedText.trim()
        : message.text.trim();
    unawaited(() async {
      await _notificationService.showChannelMessageNotification(
        radio: slot,
        channelName: notificationTitle(label),
        senderName: message.senderName,
        message: resolvedText,
        urlImagesEnabled: isChannelUrlImagesEnabled(channelIndex),
        channelIndex: message.channelIndex,
        badgeCount: getTotalUnreadCount(),
      );
    }());
  }

  /// Best-effort check for this radio's own traffic. Direct packets carry
  /// only a one-byte source hash, so this can also match other nodes.
  bool _isOwnRxPacket(_RawPacket packet) {
    final selfKey = _selfPublicKey;
    if (selfKey == null || selfKey.isEmpty) return false;
    final payload = packet.payload;
    switch (packet.payloadType) {
      case payloadTypeADVERT:
        if (payload.length < selfKey.length) return false;
        for (var i = 0; i < selfKey.length; i++) {
          if (payload[i] != selfKey[i]) return false;
        }
        return true;
      case payloadTypeREQ ||
          payloadTypeRESPONSE ||
          payloadTypeTXTMSG ||
          payloadTypePATH:
        return payload.length >= 2 && payload[1] == selfKey[0];
      case payloadTypeGRPTXT:
        final selfName = _selfName?.trim();
        if (selfName == null || selfName.isEmpty || payload.isEmpty) {
          return false;
        }
        final encrypted = Uint8List.sublistView(payload, 1);
        final channels = _channels.isNotEmpty ? _channels : _cachedChannels;
        for (final channel in channels) {
          if (channel.isEmpty ||
              _computeChannelHash(channel.psk) != payload[0]) {
            continue;
          }
          final decrypted = _decryptPayload(channel.psk, encrypted);
          if (decrypted == null || decrypted.length < 6) continue;
          final text = BufferReader(decrypted)
            ..skipBytes(5); // timestamp, txt type
          if (_splitSenderText(text.readCString()).senderName.trim() ==
              selfName) {
            return true;
          }
        }
        return false;
      default:
        return false;
    }
  }

  bool _markNextPendingChannelMessageSent() {
    while (_pendingChannelSentQueue.isNotEmpty) {
      final queuedMessageId = _pendingChannelSentQueue.removeAt(0);
      if (_isReactionSendQueueId(queuedMessageId)) {
        return true;
      }
      if (_markPendingChannelMessageSentById(queuedMessageId)) {
        return true;
      }
    }
    return false;
  }

  bool _markPendingChannelMessageSentById(String messageId) {
    for (final entry in _channelMessages.entries) {
      final channelMessages = entry.value;
      for (int i = channelMessages.length - 1; i >= 0; i--) {
        final message = channelMessages[i];
        if (message.messageId != messageId) {
          continue;
        }
        if (!message.isOutgoing ||
            message.status != ChannelMessageStatus.pending) {
          return false;
        }
        channelMessages[i] = message.copyWith(
          status: ChannelMessageStatus.sent,
        );
        _pendingChannelSentQueue.remove(messageId);
        unawaited(
          _channelMessageStore.saveChannelMessages(entry.key, channelMessages),
        );
        _notifyFromPart();
        return true;
      }
    }
    return false;
  }

  void _markPendingChannelMessageFailedById(String messageId) {
    for (final entry in _channelMessages.entries) {
      final channelMessages = entry.value;
      for (int i = channelMessages.length - 1; i >= 0; i--) {
        final message = channelMessages[i];
        if (message.messageId != messageId) {
          continue;
        }
        if (!message.isOutgoing ||
            message.status != ChannelMessageStatus.pending) {
          return;
        }
        channelMessages[i] = message.copyWith(
          status: ChannelMessageStatus.failed,
        );
        unawaited(
          _channelMessageStore.saveChannelMessages(entry.key, channelMessages),
        );
        _notifyFromPart();
        return;
      }
    }
  }

  bool _isChannelTextCommand(int commandCode) =>
      commandCode == cmdSendChannelTxtMsg ||
      commandCode == cmdSendChannelTxtMsgCorridor;

  void _handleOk() {
    if (_pendingGenericAckQueue.isEmpty) {
      return;
    }

    final pendingAck = _pendingGenericAckQueue.removeAt(0);
    pendingAck.completer?.complete();
    if (!_isChannelTextCommand(pendingAck.commandCode) ||
        pendingAck.channelSendQueueId == null) {
      return;
    }

    final queueId = pendingAck.channelSendQueueId!;
    _pendingChannelSentQueue.remove(queueId);
    if (_isReactionSendQueueId(queueId)) {
      return;
    }
    _markPendingChannelMessageSentById(queueId);
  }

  bool _handleRepeaterCommandSent(int ackHash, int timeoutMs) {
    final ackHashHex = ackHashToHex(ackHash);
    final entry = _pendingRepeaterAcks[ackHashHex];
    if (entry == null) return false;

    entry.timeout?.cancel();
    final effectiveTimeoutMs = timeoutMs > 0
        ? timeoutMs
        : calculateTimeout(
            pathLength: entry.pathLength,
            messageBytes: entry.messageBytes,
          );
    entry.timeout = Timer(Duration(milliseconds: effectiveTimeoutMs), () {
      _recordPathResult(entry.contactKeyHex, entry.selection, false, null);
      _pendingRepeaterAcks.remove(ackHashHex);
    });
    return true;
  }

  bool _handleRepeaterCommandAck(int ackHash, int tripTimeMs) {
    final ackHashHex = ackHashToHex(ackHash);
    final entry = _pendingRepeaterAcks.remove(ackHashHex);
    if (entry == null) return false;
    entry.timeout?.cancel();
    _recordPathResult(entry.contactKeyHex, entry.selection, true, tripTimeMs);
    return true;
  }

  void _applyChannelOrder() {
    if (_channelOrder.isEmpty) {
      _channels.sort((a, b) => a.index.compareTo(b.index));
      return;
    }

    final orderIndex = <int, int>{};
    for (int i = 0; i < _channelOrder.length; i++) {
      orderIndex[_channelOrder[i]] = i;
    }

    _channels.sort((a, b) {
      final aPos = orderIndex[a.index];
      final bPos = orderIndex[b.index];
      if (aPos != null && bPos != null) return aPos.compareTo(bPos);
      if (aPos != null) return -1;
      if (bPos != null) return 1;
      return a.index.compareTo(b.index);
    });
  }

  bool _shouldTrackUnreadForContactKey(String contactKeyHex) {
    final contact = _contacts.cast<Contact?>().firstWhere(
      (c) => c?.publicKeyHex == contactKeyHex,
      orElse: () => null,
    );
    if (contact == null) return true;
    return contact.type != advTypeRepeater;
  }

  Channel? _findChannelByIndex(int index) {
    return _channels.cast<Channel?>().firstWhere(
          (c) => c?.index == index,
          orElse: () => null,
        ) ??
        _cachedChannels.cast<Channel?>().firstWhere(
          (c) => c?.index == index,
          orElse: () => null,
        );
  }

  /// Whether [message] comes from a sender the user blocked: it is kept but
  /// neither notifies nor counts as unread.
  bool _isBlockedChannelSender(ChannelMessage message) =>
      !message.isOutgoing &&
      (_appSettingsService?.isSenderBlocked(message.senderName) ?? false);

  void _maybeIncrementChannelUnread(
    ChannelMessage message, {
    required bool isNew,
  }) {
    if (_isBlockedChannelSender(message)) return;
    if (!isNew || message.isOutgoing) {
      _appDebugLogService?.info(
        'Skip unread increment: isNew=$isNew, isOutgoing=${message.isOutgoing}',
        tag: 'Unread',
      );
      return;
    }
    final channelIndex = message.channelIndex;
    if (channelIndex == null) {
      _appDebugLogService?.info(
        'Skip unread increment: channelIndex is null',
        tag: 'Unread',
      );
      return;
    }
    // Don't increment if user is viewing this channel
    if (_activeChannelIndex == channelIndex) {
      _appDebugLogService?.info(
        'Skip unread increment: channel $channelIndex is active',
        tag: 'Unread',
      );
      return;
    }

    final channel = _findChannelByIndex(channelIndex);
    if (channel != null) {
      channel.unreadCount++;
      _cachedChannelsUnreadTotal++;
      _appDebugLogService?.info(
        'Channel ${channel.name.isNotEmpty ? channel.name : channelIndex} unread count incremented to ${channel.unreadCount}',
        tag: 'Unread',
      );
      unawaited(
        _channelStore.saveChannels(
          _channels.isNotEmpty ? _channels : _cachedChannels,
        ),
      );
    } else {
      _appDebugLogService?.info(
        'Channel $channelIndex not found in _channels (${_channels.length}) or _cachedChannels (${_cachedChannels.length})',
        tag: 'Unread',
      );
    }
  }

  void _maybeIncrementContactUnread(Message message) {
    if (message.isOutgoing || message.isCli) {
      _appDebugLogService?.info(
        'Skip contact unread increment: isOutgoing=${message.isOutgoing}, isCli=${message.isCli}',
        tag: 'Unread',
      );
      return;
    }
    final contactKey = message.senderKeyHex;
    if (!_shouldTrackUnreadForContactKey(contactKey)) {
      _appDebugLogService?.info(
        'Skip contact unread increment: should not track for $contactKey',
        tag: 'Unread',
      );
      return;
    }
    // Don't increment if user is viewing this contact
    if (_activeContactKey == contactKey) {
      _appDebugLogService?.info(
        'Skip contact unread increment: contact $contactKey is active',
        tag: 'Unread',
      );
      return;
    }

    final currentCount = _contactUnreadCount[contactKey] ?? 0;
    _contactUnreadCount[contactKey] = currentCount + 1;
    _cachedContactsUnreadTotal++;
    _appDebugLogService?.info(
      'Contact $contactKey unread count incremented to ${currentCount + 1}',
      tag: 'Unread',
    );
    _unreadStore.saveContactUnreadCount(
      Map<String, int>.from(_contactUnreadCount),
    );
  }

  void _addMessage(String pubKeyHex, Message message) {
    _conversations.putIfAbsent(pubKeyHex, () => []);
    final messages = _conversations[pubKeyHex]!;

    // Parse reaction info
    final reactionInfo = Message.parseReaction(message.text);
    if (reactionInfo != null) {
      // Check if we've already processed this exact reaction
      _processedContactReactions.putIfAbsent(pubKeyHex, () => {});
      reactionInfo.senderName = _resolveContactSenderName(message, null, false);
      final reactionIdentifier = reactionInfo.identifier();
      final isDuplicate = _processedContactReactions[pubKeyHex]!.contains(
        reactionIdentifier,
      );

      if (!isDuplicate) {
        // New reaction - process it
        appLogger.info('Adding reaction, id: $reactionIdentifier');
        // For hashing and dup checking, we use null for sender names in
        // normal 1:1 chats. This way if we and they have different ideas
        // about what their name is, reactions still work. But for reaction
        // reports, we want to know who sent what, rather than infer it later,
        // so we'll add it to the reactionInfo before storing it.
        reactionInfo.senderName ??= message.isOutgoing
            ? selfName
            : getContactByPubKeyHex(pubKeyHex)?.name ?? '???';
        _processContactReaction(messages, reactionInfo, pubKeyHex);
        _messageStore.saveMessages(pubKeyHex, messages);

        // Mark as processed
        _processedContactReactions[pubKeyHex]!.add(reactionIdentifier);

        _notifyFromPart();
      }
      return; // Don't add reaction as a visible message
    }

    messages.add(message);
    if (messages.length > MeshCoreConnector._messageWindowSize) {
      messages.removeRange(
        0,
        messages.length - MeshCoreConnector._messageWindowSize,
      );
    }
    _messageStore.saveMessages(pubKeyHex, messages);
    _notifyFromPart();
  }

  void _processContactReaction(
    List<Message> messages,
    ReactionInfo reactionInfo,
    String contactPubKeyHex,
  ) {
    final contact = getContactByPubKeyHex(contactPubKeyHex);
    final isRoomServer = contact?.type == advTypeRoom;

    ReactionHelper.applyReaction<Message>(
      messages: messages,
      reactionInfo: reactionInfo,
      // Incoming reactions in 1:1: match against outgoing messages only
      shouldSkip: (msg) => isRoomServer != true && !msg.isOutgoing,
      getTimestampSecs: (msg) => msg.timestamp.millisecondsSinceEpoch ~/ 1000,
      getSenderName: (msg) =>
          _resolveContactSenderName(msg, contact, isRoomServer == true),
      getMessageText: (msg) => msg.text,
      getReactions: (msg) => msg.reactions,
      updateMessage: (i, reactions) {
        messages[i] = messages[i].copyWith(reactions: reactions);
      },
    );
  }

  void _processOutgoingContactReaction(
    List<Message> messages,
    ReactionInfo reactionInfo,
    Contact contact,
  ) {
    final isRoomServer = contact.type == advTypeRoom;

    ReactionHelper.applyReaction<Message>(
      messages: messages,
      reactionInfo: reactionInfo,
      // Outgoing reactions in 1:1: match against incoming messages
      shouldSkip: (msg) => !isRoomServer && msg.isOutgoing,
      getTimestampSecs: (msg) => msg.timestamp.millisecondsSinceEpoch ~/ 1000,
      getSenderName: (msg) =>
          _resolveContactSenderName(msg, contact, isRoomServer),
      getMessageText: (msg) => msg.text,
      getReactions: (msg) => msg.reactions,
      updateMessage: (i, reactions) {
        messages[i] = messages[i].copyWith(reactions: reactions);
      },
    );
  }

  String? _resolveContactSenderName(
    Message msg,
    Contact? contact,
    bool isRoomServer,
  ) {
    if (!isRoomServer) return null;
    if (!msg.isOutgoing) {
      // Saved contacts first, then discovery-only nodes, so reaction matching
      // resolves the author's name even when they haven't been saved.
      final senderContact = allContactsUnfiltered.cast<Contact?>().firstWhere(
        (c) =>
            c != null &&
            _matchesPrefix(c.publicKey, msg.fourByteRoomContactKey),
        orElse: () => null,
      );
      return senderContact?.name;
    }
    return selfName;
  }

  /// Firmware-compatible packet hash: SHA256(payloadType + payload) -> first 8 bytes as hex.
  String _computePacketHash(int payloadType, Uint8List payload) {
    final input = Uint8List(1 + payload.length);
    input[0] = payloadType;
    input.setRange(1, input.length, payload);
    final digest = crypto.sha256.convert(input).bytes;
    return digest
        .sublist(0, 8)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  bool _addChannelMessage(int channelIndex, ChannelMessage message) {
    _channelMessages.putIfAbsent(channelIndex, () => []);
    final messages = _channelMessages[channelIndex]!;

    // Parse reaction info
    final reactionInfo = message.parseReaction();
    if (reactionInfo != null) {
      // Check if we've already processed this exact reaction
      _processedChannelReactions.putIfAbsent(channelIndex, () => {});
      final reactionIdentifier = reactionInfo.identifier();

      final isDuplicate = _processedChannelReactions[channelIndex]!.contains(
        reactionIdentifier,
      );

      if (!isDuplicate) {
        // New reaction - process it
        appLogger.info('Adding channel reaction, id: $reactionIdentifier');
        _processReaction(messages, reactionInfo);
        // Save updated messages
        _channelMessageStore.saveChannelMessages(channelIndex, messages);

        // Mark as processed
        _processedChannelReactions[channelIndex]!.add(reactionIdentifier);
      }
      return false; // Don't add reaction as a visible message
    }

    // Parse reply info from message text
    final replyInfo = ChannelMessage.parseReplyMention(message.text);
    ChannelMessage processedMessage = message;

    if (replyInfo != null) {
      // Find original message by sender name (most recent match)
      final originalMessage = _findMessageBySender(
        messages,
        replyInfo.mentionedNode,
      );

      if (originalMessage != null) {
        // Create new message with reply metadata
        processedMessage = ChannelMessage(
          senderKey: message.senderKey,
          senderName: message.senderName,
          text: replyInfo.actualMessage,
          originalText: message.originalText,
          translatedText: message.translatedText,
          translatedLanguageCode: message.translatedLanguageCode,
          translationStatus: message.translationStatus,
          translationModelId: message.translationModelId,
          timestamp: message.timestamp,
          isOutgoing: message.isOutgoing,
          status: message.status,
          repeats: message.repeats,
          repeatCount: message.repeatCount,
          pathLength: message.pathLength,
          pathHashWidth: message.pathHashWidth,
          pathBytes: message.pathBytes,
          pathVariants: message.pathVariants,
          channelIndex: message.channelIndex,
          messageId: message.messageId,
          packetHash: message.packetHash,
          region: message.region,
          replyToMessageId: originalMessage.messageId,
          replyToSenderName: originalMessage.senderName,
          replyToText: originalMessage.text,
          viaMqtt: message.viaMqtt,
        );
      }
    }

    final existingIndex = _findChannelRepeatIndex(messages, processedMessage);
    var isNew = true;
    if (existingIndex >= 0) {
      isNew = false;
      final existing = messages[existingIndex];
      if (existing.viaMqtt && !processedMessage.viaMqtt) {
        // First RF copy of a message only seen via MQTT: the radio has now
        // heard it, so drop the flag and take the radio's own path. This is
        // the first reception over RF, not a repeat.
        messages[existingIndex] = existing.copyWith(
          viaMqtt: false,
          pathLength: processedMessage.pathLength,
          pathHashWidth: processedMessage.pathHashWidth,
          pathBytes: processedMessage.pathBytes,
          pathVariants: processedMessage.pathVariants,
          packetHash: existing.packetHash ?? processedMessage.packetHash,
          region: existing.region ?? processedMessage.region,
        );
        _channelMessageStore.saveChannelMessages(channelIndex, messages);
        return false;
      }
      final mergedPathBytes = _selectPreferredPathBytes(
        existing.pathBytes,
        processedMessage.pathBytes,
      );
      final mergedPathVariants = _mergePathVariants(
        existing.pathVariants,
        processedMessage.pathVariants,
      );
      final mergedPathLength = _mergePathLength(
        existing.pathLength,
        processedMessage.pathLength,
        mergedPathBytes.length,
      );
      final newRepeatCount = existing.repeatCount + 1;
      final promotedFromPending =
          newRepeatCount == 1 &&
          existing.status == ChannelMessageStatus.pending;
      messages[existingIndex] = existing.copyWith(
        repeatCount: newRepeatCount,
        pathLength: mergedPathLength,
        pathHashWidth: existing.pathHashWidth ?? processedMessage.pathHashWidth,
        pathBytes: mergedPathBytes,
        pathVariants: mergedPathVariants,
        packetHash: existing.packetHash ?? processedMessage.packetHash,
        region: existing.region ?? processedMessage.region,
        // Mark as sent when first repeat is heard
        status: promotedFromPending
            ? ChannelMessageStatus.sent
            : existing.status,
      );
      if (promotedFromPending) {
        _pendingChannelSentQueue.remove(existing.messageId);
      }
    } else {
      messages.add(processedMessage);
    }

    // Save to persistent storage
    _channelMessageStore.saveChannelMessages(channelIndex, messages);
    return isNew;
  }

  ChannelMessage? _findMessageBySender(
    List<ChannelMessage> messages,
    String mentionedNode,
  ) {
    // Search backwards for most recent message from this sender
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].senderName == mentionedNode && !messages[i].isOutgoing) {
        return messages[i];
      }
    }
    return null;
  }

  int _findChannelRepeatIndex(
    List<ChannelMessage> messages,
    ChannelMessage incoming,
  ) {
    // First pass: match by packet hash (exact dedup)
    final incomingHash = incoming.packetHash;
    if (incomingHash != null) {
      for (int i = messages.length - 1; i >= 0; i--) {
        final existingHash = messages[i].packetHash;
        if (existingHash != null && existingHash == incomingHash) {
          return i;
        }
      }
    }
    // Second pass: heuristic fallback (outgoing echo, old messages without hash)
    for (int i = messages.length - 1; i >= 0; i--) {
      if (_isChannelRepeat(messages[i], incoming)) {
        return i;
      }
    }
    return -1;
  }

  bool _isChannelRepeat(ChannelMessage existing, ChannelMessage incoming) {
    if (existing.text != incoming.text) return false;

    // Self-echo: an outgoing message coming back via a repeater. The send is
    // delayed by _waitForRadioQuiet (often 10s+) and propagation can add more,
    // so the timestamp gap can easily exceed the cross-peer window.
    final selfName = _selfName ?? 'Me';
    final isSelfEcho =
        existing.isOutgoing &&
        !incoming.isOutgoing &&
        (incoming.senderName == selfName || existing.senderName == selfName);

    final windowMs = isSelfEcho ? 10 * 60 * 1000 : 30000;
    final diffMs =
        (existing.timestamp.millisecondsSinceEpoch -
                incoming.timestamp.millisecondsSinceEpoch)
            .abs();
    if (diffMs > windowMs) return false;

    if (existing.senderName == incoming.senderName) return true;
    if (isSelfEcho) return true;

    return false;
  }

  bool _shouldDropSelfChannelMessage(String senderName, Uint8List pathBytes) {
    final trimmed = senderName.trim();
    if (trimmed.isEmpty) return false;

    final selfName = _selfName?.trim();
    if (selfName == null || selfName.isEmpty) return false;

    // If sender name doesn't match, keep the message
    if (trimmed != selfName) return false;

    // Name matches - this is from self
    // Drop only if pathBytes is empty (direct broadcast)
    // Keep if pathBytes has data (repeated through another node)
    return pathBytes.isEmpty;
  }

  Uint8List _selectPreferredPathBytes(Uint8List existing, Uint8List incoming) {
    if (incoming.isEmpty) return existing;
    if (existing.isEmpty) return incoming;
    if (incoming.length > existing.length) return incoming;
    return existing;
  }

  int? _mergePathLength(int? existing, int? incoming, int observedLength) {
    if (existing == null) {
      if (incoming == null) return observedLength > 0 ? observedLength : null;
      return incoming >= observedLength ? incoming : observedLength;
    }
    if (incoming == null) {
      return existing >= observedLength ? existing : observedLength;
    }
    final merged = existing >= incoming ? existing : incoming;
    return merged >= observedLength ? merged : observedLength;
  }

  List<Uint8List> _mergePathVariants(
    List<Uint8List> existing,
    List<Uint8List> incoming,
  ) {
    if (incoming.isEmpty) return existing;
    if (existing.isEmpty) return incoming;

    final merged = <Uint8List>[...existing];
    for (final candidate in incoming) {
      var already = false;
      for (final current in merged) {
        if (_pathsEqual(current, candidate)) {
          already = true;
          break;
        }
      }
      if (!already && candidate.isNotEmpty) {
        merged.add(candidate);
      }
    }
    return merged;
  }

  bool _pathsEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _applyAdvert(
    Uint8List rawPacket,
    Uint8List payload,
    Uint8List path,
    int pathHashWidth,
    int routeType,
    double snr,
  ) {
    final advert = BufferReader(payload);
    double? latitude;
    double? longitude;
    String name = '';
    String contactKeyHex = '';
    Uint8List publicKey = Uint8List(0);
    int type = 0;
    int timestamp = 0;
    bool hasLocation = false;
    bool hasName = false;
    try {
      publicKey = advert.readBytes(32);
      contactKeyHex = publicKey
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      timestamp = advert.readInt32LE();
      advert.skipBytes(64); // Verified in _handlePayloadAdvertReceived
      final flags = advert.readByte();
      type = flags & 0x0F;
      hasLocation = (flags & 0x10) != 0;
      // For future use:
      //final hasFeature1 = (flags & 0x20) != 0;
      //final hasFeature2 = (flags & 0x40) != 0;
      hasName = (flags & 0x80) != 0;
      if (hasLocation && advert.remaining >= 8) {
        latitude = advert.readInt32LE() / 1e6;
        longitude = advert.readInt32LE() / 1e6;
      }
      // Validate location values if present
      hasLocation = hasValidLocation(latitude, longitude);

      if (hasName && advert.remaining > 0) {
        name = advert.readCString();
      }
    } catch (e) {
      appLogger.warn('Malformed advert frame: $e', tag: 'Connector');
      return;
    }

    //We ignore our own adverts
    if (listEquals(publicKey, _selfPublicKey)) {
      return;
    }

    // Check if this is a new contact
    final isNewContact = !_knownContactKeys.contains(contactKeyHex);

    if (isNewContact) {
      final newContact = Contact(
        rawPacket: rawPacket,
        publicKey: publicKey,
        name: name,
        type: type,
        pathLength: path.isEmpty ? -1 : (path.length ~/ pathHashWidth),
        // Store hop order reversed for easier outgoing messages; keep bytes
        // inside each multi-byte hop in their original order.
        path: _reversePathByHop(path, pathHashWidth),
        latitude: latitude,
        longitude: longitude,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      );
      if ((_autoAddUsers && type == advTypeChat) ||
          (_autoAddRepeaters && type == advTypeRepeater) ||
          (_autoAddRoomServers && type == advTypeRoom) ||
          (_autoAddSensors && type == advTypeSensor)) {
        _handleContactAdvert(newContact);
        _handleDiscovery(
          newContact,
          rawPacket,
          noNotify: true,
          addActive: true,
        );
      } else {
        _handleDiscovery(newContact, rawPacket);
      }
      _updateDirectRepeater(
        newContact,
        snr,
        path,
        pathHashWidth: pathHashWidth,
      );
      return;
    }

    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == contactKeyHex,
    );

    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      final mergedLastMessageAt = existing.lastMessageAt.isAfter(DateTime.now())
          ? DateTime.now()
          : existing.lastMessageAt;

      appLogger.info(
        'Refreshing contact ${existing.name}: devicePath=${existing.pathLength}, existingOverride=${existing.pathOverride}',
        tag: 'Connector',
      );

      // CRITICAL: Preserve user's path override when contact is refreshed from device
      _contacts[existingIndex] = existing.copyWith(
        latitude: hasLocation ? latitude : existing.latitude,
        longitude: hasLocation ? longitude : existing.longitude,
        name: hasName ? name : existing.name,
        path: _reversePathByHop(path, pathHashWidth),
        pathLength: path.isEmpty ? -1 : (path.length ~/ pathHashWidth),
        lastMessageAt: mergedLastMessageAt,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        pathOverride: existing.pathOverride, // Preserve user's path choice
        pathOverrideBytes: existing.pathOverrideBytes,
      );

      // Add path to history if we have a valid path
      if (_pathHistoryService != null &&
          _contacts[existingIndex].pathLength >= 0) {
        _pathHistoryService!.handlePathUpdated(_contacts[existingIndex]);
      }

      _updateDirectRepeater(
        _contacts[existingIndex],
        snr,
        path,
        pathHashWidth: pathHashWidth,
      );

      appLogger.info(
        'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
        tag: 'Connector',
      );
    }
  }

  void _updateDirectRepeater(
    Contact contact,
    double snr,
    Uint8List path, {
    required int pathHashWidth,
  }) {
    final hashWidth = pathHashWidth.clamp(1, 4).toInt();
    if (path.isNotEmpty && path.length < hashWidth) {
      return;
    }
    final pathStartIndex = path.isNotEmpty ? path.length - hashWidth : 0;
    final publicKeyPrefixEnd = math
        .min(hashWidth, contact.publicKey.length)
        .toInt();
    final pubkeyPrefix = path.isNotEmpty
        ? path.sublist(pathStartIndex)
        : contact.publicKey.sublist(0, publicKeyPrefixEnd);
    final contactKeyHex = _resolveDirectRepeaterContactKeyHex(
      contact,
      pubkeyPrefix,
      path.isEmpty,
    );
    final knownRepeaters = contactKeyHex == null
        ? _directRepeaters
              .where(
                (r) =>
                    r.contactKeyHex != null &&
                    _contactKeyMatchesPrefix(r.contactKeyHex!, pubkeyPrefix),
              )
              .toList()
        : const <DirectRepeater>[];
    final knownRepeater = knownRepeaters.length == 1
        ? knownRepeaters.first
        : null;
    final effectiveContactKeyHex =
        contactKeyHex ?? knownRepeater?.contactKeyHex;

    _directRepeaters.removeWhere((r) => r.isStale());

    //We can use adverts from chat and sensor nodes, but only if the advert has a path to get the last hop.
    if ((contact.type == advTypeChat || contact.type == advTypeSensor) &&
        path.isEmpty) {
      _notifyFromPart();
      return;
    }

    final isTracked = _directRepeaters.where((r) {
      if (knownRepeater != null) {
        return identical(r, knownRepeater);
      }
      if (effectiveContactKeyHex != null) {
        return r.contactKeyHex == effectiveContactKeyHex ||
            (r.contactKeyHex == null &&
                _contactKeyMatchesPrefix(
                  effectiveContactKeyHex,
                  r.pubkeyPrefix,
                ));
      }
      if (r.contactKeyHex == null &&
          r.pathHashWidth == hashWidth &&
          r.matchesPrefix(pubkeyPrefix)) {
        return true;
      }
      return false;
    }).toList();

    final sortedRepeaters = List<DirectRepeater>.from(_directRepeaters)
      ..sort((a, b) => b.snr.compareTo(a.snr));
    final weakestRepeater = sortedRepeaters.isNotEmpty
        ? sortedRepeaters.last
        : null;

    if (_directRepeaters.length >= 5 &&
        weakestRepeater != null &&
        isTracked.isEmpty) {
      _directRepeaters.remove(weakestRepeater);
    }

    if (isTracked.isNotEmpty) {
      final repeater = isTracked.first;
      repeater.update(
        snr,
        pubkeyPrefix: pubkeyPrefix,
        pathHashWidth: hashWidth,
        contactKeyHex: effectiveContactKeyHex,
      );
      if (effectiveContactKeyHex != null) {
        _directRepeaters.removeWhere(
          (r) =>
              !identical(r, repeater) &&
              (r.contactKeyHex == effectiveContactKeyHex ||
                  (r.contactKeyHex == null &&
                      _contactKeyMatchesPrefix(
                        effectiveContactKeyHex,
                        r.pubkeyPrefix,
                      ))),
        );
      }
    } else if (_directRepeaters.length < 5) {
      _directRepeaters.add(
        DirectRepeater(
          pubkeyPrefix: pubkeyPrefix,
          pathHashWidth: hashWidth,
          contactKeyHex: effectiveContactKeyHex,
          snr: snr,
        ),
      );
    }
    _notifyFromPart();
  }

  String? _resolveDirectRepeaterContactKeyHex(
    Contact contact,
    List<int> pubkeyPrefix,
    bool pathIsEmpty,
  ) {
    if (pathIsEmpty &&
        (contact.type == advTypeRepeater || contact.type == advTypeRoom)) {
      return contact.publicKeyHex;
    }

    final prefixMatches = allContacts
        .where(
          (c) =>
              (c.type == advTypeRepeater || c.type == advTypeRoom) &&
              _contactKeyMatchesPrefix(c.publicKeyHex, pubkeyPrefix),
        )
        .toList();
    if (prefixMatches.length == 1) {
      return prefixMatches.first.publicKeyHex;
    }

    return null;
  }

  bool _contactKeyMatchesPrefix(String contactKeyHex, List<int> pubkeyPrefix) {
    // Normalize both sides to upper-case hex to avoid case-sensitive mismatches.
    final normalizedPrefixHex = pubkeyPrefix
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
    final normalizedContactKeyHex = contactKeyHex.toUpperCase();
    return normalizedContactKeyHex.startsWith(normalizedPrefixHex);
  }

  void _evictStalestDiscoveredContact() {
    if (_discoveredContacts.isEmpty) return;
    var stalestIndex = 0;
    for (int i = 1; i < _discoveredContacts.length; i++) {
      if (_discoveredContacts[i].lastSeen.isBefore(
        _discoveredContacts[stalestIndex].lastSeen,
      )) {
        stalestIndex = i;
      }
    }
    _discoveredContacts.removeAt(stalestIndex);
  }
}
