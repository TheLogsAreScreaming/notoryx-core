part of 'meshcore_connector.dart';

/// Handlers for frames arriving from the radio. Part of the connector so
/// they share its private state; split out only to keep that file readable.
extension _ConnectorFrameHandlers on MeshCoreConnector {
  void _handleFrame(List<int> data) {
    if (data.isEmpty) return;

    final frame = Uint8List.fromList(data);
    _receivedFramesController.add(frame);
    _bleDebugLogService?.logFrame(frame, outgoing: false);

    final code = frame[0];
    // debugPrint('RX frame: code=$code len=${frame.length}');

    switch (code) {
      case respCodeOk:
        _handleOk();
        break;
      case respCodeDeviceInfo:
        _handleDeviceInfo(frame);
        break;
      case respCodeSelfInfo:
        debugPrint('Got SELF_INFO');
        _handleSelfInfo(frame);
        break;
      case respCodeContactsStart:
        debugPrint('Got CONTACTS_START');
        _contactSyncSeen.clear();
        _isLoadingContacts = true;
        _armContactSyncWatchdog();
        _contactSyncReceived = 0;
        // Firmware v3+ includes total contacts after CONTACTS_START.
        // Incremental sync reports total contacts, not filtered result count.
        if (frame.length >= 5 && !_contactSyncUsesSinceFilter) {
          final reader = BufferReader(frame);
          reader.skipBytes(1);
          _contactSyncTotal = reader.readUInt32LE();
        } else if (!_contactSyncUsesSinceFilter) {
          // Older firmwares may omit the count; use the nRF node capacity as
          // a conservative progress fallback instead of hiding the progress.
          _contactSyncTotal = MeshCoreConnector._defaultMaxContacts;
        } else {
          _contactSyncTotal = null;
        }
        _notifyFromPart();
        break;
      case pushCodeAdvert:
        // Known contact was seen again - just a pub key, no action needed
        break;
      case pushCodeNewAdvert:
        debugPrint('Got New CONTACT');
        // It's the same format as respCodeContact, so we can reuse the handler
        _handleContact(frame, isContact: false);
        break;
      case respCodeContact:
        debugPrint('Got CONTACT');
        _handleContact(frame);
        break;
      case respCodeEndOfContacts:
        debugPrint('Got END_OF_CONTACTS');
        _finishContactSync(stalled: false);
        break;
      case respCodeContactMsgRecv:
      case respCodeContactMsgRecvV3:
        if (_shouldDeferQueuedContactMessage(frame)) {
          _deferredQueuedContactMessageFrames.add(Uint8List.fromList(frame));
          _handleQueuedMessageReceived();
        } else {
          unawaited(_handleIncomingMessage(frame));
        }
        break;
      case respCodeChannelMsgRecv:
      case respCodeChannelMsgRecvV3:
        _handleIncomingChannelMessage(frame);
        break;
      case respCodeChannelDataRecv:
        // RESP_CODE 27 (GRP_DATA received) is delivered through the firmware
        // offline queue in reply to CMD_SYNC_NEXT_MESSAGE, so the queued-message
        // sync state machine MUST be advanced here — exactly like
        // _handleIncomingChannelMessage does. Leaving code 27 unhandled stalls
        // _queueSyncTimeout (5 s) x MeshCoreConnector._maxQueueSyncRetries (3) per chunk and
        // blocks every other queued message behind it. A receivedFrames
        // listener cannot do this: the sync state is private. Advance exactly
        // ONCE, before any async work.
        if (_isSyncingQueuedMessages) {
          _handleQueuedMessageReceived();
        }
        // Post signatures are checked whatever the image setting says.
        final channelData = parseChannelDataFrame(frame);
        if (channelData?.dataType == dataTypeSignedPost) {
          _lastChannelMsgRxTime = DateTime.now();
          unawaited(_handlePostSignature(channelData!));
          break;
        }
        // Advance the sync state machine ALWAYS (above), but only reassemble
        // when the feature is actually on. Without this the "disabled" feature
        // still reassembles, persists and displays received images: the store
        // keeps them and channel_chat_screen renders every stored entry, so a
        // user who never enabled image messages would see them appear.
        if (_appSettingsService?.settings.imageMessagesEnabled ?? false) {
          _handleIncomingChannelData(frame);
        }
        break;
      case respCodeSent:
        _handleMessageSent(frame);
        break;
      case respCodeNoMoreMessages:
        _handleNoMoreMessages();
        break;
      case pushCodeMsgWaiting:
        unawaited(syncQueuedMessages(force: true));
        break;
      case pushCodeSendConfirmed:
        _handleSendConfirmed(frame);
        break;
      case pushCodePathUpdated:
        _handlePathUpdated(frame);
        break;
      case pushCodeControlData:
        // Optional feature-specific services listen to receivedFrames directly.
        break;
      case pushCodeLoginSuccess:
        _handleLoginSuccess(frame);
        break;
      case pushCodeLoginFail:
      case pushCodeStatusResponse:
        break;
      case pushCodeLogRxData:
        _lastRadioRxTime = DateTime.now();
        _handleRxData(frame);
        _handleLogRxData(frame);
        break;
      case respCodeChannelInfo:
        _handleChannelInfo(frame);
        break;
      case respCodeAutoAddConfig:
        _handleAutoAddConfig(frame);
        _checkManualAddContacts();
        break;
      case respCodeBattAndStorage:
        _handleBatteryAndStorage(frame);
        break;
      case respCodeStats:
        _handleStatsFrame(frame);
        break;
      case respCodeCustomVars:
        _handleCustomVars(frame);
        break;
      case respCodeCorridorRegion:
        _handleCorridorRegion(frame);
        break;
      case respCodeProposeCorridor:
        // proposeCorridor() listens to receivedFrames directly.
        break;
      // RESP_CODE_ERR is a defined firmware response (code 1), not an unknown frame.
      case respCodeErr:
        _handleErrorFrame(frame);
        break;
      default:
        debugPrint('Unknown frame code: $code');
    }
  }

