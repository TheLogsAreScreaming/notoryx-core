part of 'meshcore_connector.dart';

/// Connecting, bonding, transports and reconnecting. Part of the connector so it
/// shares its private state; split out only to keep that file readable.
extension _ConnectorConnection on MeshCoreConnector {
  Future<void> _loadLinuxSystemDevicesForScan() async {
    try {
      final systemDevices = await FlutterBluePlus.systemDevices([
        Guid(MeshCoreUuids.service),
      ]);
      // systemDevices is already filtered by the NUS service UUID above, so no
      // additional name-prefix filtering is applied here. This keeps Linux
      // discovery name-agnostic and consistent with the main scan path.
      _linuxSystemScanResults
        ..clear()
        ..addAll(
          systemDevices.map(
            (device) => ScanResult(
              device: device,
              advertisementData: AdvertisementData(
                advName: device.platformName,
                txPowerLevel: null,
                appearance: null,
                connectable: true,
                manufacturerData: const <int, List<int>>{},
                serviceData: const <Guid, List<int>>{},
                serviceUuids: <Guid>[Guid(MeshCoreUuids.service)],
              ),
              rssi: 0,
              timeStamp: DateTime.now(),
            ),
          ),
        );
      _mergeLinuxSystemScanResults();
      _notifyFromPart();
    } catch (error) {
      _appDebugLogService?.warn(
        'Failed loading Linux paired/system BLE devices: $error',
        tag: 'BLE Scan',
      );
    }
  }

  void _mergeLinuxSystemScanResults() {
    if (!PlatformInfo.isLinux || _linuxSystemScanResults.isEmpty) {
      return;
    }
    final existingIds = _scanResults
        .map((result) => result.device.remoteId.str)
        .toSet();
    for (final result in _linuxSystemScanResults) {
      if (existingIds.contains(result.device.remoteId.str)) {
        continue;
      }
      _scanResults.add(result);
    }
  }

  void _scheduleScanNotify() {
    if (_scanNotifyTimer?.isActive ?? false) return;
    _scanNotifyTimer = Timer(MeshCoreConnector.scanNotifyInterval, () {
      _scanNotifyTimer = null;
      _notifyFromPart();
    });
  }