  void _handleCorridorRegion(Uint8List frame) {
    final region = parseCorridorRegionFrame(frame);
    if (region == null) return;
    _floodCorridorProbePending = false;
    _floodCorridorSupported = true;
    _corridorRegion = region;
    _notifyFromPart();
  }

  void _handleErrorFrame(Uint8List frame) {
    final errCode = frame.length > 1 ? frame[1] : -1;

    // The probe is only sent with no generic ACK pending, and the firmware
    // answers in order, so an UNSUPPORTED_CMD while it is outstanding is the
    // probe's reply and must not fail an unrelated queued command.
    if (_floodCorridorProbePending && errCode == errCodeUnsupportedCmd) {
      _floodCorridorProbePending = false;
      _floodCorridorSupported = false;
      _notifyFromPart();
      return;
    }
    _appDebugLogService?.warn(
      'Firmware responded with error code: $errCode',
      tag: 'Protocol',
    );

    if (_pendingGenericAckQueue.isEmpty) {
      return;
    }

    final failedAck = _pendingGenericAckQueue.removeAt(0);
    failedAck.completer?.completeError(
      Exception('Firmware rejected command with error code $errCode'),
    );
    if (!_isChannelTextCommand(failedAck.commandCode) ||
        failedAck.channelSendQueueId == null) {
      return;
    }
    _pendingChannelSentQueue.remove(failedAck.channelSendQueueId);
    _markPendingChannelMessageFailedById(failedAck.channelSendQueueId!);
  }