  /// Opens the platform BLE link to [device]: connect, MTU, service
  /// discovery and notifications. Throws [_ConnectSuperseded] as soon as a
  /// newer connect or a disconnect replaces attempt [generation].
  Future<void> _openBleLink(
    BluetoothDevice device,
    int generation, {
    Future<String?> Function()? linuxPairingPinProvider,
  }) async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _notifySubscription?.cancel();
    _notifySubscription = null;
    _throwIfConnectSuperseded(generation);
    _connectionSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected &&
          isConnected &&
          _deviceId == device.remoteId.toString()) {
        _handleDisconnection();
      }
    });

    if (PlatformInfo.isLinux) {
      final remoteId = device.remoteId.str;
      _appDebugLogService?.info(
        'Linux pre-connect BlueZ disconnect for $remoteId',
        tag: 'BLE Connect',
      );
      await _linuxBlePairingService.disconnectDevice(
        remoteId,
        onLog: (message) {
          _appDebugLogService?.info(message, tag: 'BLE Pair');
        },
      );
    }

    final connectTimeout = PlatformInfo.isLinux
        ? const Duration(seconds: 6)
        : const Duration(seconds: 15);
    _appDebugLogService?.info(
      'device.connect timeout set to ${connectTimeout.inSeconds}s',
      tag: 'BLE Connect',
    );
    if (PlatformInfo.isLinux) {
      Future<void> attemptConnect() {
        return device
            .connect(
              timeout: connectTimeout,
              mtu: null,
              license: License.nonprofit,
            )
            .timeout(
              connectTimeout + const Duration(seconds: 2),
              onTimeout: () {
                throw TimeoutException(
                  'Linux connect hard-timeout after ${connectTimeout.inSeconds + 2}s',
                );
              },
            );
      }

      try {
        await attemptConnect();
      } catch (error) {
        _appDebugLogService?.error(
          'device.connect() failure: $error',
          tag: 'BLE Connect',
        );
        final remoteId = device.remoteId.str;
        _appDebugLogService?.warn(
          'Linux immediate retry: forcing BlueZ disconnect before second connect attempt',
          tag: 'BLE Connect',
        );
        await _linuxBlePairingService.disconnectDevice(
          remoteId,
          onLog: (message) {
            _appDebugLogService?.info(message, tag: 'BLE Pair');
          },
        );
        await Future<void>.delayed(const Duration(milliseconds: 700));
        try {
          await attemptConnect();
          _appDebugLogService?.info(
            'Linux immediate retry connect succeeded',
            tag: 'BLE Connect',
          );
        } catch (retryError, retryStackTrace) {
          Object finalConnectError = retryError;
          StackTrace finalConnectStackTrace = retryStackTrace;
          final retryErrorText = retryError.toString().toLowerCase();
          final isAbortByLocal = retryErrorText.contains(
            'le-connection-abort-by-local',
          );
          var recoveredOnThirdAttempt = false;
          if (isAbortByLocal) {
            _appDebugLogService?.warn(
              'Linux immediate retry aborted by local stack; waiting and retrying once more',
              tag: 'BLE Connect',
            );
            await Future<void>.delayed(const Duration(milliseconds: 1200));
            try {
              await attemptConnect();
              _appDebugLogService?.info(
                'Linux third-attempt connect succeeded after local abort',
                tag: 'BLE Connect',
              );
              recoveredOnThirdAttempt = true;
            } catch (thirdError, thirdStackTrace) {
              finalConnectError = thirdError;
              finalConnectStackTrace = thirdStackTrace;
              _appDebugLogService?.error(
                'device.connect() third-attempt failure: $thirdError',
                tag: 'BLE Connect',
              );
            }
          }
          if (!recoveredOnThirdAttempt) {
            final recoveredByPairing = await _recoverLinuxConnectFailure(
              device,
              attemptConnect: attemptConnect,
              onRequestPin: linuxPairingPinProvider,
            );
            if (recoveredByPairing) {
              _appDebugLogService?.info(
                'Linux connect succeeded after pairing/trust recovery',
                tag: 'BLE Connect',
              );
            } else {
              _appDebugLogService?.error(
                'device.connect() retry failure: $finalConnectError',
                tag: 'BLE Connect',
              );
              Error.throwWithStackTrace(
                _wrapLinuxConnectStageError(finalConnectError),
                finalConnectStackTrace,
              );
            }
          }
        }
      }
    } else {
      Future<void> attemptConnect() {
        return device.connect(
          timeout: connectTimeout,
          mtu: null,
          license: License.nonprofit,
        );
      }

      // A previous app session (e.g. killed from the iOS app switcher) can
      // leave the OS holding a stale link to the peripheral. Clear it before
      // connecting so the fresh attempt doesn't race the stale handle.
      if (!PlatformInfo.isWeb && device.isConnected) {
        _appDebugLogService?.warn(
          'Device reports an existing connection before connect; clearing stale link',
          tag: 'BLE Connect',
        );
        try {
          await device.disconnect(queue: false);
        } catch (cleanupError) {
          _appDebugLogService?.warn(
            'Stale-link cleanup disconnect failed (continuing): $cleanupError',
            tag: 'BLE Connect',
          );
        }
      }

      try {
        await attemptConnect();
      } catch (error) {
        _appDebugLogService?.error(
          'device.connect() failure: $error',
          tag: 'BLE Connect',
        );
        if (PlatformInfo.isWeb ||
            !MeshCoreConnector.shouldRetryBleConnectAfterError(
              error.toString(),
            )) {
          rethrow;
        }
        // Fast (non-timeout) failures are usually a stale connection left by
        // a previous session; clean up and retry once before surfacing.
        _appDebugLogService?.warn(
          'Retrying connect once after clearing possible stale connection',
          tag: 'BLE Connect',
        );
        try {
          await device.disconnect(queue: false);
        } catch (cleanupError) {
          _appDebugLogService?.warn(
            'Pre-retry cleanup disconnect failed (continuing): $cleanupError',
            tag: 'BLE Connect',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
        try {
          await attemptConnect();
          _appDebugLogService?.info(
            'Retry connect succeeded after stale-connection cleanup',
            tag: 'BLE Connect',
          );
        } catch (retryError) {
          _appDebugLogService?.error(
            'device.connect() retry failure: $retryError',
            tag: 'BLE Connect',
          );
          rethrow;
        }
      }
    }

    _throwIfConnectSuperseded(generation);
    if (PlatformInfo.isLinux) {
      await _ensureLinuxBleBond(device, onRequestPin: linuxPairingPinProvider);
    }

    // Request larger MTU only where the platform path supports it.
    if (!PlatformInfo.isWeb && !PlatformInfo.isLinux) {
      try {
        final mtu = await device.requestMtu(185);
        _appDebugLogService?.info('MTU set to: $mtu', tag: 'BLE Connect');
      } catch (e) {
        _appDebugLogService?.warn(
          'MTU request failed: $e, using default',
          tag: 'BLE Connect',
        );
      }
    } else if (PlatformInfo.isLinux) {
      _appDebugLogService?.info(
        'Skipping MTU request on Linux; flutter_blue_plus only supports requestMtu on Android',
        tag: 'BLE Connect',
      );
    }

    late final List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (error) {
      _appDebugLogService?.error(
        'service discovery failure: $error',
        tag: 'BLE Connect',
      );
      if (PlatformInfo.isWeb &&
          error.toString().contains('GATT Server is disconnected')) {
        // Chrome Web Bluetooth intermittently disconnects between connect()
        // and service discovery; retry once to recover that transient state.
        _appDebugLogService?.warn(
          'retrying service discovery after transient web disconnect',
          tag: 'BLE Connect',
        );
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await device.connect(
          timeout: const Duration(seconds: 15),
          mtu: null,
          license: License.nonprofit,
        );
        services = await device.discoverServices();
      } else {
        rethrow;
      }
    }

    _throwIfConnectSuperseded(generation);
    BluetoothService? uartService;
    for (var service in services) {
      if (service.uuid.toString().toLowerCase() == MeshCoreUuids.service) {
        uartService = service;
        break;
      }
    }

    if (uartService == null) {
      throw Exception("MeshCore UART service not found");
    }

    for (var characteristic in uartService.characteristics) {
      String uuid = characteristic.uuid.toString().toLowerCase();
      if (uuid == MeshCoreUuids.rxCharacteristic) {
        _rxCharacteristic = characteristic;
      } else if (uuid == MeshCoreUuids.txCharacteristic) {
        _txCharacteristic = characteristic;
      }
    }

    if (_rxCharacteristic == null || _txCharacteristic == null) {
      throw Exception("MeshCore characteristics not found");
    }

    if (PlatformInfo.isWeb) {
      _appDebugLogService?.info(
        'Starting setNotifyValue(true)',
        tag: 'BLE Connect',
      );
      _appDebugLogService?.info(
        'Web: Calling setNotifyValue(true) without awaiting',
        tag: 'BLE Connect',
      );
      unawaited(() async {
        try {
          await _txCharacteristic!.setNotifyValue(true);
        } catch (error) {
          _appDebugLogService?.warn(
            'notify failure (web, ignored): $error',
            tag: 'BLE Connect',
          );
          _appDebugLogService?.warn(
            'Web setNotifyValue error (ignoring): $error',
            tag: 'BLE Connect',
          );
        }
      }());
      _appDebugLogService?.info(
        'setNotifyValue(true) configuration completed',
        tag: 'BLE Connect',
      );
    } else {
      bool notifySet = false;
      for (int attempt = 0; attempt < 3 && !notifySet; attempt++) {
        try {
          if (attempt > 0) {
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
          await _txCharacteristic!.setNotifyValue(true);
          notifySet = true;
        } catch (e) {
          _appDebugLogService?.warn('notify failure: $e', tag: 'BLE Connect');
          _appDebugLogService?.warn(
            'setNotifyValue attempt ${attempt + 1}/3 failed: $e',
            tag: 'BLE Connect',
          );
          if (attempt == 2) rethrow;
        }
      }
    }
    _throwIfConnectSuperseded(generation);
    _notifySubscription = _txCharacteristic!.onValueReceived.listen(
      _handleFrame,
    );
  }

  void _throwIfConnectSuperseded(int generation) {
    if (generation != _connectGeneration) throw const _ConnectSuperseded();
  }

  /// Disconnects a superseded attempt's device unless the current connection
  /// is to that same device.
  Future<void> _dropSupersededBleLink(BluetoothDevice device) async {
    final stillCurrent =
        _deviceId == device.remoteId.toString() &&
        _state != MeshCoreConnectionState.disconnected;
    if (stillCurrent) return;
    try {
      await _unlinkBleDevice(device);
    } catch (error) {
      _appDebugLogService?.warn(
        'Superseded link cleanup failed (ignored): $error',
        tag: 'BLE Connect',
      );
    }
  }

  Future<void> _unlinkBleDevice(BluetoothDevice device) {
    final unlink = debugBleUnlinkOverride;
    if (unlink != null) return unlink(device);
    // Skip queued BLE operations so disconnect doesn't get stuck behind them.
    return device.disconnect(queue: false);
  }

  Future<bool> _recoverLinuxConnectFailure(
    BluetoothDevice device, {
    required Future<void> Function() attemptConnect,
    Future<String?> Function()? onRequestPin,
  }) async {
    if (!PlatformInfo.isLinux ||
        !await _linuxBlePairingService.isBluetoothctlAvailable()) {
      return false;
    }
    final remoteId = device.remoteId.str;
    final pluginBondState = await _getLinuxPluginBondState(device);
    final trustedByBluez = await _linuxBlePairingService.isPairedAndTrusted(
      remoteId,
    );
    final needsBondRecovery =
        (pluginBondState != null &&
            pluginBondState != BmBondStateEnum.bonded) ||
        !trustedByBluez;
    if (!needsBondRecovery) {
      return false;
    }
    _appDebugLogService?.warn(
      pluginBondState == BmBondStateEnum.bonded
          ? 'Linux connect failed with an untrusted bond; attempting trust/pair recovery'
          : 'Linux connect failed before bond completed; attempting pairing fallback',
      tag: 'BLE Connect',
    );
    await _ensureLinuxBleBond(device, onRequestPin: onRequestPin);
    _appDebugLogService?.info(
      'Resetting BlueZ connection after Linux pairing/trust recovery',
      tag: 'BLE Connect',
    );
    await _linuxBlePairingService.disconnectDevice(
      remoteId,
      onLog: (message) {
        _appDebugLogService?.info(message, tag: 'BLE Pair');
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    try {
      await attemptConnect();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_wrapLinuxConnectStageError(error), stackTrace);
    }
    return true;
  }

  Object _wrapLinuxConnectStageError(Object error) {
    final errorText = error.toString();
    if (errorText.toLowerCase().contains(linuxConnectStageFailureMarker)) {
      return error;
    }
    return StateError('Linux connect stage failure: $error');
  }

  Future<BmBondStateEnum?> _getLinuxPluginBondState(
    BluetoothDevice device,
  ) async {
    try {
      final response = await FlutterBluePlusPlatform.instance.getBondState(
        BmBondStateRequest(remoteId: device.remoteId),
      );
      return response.bondState;
    } catch (error) {
      _appDebugLogService?.warn(
        'Linux getBondState unavailable for ${device.remoteId.str}: $error',
        tag: 'BLE Connect',
      );
      return null;
    }
  }

  Future<void> _ensureLinuxBleBond(
    BluetoothDevice device, {
    Future<String?> Function()? onRequestPin,
  }) async {
    final remoteId = device.remoteId.str;
    final bluetoothctlAvailable = await _linuxBlePairingService
        .isBluetoothctlAvailable();
    final beforeBondState = await _getLinuxPluginBondState(device);
    if (!bluetoothctlAvailable) {
      if (beforeBondState == BmBondStateEnum.bonded) {
        _appDebugLogService?.warn(
          'bluetoothctl unavailable; continuing with plugin bonded state',
          tag: 'BLE Connect',
        );
      } else if (beforeBondState == null) {
        _appDebugLogService?.warn(
          'bluetoothctl unavailable and plugin bond state is unknown; skipping Linux pairing fallback',
          tag: 'BLE Connect',
        );
      } else {
        _appDebugLogService?.warn(
          'bluetoothctl unavailable and device is not bonded; skipping Linux pairing fallback',
          tag: 'BLE Connect',
        );
      }
      return;
    }

    final trustedByBluez = await _linuxBlePairingService.isPairedAndTrusted(
      remoteId,
    );
    if (trustedByBluez) {
      _appDebugLogService?.info(
        'Linux BLE device already paired/trusted, skipping pairing flow',
        tag: 'BLE Connect',
      );
      return;
    }

    if (beforeBondState == BmBondStateEnum.bonded && !trustedByBluez) {
      _appDebugLogService?.warn(
        'Linux BLE device is bonded but not trusted in BlueZ; repairing trust',
        tag: 'BLE Connect',
      );
      final trustRepaired = await _linuxBlePairingService.trustDevice(
        remoteId,
        onLog: (message) {
          _appDebugLogService?.info(message, tag: 'BLE Pair');
        },
      );
      if (trustRepaired) {
        _appDebugLogService?.info(
          'Linux BLE trust repair succeeded without re-pairing',
          tag: 'BLE Connect',
        );
        return;
      }
      _appDebugLogService?.warn(
        'Linux BLE trust repair did not stick; retrying pairing flow',
        tag: 'BLE Connect',
      );
    }

    _appDebugLogService?.info(
      beforeBondState == BmBondStateEnum.bonded
          ? 'Linux BLE device still untrusted after repair; requesting pair'
          : beforeBondState == null
          ? 'Linux BLE device bond state unknown; requesting pair'
          : 'Linux BLE device not bonded, requesting pair',
      tag: 'BLE Connect',
    );
    final paired = await _linuxBlePairingService.pairAndTrust(
      remoteId: remoteId,
      onLog: (message) {
        _appDebugLogService?.info(message, tag: 'BLE Pair');
      },
      onRequestPin: onRequestPin,
    );
    if (!paired) {
      throw StateError('Linux pairing fallback failed');
    }

    final afterBondState = await _getLinuxPluginBondState(device);
    if (afterBondState != null && afterBondState != BmBondStateEnum.bonded) {
      throw StateError('Linux BLE pairing did not complete');
    } else if (afterBondState == null) {
      _appDebugLogService?.warn(
        'Linux plugin bond state unavailable after pairing; relying on BlueZ trust verification',
        tag: 'BLE Connect',
      );
    }
    final trustedAfter = await _linuxBlePairingService.isPairedAndTrusted(
      remoteId,
    );
    if (!trustedAfter) {
      throw StateError('Linux BLE trust repair did not complete');
    }
  }

  Future<void> _startBleInitialSync() async {
    if (_bleInitialSyncStarted ||
        !isConnected ||
        _activeTransport != MeshCoreTransportType.bluetooth) {
      return;
    }
    _bleInitialSyncStarted = true;
    _pendingInitialChannelSync = true;
    _pendingInitialContactsSync = true;
    _pendingInitialQueuedMessageSync = true;

    await _requestDeviceInfo();
    _startBatteryPolling();
    if (_radioStatsPollRefCount > 0) _startRadioStatsPolling();

    final gotSelfInfo = await _waitForSelfInfo(
      timeout: const Duration(seconds: 3),
    );
    if (!gotSelfInfo) {
      await refreshDeviceInfo();
      await _waitForSelfInfo(timeout: const Duration(seconds: 3));
    }

    await syncTime();
    _maybeStartInitialChannelSync();
  }

  void _resetConnectionHandshakeState() {
    _selfPublicKey = null;
    // Partially received images belong to the previous session's sender prefix.
    _imageTransport?.reassembler.clear();
    _selfName = null;
    _selfLatitude = null;
    _selfLongitude = null;
    _lastZeroHopAdvertLatitude = null;
    _lastZeroHopAdvertLongitude = null;
    _awaitingSelfInfo = false;
    _webInitialHandshakeRequestSent = false;
    _selfInfoRetryTimer?.cancel();
    _selfInfoRetryTimer = null;
    _hasReceivedDeviceInfo = false;
    _resetSyncProgressState();
    _bleInitialSyncStarted = false;
    _pathHashByteWidth = 1;
  }

  /// Starts a TCP or USB connect. One the user asks for begins a fresh
  /// backoff and forgets the old link; an automatic retry keeps both.
  void _beginWiredConnect(bool automaticReconnect) {
    _manualDisconnect = false;
    if (automaticReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    } else {
      _cancelReconnectTimer();
      _linkTarget = null;
    }
  }

  int _nextReconnectDelayMs() {
    final delayMs = reconnectDelayMs(_reconnectAttempts);
    _reconnectAttempts += 1;
    return delayMs;
  }

  void _scheduleReconnect() {
    if (!_shouldAutoReconnect) return;
    if (_reconnectTimer?.isActive == true) return;

    final delayMs = _nextReconnectDelayMs();
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () async {
      // The scheduled timer has fired. Clear it before attempting a connection
      // so a failed attempt can schedule the next retry.
      _reconnectTimer = null;
      if (!_shouldAutoReconnect) return;
      if (_state == MeshCoreConnectionState.connecting ||
          _state == MeshCoreConnectionState.connected) {
        return;
      }

      final target = _linkTarget;
      if (target != null) {
        _appDebugLogService?.info(
          'Reconnecting ${target.transport.name} (attempt $_reconnectAttempts)',
          tag: 'Connection',
        );
        try {
          final override = debugLinkReconnectOverride;
          if (override != null) {
            await override(target);
          } else {
            switch (target) {
              case TcpLinkTarget(:final host, :final port):
                await connectTcp(
                  host: host,
                  port: port,
                  automaticReconnect: true,
                );
              case UsbLinkTarget(:final portName, :final baudRate):
                await connectUsb(
                  portName: portName,
                  baudRate: baudRate,
                  automaticReconnect: true,
                );
            }
          }
        } catch (_) {
          _scheduleReconnect();
        }
        return;
      }

      final device =
          _lastDevice ??
          (_lastDeviceId == null
              ? null
              : BluetoothDevice.fromId(_lastDeviceId!));
      if (device == null) return;

      try {
        await connect(
          device,
          displayName: _lastDeviceDisplayName,
          automaticReconnect: true,
        );
      } catch (_) {
        _scheduleReconnect();
      }
    });
  }

  Future<void> _disconnect({
    required bool manual,
    required bool skipBleDeviceDisconnect,
  }) async {
    final transportAtDisconnect = _activeTransport;
    final transportLabel = switch (transportAtDisconnect) {
      MeshCoreTransportType.bluetooth => 'BLE',
      MeshCoreTransportType.usb => 'USB',
      MeshCoreTransportType.tcp => 'TCP',
    };

    _appDebugLogService?.info(
      'Starting disconnect transport=$transportLabel manual=$manual',
      tag: 'Connection',
    );

    if (manual) {
      _manualDisconnect = true;
      _linkTarget = null;
      _cancelReconnectTimer();
      unawaited(_backgroundService?.stop());
    } else {
      _manualDisconnect = false;
    }
    _setState(MeshCoreConnectionState.disconnecting);
    _stopBatteryPolling();
    _stopRadioStatsPolling();

    await _usbFrameSubscription?.cancel();
    _usbFrameSubscription = null;
    await _usbManager.disconnect();
    await _tcpConnector.disconnect();

    await _notifySubscription?.cancel();
    _notifySubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _selfInfoRetryTimer?.cancel();
    _selfInfoRetryTimer = null;
    _queueSyncTimeout?.cancel();
    _queueSyncTimeout = null;
    _queueSyncRetries = 0;
    _channelSyncTimeout?.cancel();
    _channelSyncTimeout = null;
    _channelSyncRetries = 0;
    await _translationService?.releaseModel();
    // The decode graph is ~833 MB resident; drop it with the connection. The
    // connector never disposes services it does not own (main.dart does).
    //
    // Cancel first: `releaseModel` serialises behind the codec's exclusive
    // lock, so disconnecting mid-decode would otherwise block this teardown
    // for the ~1 s the inference takes and then tear the session out from
    // under a job whose result nobody is waiting for any more.
    _imageCodecService?.cancelCodecJob();
    await _imageCodecService?.releaseModel();
    // Partial images belong to this session's sender prefixes; a reconnect
    // starts over. Dropping them also stops `evictExpired` from firing "image
    // incomplete" failures into the store minutes after the radio went away.
    _imageTransport?.reassembler.clear();

    if (!skipBleDeviceDisconnect) {
      try {
        final device = _device;
        if (device != null) await _unlinkBleDevice(device);
      } catch (e) {
        _appDebugLogService?.warn('Disconnect error: $e', tag: 'BLE Connect');
      }
    } else {
      _appDebugLogService?.info(
        'Skipping plugin BLE disconnect and continuing cleanup',
        tag: 'BLE Connect',
      );
    }

    _device = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _deviceDisplayName = null;
    _deviceId = null;
    _contacts.clear();
    _discoveredContacts.clear();
    _conversations.clear();
    _loadedConversationKeys.clear();
    _selfPublicKey = null;
    _selfName = null;
    _selfLatitude = null;
    _selfLongitude = null;
    _lastZeroHopAdvertLatitude = null;
    _lastZeroHopAdvertLongitude = null;
    _clientRepeat = null;
    _rememberedNonRepeatRadioState = null;
    _firmwareVerCode = null;
    _floodCorridorSupported = null;
    _floodCorridorProbePending = false;
    _corridorRegion = null;
    _batteryMillivolts = null;
    _lastRxSnr = null;
    _lastRxRssi = null;
    _lastRxSignalAt = null;
    _repeaterBatterySnapshots.clear();
    _batteryRequested = false;
    _awaitingSelfInfo = false;
    _hasReceivedDeviceInfo = false;
    _maxContacts = MeshCoreConnector._defaultMaxContacts;
    _maxContactsReported = false;
    _maxChannels = MeshCoreConnector._defaultMaxChannels;
    _resetSyncProgressState();
    _pendingChannelSentQueue.clear();
    _pendingGenericAckQueue.clear();
    _reactionSendQueueSequence = 0;

    _activeTransport = MeshCoreTransportType.bluetooth;

    _setState(MeshCoreConnectionState.disconnected);
    _appDebugLogService?.info(
      'Disconnect complete transport=$transportLabel manual=$manual',
      tag: 'Connection',
    );
    if (!manual &&
        (transportAtDisconnect == MeshCoreTransportType.bluetooth ||
            _linkTarget != null)) {
      _scheduleReconnect();
    }
  }

  void _handleDisconnection() {
    _stopBatteryPolling();
    _stopGpsLocationPolling();
    _stopRadioStatsPolling();
    _latestRadioStats = null;
    _airtimeSamples.clear();
    radioStatsNotifier.value = null;
    _prevTotalAirSecs = 0;
    _airtimeBumpStopwatch?.stop();
    _airtimeBumpStopwatch = null;

    for (final entry in _pendingRepeaterAcks.values) {
      entry.timeout?.cancel();
    }
    _pendingRepeaterAcks.clear();

    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;

    _device = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    // Preserve deviceId and displayName for UI display during reconnection
    // They're only cleared on manual disconnect via disconnect() method
    _hasReceivedDeviceInfo = false;
    _maxContacts = MeshCoreConnector._defaultMaxContacts;
    _maxContactsReported = false;
    _maxChannels = MeshCoreConnector._defaultMaxChannels;
    _resetSyncProgressState();
    _pendingChannelSentQueue.clear();
    _pendingGenericAckQueue.clear();
    _reactionSendQueueSequence = 0;

    _setState(MeshCoreConnectionState.disconnected);
    _scheduleReconnect();
  }
}