  void _handlePathUpdated(Uint8List frame) {
    // Frame format: [0]=code, [1-32]=pub_key
    if (frame.length >= 33 && _pathHistoryService != null) {
      final pubKey = Uint8List.fromList(frame.sublist(1, 33));
      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c != null && listEquals(c.publicKey, pubKey),
        orElse: () => null,
      );

      if (contact != null) {
        _pathHistoryService!.handlePathUpdated(contact);
        // Refresh just this specific contact instead of all contacts.
        // This avoids race conditions with _preserveContactsOnRefresh flag
        // that can occur when using refreshContactsSinceLastmod().
        getContactByKey(pubKey);
      }
    }
  }

  void _handleSelfInfo(Uint8List frame) {
    // SELF_INFO format:
    // [0] = RESP_CODE_SELF_INFO
    // [1] = ADV_TYPE
    // [2] = tx_power_dbm
    // [3] = MAX_LORA_TX_POWER
    // [4-35] = pub_key (32 bytes)
    // [36-39] = lat (int32 LE)
    // [40-43] = lon (int32 LE)
    // [44] = multi_acks
    // [45] = advert_loc_policy
    // [46] = telemetry modes
    // [47] = manual_add_contacts
    // [48-51] = freq (uint32 LE, in Hz)
    // [52-55] = bw (uint32 LE, in Hz)
    // [56] = sf
    // [57] = cr
    // [58+] = node_name
    final wasAwaitingSelfInfo = _awaitingSelfInfo;
    final reader = BufferReader(frame);
    try {
      reader.skipBytes(2);
      _currentTxPower = reader.readInt8();
      _maxTxPower = reader.readInt8();
      _selfPublicKey = reader.readBytes(pubKeySize);
      _selfLatitude = reader.readInt32LE() / 1000000.0;
      _selfLongitude = reader.readInt32LE() / 1000000.0;
      _multiAcks = reader.readByte();
      _advertLocPolicy = reader.readByte();
      final telemetryFlag = reader.readByte();
      _telemetryModeBase = telemetryFlag & 0x03;
      _telemetryModeLoc = telemetryFlag >> 2 & 0x03;
      _telemetryModeEnv = telemetryFlag >> 4 & 0x03;

      _manualAddContacts = reader.readByte() & 0x01 == 0x00;

      _currentFreqHz = reader.readUInt32LE();
      _currentBwHz = reader.readUInt32LE();
      _currentSf = reader.readByte();
      _currentCr = reader.readByte();

      _selfName = reader.readCString();

      // The local public key only exists once SELF_INFO has arrived, so the
      // image sender prefix (first 2 bytes, big-endian) is refreshed here.
      final prefix = senderPrefixFromKey(_selfPublicKey);
      if (prefix != null) {
        _imageTransport?.senderPrefix = prefix;
        _onImageSenderPrefix?.call(prefix);
      }
    } catch (e) {
      _appDebugLogService?.error(
        'Error parsing SELF_INFO frame: $e',
        tag: 'Connector',
      );
    }

    const locationChangeEpsilon = 2.25e-4; // ~25 meters in degrees.
    final lastAdvertLatitude = _lastZeroHopAdvertLatitude;
    final lastAdvertLongitude = _lastZeroHopAdvertLongitude;
    final currentLatitude = _selfLatitude;
    final currentLongitude = _selfLongitude;
    final latChanged =
        lastAdvertLatitude != null &&
        currentLatitude != null &&
        (currentLatitude - lastAdvertLatitude).abs() >= locationChangeEpsilon;
    final lonChanged =
        lastAdvertLongitude != null &&
        currentLongitude != null &&
        (currentLongitude - lastAdvertLongitude).abs() >= locationChangeEpsilon;
    final gpsSampleChanged =
        hasValidLocation(currentLatitude, currentLongitude) &&
        (!hasValidLocation(lastAdvertLatitude, lastAdvertLongitude) ||
            latChanged ||
            lonChanged);
    final effectiveGpsIntervalSeconds =
        _appSettingsService?.resolvedGpsIntervalSeconds(_currentCustomVars) ??
        0;
    final timeSinceLastZeroHopAdvert = DateTime.now().difference(
      _lastZeroHopAdvertAt,
    );
    final shouldAutoSendZeroHopAdvert =
        (gpsSampleChanged || (_clientRepeat ?? false)) &&
        _advertLocPolicy == 1 &&
        (_appSettingsService?.settings.autoSendZeroHopAdvertOnGpsUpdate ??
            false) &&
        effectiveGpsIntervalSeconds > 0 &&
        timeSinceLastZeroHopAdvert.inSeconds >= effectiveGpsIntervalSeconds;
    if (shouldAutoSendZeroHopAdvert) {
      unawaited(sendSelfAdvert(flood: false));
    }

    final selfName = _selfName?.trim();
    if (_activeTransport == MeshCoreTransportType.usb &&
        selfName != null &&
        selfName.isNotEmpty) {
      _usbManager.updateConnectedLabel(selfName);
    }

    // GPS poll responses arrive as RESP_CODE_SELF_INFO but are not the real
    // handshake — only update location and notify, skip store reloads and
    // contact sync which would clear and re-fetch contacts every minute.
    if (!wasAwaitingSelfInfo) {
      _notifyFromPart();
      return;
    }

    //set all the stores' public key so they can load the correct data
    _channelMessageStore.setPublicKeyHex = selfPublicKeyHex;
    _messageStore.setPublicKeyHex = selfPublicKeyHex;
    _channelOrderStore.setPublicKeyHex = selfPublicKeyHex;
    _channelSettingsStore.setPublicKeyHex = selfPublicKeyHex;
    _channelRegionStore.setPublicKeyHex = selfPublicKeyHex;
    _contactSettingsStore.setPublicKeyHex = selfPublicKeyHex;
    _contactStore.setPublicKeyHex = selfPublicKeyHex;
    _channelStore.setPublicKeyHex = selfPublicKeyHex;
    _unreadStore.setPublicKeyHex = selfPublicKeyHex;

    // Now that we have self info, we can load all the persisted data for this node
    _loadChannelOrder();
    loadContactCache();
    loadChannelSettings();
    loadCachedChannels();

    // Load persisted channel messages
    loadAllChannelMessages();
    loadUnreadState();
    _loadDiscoveredContactCache();

    _awaitingSelfInfo = false;
    _selfInfoRetryTimer?.cancel();
    _selfInfoRetryTimer = null;
    _notifyFromPart();

    unawaited(_probeFloodCorridorSupport());

    // Start the serialized initial sync pipeline after SELF_INFO.
    _maybeStartInitialChannelSync();
  }

  void _handleDeviceInfo(Uint8List frame) {
    if (frame.length < 4) return;
    if (_shouldGateInitialChannelSync) {
      _hasReceivedDeviceInfo = true;
    }
    _firmwareVerCode = frame[1];

    // Manufacturer/model name (bytes 20..59) and firmware version (60..79)
    String? readCString(int start, int maxLen) {
      if (frame.length < start + maxLen) return null;
      final bytes = frame.sublist(start, start + maxLen);
      final end = bytes.indexOf(0);
      final s = String.fromCharCodes(
        end >= 0 ? bytes.sublist(0, end) : bytes,
      ).trim();
      return s.isEmpty ? null : s;
    }

    _manufacturerName = readCString(20, 40);
    _firmwareVersionString = readCString(60, 20);

    // Parse client_repeat from firmware v9+ (byte 80)
    if (frame.length >= 81) {
      _clientRepeat = frame[80] != 0;
    }
    // Path hash mode v10+ (byte 81): width = mode + 1 byte(s) per hop
    final previousPathHashByteWidth = _pathHashByteWidth;
    if (frame.length >= 82) {
      final mode = (frame[81] & 0xFF).clamp(0, 3);
      _pathHashByteWidth = mode + 1;
    } else {
      _pathHashByteWidth = 1;
    }
    if (_pathHashByteWidth != previousPathHashByteWidth) {
      _directRepeaters.clear();
    }

    // Firmware reports MAX_CONTACTS / 2 for v3+ device info.
    final reportedContacts = frame[2];
    final reportedChannels = frame[3];
    final nextMaxContacts = reportedContacts > 0
        ? reportedContacts * 2
        : _maxContacts;
    if (reportedContacts > 0) _maxContactsReported = true;
    final nextMaxChannels = reportedChannels > 0
        ? reportedChannels
        : _maxChannels;
    final previousMaxChannels = _maxChannels;
    if (nextMaxContacts != _maxContacts || nextMaxChannels != _maxChannels) {
      _maxContacts = nextMaxContacts;
      _maxChannels = nextMaxChannels;
      if (nextMaxChannels > previousMaxChannels) {
        unawaited(loadChannelSettings(maxChannels: nextMaxChannels));
        unawaited(loadAllChannelMessages(maxChannels: nextMaxChannels));
        if (isConnected &&
            _selfPublicKey != null &&
            !_pendingInitialChannelSync) {
          unawaited(getChannels(maxChannels: nextMaxChannels));
        }
      }
    }
    _notifyFromPart();
    if (_shouldGateInitialChannelSync) {
      _maybeStartInitialChannelSync();
    }
  }

  void _handleNoMoreMessages() {
    debugPrint('[QueueSync] No more messages, sync complete');
    _queueSyncTimeout?.cancel();
    _isSyncingQueuedMessages = false;
    _queuedMessageSyncInFlight = false;
    _queueSyncRetries = 0; // Reset retry counter on successful completion
    _notifyFromPart();
    _continueAfterQueuedMessageSync();
  }

  void _handleQueuedMessageReceived() {
    if (!_isSyncingQueuedMessages) return;
    debugPrint('[QueueSync] Message received, requesting next');
    _queueSyncTimeout?.cancel(); // Cancel timeout - message arrived
    _queuedMessageSyncInFlight = false;
    _queueSyncRetries = 0; // Reset retry counter on successful message
    _notifyFromPart();
    unawaited(_requestNextQueuedMessage());
  }

  void _handleStatsFrame(Uint8List frame) {
    final stats = CompanionRadioStats.tryParse(frame);
    if (stats == null) return;
    final total = stats.txAirSecs + stats.rxAirSecs;
    if (total > _prevTotalAirSecs) {
      (_airtimeBumpStopwatch ??= Stopwatch()).reset();
      _airtimeBumpStopwatch!.start();
    }
    _prevTotalAirSecs = total;
    _airtimeSamples.add(AirtimeSample(stats.receivedAt, total));
    _airtimeSamples.removeWhere(
      (s) => stats.receivedAt.difference(s.at) > const Duration(minutes: 30),
    );
    if (_airtimeSamples.length > 240) _airtimeSamples.removeAt(0);
    _latestRadioStats = stats;
    radioStatsNotifier.value = stats;
  }

  void _handleBatteryAndStorage(Uint8List frame) {
    // Frame format from C++:
    // [0] = RESP_CODE_BATT_AND_STORAGE
    // [1-2] = battery_mv (uint16 LE)
    // [3-6] = storage_used_kb (uint32 LE)
    // [7-10] = storage_total_kb (uint32 LE)
    try {
      final reader = BufferReader(frame);
      reader.skipBytes(1);
      _batteryMillivolts = reader.readUInt16LE();
      _storageUsedKb = reader.readUInt32LE();
      _storageTotalKb = reader.readUInt32LE();
      final volts = (_batteryMillivolts! / 1000.0).toStringAsFixed(2);
      _appDebugLogService?.info(
        'Pulled battery: $volts V ($_batteryMillivolts mV)',
        tag: 'Battery',
      );
      _notifyFromPart();
    } catch (e) {
      _appDebugLogService?.error(
        'Error parsing battery and storage frame: $e',
        tag: 'Connector',
      );
    }
  }

  void _handleContact(Uint8List frame, {bool isContact = true}) {
    final contactTmp = Contact.fromFrame(frame);
    if (contactTmp != null) {
      if (isContact && _isLoadingContacts) {
        _contactSyncReceived++;
        _contactSyncSeen.add(contactTmp.publicKeyHex);
        _armContactSyncWatchdog();
      }
      if (listEquals(contactTmp.publicKey, _selfPublicKey)) {
        appLogger.info(
          'Ignoring contact with self public key: ${contactTmp.name}',
          tag: 'Connector',
        );
        _notifyFromPart();
        unawaited(
          removeContact(contactTmp).catchError(
            (e) => appLogger.warn(
              'Failed to remove self contact: $e',
              tag: 'Connector',
            ),
          ),
        );
        return;
      }
      final contact = getFromDiscovered(contactTmp);
      _handleDiscovery(contact, frame, noNotify: true, addActive: true);

      if (contact.type == advTypeRepeater) {
        final removedCount = _contactUnreadCount[contact.publicKeyHex] ?? 0;
        _cachedContactsUnreadTotal = (_cachedContactsUnreadTotal - removedCount)
            .clamp(0, _cachedContactsUnreadTotal);
        _contactUnreadCount.remove(contact.publicKeyHex);
        _unreadStore.saveContactUnreadCount(
          Map<String, int>.from(_contactUnreadCount),
        );
      }
      // Check if this is a new contact
      final isNewContact = !_knownContactKeys.contains(contact.publicKeyHex);
      final existingIndex = _contacts.indexWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );

      if (existingIndex >= 0) {
        final existing = _contacts[existingIndex];
        final mergedLastMessageAt =
            existing.lastMessageAt.isAfter(contact.lastMessageAt)
            ? existing.lastMessageAt
            : contact.lastMessageAt;

        appLogger.info(
          'Refreshing contact ${contact.name}: devicePath=${contact.pathLength}, existingOverride=${existing.pathOverride}',
          tag: 'Connector',
        );

        // Preserve user-selected path settings and previously known GPS when
        // refreshed frames omit coordinates (lat/lon encoded as 0,0).
        _contacts[existingIndex] = contact.copyWith(
          lastMessageAt: mergedLastMessageAt,
          pathOverride: existing.pathOverride, // Preserve user's path choice
          pathOverrideBytes: existing.pathOverrideBytes,
          latitude: contact.latitude ?? existing.latitude,
          longitude: contact.longitude ?? existing.longitude,
        );

        appLogger.info(
          'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
          tag: 'Connector',
        );
      } else {
        if ((_autoAddUsers && contact.type == advTypeChat) ||
            (_autoAddRepeaters && contact.type == advTypeRepeater) ||
            (_autoAddRoomServers && contact.type == advTypeRoom) ||
            (_autoAddSensors && contact.type == advTypeSensor) ||
            isContact) {
          // A contact from the radio's own list is truth; one the radio
          // auto-added from an advert must fit its table, as it does there.
          if (!isContact && !_admitAutoAddedContact(contact)) {
            _notifyFromPart();
            return;
          }
          _contacts.add(contact);
          appLogger.info(
            'Added new contact ${contact.name}: pathLen=${contact.pathLength}',
            tag: 'Connector',
          );
        } else {
          appLogger.info(
            "Discovered contact ${contact.name} (type ${contact.typeLabelRaw}) not added due to auto-add settings",
            tag: 'Connector',
          );
          _notifyFromPart();
          return;
        }
      }
      _knownContactKeys.add(contact.publicKeyHex);
      _loadMessagesForContact(contact.publicKeyHex);

      // Add path to history if we have a valid path
      if (_pathHistoryService != null && contact.pathLength >= 0) {
        _pathHistoryService!.handlePathUpdated(contact);
      }

      _notifyFromPart();

      // Show notification for new contact (advertisement)
      if (isNewContact && _appSettingsService != null) {
        final settings = _appSettingsService!.settings;
        if (settings.notificationsEnabled && settings.notifyOnNewAdvert) {
          _notificationService.showAdvertNotification(
            radio: slot,
            contactName: contact.name,
            contactType: contact.typeLabelRaw,
            contactId: contact.publicKeyHex,
          );
        }
      }

      if (!_isLoadingContacts) {
        unawaited(_persistContacts());
      }
    }
  }

  void _handleContactAdvert(Contact contact) {
    if (listEquals(contact.publicKey, _selfPublicKey)) {
      return;
    }

    if (contact.type == advTypeRepeater) {
      final removedCount = _contactUnreadCount[contact.publicKeyHex] ?? 0;
      _cachedContactsUnreadTotal = (_cachedContactsUnreadTotal - removedCount)
          .clamp(0, _cachedContactsUnreadTotal);
      _contactUnreadCount.remove(contact.publicKeyHex);
      _unreadStore.saveContactUnreadCount(
        Map<String, int>.from(_contactUnreadCount),
      );
    }
    // Check if this is a new contact
    final isNewContact = !_knownContactKeys.contains(contact.publicKeyHex);
    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );

    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      final mergedLastMessageAt =
          existing.lastMessageAt.isAfter(contact.lastMessageAt)
          ? existing.lastMessageAt
          : contact.lastMessageAt;

      appLogger.info(
        'Refreshing contact ${contact.name}: devicePath=${contact.pathLength}, existingOverride=${existing.pathOverride}',
        tag: 'Connector',
      );

      // CRITICAL: Preserve user's path override when contact is refreshed from device
      _contacts[existingIndex] = contact.copyWith(
        lastMessageAt: mergedLastMessageAt,
        pathOverride: existing.pathOverride, // Preserve user's path choice
        pathOverrideBytes: existing.pathOverrideBytes,
      );

      appLogger.info(
        'After merge: pathOverride=${_contacts[existingIndex].pathOverride}, devicePath=${_contacts[existingIndex].pathLength}',
        tag: 'Connector',
      );
    } else {
      if (!_admitAutoAddedContact(contact)) {
        _notifyFromPart();
        return;
      }
      _contacts.add(contact);
      appLogger.info(
        'Added new contact ${contact.name}: pathLen=${contact.pathLength}',
        tag: 'Connector',
      );
    }
    _knownContactKeys.add(contact.publicKeyHex);
    _loadMessagesForContact(contact.publicKeyHex);

    // Add path to history if we have a valid path
    if (_pathHistoryService != null && contact.pathLength >= 0) {
      _pathHistoryService!.handlePathUpdated(contact);
    }

    _notifyFromPart();

    // Show notification for new contact (advertisement)
    if (isNewContact && _appSettingsService != null) {
      final settings = _appSettingsService!.settings;
      if (settings.notificationsEnabled && settings.notifyOnNewAdvert) {
        _notificationService.showAdvertNotification(
          radio: slot,
          contactName: contact.name,
          contactType: contact.typeLabelRaw,
          contactId: contact.publicKeyHex,
        );
      }
    }

    if (!_isLoadingContacts) {
      unawaited(_persistContacts());
    }
  }

  Future<void> _handleIncomingMessage(Uint8List frame) async {
    if (_selfPublicKey == null) return;
    final fromBacklog =
        _pendingInitialQueuedMessageSync ||
        _pendingInitialContactsSync ||
        _deferQueuedContactMessagesUntilContacts ||
        _isProcessingDeferredQueuedContactMessages;

    // If we're syncing the queued messages, advance the queue immediately
    // before any potentially long async work (like translation/notifications).
    if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }

    var message = _parseContactMessage(frame);

    // If message parsing failed due to unknown contact, refresh contacts and retry
    if (message == null && !_isLoadingContacts) {
      final senderPrefix = _extractSenderPrefix(frame);
      if (senderPrefix != null) {
        final hasContact = _contacts.any(
          (c) => _matchesPrefix(c.publicKey, senderPrefix),
        );
        if (!hasContact) {
          debugPrint(
            'Received message from unknown contact, refreshing contacts...',
          );
          await refreshContactsSinceLastmod();
          // Retry parsing after refresh
          message = _parseContactMessage(frame);
          if (message != null) {
            debugPrint('Successfully parsed message after contact refresh');
          }
        }
      }
    }

    if (message != null) {
      if (!message.isOutgoing) {
        _lastContactMsgRxTime = DateTime.now();
      }
      // Ignore messages from self (device hearing its own broadcast)
      // BUT allow repeated messages (pathLength indicates it went through repeater)
      if (_selfPublicKey != null &&
          message.senderKeyHex == pubKeyToHex(_selfPublicKey!) &&
          (message.pathLength == null || message.pathLength == 0)) {
        debugPrint('Ignoring direct message from self');
        return;
      }

      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c?.publicKeyHex == message!.senderKeyHex,
        orElse: () => null,
      );
      if (contact != null) {
        message = message.copyWith(
          pathLength: contact.pathLength < 0 ? -1 : contact.pathLength,
          pathBytes: contact.pathLength < 0 ? Uint8List(0) : contact.path,
        );
      }
      if (contact != null) {
        _updateContactLastMessageAt(contact.publicKeyHex, message.timestamp);
      }
      if (!message.isOutgoing) {
        final existing = _conversations[message.senderKeyHex];
        final incomingTimestamp = message.timestamp.millisecondsSinceEpoch;
        if (existing != null && existing.isNotEmpty) {
          final last = existing.last;
          if (!last.isOutgoing &&
              last.timestamp.millisecondsSinceEpoch == incomingTimestamp &&
              last.text == message.text) {
            return;
          }
        }
      }
      _addMessage(message.senderKeyHex, message);
      _maybeIncrementContactUnread(message);
      _notifyFromPart();
      if (!fromBacklog &&
          !message.isOutgoing &&
          !message.isCli &&
          !_receivedDirectMessagesController.isClosed) {
        _receivedDirectMessagesController.add(message);
      }

      // Show notification for new incoming message (run async with translation)
      if (!message.isOutgoing &&
          !message.isCli &&
          _appSettingsService != null) {
        final settings = _appSettingsService!.settings;
        if (settings.notificationsEnabled && settings.notifyOnNewMessage) {
          final msg = message; // capture for closure
          final c = contact; // capture contact reference
          unawaited(() async {
            final translationResult = await translateContactMessage(
              msg.senderKeyHex,
              msg,
            );
            if (c?.type == advTypeChat) {
              final resolvedText =
                  (translationResult != null &&
                      translationResult.status ==
                          MessageTranslationStatus.completed &&
                      translationResult.translatedText.trim().isNotEmpty)
                  ? translationResult.translatedText.trim()
                  : msg.text.trim();
              await _notificationService.showMessageNotification(
                radio: slot,
                contactName: notificationTitle(c?.name ?? 'Unknown'),
                message: resolvedText,
                urlImagesEnabled:
                    c != null && isContactUrlImagesEnabled(c.publicKeyHex),
                contactId: msg.senderKeyHex,
                badgeCount: getTotalUnreadCount(),
                dedupeKey: NotificationDeduper.directKey(
                  radio: slot,
                  senderKeyHex: msg.senderKeyHex,
                  sentAt: msg.timestamp,
                  text: msg.text,
                ),
              );
            } else if (c?.type == advTypeRoom) {
              final resolvedText =
                  (translationResult != null &&
                      translationResult.status ==
                          MessageTranslationStatus.completed &&
                      translationResult.translatedText.trim().isNotEmpty)
                  ? translationResult.translatedText.trim()
                  : msg.text.trim();
              await _notificationService.showMessageNotification(
                radio: slot,
                contactName: notificationTitle(c?.name ?? 'Unknown Room'),
                message: resolvedText,
                urlImagesEnabled:
                    c != null && isContactUrlImagesEnabled(c.publicKeyHex),
                contactId: msg.senderKeyHex,
                badgeCount: getTotalUnreadCount(),
                dedupeKey: NotificationDeduper.directKey(
                  radio: slot,
                  senderKeyHex: msg.senderKeyHex,
                  sentAt: msg.timestamp,
                  text: msg.text,
                ),
              );
            }
          }());
        }
      }
      _handleQueuedMessageReceived();
    } else if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }
  }

  /// Handles RESP_CODE_CHANNEL_DATA_RECV (GRP_DATA). Frames whose dataType is
  /// not 0xAE1C — or that arrive before an [ImageChunkTransport] is installed —
  /// are ignored without disturbing any other behaviour.
  void _handleIncomingChannelData(Uint8List frame) {
    // Anchor the post-RX backoff for our own next channel send, exactly as
    // _handleIncomingChannelMessage does.
    _lastChannelMsgRxTime = DateTime.now();
    final outcome = _imageTransport?.handleFrame(frame);
    if (outcome == null) return; // Not an AEIC image chunk.
    _onImageChunk?.call(outcome);
    _notifyFromPart();
  }

  void _handleIncomingChannelMessage(Uint8List frame) async {
    // If we're syncing the queued messages, advance the queue immediately
    // before any potentially long async work (like translation/notifications).
    if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }
    final parsed = ChannelMessage.fromFrame(frame);
    if (parsed != null && parsed.channelIndex != null) {
      if (_shouldDropSelfChannelMessage(parsed.senderName, parsed.pathBytes)) {
        return;
      }
      _lastChannelMsgRxTime = DateTime.now();
      final contentHash = _computeContentHash(
        parsed.channelIndex!,
        parsed.timestamp.millisecondsSinceEpoch ~/ 1000,
        '${parsed.senderName}: ${parsed.text}',
      );
      final message = parsed.copyWith(packetHash: contentHash);
      _updateContactLastMessageAtByName(
        message.senderName,
        message.timestamp,
        pathBytes: message.pathBytes,
        pathHashWidth: message.pathHashWidth,
      );
      final isNew = _addChannelMessage(message.channelIndex!, message);
      _maybeIncrementChannelUnread(message, isNew: isNew);
      _notifyFromPart();
      if (isNew && !message.isOutgoing) {
        unawaited(_claimHeldSignature(message));
        if (!_radioChannelMessagesController.isClosed) {
          _radioChannelMessagesController.add(message);
        }
      }
      if (isNew && !message.isOutgoing) {
        final msg = message; // capture for closure
        unawaited(() async {
          final translationResult = await translateChannelMessage(
            msg.channelIndex!,
            msg,
          );
          _maybeNotifyChannelMessage(msg, translationResult: translationResult);
        }());
      }
      _handleQueuedMessageReceived();
    } else if (_isSyncingQueuedMessages) {
      _handleQueuedMessageReceived();
    }
  }

  /// Matches a signature packet to its text, or holds it until the text
  /// arrives. The text it signs is the newest unsigned incoming post on
  /// that channel with the same timestamp that it verifies against.
  Future<void> _handlePostSignature(ParsedChannelData data) async {
    final payload = SignedPostPayload.decode(data.payload);
    if (payload == null) return;
    final channel = data.channelIndex;
    final candidates = [
      for (final m in (_channelMessages[channel] ?? const <ChannelMessage>[]))
        if (!m.isOutgoing &&
            m.timestamp.millisecondsSinceEpoch ~/ 1000 == payload.timestamp)
          m,
    ];
    if (candidates.isEmpty) {
      _heldSignatures.add(channel, payload, DateTime.now());
      return;
    }
    // A repeat of a signature already applied changes nothing.
    if (candidates.any(
      (m) =>
          m.signature != ChannelSignature.none &&
          listEquals(m.signerKey, payload.publicKey),
    )) {
      return;
    }
    for (final m in candidates.reversed) {
      if (m.signature != ChannelSignature.none) continue;
      if (await verifySignedPost(
        payload,
        senderName: m.senderName,
        text: m.text,
      )) {
        _updateChannelMessage(
          channel,
          m.messageId,
          (m) => m.copyWith(
            signature: ChannelSignature.valid,
            signerKey: payload.publicKey,
          ),
        );
        return;
      }
    }
    // It names a post we have but signs something else: the post was
    // changed on the way, or it isn't the sender's.
    final unsigned = candidates.where(
      (m) => m.signature == ChannelSignature.none,
    );
    if (unsigned.length == 1) {
      _updateChannelMessage(
        channel,
        unsigned.single.messageId,
        (m) => m.copyWith(
          signature: ChannelSignature.invalid,
          signerKey: payload.publicKey,
        ),
      );
    }
  }

  void _handleLogRxData(Uint8List frame) {
    if (frame.length < 4) return;
    final reader = BufferReader(frame);
    reader.skipBytes(3); // Skip code, SNR x4, RSSI
    final raw = reader.readRemainingBytes();
    final signal = frame.buffer.asByteData(frame.offsetInBytes);
    _lastRxSnr = signal.getInt8(1) / 4;
    _lastRxRssi = signal.getInt8(2);
    _lastRxSignalAt = DateTime.now();
    markNotifyDirty();
    _handleRawRxPacket(raw);
    if (!_rxPacketsController.hasListener) return;
    final packet = _parseRawPacket(raw);
    if (packet == null) return;
    _rxPacketsController.add(
      RadioRxPacket(
        raw: Uint8List.fromList(raw),
        snr: _lastRxSnr!,
        rssi: _lastRxRssi!,
        receivedAt: DateTime.now(),
        fromSelf: _isOwnRxPacket(packet),
      ),
    );
  }

  void _handleMessageSent(Uint8List frame) {
    // Frame format from C++:
    // [0] = RESP_CODE_SENT
    // [1] = is_flood (1 or 0)
    // [2-5] = expected_ack_hash (uint32)
    // [6-9] = estimated_timeout_ms (uint32)

    try {
      final reader = BufferReader(frame);
      reader.skipBytes(2); //Skip code and is_flood
      final ackHash = reader.readUInt32LE();
      final timeoutMs = reader.readUInt32LE();

      // Check if this is a CLI command ACK - if so, ignore it
      if (_lastSentWasCliCommand) {
        final ackHashHex = ackHashToHex(ackHash);
        debugPrint('Ignoring CLI command ACK (sent): $ackHashHex');
        _lastSentWasCliCommand = false;
        return;
      }

      if (_handleRepeaterCommandSent(ackHash, timeoutMs)) {
        return;
      }

      final retryService = _retryService;
      if (retryService != null &&
          retryService.updateMessageFromSent(ackHash, timeoutMs)) {
        return;
      }

      if (_markNextPendingChannelMessageSent()) {
        return;
      }
    } catch (e) {
      appLogger.warn('Error handling message sent frame: $e');
      // Fallback to old behavior
      for (var messages in _conversations.values) {
        for (int i = messages.length - 1; i >= 0; i--) {
          if (messages[i].isOutgoing &&
              messages[i].status == MessageStatus.pending) {
            messages[i] = messages[i].copyWith(status: MessageStatus.sent);
            _notifyFromPart();
            return;
          }
        }
      }
    }
  }

  void _handleSendConfirmed(Uint8List frame) {
    // Frame format from C++:
    // [0] = PUSH_CODE_SEND_CONFIRMED
    // [1-4] = ack_hash (uint32)
    // [5-8] = trip_time_ms (uint32)

    try {
      final reader = BufferReader(frame);
      reader.skipBytes(1); // Skip code
      final ackHash = reader.readUInt32LE();
      final tripTimeMs = reader.readUInt32LE();

      // CLI command ACKs are already filtered in _handleMessageSent, so this should only see real messages

      if (_handleRepeaterCommandAck(ackHash, tripTimeMs)) {
        return;
      }

      // Handle ACK in retry service
      if (_retryService != null) {
        _retryService!.handleAckReceived(ackHash, tripTimeMs);
      }
    } catch (e) {
      appLogger.warn('Error handling send confirmed frame: $e');
      // Fallback to old behavior
      for (var messages in _conversations.values) {
        for (int i = messages.length - 1; i >= 0; i--) {
          if (messages[i].isOutgoing &&
              messages[i].status == MessageStatus.sent) {
            messages[i] = messages[i].copyWith(status: MessageStatus.delivered);
            _notifyFromPart();
            return;
          }
        }
      }
    }
  }

  void _handleChannelInfo(Uint8List frame) {
    final channel = Channel.fromFrame(frame);
    if (channel == null) return;

    debugPrint(
      '[ChannelSync] Received channel ${channel.index}: ${channel.isEmpty ? "empty" : channel.name}',
    );

    // Preserve unread count from cached channel
    final cachedChannel = _cachedChannels.cast<Channel?>().firstWhere(
      (c) => c?.index == channel.index,
      orElse: () => null,
    );
    if (cachedChannel != null) {
      channel.unreadCount = cachedChannel.unreadCount;
    }

    // If we're syncing and this is the channel we're waiting for
    if (_isSyncingChannels && _channelSyncInFlight) {
      if (channel.index == _nextChannelIndexToRequest) {
        // Expected channel arrived
        _channelSyncTimeout?.cancel();
        _channelSyncInFlight = false;
        _channelSyncRetries = 0; // Reset retry counter on success

        // Only add non-empty channels
        if (!channel.isEmpty) {
          _channels.add(channel);
        }

        // Move to next channel
        _nextChannelIndexToRequest++;
        _notifyFromPart();
        unawaited(_requestNextChannel());
        return;
      } else {
        // Received a channel but not the one we're waiting for
        // This can happen if device sends unsolicited updates
        debugPrint(
          '[ChannelSync] Received unexpected channel ${channel.index}, expected $_nextChannelIndexToRequest',
        );
        // Add it anyway but don't advance sync
        if (!channel.isEmpty &&
            !_channels.any((c) => c.index == channel.index)) {
          _channels.add(channel);
        }
        return;
      }
    }

    // Not syncing, or received unsolicited update - handle normally
    if (!channel.isEmpty) {
      // Update or add channel
      final existingIndex = _channels.indexWhere(
        (c) => c.index == channel.index,
      );
      if (existingIndex >= 0) {
        // Preserve unread count from existing channel
        channel.unreadCount = _channels[existingIndex].unreadCount;
        _channels[existingIndex] = channel;
      } else {
        _channels.add(channel);
      }
    }

    // Only notify if not in loading state
    if (!_isLoadingChannels) {
      _applyChannelOrder();
      _notifyFromPart();
    }
  }

  /// Parse PUSH_CODE_LOGIN_SUCCESS (0x85) frame and stash the repeater's
  /// reported clock. Frame layout (firmware companion_radio/MyMesh.cpp:678+):
  ///   [0]=0x85, [1]=permissions, [2..7]=pubkey prefix (6 bytes),
  ///   [8..11]=repeater RTC unix seconds (LE), [12]=ACL perms, [13]=fw level
  /// The timestamp is only present in the v7+ "new login response" — older
  /// firmware emits a shorter frame that we silently skip.
  void _handleLoginSuccess(Uint8List frame) {
    if (frame.length < 12) return;
    final prefix = pubKeyToHex(frame.sublist(2, 8));
    final ts = ByteData.sublistView(frame, 8, 12).getUint32(0, Endian.little);
    if (ts == 0) return;
    _repeaterLoginClocks[prefix] = DateTime.fromMillisecondsSinceEpoch(
      ts * 1000,
      isUtc: true,
    );
    _notifyFromPart();
  }

  void _handleCustomVars(Uint8List frame) {
    final buf = BufferReader(frame.sublist(1));
    try {
      _currentCustomVars = _parseKeyValueString(buf.readCString());
      // Reflect current GPS state in the polling timer (handles initial
      // device state on connect as well as external CLI/USB toggles).
      if (_currentCustomVars?['gps'] == '1') {
        _startGpsLocationPolling();
      } else {
        _stopGpsLocationPolling();
      }
    } catch (e) {
      appLogger.warn('Malformed custom vars frame: $e', tag: 'Connector');
    }
  }

  void _handleRxData(Uint8List frame) {
    final packet = BufferReader(frame);
    try {
      packet.skipBytes(1); // Skip frame type byte
      final snr = packet.readInt8() / 4.0;
      packet.skipBytes(1); // Skip RSSI byte
      //final rssi = packet.readByte();
      final header = packet.readByte();
      final routeType = header & 0x03;
      final payloadType = (header >> 2) & 0x0F;
      if (routeType == _routeTransportFlood ||
          routeType == _routeTransportDirect) {
        packet.skipBytes(4); // Skip transport-specific bytes
      }
      //final payloadVer = (header >> 6) & 0x03;
      final pathLenRaw = packet.readByte();
      final pathByteLen = _decodePathByteLen(pathLenRaw);
      final pathHashWidth = _decodePathHashWidth(pathLenRaw);
      final pathBytes = packet.readBytes(pathByteLen);
      final payload = packet.readBytes(packet.remaining);

      final rawPacket = frame.sublist(3);
      switch (payloadType) {
        case payloadTypeADVERT:
          _handlePayloadAdvertReceived(
            rawPacket,
            payload,
            pathBytes,
            pathHashWidth,
            routeType,
            snr,
          );
          break;
        default:
      }
    } catch (e) {
      appLogger.warn('Malformed RX frame: $e', tag: 'Connector');
      return;
    }
  }

  /// Takes an advert heard on air or via MQTT only once its signature
  /// checks out.
  void _handlePayloadAdvertReceived(
    Uint8List rawPacket,
    Uint8List payload,
    Uint8List path,
    int pathHashWidth,
    int routeType,
    double snr,
  ) {
    unawaited(
      _verifiedAdverts.verify(payload).then((ok) {
        if (!ok) {
          appLogger.warn(
            'Dropped an advert with a bad signature',
            tag: 'Connector',
          );
          return;
        }
        _applyAdvert(rawPacket, payload, path, pathHashWidth, routeType, snr);
      }),
    );
  }

  void _handleAutoAddConfig(Uint8List frame) {
    final reader = BufferReader(frame);
    try {
      reader.skipBytes(1); // Skip the response code byte
      final flags = reader.readByte();
      _autoAddUsers = (flags & autoAddChatFlag) != 0;
      _autoAddRepeaters = (flags & autoAddRepeaterFlag) != 0;
      _autoAddRoomServers = (flags & autoAddRoomServerFlag) != 0;
      _autoAddSensors = (flags & autoAddSensorFlag) != 0;
      _overwriteOldest = (flags & autoAddOverwriteOldestFlag) != 0;
    } catch (e) {
      appLogger.error('Failed to parse auto-add config: $e', tag: 'Connector');
    }
  }

  void _handleDiscovery(
    Contact contact,
    Uint8List rawPacket, {
    bool noNotify = false,
    bool addActive = false,
  }) {
    appLogger.info('Discovered new contact: ${contact.name}', tag: 'Connector');

    final existingIndex = _discoveredContacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );

    // Update existing contact
    if (existingIndex >= 0) {
      _discoveredContacts[existingIndex] = _discoveredContacts[existingIndex]
          .copyWith(
            rawPacket: rawPacket,
            name: contact.name,
            type: contact.type,
            pathLength: contact.pathLength,
            path: contact.path,
            latitude: contact.latitude,
            longitude: contact.longitude,
            lastSeen: contact.lastSeen,
            flags: 0,
            isActive: addActive,
          );
      _notifyFromPart();
      unawaited(_persistDiscoveredContacts());
      return;
    }

    final disContact = Contact(
      rawPacket: rawPacket,
      publicKey: contact.publicKey,
      name: contact.name,
      type: contact.type,
      pathLength: contact.pathLength,
      path: contact.path,
      latitude: contact.latitude,
      longitude: contact.longitude,
      lastSeen: contact.lastSeen,
      lastMessageAt: contact.lastMessageAt,
      isActive: addActive,
      flags: 0,
    );

    if (_discoveredContacts.length >=
        MeshCoreConnector._maxDiscoveredContacts) {
      _evictStalestDiscoveredContact();
    }
    _discoveredContacts.add(disContact);

    unawaited(_persistDiscoveredContacts());

    // Show notification for new contact (advertisement)
    if (_appSettingsService != null && !noNotify) {
      final settings = _appSettingsService!.settings;
      if (settings.notificationsEnabled && settings.notifyOnNewAdvert) {
        _notificationService.showAdvertNotification(
          radio: slot,
          contactName: contact.name,
          contactType: contact.typeLabelRaw,
          contactId: contact.publicKeyHex,
        );
      }
    }
  }
}
