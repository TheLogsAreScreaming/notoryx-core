import '../services/node_telemetry_store.dart';
import '../services/repeater_battery_history.dart';
import '../helpers/cayenne_lpp.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto;
import 'package:meshcore_open/storage/region_store.dart';
import 'package:pointycastle/export.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/region_setup.dart' show parseRegionTrees;
import '../models/region_scope.dart';
import '../models/advert_signature.dart';
import '../models/channel_notify_mode.dart';
import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/companion_radio_stats.dart';
import '../models/mesh_health.dart';
import '../models/radio_rx_packet.dart';
import '../models/saved_radio.dart';
import '../models/contact.dart';
import '../models/flood_corridor.dart';
import '../models/heard_channel_packet.dart';
import '../models/message.dart';
import '../models/path_selection.dart';
import '../models/translation_support.dart';
import 'radio_signing.dart';
import '../helpers/share_links.dart';
import '../helpers/reaction_helper.dart';
import '../helpers/cyr2lat.dart';
import '../helpers/smaz.dart';
import '../services/app_debug_log_service.dart';
import '../services/ble_debug_log_service.dart';
import '../services/linux_ble_error_classifier.dart';
import '../services/linux_ble_pairing_service_stub.dart'
    if (dart.library.io) '../services/linux_ble_pairing_service.dart';
import '../services/image_chunk_transport.dart'
    show
        ImageChunkOutcome,
        ImageChunkTransport,
        ParsedChannelData,
        buildSendChannelDataFrame,
        dataTypeAeicImage,
        outPathUnknown,
        parseChannelDataFrame,
        respCodeChannelDataRecv,
        senderPrefixFromKey;
import '../services/signed_posts.dart';
import '../services/image_codec_service.dart';
import '../services/message_retry_service.dart';
import '../services/path_history_service.dart';
import '../services/app_settings_service.dart';
import '../services/background_service.dart';
import '../services/timeout_prediction_service.dart';
import '../services/translation_service.dart';
import '../services/notification_deduper.dart';
import '../services/notification_service.dart';
import 'meshcore_connector_usb.dart';
import 'meshcore_connector_tcp.dart';
import '../storage/channel_message_store.dart';
import '../storage/channel_order_store.dart';
import '../storage/channel_settings_store.dart';
import '../storage/channel_region_store.dart';
import '../storage/channel_store.dart';
import '../storage/contact_discovery_store.dart';
import '../storage/contact_settings_store.dart';
import '../storage/contact_store.dart';
import '../storage/message_store.dart';
import '../storage/prefs_manager.dart';
import '../storage/unread_store.dart';
import '../utils/app_logger.dart';
import '../utils/battery_utils.dart';
import '../utils/platform_info.dart';
import 'meshcore_uuids.dart';
import 'connector_types.dart';
import 'meshcore_protocol.dart';
import 'reconnect_policy.dart';
import 'tx_backoff.dart';

export 'connector_types.dart';

part 'connector_frame_handlers.dart';
part 'connector_messaging.dart';
part 'connector_sync.dart';
part 'connector_connection.dart';

class MeshCoreConnector extends ChangeNotifier {
  /// Creates one radio connection. [slot] keeps this connection's saved
  /// radio apart from other connections; the first radio uses '' so it
  /// reads the same saved radio as earlier builds.
  MeshCoreConnector({this.slot = ''});

  /// Which saved-radio slot this connection uses: '' for the first radio.
  final String slot;

  /// The radio's name to add to notification titles, or null. Set by the
  /// app when it has more than one radio, so you can tell which one a
  /// message came in on.
  String? Function()? notificationRadioName;

  /// [title] with the radio's name after it, when there is one.
  String notificationTitle(String title) {
    final radio = notificationRadioName?.call();
    return radio == null || radio.isEmpty ? title : '$title · $radio';
  }

  /// This connection's retry service, once [initialize] has run.
  MessageRetryService? get retryService => _retryService;

  /// Lets the part files notify, since extensions can't call protected
  /// members directly.
  void _notifyFromPart() => notifyListeners();

  // Message windowing to limit memory usage
  static const int _messageWindowSize = 200;

  // Cap on discovered (non-contact) nodes retained in memory. Adverts arrive
  // continuously from the whole mesh, so without a bound this list grows for
  // as long as the app stays connected. When full, the stalest node (oldest
  // lastSeen) is evicted to make room for a newly heard one.
  static const int _maxDiscoveredContacts = 500;

  MeshCoreConnectionState _state = MeshCoreConnectionState.disconnected;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  String? _deviceDisplayName;
  String? _deviceId;
  BluetoothDevice? _lastDevice;
  String? _lastDeviceId;
  String? _lastDeviceDisplayName;
  bool _manualDisconnect = false;
  // Set once a TCP or USB connect succeeds; cleared by a manual disconnect
  // or by any connect the user starts. While set, a dropped link is retried
  // with the same backoff as Bluetooth.
  LinkTarget? _linkTarget;
  final MeshCoreUsbManager _usbManager = MeshCoreUsbManager();
  final LinuxBlePairingService _linuxBlePairingService =
      LinuxBlePairingService();
  StreamSubscription<Uint8List>? _usbFrameSubscription;
  final MeshCoreTcpConnector _tcpConnector = MeshCoreTcpConnector();
  MeshCoreTransportType _activeTransport = MeshCoreTransportType.bluetooth;

  final List<ScanResult> _scanResults = [];
  final List<ScanResult> _linuxSystemScanResults = [];
  final List<Contact> _contacts = [];
  final List<Contact> _discoveredContacts = [];
  final List<Channel> _channels = [];
  final Map<String, List<Message>> _conversations = {};
  final Map<int, List<ChannelMessage>> _channelMessages = {};
  final List<String> _pendingChannelSentQueue = [];
  final List<_PendingCommandAck> _pendingGenericAckQueue = [];
  static const String _reactionSendQueuePrefix = '__reaction_send__';
  int _reactionSendQueueSequence = 0;
  final Set<String> _loadedConversationKeys = {};
  final Map<int, Set<String>> _processedChannelReactions =
      {}; // channelIndex -> Set of "targetHash_emoji"
  final Map<String, Set<String>> _processedContactReactions =
      {}; // contactPubKeyHex -> Set of "targetHash_emoji"

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  Timer? _notifyListenersTimer;
  Timer? _selfInfoRetryTimer;
  Timer? _reconnectTimer;
  Timer? _batteryPollTimer;
  Timer? _gpsLocationPollTimer;
  static const _gpsLocationPollInterval = Duration(minutes: 1);
  Timer? _radioStatsPollTimer;
  int _radioStatsPollRefCount = 0;
  final ValueNotifier<CompanionRadioStats?> radioStatsNotifier =
      ValueNotifier<CompanionRadioStats?>(null);
  int _reconnectAttempts = 0;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  // Set when Bluetooth went off while a BLE link was up, connecting or about
  // to retry, so exactly one reconnect is scheduled when it comes back.
  bool _resumeBleWhenAdapterOn = false;
  // Bumped by every BLE connect and every disconnect. A connect attempt that
  // sees a newer generation after an await was superseded and must stop.
  int _connectGeneration = 0;
  Future<void>? _disconnectInFlight;
  String? _lastConnectionError;
  double? _lastRxSnr;
  int? _lastRxRssi;
  DateTime? _lastRxSignalAt;
  bool _notifyListenersDirty = false;
  static const Duration _notifyListenersDebounce = Duration(milliseconds: 50);

  final StreamController<Uint8List> _receivedFramesController =
      StreamController<Uint8List>.broadcast();
  final StreamController<RadioRxPacket> _rxPacketsController =
      StreamController<RadioRxPacket>.broadcast();
  final StreamController<Message> _receivedDirectMessagesController =
      StreamController<Message>.broadcast();
  final StreamController<ReceivedChannelMessage>
  _receivedChannelMessagesController =
      StreamController<ReceivedChannelMessage>.broadcast();
  final StreamController<ChannelMessage> _radioChannelMessagesController =
      StreamController<ChannelMessage>.broadcast();

  Uint8List? _selfPublicKey;
  String? _selfName;
  int? _currentTxPower;
  int? _maxTxPower;
  int? _currentFreqHz;
  int? _currentBwHz;
  int? _currentSf;
  int? _currentCr;
  bool? _clientRepeat;
  MeshCoreRadioStateSnapshot? _rememberedNonRepeatRadioState;
  int? _firmwareVerCode;
  bool? _floodCorridorSupported;
  bool _floodCorridorProbePending = false;
  String? _corridorRegion;
  int _pathHashByteWidth = 1;
  CompanionRadioStats? _latestRadioStats;
  Stopwatch? _airtimeBumpStopwatch;
  int _prevTotalAirSecs = 0;
  int? _batteryMillivolts;
  double? _selfLatitude;
  double? _selfLongitude;
  final List<DirectRepeater> _directRepeaters = List.empty(growable: true);
  bool _isLoadingContacts = false;
  bool _hasLoadedContacts = false;
  bool _isLoadingChannels = false;
  bool _hasLoadedChannels = false;
  TimeoutPredictionService? _timeoutPredictionService;
  TranslationService? _translationService;
  ImageCodecService? _imageCodecService;
  // Holds the ImageReassembler, so partially received images survive across
  // frames (chunks of one image arrive in separate GRP_DATA frames, and via the
  // firmware offline queue they may be minutes apart).
  ImageChunkTransport? _imageTransport;
  void Function(ImageChunkOutcome outcome)? _onImageChunk;
  void Function(int senderPrefix)? _onImageSenderPrefix;
  // Intentionally global (not per-contact): tracks overall network activity.
  // Frequent RX from any source indicates a busy network with more collisions.
  DateTime _lastRxTime = DateTime.now();
  // Snapshot of _lastRxTime taken before the ACK frame updates it, so that
  // onDeliveryObserved records the pre-ACK elapsed time (matching prediction).
  DateTime _lastRxBeforeFrame = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastRadioRxTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastContactMsgRxTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastChannelMsgRxTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastZeroHopAdvertAt = DateTime.fromMillisecondsSinceEpoch(0);
  double? _lastZeroHopAdvertLatitude;
  double? _lastZeroHopAdvertLongitude;
  static const int _radioQuietMs = 3000;
  static const int _radioQuietMaxWaitMs = 3000;

  /// When companion radio stats are unavailable, keep the legacy fixed backoff.
  static const int _contactMsgBackoffFallbackMs = 5000;
  static const int _contactMsgBackoffMinMs = 500;
  static const int _contactMsgBackoffMaxMs = 15000;
  int _pollingInterval = 30;
  bool _batteryRequested = false;
  bool _awaitingSelfInfo = false;
  bool _hasReceivedDeviceInfo = false;
  String? _manufacturerName;
  String? _firmwareVersionString;
  // Initial sync is serialized for predictable progress. Firmware exposes one
  // FIFO queued-message stream, so direct/room frames are buffered until after
  // contacts are known.
  bool _pendingInitialChannelSync = false;
  bool _pendingInitialContactsSync = false;
  bool _pendingInitialQueuedMessageSync = false;
  bool _bleInitialSyncStarted = false;
  bool _webInitialHandshakeRequestSent = false;
  bool _preserveContactsOnRefresh = false;

  /// Contact sync watchdog: keys received in this sync, how many times the
  /// request was re-sent after silence, and whether the last sync gave up.
  final Set<String> _contactSyncSeen = {};
  Timer? _contactSyncWatchdog;
  int _contactSyncRetries = 0;
  int? _contactSyncSince;
  bool _contactSyncStalled = false;

  /// Silence that counts as a stalled contact sync.
  @visibleForTesting
  static Duration contactSyncSilence = const Duration(seconds: 20);
  bool _autoAddUsers = false;
  bool _autoAddRepeaters = false;
  bool _autoAddRoomServers = false;
  bool _autoAddSensors = false;
  bool _overwriteOldest = false;
  bool _manualAddContacts = false;
  int _telemetryModeBase = 0;
  int _telemetryModeLoc = 0;
  int _telemetryModeEnv = 0;
  int _advertLocPolicy = 0;
  int _multiAcks = 0;

  static const int _defaultMaxContacts = 350;
  static const int _defaultMaxChannels = 40;
  int _maxContacts = _defaultMaxContacts;
  bool _maxContactsReported = false;
  int _maxChannels = _defaultMaxChannels;
  int? _contactSyncTotal;
  int _contactSyncReceived = 0;
  bool _contactSyncUsesSinceFilter = false;
  bool _isSyncingQueuedMessages = false;
  bool _deferQueuedContactMessagesUntilContacts = false;
  bool _isProcessingDeferredQueuedContactMessages = false;
  bool _queuedMessageSyncInFlight = false;
  final List<Uint8List> _deferredQueuedContactMessageFrames = [];
  bool _pendingQueueSync = false;
  Timer? _queueSyncTimeout;
  int _queueSyncRetries = 0;
  static const int _maxQueueSyncRetries = 3;
  static const int _queueSyncTimeoutMs = 5000; // 5 second timeout
  // Serializes path operations (setContactPath/clearContactPath) to prevent
  // interleaved async calls from leaving in-memory state inconsistent with device.
  Future<void> _pathOpLock = Future.value();
  // Flood scope is a global firmware setting, so scoped channel sends must not
  // overlap or a message may inherit another channel's region.
  Future<void> _channelScopedSendLock = Future.value();
  // Companion CLI commands run one at a time; replies carry no request id
  // beyond the optional two-character prefix the firmware echoes back.
  Future<void> _cliLock = Future.value();
  int _cliPrefixCounter = 0;
  // CMD_SIGN_* keeps one buffer on the radio, so signings never overlap.
  Future<void> _signLock = Future.value();

  /// Receives sign frames instead of the radio link, for tests.
  @visibleForTesting
  Future<void> Function(Uint8List frame)? debugSignFrameWriter;
  static const Duration _commandAckTimeout = Duration(seconds: 5);
  Map<String, String>? _currentCustomVars;

  /// Maps repeater pubkey-prefix hex (12 hex chars = first 6 bytes) → the
  /// repeater's RTC clock at the moment of the most recent successful login.
  /// Reported by firmware in the login-success push frame at byte offset 8.
  final Map<String, DateTime> _repeaterLoginClocks = {};

  // Channel syncing state (sequential pattern)
  bool _isSyncingChannels = false;
  bool _channelSyncInFlight = false;
  Timer? _channelSyncTimeout;
  int _channelSyncRetries = 0;
  int _nextChannelIndexToRequest = 0;
  int _totalChannelsToRequest = 0;
  List<Channel> _previousChannelsCache = [];
  static const int _maxChannelSyncRetries = 3;
  static const int _channelSyncTimeoutMs = 2000; // 2 second timeout per channel
  static const Duration _batteryPollInterval = Duration(seconds: 120);

  // Services
  MessageRetryService? _retryService;
  PathHistoryService? _pathHistoryService;
  AppSettingsService? _appSettingsService;
  BackgroundService? _backgroundService;
  final NotificationService _notificationService = NotificationService();
  BleDebugLogService? _bleDebugLogService;
  AppDebugLogService? _appDebugLogService;
  final ChannelMessageStore _channelMessageStore = ChannelMessageStore();
  final MessageStore _messageStore = MessageStore();
  final ChannelOrderStore _channelOrderStore = ChannelOrderStore();
  final ChannelSettingsStore _channelSettingsStore = ChannelSettingsStore();
  final ChannelRegionStore _channelRegionStore = ChannelRegionStore();
  final ContactSettingsStore _contactSettingsStore = ContactSettingsStore();
  final ContactStore _contactStore = ContactStore();
  final ContactDiscoveryStore _discoveryContactStore = ContactDiscoveryStore();
  final ChannelStore _channelStore = ChannelStore();
  final UnreadStore _unreadStore = UnreadStore();
  List<Channel> _cachedChannels = [];
  final Map<int, bool> _channelSmazEnabled = {};
  final Map<int, bool> _channelCyr2LatEnabled = {};
  final Map<int, bool> _channelUrlImagesEnabled = {};
  final Map<int, String?> _channelCyr2LatProfileId = {};
  final Map<int, Region> _channelRegions = {};
  bool _lastSentWasCliCommand =
      false; // Track if last sent message was a CLI command
  final Map<String, bool> _contactSmazEnabled = {};
  final Map<String, bool> _contactCyr2LatEnabled = {};
  final Map<String, bool> _contactUrlImagesEnabled = {};
  final Map<String, String?> _contactCyr2LatProfileId = {};
  final Set<String> _knownContactKeys = {};
  final Map<String, int> _contactUnreadCount = {};

  /// App-owned cache; optional for headless connectors and tests.
  NodeTelemetryStore? telemetryStore;

  /// Where repeater battery readings are kept over time; set by the app.
  RepeaterBatteryHistory? batteryHistory;
  final Map<String, RepeaterBatterySnapshot> _repeaterBatterySnapshots = {};
  bool _unreadStateLoaded = false;
  int _cachedContactsUnreadTotal = 0;
  int _cachedChannelsUnreadTotal = 0;
  final Map<String, _RepeaterAckContext> _pendingRepeaterAcks = {};
  String? _activeContactKey;
  int? _activeChannelIndex;
  List<int> _channelOrder = [];

  int _storageUsedKb = -1;
  int _storageTotalKb = -1;

  // Getters
  MeshCoreConnectionState get state => _state;
  BluetoothDevice? get device => _device;
  String? get deviceId => _deviceId;
  String get deviceIdLabel => _deviceId ?? 'Unknown';

  /// Stable per-radio key for transport-agnostic per-device settings such as
  /// battery chemistry. On BLE this is the existing remoteId (so previously
  /// saved settings are preserved); on USB/TCP — where there is no BLE
  /// remoteId — it falls back to the node's public key, which identifies the
  /// same physical radio across transports. Null until a device identity is
  /// known.
  String? get batteryDeviceKey {
    if (_deviceId != null) return _deviceId;
    if (_selfPublicKey != null && _selfPublicKey!.isNotEmpty) {
      return selfPublicKeyHex;
    }
    return null;
  }

  MeshCoreTransportType get activeTransport => _activeTransport;
  String? get activeUsbPort => _usbManager.activePortKey;
  String? get activeUsbPortDisplayLabel => _usbManager.activePortDisplayLabel;
  bool get isUsbTransportConnected =>
      _state == MeshCoreConnectionState.connected &&
      _activeTransport == MeshCoreTransportType.usb;
  bool get isAutoReconnectScheduled =>
      _shouldAutoReconnect && (_reconnectTimer?.isActive ?? false);

  /// Whether the Bluetooth adapter is known to be off (or turning off).
  /// False while the adapter state is unknown, e.g. on web or before the
  /// first platform report.
  bool get isBluetoothOff =>
      _adapterState == BluetoothAdapterState.off ||
      _adapterState == BluetoothAdapterState.turningOff;

  /// Human-readable cause of the last failed or dropped radio connection.
  /// Cleared when a connection succeeds.
  String? get lastConnectionError => _lastConnectionError;

  /// SNR (dB) of the last packet the radio heard, from LOG_RX_DATA.
  double? get lastRxSnr => _lastRxSnr;

  /// RSSI (dBm) of the last packet the radio heard, from LOG_RX_DATA.
  int? get lastRxRssi => _lastRxRssi;
  DateTime? get lastRxSignalAt => _lastRxSignalAt;

  /// Public key prefix (first 6 bytes, hex) of the connected radio.
  String? get selfPublicKeyPrefixHex {
    final key = _selfPublicKey;
    if (key == null || key.isEmpty) return null;
    return pubKeyToHex(key.sublist(0, key.length < 6 ? key.length : 6));
  }

  /// The last radio this app connected to, or null. Never secrets: only the
  /// transport and its address.
  SavedRadio? get savedRadio {
    final prefs = _prefsOrNull;
    return prefs == null ? null : SavedRadio.load(prefs, slot: slot);
  }

  /// Replaces the platform BLE link steps (connect, MTU, discovery, notify)
  /// in tests, so connection bookkeeping can run without a radio.
  @visibleForTesting
  Future<void> Function(BluetoothDevice device)? debugBleLinkOverride;

  /// Replaces the TCP/USB reconnect attempt; for tests.
  @visibleForTesting
  Future<void> Function(LinkTarget target)? debugLinkReconnectOverride;

  /// The TCP endpoint or USB port a dropped link will be retried on.
  LinkTarget? get reconnectTarget => _linkTarget;

  /// Marks [target] as the link to retry, as a successful connect would;
  /// for tests.
  @visibleForTesting
  void debugRememberLink(LinkTarget target) {
    _linkTarget = target;
    _manualDisconnect = false;
  }

  /// Replaces the platform BLE disconnect in tests.
  @visibleForTesting
  Future<void> Function(BluetoothDevice device)? debugBleUnlinkOverride;

  String? get activeTcpEndpoint => _tcpConnector.activeEndpoint;
  bool get isTcpTransportConnected =>
      _state == MeshCoreConnectionState.connected &&
      _activeTransport == MeshCoreTransportType.tcp;

  String get deviceDisplayName {
    if (_selfName != null && _selfName!.isNotEmpty) {
      return _selfName!;
    }
    final platformName = _device?.platformName;
    if (platformName != null && platformName.isNotEmpty) {
      return platformName;
    }
    if (_deviceDisplayName != null && _deviceDisplayName!.isNotEmpty) {
      return _deviceDisplayName!;
    }
    return 'Unknown Device';
  }

  List<ScanResult> get scanResults => List.unmodifiable(_scanResults);
  List<Contact> get contacts {
    final selfKey = _selfPublicKey;
    if (selfKey == null) {
      return List.unmodifiable(_contacts);
    }
    return List.unmodifiable(
      _contacts.where((contact) => !listEquals(contact.publicKey, selfKey)),
    );
  }

  Contact? getContactByPubKeyHex(String contactPubKeyHex) {
    return _contacts.cast<Contact?>().firstWhere(
      (c) => c?.publicKeyHex == contactPubKeyHex,
      orElse: () => null,
    );
  }

  List<Contact> get allContacts => List.unmodifiable([
    ..._contacts,
    ..._discoveredContacts.where(
      (c) => !c.isActive && c.publicKeyHex != selfPublicKeyHex,
    ),
  ]);

  List<Contact> get allContactsUnfiltered =>
      List.unmodifiable([..._contacts, ..._discoveredContacts]);

  List<Contact> get discoveredContacts {
    return List.unmodifiable(_discoveredContacts);
  }

  List<Channel> get channels => List.unmodifiable(_channels);
  bool get isConnected => _state == MeshCoreConnectionState.connected;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get hasLoadedContacts => _hasLoadedContacts;
  bool get isLoadingChannels => _isLoadingChannels;
  bool get hasLoadedChannels => _hasLoadedChannels;
  Stream<Uint8List> get receivedFrames => _receivedFramesController.stream;

  /// Fresh direct-message events; cached history and reconnect sync are excluded.
  Stream<Message> get receivedDirectMessages =>
      _receivedDirectMessagesController.stream;

  /// Incoming channel messages on channels that aren't muted.
  Stream<ReceivedChannelMessage> get receivedChannelMessages =>
      _receivedChannelMessagesController.stream;

  /// New channel messages heard over the radio, as they arrive: not muted
  /// or translated first, and never MQTT copies. For the bot.
  Stream<ChannelMessage> get radioChannelMessages =>
      _radioChannelMessagesController.stream;
  Uint8List? get selfPublicKey => _selfPublicKey;
  String get selfPublicKeyHex => pubKeyToHex(_selfPublicKey ?? Uint8List(0));

  /// First 2 bytes of the local public key, big-endian: the `senderPrefix`
  /// stamped into every outgoing image chunk header. Null until SELF_INFO.
  int? get imageSenderPrefix => senderPrefixFromKey(_selfPublicKey);

  String? get selfName => _selfName;
  String? get manufacturerName => _manufacturerName;
  String? get firmwareVersionString => _firmwareVersionString;
  double? get selfLatitude => _selfLatitude;
  double? get selfLongitude => _selfLongitude;
  List<DirectRepeater> get directRepeaters => _directRepeaters;
  int? get currentTxPower => _currentTxPower;
  int? get maxTxPower => _maxTxPower;

  int get pathHashByteWidth => _pathHashByteWidth;

  CompanionRadioStats? get latestRadioStats => _latestRadioStats;

  /// Contacts you sent a direct message to in the last [within].
  List<Contact> recentlyMessagedContacts({
    Duration within = const Duration(days: 7),
  }) {
    final since = DateTime.now().subtract(within);
    final keys = <String>{
      for (final e in _conversations.entries)
        if (e.value.any((m) => m.isOutgoing && m.timestamp.isAfter(since)))
          e.key,
    };
    return [
      for (final c in _contacts)
        if (keys.contains(c.publicKeyHex)) c,
    ];
  }

  final List<AirtimeSample> _airtimeSamples = [];

  /// Recent airtime counter readings (about the last half hour), for how
  /// busy the channel has been.
  List<AirtimeSample> get airtimeSamples => List.unmodifiable(_airtimeSamples);

  /// Direct messages sent in the last [within] that were acknowledged, and
  /// those that gave up.
  ({int delivered, int failed}) recentDirectDeliveries({
    Duration within = const Duration(hours: 24),
  }) {
    final since = DateTime.now().subtract(within);
    var delivered = 0, failed = 0;
    for (final list in _conversations.values) {
      for (final m in list) {
        if (!m.isOutgoing || m.timestamp.isBefore(since)) continue;
        if (m.status == MessageStatus.delivered) delivered++;
        if (m.status == MessageStatus.failed) failed++;
      }
    }
    return (delivered: delivered, failed: failed);
  }

  bool get supportsCompanionRadioStats => (_firmwareVerCode ?? 0) >= 8;

  /// True when the connected companion has a text CLI (firmware v14+).
  bool get supportsCompanionCli =>
      isConnected &&
      (_firmwareVerCode ?? 0) >= minFirmwareVerCodeForCompanionCli;

  bool get radioStatsAirActivityPulse {
    final sw = _airtimeBumpStopwatch;
    if (sw == null || !sw.isRunning) return false;
    return sw.elapsed < const Duration(seconds: 2);
  }

  int? get currentFreqHz => _currentFreqHz;

  /// Whether the radio is on the EU 863–870 MHz band, where duty-cycle
  /// limits make every extra packet count.
  bool get isOnEuDutyCycleBand {
    final hz = _currentFreqHz;
    return hz != null && hz >= 863000000 && hz <= 870000000;
  }

  /// Whether a reaction is sent over the radio, or only shown on this
  /// device. 'auto' keeps reactions local on the EU duty-cycle band.
  bool get sendsReactionsOverRadio =>
      switch (_appSettingsService?.settings.reactionsOverRadio) {
        'on' => true,
        'off' => false,
        _ => !isOnEuDutyCycleBand,
      };
  int? get currentBwHz => _currentBwHz;
  int? get currentSf => _currentSf;
  int? get currentCr => _currentCr;
  MeshCoreRadioStateSnapshot? get rememberedNonRepeatRadioState =>
      _rememberedNonRepeatRadioState;
  bool? get autoAddUsers => _autoAddUsers;
  bool? get autoAddRepeaters => _autoAddRepeaters;
  bool? get autoAddRoomServers => _autoAddRoomServers;
  bool? get autoAddSensors => _autoAddSensors;
  bool? get autoAddOverwriteOldest => _overwriteOldest;
  int get telemetryModeBase => _telemetryModeBase;
  int get telemetryModeLoc => _telemetryModeLoc;
  int get telemetryModeEnv => _telemetryModeEnv;
  int get advertLocationPolicy => _advertLocPolicy;
  int get multiAcks => _multiAcks;
  bool? get clientRepeat => _clientRepeat;

  /// Returns the repeater's RTC clock at the time of the most recent
  /// successful login, looked up by the contact's full public key.
  /// Returns null if no login response has been observed for this repeater
  /// since connection.
  DateTime? repeaterClockAtLogin(Uint8List publicKey) {
    if (publicKey.length < 6) return null;
    final prefix = pubKeyToHex(publicKey.sublist(0, 6));
    return _repeaterLoginClocks[prefix];
  }

  void rememberNonRepeatRadioState(MeshCoreRadioStateSnapshot snapshot) {
    _rememberedNonRepeatRadioState = snapshot;
  }

  int? get firmwareVerCode => _firmwareVerCode;

  /// Null until probed after SELF_INFO; true only on Flood Corridor firmware.
  bool? get floodCorridorSupported => _floodCorridorSupported;

  /// Compat region corridor packets are tagged with; empty means "#corridor".
  String? get corridorRegion => _corridorRegion;
  Map<String, String>? get currentCustomVars => _currentCustomVars;
  int? get batteryMillivolts => _batteryMillivolts;
  int? get storageUsedKb => _storageUsedKb;
  int? get storageTotalKb => _storageTotalKb;
  int get maxContacts => _maxContacts;

  /// Whether [maxContacts] came from the radio's device info rather than the
  /// built-in default, so a fullness warning can trust it.
  bool get maxContactsReported => _maxContactsReported;
  int get maxChannels => _maxChannels;
  Set<String> get knownContactKeys => Set.unmodifiable(_knownContactKeys);

  /// True when the last contact sync got no answer from the radio and gave
  /// up; saved contacts are still shown.
  bool get contactSyncStalled => _contactSyncStalled;

  /// Asks the radio for its contacts again after a stalled sync.
  Future<void> retryContactSync() => getContacts(preserveExisting: true);

  double? get contactSyncProgress {
    final total = _contactSyncTotal;
    if (!_isLoadingContacts || total == null || total <= 0) return null;
    return (_contactSyncReceived / total).clamp(0.0, 1.0).toDouble();
  }

  bool get isSyncingQueuedMessages =>
      _isSyncingQueuedMessages || _isProcessingDeferredQueuedContactMessages;
  bool get isShowingQueuedMessageSyncProgress =>
      _deferQueuedContactMessagesUntilContacts && isSyncingQueuedMessages;
  bool get isSyncingChannels => _isSyncingChannels;
  int get channelSyncProgress =>
      _isSyncingChannels && _totalChannelsToRequest > 0
      ? ((_nextChannelIndexToRequest / _totalChannelsToRequest) * 100).round()
      : 0;
  int? get batteryPercent => _batteryMillivolts == null
      ? null
      : estimateBatteryPercentFromMillivolts(
          _batteryMillivolts!,
          _batteryChemistryForDevice(),
        );
  RepeaterBatterySnapshot? getRepeaterBatterySnapshot(String contactKeyHex) =>
      _repeaterBatterySnapshots[contactKeyHex];
  int? getRepeaterBatteryMillivolts(String contactKeyHex) =>
      _repeaterBatterySnapshots[contactKeyHex]?.millivolts;

  void updateRepeaterBatterySnapshot(
    String contactKeyHex,
    int millivolts, {
    String source = 'unknown',
  }) {
    if (contactKeyHex.isEmpty || millivolts <= 0) return;
    final previous = _repeaterBatterySnapshots[contactKeyHex];
    final snapshot = RepeaterBatterySnapshot(
      millivolts: millivolts,
      updatedAt: DateTime.now(),
      source: source,
    );
    _repeaterBatterySnapshots[contactKeyHex] = snapshot;
    batteryHistory?.record(contactKeyHex, millivolts);
    telemetryStore?.record(
      contactKeyHex,
      [
        {
          'channel': 0,
          'type': CayenneLpp.lppVoltage,
          'value': millivolts / 1000.0,
        },
      ],
      source: source == 'telemetry'
          ? TelemetrySource.telemetry
          : TelemetrySource.status,
    );

    if (previous?.millivolts != millivolts) {
      notifyListeners();
    }
  }

  String _batteryChemistryForDevice() {
    final deviceId = batteryDeviceKey;
    if (deviceId == null || _appSettingsService == null) return 'nmc';
    return _appSettingsService!.batteryChemistryForDevice(deviceId);
  }

  List<Message> getMessages(Contact contact) {
    return _conversations[contact.publicKeyHex] ?? [];
  }

  /// Puts [message] in its conversation, for tests.
  @visibleForTesting
  void debugAddMessage(Message message) {
    _conversations.putIfAbsent(message.senderKeyHex, () => []).add(message);
  }

  Future<void> deleteMessage(Message message) async {
    final contactKeyHex = message.senderKeyHex;
    final messages = _conversations[contactKeyHex];
    if (messages == null) return;
    final removed = messages.remove(message);
    if (!removed) return;
    _retryService?.untrack(message.messageId);
    await _messageStore.saveMessages(contactKeyHex, messages);
    notifyListeners();
  }

  /// Sends [message] again as a new message and removes the old one.
  /// Returns false, keeping the message and marking it failed, when the
  /// radio is disconnected: deleting it then would lose it, since nothing
  /// can be sent.
  Future<bool> resendMessage(Contact contact, Message message) async {
    if (!isConnected) {
      if (message.status != MessageStatus.failed) {
        _updateMessage(message.copyWith(status: MessageStatus.failed));
      }
      return false;
    }
    await deleteMessage(message);
    await sendMessage(
      contact,
      message.text,
      originalText: message.originalText,
      translatedLanguageCode: message.translatedLanguageCode,
      translationModelId: message.translationModelId,
    );
    return true;
  }

  /// Load older messages for a contact (pagination)
  Future<List<Message>> loadOlderMessages(
    String contactKeyHex, {
    int count = 50,
  }) async {
    final allMessages = await _messageStore.loadMessages(contactKeyHex);
    final currentMessages = _conversations[contactKeyHex] ?? [];

    if (allMessages.length <= currentMessages.length) {
      return []; // No more messages to load
    }

    final currentOffset = allMessages.length - currentMessages.length;
    final fetchCount = count.clamp(0, currentOffset);
    final startIndex = currentOffset - fetchCount;

    final olderMessages = allMessages.sublist(startIndex, currentOffset);

    // Prepend to current conversation
    _conversations[contactKeyHex] = [...olderMessages, ...currentMessages];
    notifyListeners();

    return olderMessages;
  }

  List<ChannelMessage> getChannelMessages(Channel channel) {
    return _channelMessages[channel.index] ?? [];
  }

  Future<void> deleteChannelMessage(ChannelMessage message) async {
    final channelIndex = message.channelIndex;
    if (channelIndex == null) return;
    final messages = _channelMessages[channelIndex];
    if (messages == null) return;
    final removed = messages.remove(message);
    if (!removed) return;
    await _channelMessageStore.saveChannelMessages(channelIndex, messages);
    notifyListeners();
  }

  int getUnreadCountForContact(Contact contact) {
    if (contact.type == advTypeRepeater) return 0;
    return getUnreadCountForContactKey(contact.publicKeyHex);
  }

  int getUnreadCountForContactKey(String contactKeyHex) {
    if (!_unreadStateLoaded) return 0;
    if (!_shouldTrackUnreadForContactKey(contactKeyHex)) return 0;
    return _contactUnreadCount[contactKeyHex] ?? 0;
  }

  int getUnreadCountForChannel(Channel channel) {
    return getUnreadCountForChannelIndex(channel.index);
  }

  int getUnreadCountForChannelIndex(int channelIndex) {
    if (!_unreadStateLoaded) return 0;
    return _findChannelByIndex(channelIndex)?.unreadCount ?? 0;
  }

  int getTotalUnreadCount() {
    if (!_unreadStateLoaded) return 0;
    return getTotalContactsUnreadCount() + getTotalChannelsUnreadCount();
  }

  int getTotalContactsUnreadCount() {
    if (!_unreadStateLoaded) return 0;
    return _cachedContactsUnreadTotal;
  }

  int getTotalChannelsUnreadCount() {
    if (!_unreadStateLoaded) return 0;
    return _cachedChannelsUnreadTotal;
  }

  bool isChannelSmazEnabled(int channelIndex) {
    return _channelSmazEnabled[channelIndex] ?? false;
  }

  bool isContactSmazEnabled(String contactKeyHex) {
    return _contactSmazEnabled[contactKeyHex] ?? false;
  }

  bool isChannelUrlImagesEnabled(int channelIndex) {
    return _channelUrlImagesEnabled[channelIndex] ?? false;
  }

  bool isContactUrlImagesEnabled(String contactKeyHex) {
    _ensureContactUrlImagesSettingLoaded(contactKeyHex);
    return _contactUrlImagesEnabled[contactKeyHex] ?? false;
  }

  /// Region names a scoped message can be matched against: the bundled
  /// region trees plus any region set on a channel here.
  Set<String> _knownRegionNames() => {
    ..._bundledRegionNames,
    for (final r in _channelRegions.values)
      if (r.isNotEmpty) r,
  };

  /// Names from `assets/region_trees.json`, loaded once at start.
  Set<String> _bundledRegionNames = const {};

  @visibleForTesting
  set debugRegionNames(Set<String> names) => _bundledRegionNames = names;

  bool hasChannelRegion(int channelIndex) {
    return (_channelRegions[channelIndex] ?? '').isNotEmpty;
  }

  Region getChannelRegion(int channelIndex) {
    return _channelRegions[channelIndex] ?? '';
  }

  void ensureContactSmazSettingLoaded(String contactKeyHex) {
    _ensureContactSmazSettingLoaded(contactKeyHex);
  }

  bool isChannelCyr2LatEnabled(int channelIndex) {
    _ensureChannelCyr2LatSettingLoaded(channelIndex);
    return _channelCyr2LatEnabled[channelIndex] ?? false;
  }

  bool isContactCyr2LatEnabled(String contactKeyHex) {
    _ensureContactCyr2LatSettingLoaded(contactKeyHex);
    return _contactCyr2LatEnabled[contactKeyHex] ?? false;
  }

  void ensureContactCyr2LatSettingLoaded(String contactKeyHex) {
    _ensureContactCyr2LatSettingLoaded(contactKeyHex);
  }

  Future<void> loadUnreadState() async {
    _contactUnreadCount
      ..clear()
      ..addAll(await _unreadStore.loadContactUnreadCount());
    _unreadStateLoaded = true;
    _recalculateCachedUnreadTotals();
    notifyListeners();
  }

  Future<void> loadCachedChannels() async {
    _cachedChannels = await _channelStore.loadChannels();
    _recalculateCachedChannelsUnreadTotal();
  }

  void setActiveContact(String? contactKeyHex) {
    if (contactKeyHex != null &&
        !_shouldTrackUnreadForContactKey(contactKeyHex)) {
      _activeContactKey = null;
      return;
    }
    _activeContactKey = contactKeyHex;
    if (contactKeyHex != null) {
      markContactRead(contactKeyHex);
    }
  }

  void setActiveChannel(int? channelIndex) {
    _activeChannelIndex = channelIndex;
    if (channelIndex != null) {
      markChannelRead(channelIndex);
    }
  }

  void markContactRead(String contactKeyHex) {
    if (!_shouldTrackUnreadForContactKey(contactKeyHex)) return;
    final previousCount = _contactUnreadCount[contactKeyHex] ?? 0;
    if (previousCount > 0) {
      _contactUnreadCount[contactKeyHex] = 0;
      _cachedContactsUnreadTotal = (_cachedContactsUnreadTotal - previousCount)
          .clamp(0, _cachedContactsUnreadTotal);
      _appDebugLogService?.info(
        'Contact $contactKeyHex marked as read (was $previousCount unread)',
        tag: 'Unread',
      );
      _unreadStore.saveContactUnreadCount(
        Map<String, int>.from(_contactUnreadCount),
      );
      _notificationService.clearContactNotification(
        contactKeyHex,
        getTotalUnreadCount(),
        radio: slot,
      );
      notifyListeners();
    }
  }

  void setContactUnreadCount(String contactKeyHex, int count) {
    _contactUnreadCount[contactKeyHex] = count;
    _unreadStore.saveContactUnreadCount(
      Map<String, int>.from(_contactUnreadCount),
    );
    notifyListeners();
  }

  void setChannelUnreadCount(int channelIndex, int count) {
    final channel = _findChannelByIndex(channelIndex);
    if (channel != null) {
      channel.unreadCount = count;
      unawaited(
        _channelStore.saveChannels(
          _channels.isNotEmpty ? _channels : _cachedChannels,
        ),
      );
      notifyListeners();
    }
  }

  void markChannelRead(int channelIndex) {
    final channel = _findChannelByIndex(channelIndex);
    if (channel != null && channel.unreadCount > 0) {
      final previousCount = channel.unreadCount;
      channel.unreadCount = 0;
      _cachedChannelsUnreadTotal = (_cachedChannelsUnreadTotal - previousCount)
          .clamp(0, _cachedChannelsUnreadTotal);
      _appDebugLogService?.info(
        'Channel ${channel.name.isNotEmpty ? channel.name : channelIndex} marked as read (was $previousCount unread)',
        tag: 'Unread',
      );
      unawaited(
        _channelStore.saveChannels(
          _channels.isNotEmpty ? _channels : _cachedChannels,
        ),
      );
      _notificationService.clearChannelNotification(
        channelIndex,
        getTotalUnreadCount(),
        radio: slot,
      );
      notifyListeners();
    }
  }

  Future<void> setChannelSmazEnabled(int channelIndex, bool enabled) async {
    _channelSmazEnabled[channelIndex] = enabled;
    if (enabled) {
      _channelCyr2LatEnabled[channelIndex] = false;
      await _channelSettingsStore.saveCyr2LatEnabled(channelIndex, false);
    }
    await _channelSettingsStore.saveSmazEnabled(channelIndex, enabled);
    notifyListeners();
  }

  Future<void> setContactSmazEnabled(String contactKeyHex, bool enabled) async {
    _contactSmazEnabled[contactKeyHex] = enabled;
    await _contactSettingsStore.saveSmazEnabled(contactKeyHex, enabled);
    notifyListeners();
  }

  Future<void> setChannelUrlImagesEnabled(
    int channelIndex,
    bool enabled,
  ) async {
    _channelUrlImagesEnabled[channelIndex] = enabled;
    await _channelSettingsStore.saveUrlImagesEnabled(channelIndex, enabled);
    notifyListeners();
  }

  Future<void> setContactUrlImagesEnabled(
    String contactKeyHex,
    bool enabled,
  ) async {
    _contactUrlImagesEnabled[contactKeyHex] = enabled;
    await _contactSettingsStore.saveUrlImagesEnabled(contactKeyHex, enabled);
    notifyListeners();
  }

  Future<void> setChannelCyr2LatEnabled(int channelIndex, bool enabled) async {
    _channelCyr2LatEnabled[channelIndex] = enabled;
    if (enabled) {
      _channelSmazEnabled[channelIndex] = false;
      await _channelSettingsStore.saveSmazEnabled(channelIndex, false);
    }
    await _channelSettingsStore.saveCyr2LatEnabled(channelIndex, enabled);
    notifyListeners();
  }

  Future<void> setContactCyr2LatEnabled(
    String contactKeyHex,
    bool enabled,
  ) async {
    _contactCyr2LatEnabled[contactKeyHex] = enabled;
    await _contactSettingsStore.saveCyr2LatEnabled(contactKeyHex, enabled);
    notifyListeners();
  }

  Future<void> setChannelRegion(int channelIndex, String region) async {
    // Update in-memory state and notify synchronously so the UI reflects the
    // change immediately; persistence happens in the background.
    _channelRegions[channelIndex] = region;
    notifyListeners();
    await _channelRegionStore.saveRegion(channelIndex, region);
  }

  /// A conversation's whole saved history plus anything newer in memory,
  /// for search. Doesn't change what the chat screen has loaded.
  Future<List<Message>> loadFullConversation(Contact contact) async {
    final saved = await _messageStore.loadMessages(contact.publicKeyHex);
    return _mergeHistory(saved, getMessages(contact), (m) => m.messageId);
  }

  /// A channel's whole saved history plus anything newer in memory.
  Future<List<ChannelMessage>> loadFullChannelHistory(Channel channel) async {
    final saved = await _channelMessageStore.loadChannelMessages(channel.index);
    return _mergeHistory(
      saved,
      _channelMessages[channel.index] ?? const <ChannelMessage>[],
      (m) => m.messageId,
    );
  }

  static List<T> _mergeHistory<T>(
    List<T> saved,
    List<T> memory,
    String Function(T) id,
  ) {
    final seen = saved.map(id).toSet();
    return [...saved, ...memory.where((m) => !seen.contains(id(m)))];
  }

  /// Points the channel message store at [selfKeyHex]'s data and uses
  /// [settings], as connecting to that radio would.
  /// Feeds a companion stats frame, as the radio would.
  @visibleForTesting
  void debugHandleStatsFrame(Uint8List frame) => _handleStatsFrame(frame);

  /// Sets the radio frequency as a self-info reply would.
  @visibleForTesting
  void debugSetFrequencyHz(int? hz) => _currentFreqHz = hz;

  @visibleForTesting
  void debugUseChannelStore(String selfKeyHex, AppSettingsService settings) {
    _channelMessageStore.setPublicKeyHex = selfKeyHex;
    _appSettingsService = settings;
  }

  /// The auto-delete cutoff from settings, or null to keep everything.
  DateTime? get _channelRetentionCutoff {
    final days = _appSettingsService?.settings.channelMessageRetentionDays ?? 0;
    if (days <= 0) return null;
    return DateTime.now().subtract(Duration(days: days));
  }

  /// Deletes channel messages older than the auto-delete setting, saved and
  /// in memory. Returns how many were deleted.
  Future<int> pruneOldChannelMessages({int? maxChannels}) async {
    final cutoff = _channelRetentionCutoff;
    if (cutoff == null) return 0;
    var removed = 0;
    for (var i = 0; i < (maxChannels ?? _maxChannels); i++) {
      final saved = await _channelMessageStore.loadChannelMessages(i);
      final kept = keepChannelMessagesSince(saved, cutoff);
      if (kept.length != saved.length) {
        removed += saved.length - kept.length;
        await _channelMessageStore.saveChannelMessages(i, kept);
      }
      final memory = _channelMessages[i];
      if (memory != null) {
        _channelMessages[i] = keepChannelMessagesSince(memory, cutoff);
      }
    }
    if (removed > 0) {
      appLogger.info('Auto-deleted $removed old channel messages');
      notifyListeners();
    }
    return removed;
  }

  /// Load older channel messages (pagination)
  Future<List<ChannelMessage>> loadOlderChannelMessages(
    int channelIndex, {
    int count = 50,
  }) async {
    final allMessages = await _channelMessageStore.loadChannelMessages(
      channelIndex,
    );
    final currentMessages = _channelMessages[channelIndex] ?? [];

    if (allMessages.length <= currentMessages.length) {
      return []; // No more messages to load
    }

    final currentOffset = allMessages.length - currentMessages.length;
    final fetchCount = count.clamp(0, currentOffset);
    final startIndex = currentOffset - fetchCount;

    final olderMessages = allMessages.sublist(startIndex, currentOffset);

    // Prepend to current conversation
    _channelMessages[channelIndex] = [...olderMessages, ...currentMessages];
    notifyListeners();

    return olderMessages;
  }

  /// Load all persisted channel messages on startup
  Future<void> loadAllChannelMessages({int? maxChannels}) async {
    final channelCount = maxChannels ?? _maxChannels;
    // Load messages for all known channels (0-7 by default)
    for (int i = 0; i < channelCount; i++) {
      await _loadChannelMessages(i);
    }
  }

  void initialize({
    required MessageRetryService retryService,
    required PathHistoryService pathHistoryService,
    AppSettingsService? appSettingsService,
    TranslationService? translationService,
    BleDebugLogService? bleDebugLogService,
    AppDebugLogService? appDebugLogService,
    BackgroundService? backgroundService,
    TimeoutPredictionService? timeoutPredictionService,
    ImageCodecService? imageCodecService,
    ImageChunkTransport? imageTransport,
    void Function(ImageChunkOutcome outcome)? onImageChunk,
    void Function(int senderPrefix)? onImageSenderPrefix,
  }) {
    _retryService = retryService;
    _pathHistoryService = pathHistoryService;
    _appSettingsService = appSettingsService;
    _translationService = translationService;
    _imageCodecService = imageCodecService;
    _imageTransport = imageTransport;
    _onImageChunk = onImageChunk;
    _onImageSenderPrefix = onImageSenderPrefix;
    _bleDebugLogService = bleDebugLogService;
    _appDebugLogService = appDebugLogService;
    _backgroundService = backgroundService;
    _timeoutPredictionService = timeoutPredictionService;
    _usbManager.setDebugLogService(_appDebugLogService);
    _tcpConnector.setDebugLogService(_appDebugLogService);
    _watchBluetoothAdapter();

    // Initialize notification service
    _notificationService.initialize();
    unawaited(_loadBundledRegionNames());
    _loadChannelOrder();

    // Initialize retry service callbacks
    _retryService?.initialize(
      RetryServiceConfig(
        sendMessage: _sendMessageDirect,
        addMessage: _addMessage,
        updateMessage: _updateMessage,
        clearContactPath: clearContactPath,
        setContactPath: setContactPath,
        calculateTimeout:
            (
              pathLength,
              messageBytes, {
              String? contactKey,
              int? deviceTimeoutMs,
            }) => calculateTimeout(
              pathLength: pathLength,
              messageBytes: messageBytes,
              contactKey: contactKey,
              deviceTimeoutMs: deviceTimeoutMs,
            ),
        getSelfPublicKey: () => _selfPublicKey,
        prepareContactOutboundText: prepareContactOutboundText,
        appSettingsService: appSettingsService,
        debugLogService: _appDebugLogService,
        recordPathResult: _recordPathResult,
        selectRetryPath:
            (contactKey, attemptIndex, maxRetries, recentSelections) =>
                _selectAutoPathForAttempt(
                  contactKey,
                  attemptIndex: attemptIndex,
                  maxRetries: maxRetries,
                  recentSelections: recentSelections,
                ),
        onDeliveryObserved: (contactKey, pathLength, messageBytes, tripTimeMs) {
          final secSinceRx = DateTime.now()
              .difference(_lastRxBeforeFrame)
              .inSeconds;
          _timeoutPredictionService?.recordObservation(
            contactKey: contactKey,
            pathLength: pathLength,
            messageBytes: messageBytes,
            tripTimeMs: tripTimeMs,
            secondsSinceLastRx: secSinceRx,
          );
        },
      ),
    );
    final maxRetries = _appSettingsService?.settings.maxMessageRetries ?? 5;
    _retryService?.setMaxRetries(maxRetries);
  }

  Future<void> loadContactCache() async {
    _contactUrlImagesEnabled.clear();
    final cached = await _contactStore.loadContacts();
    _knownContactKeys
      ..clear()
      ..addAll(cached.map((c) => c.publicKeyHex));
    _contacts
      ..clear()
      ..addAll(cached);
    for (final contact in cached) {
      _ensureContactSmazSettingLoaded(contact.publicKeyHex);
      _ensureContactCyr2LatSettingLoaded(contact.publicKeyHex);
      _ensureContactUrlImagesSettingLoaded(contact.publicKeyHex);
    }
  }

  Future<void> loadChannelSettings({int? maxChannels}) async {
    _channelSmazEnabled.clear();
    _channelCyr2LatEnabled.clear();
    _channelUrlImagesEnabled.clear();
    _channelRegions.clear();
    final channelCount = maxChannels ?? _maxChannels;
    for (int i = 0; i < channelCount; i++) {
      _channelSmazEnabled[i] = await _channelSettingsStore.loadSmazEnabled(i);
      _channelCyr2LatEnabled[i] = await _channelSettingsStore
          .loadCyr2LatEnabled(i);
      _channelUrlImagesEnabled[i] = await _channelSettingsStore
          .loadUrlImagesEnabled(i);
      _channelRegions[i] = await _channelRegionStore.loadRegion(i);
    }
  }

  /// 1.0 shortly after TX/RX airtime counters increase, decaying to 0 over ~8s.
  double _recentAirtimeBusyFraction() {
    final sw = _airtimeBumpStopwatch;
    if (sw == null || !sw.isRunning) return 0;
    final ms = sw.elapsedMilliseconds;
    const windowMs = 8000;
    if (ms >= windowMs) return 0;
    return 1.0 - (ms / windowMs);
  }

  Future<void> _waitForRadioQuiet({required DateTime lastInboundRxTime}) async {
    // Wait for backoff after inbound traffic / RF airtime (avoid collision with
    // mesh propagation). Elapsed time uses the dot's airtime bump when newer.
    final backoffTargetMs = _contactMessageBackoffTargetMs();
    final anchor = _postTxBackoffAnchor(lastInboundRxTime);
    final msSinceAnchor = DateTime.now().difference(anchor).inMilliseconds;
    if (msSinceAnchor < backoffTargetMs) {
      final waitMs = backoffTargetMs - msSinceAnchor;
      debugPrint(
        'Post-inbound backoff: waiting ${waitMs}ms '
        '(target=${backoffTargetMs}ms, anchorAge=${msSinceAnchor}ms)',
      );
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }

    // Then wait for radio silence (no RF activity for 3s)
    final msSinceRx = DateTime.now()
        .difference(_lastRadioRxTime)
        .inMilliseconds;
    if (msSinceRx >= _radioQuietMs) return;

    final deadline = DateTime.now().add(
      const Duration(milliseconds: _radioQuietMaxWaitMs),
    );
    while (DateTime.now().isBefore(deadline)) {
      final quiet = DateTime.now().difference(_lastRadioRxTime).inMilliseconds;
      if (quiet >= _radioQuietMs) {
        debugPrint('Radio quiet for ${quiet}ms, proceeding with send');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    debugPrint(
      'Radio quiet wait exceeded ${_radioQuietMaxWaitMs}ms, sending anyway',
    );
  }

  Future<TranslationResult?> translateContactMessage(
    String contactKeyHex,
    Message message, {
    bool manualTranslation = false,
  }) async {
    try {
      if (message.translatedText?.trim().isNotEmpty == true ||
          (!manualTranslation &&
              message.translationStatus != MessageTranslationStatus.none)) {
        return null;
      }
      final service = _translationService;
      if (service == null ||
          !(manualTranslation
              ? service.canTranslateIncoming(
                  text: message.text,
                  isCli: message.isCli,
                  isOutgoing: message.isOutgoing,
                )
              : service.shouldAutoTranslateIncoming(
                  text: message.text,
                  isCli: message.isCli,
                  isOutgoing: message.isOutgoing,
                ))) {
        return null;
      }
      final targetLanguageCode = service.resolvedIncomingLanguageCode(
        _appSettingsService?.settings.languageOverride,
      );
      final result = await service.translateIncomingText(
        text: message.text,
        targetLanguageCode: targetLanguageCode,
      );
      if (result == null) {
        return null;
      }
      final translated = result.status == MessageTranslationStatus.completed
          ? result.translatedText
          : null;
      _updateStoredContactMessage(
        contactKeyHex,
        message.messageId,
        (current) => current.copyWith(
          translatedText: translated,
          translatedLanguageCode: result.detectedLanguageCode,
          translationStatus: result.status,
          translationModelId: result.modelId,
        ),
      );
      return result;
    } catch (error) {
      appLogger.warn('Translation failed for contact message: $error');
      return null;
    }
  }

  Future<TranslationResult?> translateChannelMessage(
    int channelIndex,
    ChannelMessage message, {
    bool manualTranslation = false,
  }) async {
    try {
      if (message.translatedText?.trim().isNotEmpty == true ||
          (!manualTranslation &&
              message.translationStatus != MessageTranslationStatus.none)) {
        return null;
      }
      final service = _translationService;
      if (service == null ||
          !(manualTranslation
              ? service.canTranslateIncoming(
                  text: message.text,
                  isCli: false,
                  isOutgoing: message.isOutgoing,
                )
              : service.shouldAutoTranslateIncoming(
                  text: message.text,
                  isCli: false,
                  isOutgoing: message.isOutgoing,
                ))) {
        return null;
      }
      final targetLanguageCode = service.resolvedIncomingLanguageCode(
        _appSettingsService?.settings.languageOverride,
      );
      final result = await service.translateIncomingText(
        text: message.text,
        targetLanguageCode: targetLanguageCode,
      );
      if (result == null) {
        return null;
      }
      var translated = result.status == MessageTranslationStatus.completed
          ? result.translatedText
          : null;
      // Strip replyInfo prefix from translated text to match stored message.text
      if (translated != null) {
        final regex = RegExp(r'^@\[[^\]]+\]\s+', dotAll: true);
        translated = translated.replaceFirst(regex, '');
      }
      _updateStoredChannelMessage(
        channelIndex,
        message.messageId,
        (current) => current.copyWith(
          translatedText: translated,
          translatedLanguageCode: result.detectedLanguageCode,
          translationStatus: result.status,
          translationModelId: result.modelId,
        ),
      );
      return result;
    } catch (error) {
      appLogger.warn('Translation failed for channel message: $error');
      return null;
    }
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_state == MeshCoreConnectionState.scanning) return;

    // A BLE scan must never disturb an active (or in-progress) non-BLE
    // connection. The connection state enum is shared across transports, so
    // entering the `scanning` state while connected over TCP/USB would clobber
    // the live `connected` state and later reset it to `disconnected`.
    if (_state != MeshCoreConnectionState.disconnected ||
        _tcpConnector.isConnected ||
        _usbManager.isConnected) {
      _appDebugLogService?.warn(
        'startScan ignored: not idle (state=$_state, '
        'tcp=${_tcpConnector.isConnected}, usb=${_usbManager.isConnected})',
        tag: 'BLE Scan',
      );
      return;
    }

    _scanResults.clear();
    _linuxSystemScanResults.clear();
    _setState(MeshCoreConnectionState.scanning);

    // Ensure any previous scan is fully stopped. Guard with isScanningNow to
    // avoid triggering stale native callbacks when no scan is active.
    if (FlutterBluePlus.isScanningNow) {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        _appDebugLogService?.warn(
          'stopScan error in startScan (ignored): $e',
          tag: 'BLE Scan',
        );
      }
    }
    await _scanSubscription?.cancel();

    // On iOS/macOS, wait for Bluetooth to be powered on before scanning
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Wait for adapter state to be powered on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        // Wait for the adapter to turn on, with timeout
        await FlutterBluePlus.adapterState
            .firstWhere((state) => state == BluetoothAdapterState.on)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                _setState(MeshCoreConnectionState.disconnected);
                throw Exception('Bluetooth adapter not available');
              },
            );
      }

      // Add a small delay to allow BLE stack to fully initialize
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (PlatformInfo.isLinux) {
      await _loadLinuxSystemDevicesForScan();
    }

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults
        ..clear()
        ..addAll(results);
      _mergeLinuxSystemScanResults();
      _scheduleScanNotify();
    });

    try {
      // Filter by the Nordic UART Service UUID rather than by advertised
      // name. All MeshCore-compatible firmware (ESP32 + nRF52) advertises this
      // service UUID, so this matches every device regardless of the name it
      // chooses to advertise (e.g. community forks like the M5 Cardputer that
      // do not use a "MeshCore-" name prefix). This mirrors how the official
      // app discovers devices. Note: on Android `withKeywords` cannot be
      // combined with any other filter, which is why name keywords are not
      // used here.
      await FlutterBluePlus.startScan(
        withServices: [Guid(MeshCoreUuids.service)],
        webOptionalServices: [Guid(MeshCoreUuids.service)],
        timeout: timeout,
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (error) {
      _appDebugLogService?.warn('Scan/picker failure: $error', tag: 'BLE Scan');
      await stopScan();
      rethrow;
    }

    // Reset our shared state when the native scan ends — whether it was stopped
    // by the user (stopScan), by the platform timeout, or by Bluetooth turning
    // off. This replaces a blocking `Future.delayed(timeout)` tail that kept
    // startScan() pending for the whole timeout and made Stop appear ineffective.
    // `isScanning` is a re-emit stream that replays its latest value on listen,
    // so skip(1) to ignore that and only react to a genuine transition to false.
    await _isScanningSubscription?.cancel();
    _isScanningSubscription = FlutterBluePlus.isScanning.skip(1).listen((
      scanning,
    ) {
      if (!scanning && _state == MeshCoreConnectionState.scanning) {
        unawaited(stopScan());
      }
    });
  }

  /// Longest a fresh scan result waits before listeners hear about it.
  /// Radios advertise many times a second; notifying on each one rebuilt
  /// every screen listening to the connector and made the UI flicker.
  static const scanNotifyInterval = Duration(milliseconds: 300);
  Timer? _scanNotifyTimer;

  Future<void> stopScan() async {
    // Only call FlutterBluePlus.stopScan() when a scan is actually running.
    // Calling it when idle triggers a native BLE completion callback even
    // though no scan was started. After a hot restart Dart has already freed
    // those callback handles, so the callback crashes with
    // "Callback invoked after it has been deleted".
    if (FlutterBluePlus.isScanningNow) {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        _appDebugLogService?.warn(
          'stopScan error (ignored): $e',
          tag: 'BLE Scan',
        );
      }
    }
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _isScanningSubscription?.cancel();
    _isScanningSubscription = null;

    if (_state == MeshCoreConnectionState.scanning) {
      // Restore to `connected` if a non-BLE transport is still live, so a stray
      // scan can never tear down the reported connection state. Normally there
      // is no live transport here and we fall through to `disconnected`.
      final restored = (_tcpConnector.isConnected || _usbManager.isConnected)
          ? MeshCoreConnectionState.connected
          : MeshCoreConnectionState.disconnected;
      _setState(restored);
    }
  }

  Future<List<String>> listUsbPorts() => _usbManager.listPorts();

  void setUsbRequestPortLabel(String label) {
    _usbManager.setRequestPortLabel(label);
  }

  void setUsbFallbackDeviceName(String label) {
    _usbManager.setFallbackDeviceName(label);
  }

  Future<void> connectUsb({
    required String portName,
    int baudRate = 115200,
    bool automaticReconnect = false,
  }) async {
    final pendingDisconnect = _disconnectInFlight;
    if (pendingDisconnect != null) await pendingDisconnect;
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      _appDebugLogService?.warn(
        'connectUsb ignored: already $_state',
        tag: 'USB',
      );
      return;
    }

    _appDebugLogService?.info(
      'connectUsb: port=$portName baud=$baudRate',
      tag: 'USB',
    );

    await stopScan();
    _beginWiredConnect(automaticReconnect);
    _resetConnectionHandshakeState();
    _activeTransport = MeshCoreTransportType.usb;
    _setState(MeshCoreConnectionState.connecting);

    try {
      await _usbFrameSubscription?.cancel();
      _usbFrameSubscription = null;
      _appDebugLogService?.info('connectUsb: opening serial port…', tag: 'USB');
      await _usbManager.connect(portName: portName, baudRate: baudRate);
      _appDebugLogService?.info(
        'connectUsb: serial port opened, label=${_usbManager.activePortDisplayLabel}',
        tag: 'USB',
      );
      notifyListeners();
      if (PlatformInfo.isWeb) {
        await stopScan();
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // The read pump can fail the instant the port opens (e.g. a device that
      // re-enumerates on open). That error is emitted on a broadcast stream
      // before the listener below attaches, so it would otherwise be lost and
      // the connect would stall until the SELF_INFO timeout. Check transport
      // liveness directly and abort fast with the real cause.
      if (!_usbManager.isConnected) {
        final cause = _usbManager.lastError;
        throw StateError(
          'USB device disconnected during connect'
          '${cause == null ? '' : ': $cause'}',
        );
      }

      _usbFrameSubscription = _usbManager.frameStream.listen(
        _handleFrame,
        onError: (error, stackTrace) {
          _appDebugLogService?.error('USB transport error: $error', tag: 'USB');
          unawaited(disconnect(manual: false));
        },
        onDone: () {
          _appDebugLogService?.warn('USB frame stream ended', tag: 'USB');
          unawaited(disconnect(manual: false));
        },
      );

      _setState(MeshCoreConnectionState.connected);
      _pendingInitialChannelSync = true;
      _pendingInitialQueuedMessageSync = true;
      _pendingInitialContactsSync = true;
      _appDebugLogService?.info(
        'connectUsb: requesting device info…',
        tag: 'USB',
      );
      await _requestDeviceInfo();
      _startBatteryPolling();
      if (_radioStatsPollRefCount > 0) _startRadioStatsPolling();
      var gotSelfInfo = await _waitForSelfInfo(
        timeout: const Duration(seconds: 3),
      );
      if (!gotSelfInfo) {
        _appDebugLogService?.warn(
          'connectUsb: SELF_INFO timeout, retrying…',
          tag: 'USB',
        );
        await refreshDeviceInfo();
        gotSelfInfo = await _waitForSelfInfo(
          timeout: const Duration(seconds: 3),
        );
      }
      if (!gotSelfInfo) {
        throw StateError('Timed out waiting for SELF_INFO during connect');
      }

      _appDebugLogService?.info('connectUsb: syncing time…', tag: 'USB');
      await syncTime();
      _appDebugLogService?.info('connectUsb: complete', tag: 'USB');
      _lastConnectionError = null;
      _reconnectAttempts = 0;
      // Web serial ports can only be reopened from a user gesture.
      if (!PlatformInfo.isWeb) {
        _linkTarget = UsbLinkTarget(portName, baudRate);
      }
      unawaited(_rememberRadio(SavedRadioTransport.usb, portName));
    } catch (error) {
      _appDebugLogService?.error('USB connection error: $error', tag: 'USB');
      _lastConnectionError = describeConnectionError(error);
      await disconnect(manual: false);
      rethrow;
    }
  }

  Future<void> connectTcp({
    required String host,
    required int port,
    bool automaticReconnect = false,
  }) async {
    final pendingDisconnect = _disconnectInFlight;
    if (pendingDisconnect != null) await pendingDisconnect;
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      _appDebugLogService?.warn(
        'connectTcp ignored: already $_state',
        tag: 'TCP',
      );
      return;
    }

    _appDebugLogService?.info('connectTcp: endpoint=$host:$port', tag: 'TCP');

    await stopScan();
    _beginWiredConnect(automaticReconnect);
    _resetConnectionHandshakeState();
    _activeTransport = MeshCoreTransportType.tcp;
    _setState(MeshCoreConnectionState.connecting);

    try {
      Future<void> handleTcpConnectAbort({required String message}) async {
        _appDebugLogService?.warn(message, tag: 'TCP');
        final shouldResetState = shouldResetStateAfterTcpConnectAbort(
          state: _state,
          activeTransport: _activeTransport,
        );
        if (shouldResetState) {
          await disconnect(manual: false);
          return;
        }
        if (_tcpConnector.isConnected) {
          await _tcpConnector.disconnect();
        }
      }

      await _tcpConnector.cancelFrameSubscription();
      await _tcpConnector.connect(host: host, port: port);
      final isTcpConnectCancelled =
          _activeTransport != MeshCoreTransportType.tcp ||
          _state != MeshCoreConnectionState.connecting ||
          !_tcpConnector.isConnected;
      if (isTcpConnectCancelled) {
        await handleTcpConnectAbort(
          message:
              'connectTcp aborted before handshake: state=$_state transport=$_activeTransport connected=${_tcpConnector.isConnected}',
        );
        return;
      }
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 200));
      final isTcpConnectCancelledAfterDelay =
          _activeTransport != MeshCoreTransportType.tcp ||
          _state != MeshCoreConnectionState.connecting ||
          !_tcpConnector.isConnected;
      if (isTcpConnectCancelledAfterDelay) {
        await handleTcpConnectAbort(
          message:
              'connectTcp aborted after connect delay: state=$_state transport=$_activeTransport connected=${_tcpConnector.isConnected}',
        );
        return;
      }
      _tcpConnector.listenFrames(
        onFrame: _handleFrame,
        onError: (error, stackTrace) {
          _appDebugLogService?.error('TCP transport error: $error', tag: 'TCP');
          unawaited(disconnect(manual: false));
        },
        onDone: () {
          _appDebugLogService?.warn('TCP frame stream ended', tag: 'TCP');
          unawaited(disconnect(manual: false));
        },
      );

      _setState(MeshCoreConnectionState.connected);
      _pendingInitialChannelSync = true;
      _pendingInitialQueuedMessageSync = true;
      _pendingInitialContactsSync = true;
      await _requestDeviceInfo();
      _startBatteryPolling();
      if (_radioStatsPollRefCount > 0) _startRadioStatsPolling();

      var gotSelfInfo = await _waitForSelfInfo(
        timeout: const Duration(seconds: 3),
      );
      if (!gotSelfInfo) {
        await refreshDeviceInfo();
        gotSelfInfo = await _waitForSelfInfo(
          timeout: const Duration(seconds: 3),
        );
      }
      if (!gotSelfInfo) {
        throw StateError('Timed out waiting for SELF_INFO during TCP connect');
      }

      await syncTime();
      _lastConnectionError = null;
      _reconnectAttempts = 0;
      _linkTarget = TcpLinkTarget(host, port);
      unawaited(_rememberRadio(SavedRadioTransport.tcp, '$host:$port'));
    } catch (error) {
      _appDebugLogService?.error('TCP connection error: $error', tag: 'TCP');
      final tcpConnectCancelledBeforeHandshake =
          shouldIgnoreLateTcpConnectError(
            manualDisconnect: _manualDisconnect,
            state: _state,
            activeTransport: _activeTransport,
            tcpManagerConnected: _tcpConnector.isConnected,
          );
      if (tcpConnectCancelledBeforeHandshake) {
        _appDebugLogService?.info(
          'Ignoring late TCP connect error after cancellation/switch: state=$_state transport=$_activeTransport',
          tag: 'TCP',
        );
        return;
      }
      _lastConnectionError = describeConnectionError(error);
      await disconnect(manual: false);
      rethrow;
    }
  }

  @visibleForTesting
  static bool shouldIgnoreLateTcpConnectError({
    required bool manualDisconnect,
    required MeshCoreConnectionState state,
    required MeshCoreTransportType activeTransport,
    required bool tcpManagerConnected,
  }) {
    return manualDisconnect &&
        (state == MeshCoreConnectionState.disconnected ||
            state == MeshCoreConnectionState.disconnecting) &&
        (activeTransport != MeshCoreTransportType.tcp || !tcpManagerConnected);
  }

  @visibleForTesting
  static bool shouldResetStateAfterTcpConnectAbort({
    required MeshCoreConnectionState state,
    required MeshCoreTransportType activeTransport,
  }) {
    return state == MeshCoreConnectionState.connecting &&
        activeTransport == MeshCoreTransportType.tcp;
  }

  /// Fast (non-timeout) connect failures are usually a stale link left over
  /// from a previous session and recover on an immediate retry. Timeouts mean
  /// the device is likely off or out of range, so retrying would only delay
  /// genuine failure feedback.
  @visibleForTesting
  static bool shouldRetryBleConnectAfterError(String errorText) {
    final lowerErrorText = errorText.toLowerCase();
    return !lowerErrorText.contains('timed out') &&
        !lowerErrorText.contains('timeout');
  }

  Future<void> connect(
    BluetoothDevice device, {
    String? displayName,
    Future<String?> Function()? linuxPairingPinProvider,
    bool automaticReconnect = false,
  }) async {
    final targetId = device.remoteId.toString();
    final pendingDisconnect = _disconnectInFlight;
    if (pendingDisconnect != null) await pendingDisconnect;
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      final sameTarget =
          _activeTransport == MeshCoreTransportType.bluetooth &&
          _deviceId == targetId;
      // A retry timer must never replace a live link, and asking for the
      // device that is already connecting or connected is a no-op.
      if (sameTarget || automaticReconnect) return;
      _appDebugLogService?.info(
        'Replacing $_state ${_activeTransport.name} link ($_deviceId) with $targetId',
        tag: 'BLE Connect',
      );
      await disconnect();
      // Another request may have claimed the radio while the old link closed.
      if (_state == MeshCoreConnectionState.connecting ||
          _state == MeshCoreConnectionState.connected) {
        return;
      }
    }

    final generation = ++_connectGeneration;
    _activeTransport = MeshCoreTransportType.bluetooth;

    await stopScan();
    _setState(MeshCoreConnectionState.connecting);
    _device = device;
    _deviceId = targetId;
    if (displayName != null && displayName.trim().isNotEmpty) {
      _deviceDisplayName = displayName.trim();
    } else if (device.platformName.isNotEmpty) {
      _deviceDisplayName = device.platformName;
    }
    _lastDevice = device;
    _lastDeviceId = _deviceId;
    _lastDeviceDisplayName = _deviceDisplayName;
    _manualDisconnect = false;
    // Preserve exponential backoff across automatic retries. Manual connects
    // begin a fresh retry sequence.
    if (!automaticReconnect) {
      _cancelReconnectTimer();
      _linkTarget = null;
    }
    _bleInitialSyncStarted = false;
    if (PlatformInfo.isWeb) {
      _resetConnectionHandshakeState();
    }
    unawaited(_backgroundService?.start());
    notifyListeners();

    try {
      final connectLabel = _deviceDisplayName ?? _deviceId;
      _appDebugLogService?.info(
        'Starting connect to $connectLabel',
        tag: 'BLE Connect',
      );
      final link = debugBleLinkOverride;
      if (link != null) {
        await link(device);
      } else {
        await _openBleLink(
          device,
          generation,
          linuxPairingPinProvider: linuxPairingPinProvider,
        );
      }
      _throwIfConnectSuperseded(generation);

      _setState(MeshCoreConnectionState.connected);
      _lastConnectionError = null;
      unawaited(_rememberRadio(SavedRadioTransport.bluetooth, targetId));
      if (_shouldGateInitialChannelSync) {
        _hasReceivedDeviceInfo = false;
        _pendingInitialChannelSync = true;
      }
      if (link == null) await _startBleInitialSync();
      _reconnectAttempts = 0;
    } catch (e) {
      if (e is _ConnectSuperseded || generation != _connectGeneration) {
        // A newer connect or a disconnect owns the connection state now; only
        // make sure this attempt's link does not linger next to it.
        _appDebugLogService?.info(
          'Connect to $targetId superseded; dropping its link',
          tag: 'BLE Connect',
        );
        await _dropSupersededBleLink(device);
        return;
      }
      _appDebugLogService?.error('Connection error: $e', tag: 'BLE Connect');
      _lastConnectionError = isBluetoothOff
          ? 'Bluetooth is off'
          : describeConnectionError(e);
      final errorText = e.toString();
      final lowerErrorText = errorText.toLowerCase();
      final isLinuxPairingFailure =
          PlatformInfo.isLinux && isLinuxBlePairingFailureText(errorText);
      final isLikelyPairingTimeout = isLikelyLinuxBlePairingTimeoutText(
        errorText,
      );
      final isConnectFailure = isLinuxBleConnectFailureText(errorText);
      final isConnectTimeoutFailure =
          isConnectFailure && lowerErrorText.contains('timed out');
      final isLinuxConnectFailure = PlatformInfo.isLinux && isConnectFailure;
      // Linux pairing failures should not enter auto-reconnect loops; user
      // needs to retry manually so they can re-enter PIN / resolve pairing.
      if (isLinuxPairingFailure) {
        _appDebugLogService?.warn(
          isLikelyPairingTimeout
              ? 'Linux pairing timed out: stopping reconnect until user retries manually'
              : 'Linux pairing failure: stopping reconnect until user retries manually',
          tag: 'BLE Connect',
        );
        await disconnect(manual: true);
      } else if (isLinuxConnectFailure) {
        _appDebugLogService?.warn(
          isConnectTimeoutFailure
              ? 'Linux connect timeout: issuing BlueZ disconnect before reconnect'
              : 'Linux connect failure: issuing BlueZ disconnect before reconnect',
          tag: 'BLE Connect',
        );
        final remoteId = _device?.remoteId.str;
        if (remoteId != null) {
          await _linuxBlePairingService.disconnectDevice(
            remoteId,
            onLog: (message) {
              _appDebugLogService?.info(message, tag: 'BLE Pair');
            },
          );
        }
        await disconnect(manual: false, skipBleDeviceDisconnect: true);
      } else {
        await disconnect(manual: false);
      }
      rethrow;
    }
  }

  Future<bool> _waitForSelfInfo({required Duration timeout}) async {
    if (_selfPublicKey != null) return true;
    if (!isConnected) return false;

    final completer = Completer<bool>();
    late final VoidCallback listener;
    listener = () {
      if (_selfPublicKey != null) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } else if (!isConnected) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    };
    addListener(listener);

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    final result = await completer.future;
    timer.cancel();
    removeListener(listener);
    return result;
  }

  bool get _shouldAutoReconnect {
    if (_manualDisconnect) return false;
    if (_linkTarget != null) return true;
    return !isBluetoothOff &&
        _lastDeviceId != null &&
        _activeTransport == MeshCoreTransportType.bluetooth;
  }

  SharedPreferences? get _prefsOrNull {
    try {
      return PrefsManager.instance;
    } on StateError {
      return null;
    }
  }

  void _watchBluetoothAdapter() {
    if (PlatformInfo.isWeb || _adapterStateSubscription != null) return;
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen(
      handleAdapterState,
      onError: (Object error) {
        _appDebugLogService?.warn(
          'Bluetooth adapter state unavailable: $error',
          tag: 'BLE',
        );
      },
    );
  }

  /// Reacts to the Bluetooth adapter turning off or on. While it is off no
  /// reconnect is attempted; when it comes back after dropping a BLE link,
  /// one reconnect is scheduled through the normal backoff.
  @visibleForTesting
  void handleAdapterState(BluetoothAdapterState adapterState) {
    final wasOff = isBluetoothOff;
    _adapterState = adapterState;
    if (isBluetoothOff && !wasOff) {
      final bleActive =
          _activeTransport == MeshCoreTransportType.bluetooth &&
          (_state == MeshCoreConnectionState.connected ||
              _state == MeshCoreConnectionState.connecting ||
              (_reconnectTimer?.isActive ?? false));
      _resumeBleWhenAdapterOn =
          bleActive && !_manualDisconnect && _lastDeviceId != null;
      // Keep the attempt count so the retry after power-on continues the
      // existing backoff instead of starting a fresh burst.
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _appDebugLogService?.warn(
        'Bluetooth adapter is $adapterState; pausing reconnects',
        tag: 'BLE',
      );
      if (_activeTransport == MeshCoreTransportType.bluetooth &&
          _state != MeshCoreConnectionState.disconnected) {
        _lastConnectionError = 'Bluetooth is off';
      }
      if (_activeTransport == MeshCoreTransportType.bluetooth && isConnected) {
        _handleDisconnection();
      }
      notifyListeners();
    } else if (!isBluetoothOff && wasOff) {
      if (_lastConnectionError == 'Bluetooth is off') {
        _lastConnectionError = null;
      }
      notifyListeners();
    }
    // Resume only once the adapter is fully on, not while turning on.
    if (adapterState == BluetoothAdapterState.on && _resumeBleWhenAdapterOn) {
      _resumeBleWhenAdapterOn = false;
      if (_state == MeshCoreConnectionState.disconnected) {
        _scheduleReconnect();
        notifyListeners();
      }
    }
  }

  /// Turns a transport exception into a short message for the dashboard.
  @visibleForTesting
  static String describeConnectionError(Object error) {
    var text = error.toString();
    for (final prefix in const [
      'Exception: ',
      'Bad state: ',
      'StateError: ',
      'TimeoutException: ',
      'FlutterBluePlusException: ',
    ]) {
      if (text.startsWith(prefix)) text = text.substring(prefix.length);
    }
    final lower = text.toLowerCase();
    if (lower.contains('timed out') || lower.contains('timeout')) {
      if (lower.contains('self_info')) {
        return 'The radio did not answer. Check that it runs MeshCore '
            'companion firmware.';
      }
      return 'Timed out. Check that the radio is on and in range.';
    }
    if (lower.contains('uart service not found') ||
        lower.contains('characteristics not found')) {
      return 'This device is not a MeshCore companion radio.';
    }
    if (lower.contains('bluetooth adapter not available') ||
        lower.contains('bluetooth must be turned on') ||
        lower.contains('adapter is off')) {
      return 'Bluetooth is off';
    }
    if (lower.contains('pairing')) {
      return 'Bluetooth pairing failed. Try again and check the PIN.';
    }
    if (lower.contains('connection refused') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable')) {
      return 'Could not reach the radio over the network.';
    }
    text = text.trim();
    if (text.length > 160) text = '${text.substring(0, 157)}...';
    return text.isEmpty ? 'Connection failed' : text;
  }

  Future<void> _rememberRadio(SavedRadioTransport transport, String address) {
    final prefs = _prefsOrNull;
    if (prefs == null || address.trim().isEmpty) return Future.value();
    // Web BLE and Web Serial devices can't be reopened from a stored id.
    if (PlatformInfo.isWeb && transport != SavedRadioTransport.tcp) {
      return Future.value();
    }
    final name = _selfName?.trim().isNotEmpty == true
        ? _selfName!.trim()
        : (_deviceDisplayName?.trim().isNotEmpty == true
              ? _deviceDisplayName!.trim()
              : address);
    return SavedRadio(
      transport: transport,
      address: address.trim(),
      name: name,
    ).save(prefs, slot: slot).catchError((Object error) {
      _appDebugLogService?.warn(
        'Saving last radio failed: $error',
        tag: 'Connection',
      );
    });
  }

  /// Forgets the saved radio so the dashboard stops offering it.
  Future<void> forgetSavedRadio() async {
    final prefs = _prefsOrNull;
    if (prefs == null) return;
    await SavedRadio.clear(prefs, slot: slot);
    notifyListeners();
  }

  /// Connects to the saved radio, and only that one. Does nothing when no
  /// radio is saved.
  Future<void> reconnectSavedRadio() async {
    final saved = savedRadio;
    if (saved == null) return;
    switch (saved.transport) {
      case SavedRadioTransport.bluetooth:
        await connect(
          BluetoothDevice.fromId(saved.address),
          displayName: saved.name,
        );
      case SavedRadioTransport.usb:
        await connectUsb(portName: saved.address);
      case SavedRadioTransport.tcp:
        final endpoint = SavedRadio.parseTcp(saved.address);
        if (endpoint == null) return;
        await connectTcp(host: endpoint.host, port: endpoint.port);
    }
  }

  bool get _shouldGateInitialChannelSync =>
      _activeTransport == MeshCoreTransportType.usb ||
      _activeTransport == MeshCoreTransportType.tcp ||
      (_activeTransport == MeshCoreTransportType.bluetooth &&
          PlatformInfo.isWeb);

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  Future<void> disconnect({
    bool manual = true,
    bool skipBleDeviceDisconnect = false,
  }) {
    final inFlight = _disconnectInFlight;
    if (inFlight != null) return inFlight;
    if (_state == MeshCoreConnectionState.disconnecting) return Future.value();
    // Any connect attempt still awaiting the platform is now stale.
    _connectGeneration++;
    late final Future<void> run;
    run =
        _disconnect(
          manual: manual,
          skipBleDeviceDisconnect: skipBleDeviceDisconnect,
        ).whenComplete(() {
          if (identical(_disconnectInFlight, run)) _disconnectInFlight = null;
        });
    _disconnectInFlight = run;
    return run;
  }

  Future<void> sendFrame(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async {
    if (!isConnected) {
      throw Exception("Not connected to a MeshCore device");
    }
    _bleDebugLogService?.logFrame(data, outgoing: true);

    final pendingAck = _trackPendingGenericAck(
      data,
      channelSendQueueId: channelSendQueueId,
      expectsGenericAck: expectsGenericAck || waitForGenericAck,
      waitForAck: waitForGenericAck,
    );

    try {
      if (_activeTransport == MeshCoreTransportType.usb) {
        await _usbManager.write(data);
        // Brief pause so the device firmware can process each frame before the
        // next arrives. Without this, rapid-fire frames over USB can cause the
        // device to miss responses (especially on reconnect).
        await Future<void>.delayed(const Duration(milliseconds: 10));
      } else if (_activeTransport == MeshCoreTransportType.tcp) {
        await _tcpConnector.write(data);
      } else {
        if (_rxCharacteristic == null) {
          throw Exception("MeshCore RX characteristic not available");
        }
        // Prefer write without response when supported; fall back to write with response.
        final properties = _rxCharacteristic!.properties;
        final canWriteWithoutResponse = properties.writeWithoutResponse;
        final canWriteWithResponse = properties.write;
        if (!canWriteWithoutResponse && !canWriteWithResponse) {
          throw Exception("MeshCore RX characteristic does not support write");
        }
        await _rxCharacteristic!.write(
          data.toList(),
          withoutResponse: canWriteWithoutResponse,
        );
      }
    } catch (_) {
      if (pendingAck != null) {
        _pendingGenericAckQueue.remove(pendingAck);
      }
      rethrow;
    }

    if (pendingAck?.completer != null) {
      try {
        await pendingAck!.completer!.future.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        _pendingGenericAckQueue.remove(pendingAck);
        throw TimeoutException(
          'Timed out waiting for firmware acknowledgement',
        );
      }
    }
  }

  Future<void> requestBatteryStatus({bool force = false}) async {
    if (!isConnected) return;
    if (_batteryRequested && !force) return;
    _batteryRequested = true;
    await sendFrame(buildGetBattAndStorageFrame());
  }

  bool _batterySaver = false;
  bool get batterySaver => _batterySaver;

  /// Battery saver: poll the radio's battery every 10 minutes instead of 2,
  /// its GPS position every 5 minutes instead of 1, and radio stats at most
  /// once a minute. Messages and adverts still arrive as they happen.
  void setBatterySaver(bool on) {
    if (on == _batterySaver) return;
    _batterySaver = on;
    if (isConnected) {
      _startBatteryPolling();
      if (_gpsLocationPollTimer != null) {
        _stopGpsLocationPolling();
        _startGpsLocationPolling();
      }
      if (_radioStatsPollTimer != null) _startRadioStatsPolling();
    }
    notifyListeners();
  }

  double _pollScale = 1;

  /// Scales routine polling of battery, GPS and radio stats: 0.5 is twice
  /// as often, 3 is a third as often. Battery saver still wins when on.
  void setPollScale(double scale) {
    final next = scale.clamp(0.25, 10).toDouble();
    if (next == _pollScale) return;
    _pollScale = next;
    if (isConnected) {
      _startBatteryPolling();
      if (_gpsLocationPollTimer != null) {
        _stopGpsLocationPolling();
        _startGpsLocationPolling();
      }
      if (_radioStatsPollTimer != null) _startRadioStatsPolling();
    }
  }

  @visibleForTesting
  Duration get batteryPollInterval => _batterySaver
      ? const Duration(minutes: 10)
      : _batteryPollInterval * _pollScale;
  @visibleForTesting
  Duration get gpsLocationPollInterval => _batterySaver
      ? const Duration(minutes: 5)
      : _gpsLocationPollInterval * _pollScale;
  @visibleForTesting
  Duration get radioStatsPollInterval {
    // The radio stats screen asks for 1 s while it's open; leave that alone.
    final seconds = _pollingInterval < 5
        ? _pollingInterval
        : (_pollingInterval * _pollScale).round();
    return Duration(seconds: _batterySaver && seconds < 60 ? 60 : seconds);
  }

  void setPollingInterval(int i) {
    _pollingInterval = i.clamp(1, 60);
    if (isConnected) {
      _startRadioStatsPolling();
    }
  }

  void acquireRadioStatsPolling() {
    _radioStatsPollRefCount++;
    if (_radioStatsPollRefCount == 1 && isConnected) {
      _startRadioStatsPolling();
    }
  }

  void releaseRadioStatsPolling() {
    _radioStatsPollRefCount = (_radioStatsPollRefCount - 1).clamp(0, 999);
    if (_radioStatsPollRefCount == 0) {
      _stopRadioStatsPolling();
    }
  }

  Future<void> requestRadioStats() async {
    if (!isConnected) return;
    if (!supportsCompanionRadioStats) return;
    try {
      await sendFrame(buildGetStatsFrame(statsTypeRadio));
    } catch (_) {}
  }

  Future<void> setPathHashMode(int mode) async {
    if (!isConnected) return;
    final clampedMode = mode.clamp(0, 3).toInt();
    await sendFrame(buildSetPathHashModeFrame(clampedMode));
    final nextWidth = clampedMode + 1;
    if (_pathHashByteWidth != nextWidth) {
      _pathHashByteWidth = nextWidth;
      _directRepeaters.clear();
      notifyListeners();
    }
  }

  Future<void> refreshDeviceInfo() async {
    if (!isConnected) return;
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth &&
        _webInitialHandshakeRequestSent &&
        _selfPublicKey == null) {
      return;
    }
    _awaitingSelfInfo = true;
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth &&
        _selfPublicKey == null) {
      _webInitialHandshakeRequestSent = true;
    }
    await sendFrame(buildDeviceQueryFrame());
    await sendFrame(buildAppStartFrame());
    await requestBatteryStatus(force: true);
    await sendFrame(buildGetCustomVarsFrame());
    await sendFrame(buildGetAutoAddFlagsFrame());

    _scheduleSelfInfoRetry();
  }

  Future<void> _requestDeviceInfo() async {
    if (!isConnected || _awaitingSelfInfo) return;
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth &&
        _webInitialHandshakeRequestSent &&
        _selfPublicKey == null) {
      return;
    }
    _awaitingSelfInfo = true;
    if (PlatformInfo.isWeb &&
        _activeTransport == MeshCoreTransportType.bluetooth &&
        _selfPublicKey == null) {
      _webInitialHandshakeRequestSent = true;
    }
    await sendFrame(buildDeviceQueryFrame());
    await sendFrame(buildAppStartFrame());
    await sendFrame(buildGetCustomVarsFrame());
    await requestBatteryStatus();
    await sendFrame(buildGetAutoAddFlagsFrame());
    _scheduleSelfInfoRetry();
  }

  Contact getFromDiscovered(Contact contact) {
    final tmp = _discoveredContacts.firstWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
      orElse: () => contact,
    );
    return contact.copyWith(
      rawPacket: tmp.rawPacket,
      latitude: tmp.latitude,
      longitude: tmp.longitude,
    );
  }

  Future<void> getContacts({int? since, bool preserveExisting = false}) async {
    if (!isConnected) return;

    _isLoadingContacts = true;
    _preserveContactsOnRefresh = preserveExisting;
    _contactSyncTotal = null;
    _contactSyncReceived = 0;
    _contactSyncUsesSinceFilter = since != null;
    _contactSyncSince = since;
    _contactSyncRetries = 0;
    _contactSyncStalled = false;
    _contactSyncSeen.clear();
    // Saved contacts stay visible during the sync; a complete sync replaces
    // them at END_OF_CONTACTS instead of blanking the list up front.
    _armContactSyncWatchdog();
    notifyListeners();

    await sendFrame(buildGetContactsFrame(since: since));
  }

  /// Adds a contact shared as a [ContactLink]. Its route is unknown until it
  /// is heard, so the first message to it floods.
  Future<void> addContactFromLink(ContactLink link) async {
    if (!isConnected) throw StateError('Connect your radio first.');
    await sendFrame(
      buildUpdateContactPathFrame(
        link.publicKey,
        Uint8List(0),
        0xFF, // OUT_PATH_UNKNOWN
        type: link.type,
        name: link.name,
      ),
      expectsGenericAck: true,
      waitForGenericAck: true,
    );
    await refreshContacts();
  }

  /// Forgets when [contact] last advertised, keeping its name, type, route
  /// and position. The radio drops an advert that isn't newer than the last
  /// one, so a node whose clock went backwards (a reset or a dead RTC
  /// battery) stays stuck until this is cleared.
  Future<void> forgetLastAdvert(Contact contact) async {
    if (!isConnected) throw StateError('Connect your radio first.');
    final flood = contact.pathLength < 0;
    final pathLen = flood
        ? 0xFF
        : _encodePathLenForCurrentMode(contact.pathLength, contact.path);
    await sendFrame(
      buildUpdateContactPathFrame(
        contact.publicKey,
        flood ? Uint8List(0) : contact.path,
        pathLen ?? 0xFF,
        type: contact.type,
        flags: contact.flags,
        name: contact.name,
        lat: contact.hasLocation ? contact.latitude : null,
        lon: contact.hasLocation ? contact.longitude : null,
        lastAdvertTimestamp: 0,
      ),
      expectsGenericAck: true,
      waitForGenericAck: true,
    );
  }

  /// Stops retrying [message] and marks it failed, so it isn't sent again.
  void stopRetrying(Message message) {
    if (message.status != MessageStatus.pending) return;
    _retryService?.untrack(message.messageId);
    _updateMessage(message.copyWith(status: MessageStatus.failed));
  }

  Future<void> refreshContacts() async {
    await getContacts(preserveExisting: true);
  }

  Future<void> refreshContactsSinceLastmod() async {
    await getContacts(since: _latestContactLastmod(), preserveExisting: true);
  }

  Future<void> getContactByKey(Uint8List pubKey) async {
    if (!isConnected) return;
    await sendFrame(buildGetContactByKeyFrame(pubKey));
  }

  Future<void> sendMessage(
    Contact contact,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
  }) async {
    if (!isConnected || text.isEmpty) return;

    final outboundBytes = utf8.encode(
      prepareContactOutboundText(contact, text),
    );
    if (outboundBytes.length > maxTextPayloadBytes) {
      debugPrint(
        'sendMessage: dropping overlong message '
        '(${outboundBytes.length} > $maxTextPayloadBytes bytes)',
      );
      return;
    }

    // Check if this is a reaction - apply locally with pending status and route through retry service
    final reactionInfo = ReactionHelper.parseReaction(text);
    if (reactionInfo != null) {
      appLogger.info('Sending reaction: ${reactionInfo.identifier()}');
      _conversations.putIfAbsent(contact.publicKeyHex, () => []);
      final messages = _conversations[contact.publicKeyHex]!;

      // No check for duplicates. If you want to do it again to resend, you can.
      final String reactionID = reactionInfo.identifier();
      _processedContactReactions.putIfAbsent(contact.publicKeyHex, () => {});
      _processedContactReactions[contact.publicKeyHex]!.add(reactionID);

      // Apply reaction locally with pending status
      _processOutgoingContactReaction(messages, reactionInfo, contact);
      if (!sendsReactionsOverRadio) {
        // Local only: shown here, never sent, so there's nothing pending.
        _messageStore.saveMessages(contact.publicKeyHex, messages);
        notifyListeners();
        return;
      }
      _setReactionStatus(
        contact.publicKeyHex,
        reactionInfo,
        MessageStatus.pending,
      );
      _messageStore.saveMessages(contact.publicKeyHex, messages);
      notifyListeners();

      // Route through retry service (same as normal messages)
      // Don't use auto-rotation for reactions — just send directly
      if (_retryService != null) {
        _retryService!.sendMessageWithRetry(contact: contact, text: text);
      } else {
        final outboundText = prepareContactOutboundText(contact, text);
        await sendFrame(buildSendTextMsgFrame(contact.publicKey, outboundText));
      }
      return;
    }

    if (_retryService != null) {
      await _retryService!.sendMessageWithRetry(
        contact: contact,
        text: text,
        originalText: originalText,
        translatedLanguageCode: translatedLanguageCode,
        translationModelId: translationModelId,
      );
    } else {
      // Fallback to old behavior if retry service not initialized
      final resolved = resolvePathSelection(contact);
      final message = Message.outgoing(
        contact.publicKey,
        text,
        pathLength: resolved.useFlood ? -1 : resolved.hopCount,
        pathBytes: Uint8List.fromList(resolved.pathBytes),
        originalText: originalText,
        translatedLanguageCode: translatedLanguageCode,
        translationModelId: translationModelId,
      );
      _addMessage(contact.publicKeyHex, message); // recipient as "sender"
      notifyListeners();
      final outboundText = prepareContactOutboundText(contact, text);
      await sendFrame(buildSendTextMsgFrame(contact.publicKey, outboundText));
    }
  }

  Future<void> setContactPath(
    Contact contact,
    Uint8List customPath,
    int pathLen,
  ) async {
    // Serialize path operations to prevent interleaved async calls from
    // leaving in-memory state inconsistent with the device.
    final prev = _pathOpLock;
    final completer = Completer<void>();
    _pathOpLock = completer.future;
    await prev;
    try {
      if (!isConnected) return;

      final encodedPathLen = _encodePathLenForCurrentMode(pathLen, customPath);
      if (encodedPathLen == null) {
        return;
      }
      await sendFrame(
        buildUpdateContactPathFrame(
          contact.publicKey,
          customPath,
          encodedPathLen,
          type: contact.type,
          flags: contact.flags,
          name: contact.name,
        ),
      );
      // USB writes return instantly (no BLE flow control), so give the firmware
      // time to persist the path change before subsequent commands.
      if (_activeTransport == MeshCoreTransportType.usb) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      final idx = _contacts.indexWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );
      if (idx != -1) {
        _contacts[idx] = _contacts[idx].copyWith(
          pathLength: pathLen,
          path: customPath,
        );
        notifyListeners();
      }
    } finally {
      completer.complete();
    }
  }

  Future<void> setContactFlags(
    Contact contact, {
    bool? isFavorite,
    bool? teleBase,
    bool? teleLoc,
    bool? teleEnv,
    bool? remoteCli,
  }) async {
    if (!isConnected) return;
    final latestContact =
        await _fetchContactSnapshotFromDevice(contact.publicKey) ?? contact;
    int updatedFlags = isFavorite != null
        ? (isFavorite
              ? (latestContact.flags | contactFlagFavorite)
              : (latestContact.flags & ~contactFlagFavorite))
        : latestContact.flags;
    updatedFlags = teleBase != null
        ? (teleBase
              ? (updatedFlags | contactFlagTeleBase)
              : (updatedFlags & ~contactFlagTeleBase))
        : updatedFlags;
    updatedFlags = teleLoc != null
        ? (teleLoc
              ? (updatedFlags | contactFlagTeleLoc)
              : (updatedFlags & ~contactFlagTeleLoc))
        : updatedFlags;
    updatedFlags = teleEnv != null
        ? (teleEnv
              ? (updatedFlags | contactFlagTeleEnv)
              : (updatedFlags & ~contactFlagTeleEnv))
        : updatedFlags;
    updatedFlags = remoteCli != null
        ? (remoteCli
              ? (updatedFlags | contactFlagRemoteCli)
              : (updatedFlags & ~contactFlagRemoteCli))
        : updatedFlags;

    final encodedPathLen = _encodePathLenForCurrentMode(
      latestContact.pathLength,
      latestContact.path,
    );
    if (encodedPathLen == null) return;
    await sendFrame(
      buildUpdateContactPathFrame(
        latestContact.publicKey,
        latestContact.path,
        encodedPathLen,
        type: latestContact.type,
        flags: updatedFlags,
        name: latestContact.name,
      ),
    );

    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index >= 0) {
      _contacts[index] = _contacts[index].copyWith(
        type: latestContact.type,
        name: latestContact.name,
        pathLength: latestContact.pathLength,
        path: latestContact.path,
        flags: updatedFlags,
      );
      notifyListeners();
      unawaited(_persistContacts());
    }
  }

  /// Set path override for a contact (persists across contact refreshes)
  /// pathLen: -1 = force flood, null = auto (use device path), >= 0 = specific path
  Future<void> setPathOverride(
    Contact contact, {
    int? pathLen,
    Uint8List? pathBytes,
  }) async {
    appLogger.info(
      'setPathOverride called for ${contact.name}: pathLen=$pathLen, bytesLen=${pathBytes?.length ?? 0}',
      tag: 'Connector',
    );

    // Find contact in list
    final index = _contacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (index == -1) {
      appLogger.warn(
        'setPathOverride: Contact not found in list: ${contact.name}',
        tag: 'Connector',
      );
      return;
    }

    appLogger.info(
      'Found contact at index $index. Current override: ${_contacts[index].pathOverride}',
      tag: 'Connector',
    );

    if (pathLen != null &&
        pathLen >= 0 &&
        !_isPathLenValidForCurrentMode(pathLen, pathBytes ?? Uint8List(0))) {
      appLogger.warn(
        'setPathOverride: invalid path for ${contact.name}: '
        'pathLen=$pathLen, bytesLen=${pathBytes?.length ?? 0}, '
        'width=$_pathHashByteWidth',
        tag: 'Connector',
      );
      return;
    }

    // Update contact with new path override
    _contacts[index] = _contacts[index].copyWith(
      pathOverride: pathLen,
      pathOverrideBytes: pathBytes,
      clearPathOverride: pathLen == null, // Clear if pathLen is null
    );

    appLogger.info(
      'Updated contact. New override: ${_contacts[index].pathOverride}, bytesLen: ${_contacts[index].pathOverrideBytes?.length}',
      tag: 'Connector',
    );

    // Save to storage
    await _contactStore.saveContacts(_contacts);
    appLogger.info('Saved contacts to storage', tag: 'Connector');

    // Update any in-flight retries so they use the new path override
    _retryService?.updatePendingContact(_contacts[index]);

    // If setting a specific path (not flood, not auto), also sync with device
    if (pathLen != null && pathLen >= 0 && pathBytes != null) {
      appLogger.info('Sending path to device...', tag: 'Connector');
      await setContactPath(contact, pathBytes, pathLen);
      appLogger.info('Path sent to device', tag: 'Connector');
    }

    debugPrint(
      'Set path override for ${contact.name}: pathLen=$pathLen, bytes=${pathBytes?.length ?? 0}',
    );
    notifyListeners();
  }

  Future<PathSelection> preparePathForContactSend(Contact contact) async {
    PathSelection? autoSelection;
    final autoRotationEnabled =
        _appSettingsService?.settings.autoRouteRotationEnabled == true;
    if (autoRotationEnabled && contact.pathOverride == null) {
      final maxRetries = _appSettingsService?.settings.maxMessageRetries ?? 5;
      autoSelection = _selectAutoPathForAttempt(
        contact.publicKeyHex,
        attemptIndex: 0,
        maxRetries: maxRetries,
      );
    }

    final resolved = resolvePathSelection(contact, selection: autoSelection);

    if (resolved.useFlood) {
      await clearContactPath(contact);
    } else {
      await setContactPath(
        contact,
        Uint8List.fromList(resolved.pathBytes),
        resolved.hopCount,
      );
    }

    return resolved;
  }

  void trackRepeaterAck({
    required Contact contact,
    required PathSelection selection,
    required String text,
    required int timestampSeconds,
    int attempt = 0,
  }) {
    final selfKey = _selfPublicKey;
    if (selfKey == null) return;
    // Use transformed text to match device's ACK hash computation
    final outboundText = prepareContactOutboundText(contact, text);
    final ackHash = MessageRetryService.computeExpectedAckHash(
      timestampSeconds,
      attempt,
      outboundText,
      selfKey,
    );
    final ackHashHex = ackHashToHex(ackHash);
    final messageBytes = utf8.encode(outboundText).length;
    _pendingRepeaterAcks[ackHashHex]?.timeout?.cancel();
    _pendingRepeaterAcks[ackHashHex] = _RepeaterAckContext(
      contactKeyHex: contact.publicKeyHex,
      selection: selection,
      pathLength: selection.useFlood ? -1 : selection.hopCount,
      messageBytes: messageBytes,
    );
  }

  void recordRepeaterPathResult(
    Contact contact,
    PathSelection selection,
    bool success,
    int? tripTimeMs,
  ) {
    _recordPathResult(contact.publicKeyHex, selection, success, tripTimeMs);
  }

  Future<bool> verifyContactPathOnDevice(
    Contact contact,
    Uint8List expectedPath, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isConnected) return false;

    final expectedLength = expectedPath.length;
    final completer = Completer<bool>();

    void finish(bool result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    }

    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty || frame[0] != respCodeContact) return;
      final updated = Contact.fromFrame(frame);
      if (updated == null) return;
      if (updated.publicKeyHex != contact.publicKeyHex) return;
      final matchesLength = updated.pathLength == expectedLength;
      final matchesBytes = _pathsEqual(updated.path, expectedPath);
      if (matchesLength && matchesBytes) {
        finish(true);
      }
    });

    final timer = Timer(timeout, () => finish(false));
    try {
      await getContactByKey(contact.publicKey);
      return await completer.future;
    } finally {
      await subscription.cancel();
      timer.cancel();
    }
  }

  /// Sends [text] on [channel]. With [sign], or with signing every post
  /// turned on in Settings, a signature packet follows it.
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
    bool sign = false,
  }) async {
    if (!isConnected || text.isEmpty) return;

    // Check if this is a reaction - if so, process it immediately instead of adding as a message
    final reactionInfo = ReactionHelper.parseReaction(text);
    if (reactionInfo != null) {
      reactionInfo.senderName = selfName;
      // Check if we've already processed this reaction
      _processedChannelReactions.putIfAbsent(channel.index, () => {});
      final reactionIdentifier = reactionInfo.identifier();

      // Maybe we should allow resending. Recipients can drop duplicates.
      if (_processedChannelReactions[channel.index]!.contains(
        reactionIdentifier,
      )) {
        // Already processed, don't process again
        return;
      }

      // Get the in-memory messages list (same as _addChannelMessage uses)
      _channelMessages.putIfAbsent(channel.index, () => []);
      final messages = _channelMessages[channel.index]!;

      // Process reaction locally to update the UI immediately
      appLogger.info('Adding sent channel reaction, id: $reactionIdentifier');
      _processReaction(messages, reactionInfo);
      await _channelMessageStore.saveChannelMessages(channel.index, messages);

      // Mark this reaction as processed
      _processedChannelReactions[channel.index]!.add(reactionIdentifier);

      notifyListeners();
      if (!sendsReactionsOverRadio) return;

      // Send the reaction to the device (don't add as a visible message)
      final reactionQueueId = _nextReactionSendQueueId();
      _pendingChannelSentQueue.add(reactionQueueId);
      await _runScopedChannelSend(() async {
        await _waitForRadioQuiet(lastInboundRxTime: _lastChannelMsgRxTime);
        await _sendFrameAndWaitForCommandAck(
          buildSendChannelTextMsgFrame(channel.index, text),
          channelSendQueueId: reactionQueueId,
          expectsGenericAck: true,
        );
      }, region: getChannelRegion(channel.index));
      return;
    }

    final message = ChannelMessage.outgoing(
      text,
      _selfName ?? 'Me',
      channel.index,
      originalText: originalText,
      translatedLanguageCode: translatedLanguageCode,
      translationModelId: translationModelId,
    );
    _addChannelMessage(channel.index, message);
    _pendingChannelSentQueue.add(message.messageId);
    notifyListeners();

    final outboundText = prepareChannelOutboundText(channel.index, text);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signing =
        (sign || (_appSettingsService?.settings.signChannelPosts ?? false)) &&
        canSignPosts;
    await _runScopedChannelSend(() async {
      await _waitForRadioQuiet(lastInboundRxTime: _lastChannelMsgRxTime);
      await _sendFrameAndWaitForCommandAck(
        buildSendChannelTextMsgFrame(
          channel.index,
          outboundText,
          timestamp: timestamp,
        ),
        channelSendQueueId: message.messageId,
        expectsGenericAck: true,
      );
      if (signing) {
        await _sendPostSignature(
          channel.index,
          message.messageId,
          outboundText,
          timestamp,
        );
      }
    }, region: getChannelRegion(channel.index));
  }

  /// Whether this radio can sign channel posts: it carries channel data,
  /// its key is known, and its name reaches receivers unchanged.
  bool get canSignPosts =>
      supportsChannelData &&
      selfPublicKey?.length == 32 &&
      canSignAs(selfName ?? '');

  /// Signs the text just sent and sends the signature as one GRP_DATA
  /// packet. The signature covers the text as receivers will display it.
  /// A failure only costs the signature: the text has already gone.
  Future<void> _sendPostSignature(
    int channelIndex,
    String messageId,
    String wireText,
    int timestamp,
  ) async {
    final key = Uint8List.fromList(selfPublicKey!);
    final shown = Smaz.tryDecodePrefixed(wireText) ?? wireText;
    try {
      final signature = await signWithRadio(
        signedPostInput(
          timestamp: timestamp,
          senderName: selfName!,
          text: shown,
        ),
      );
      final payload = SignedPostPayload(
        publicKey: key,
        timestamp: timestamp,
        signature: signature,
      );
      await _waitForRadioQuiet(lastInboundRxTime: _lastChannelMsgRxTime);
      await _sendFrameAndWaitForCommandAck(
        buildSendChannelDataFrame(
          channelIndex: channelIndex,
          dataType: dataTypeSignedPost,
          payload: payload.encode(),
        ),
        // Code 62 must not be enrolled in the generic-ack queue.
        expectsGenericAck: false,
      );
      _updateChannelMessage(
        channelIndex,
        messageId,
        (m) => m.copyWith(signature: ChannelSignature.valid, signerKey: key),
      );
    } catch (e) {
      appLogger.warn('Post signature not sent: $e');
    }
  }

  /// Sends a channel text that corridor-aware repeaters forward only inside
  /// [corridor]. Flood Corridor firmware confirms it with RESP_CODE_OK rather
  /// than RESP_CODE_SENT, so it rides the generic-ack queue.
  Future<void> sendChannelMessageWithCorridor(
    Channel channel,
    String text,
    List<CorridorTriple> corridor, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
  }) async {
    if (!isConnected || text.isEmpty || _floodCorridorSupported != true) {
      return;
    }

    final message = ChannelMessage.outgoing(
      text,
      _selfName ?? 'Me',
      channel.index,
      originalText: originalText,
      translatedLanguageCode: translatedLanguageCode,
      translationModelId: translationModelId,
    );
    _addChannelMessage(channel.index, message);
    notifyListeners();

    final outboundText = prepareChannelOutboundText(channel.index, text);
    try {
      await _runScopedChannelSend(() async {
        await _waitForRadioQuiet(lastInboundRxTime: _lastChannelMsgRxTime);
        await _sendFrameAndWaitForCommandAck(
          buildSendChannelTextMsgCorridorFrame(
            channel.index,
            outboundText,
            corridor,
          ),
          channelSendQueueId: message.messageId,
          expectsGenericAck: true,
        );
      }, region: '');
    } catch (e) {
      appLogger.warn('Corridor channel send failed: $e');
      _markPendingChannelMessageFailedById(message.messageId);
    }
  }

  /// Minimum companion firmware version code that implements
  /// CMD_SEND_CHANNEL_DATA (62) / RESP_CODE_CHANNEL_DATA_RECV (27).
  static const int _minFirmwareVerCodeForChannelData = 13;

  /// True when the connected device can send/receive GRP_DATA blobs.
  bool get supportsChannelData =>
      isConnected &&
      (_firmwareVerCode ?? 0) >= _minFirmwareVerCodeForChannelData;

  /// Sends one image's chunk [blobs] as GRP_DATA packets on [channelIndex],
  /// strictly sequentially, inside a single scoped-send scope for the whole
  /// image (the flood scope is global, so re-entering it per chunk would let
  /// another channel's send interleave mid-image).
  ///
  /// [onProgress] fires after each chunk is acked, so the UI can show
  /// "sending 2 of 3".
  ///
  /// IMPORTANT: the command ACK only proves the firmware accepted the blob and
  /// queued a packet to the radio. It says nothing about transmission or
  /// delivery — GRP_DATA is unacknowledged flood traffic, there is no
  /// PUSH_CODE_SEND_CONFIRMED for it, and a chunk may still be lost on air.
  /// That is what the XOR parity chunk is for.
  ///
  /// Returns false when the transport is unavailable (disconnected or firmware
  /// too old); throws whatever [_sendFrameAndWaitForCommandAck] throws, i.e.
  /// Exception('Command failed with error code N') where N is 1
  /// (unsupported command), 2 (bad channel index), 3 (packet pool full, worth
  /// retrying) or 4 (illegal arg — blob too long), or a TimeoutException after
  /// _commandAckTimeout.
  Future<bool> sendImageChunks(
    List<Uint8List> blobs, {
    required int channelIndex,
    required Duration interChunkDelay,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (blobs.isEmpty) return false;
    if (!supportsChannelData) return false;
    // `return` inside the scoped callback only exits the callback, so a
    // disconnect mid-send used to fall through to `return true` below and the
    // caller would record a complete outgoing image and tell the user "sent"
    // after transmitting a prefix of the chunks. Track it explicitly.
    var sentAll = true;
    await _runScopedChannelSend(() async {
      for (var i = 0; i < blobs.length; i++) {
        if (!isConnected) {
          sentAll = false;
          return;
        }
        if (i > 0) await Future<void>.delayed(interChunkDelay);
        // Same collision avoidance as every other channel send. On a quiet mesh
        // this returns almost immediately; interChunkDelay is what actually
        // paces the chunks so we do not talk over our own previous packet.
        await _waitForRadioQuiet(lastInboundRxTime: _lastChannelMsgRxTime);
        await _sendFrameAndWaitForCommandAck(
          buildSendChannelDataFrame(
            channelIndex: channelIndex,
            dataType: dataTypeAeicImage,
            payload: blobs[i],
            pathLen: outPathUnknown, // 0xFF => flood
          ),
          // Code 62 must not be enrolled in the generic-ack queue.
          expectsGenericAck: false,
        );
        onProgress?.call(i + 1, blobs.length);
      }
    }, region: getChannelRegion(channelIndex));
    return sentAll;
  }

  Future<void> removeContact(Contact contact) async {
    if (!isConnected) return;

    _handleDiscovery(
      contact,
      contact.rawPacket ?? Uint8List(0),
      noNotify: true,
    );

    await sendFrame(buildRemoveContactFrame(contact.publicKey));
    _contacts.removeWhere((c) => c.publicKeyHex == contact.publicKeyHex);
    _knownContactKeys.remove(contact.publicKeyHex);
    unawaited(updateKnownDiscovered());
    unawaited(_persistContacts());
    _conversations.remove(contact.publicKeyHex);
    _loadedConversationKeys.remove(contact.publicKeyHex);
    final removedCount = _contactUnreadCount[contact.publicKeyHex] ?? 0;
    _cachedContactsUnreadTotal = (_cachedContactsUnreadTotal - removedCount)
        .clamp(0, _cachedContactsUnreadTotal);
    _contactUnreadCount.remove(contact.publicKeyHex);
    _unreadStore.saveContactUnreadCount(
      Map<String, int>.from(_contactUnreadCount),
    );
    _messageStore.clearMessages(contact.publicKeyHex);
    notifyListeners();
  }

  Future<void> updateKnownDiscovered() async {
    if (!isConnected) return;
    for (int i = 0; i < _discoveredContacts.length; i++) {
      _discoveredContacts[i] = _discoveredContacts[i].copyWith(
        isActive: _knownContactKeys.contains(
          _discoveredContacts[i].publicKeyHex,
        ),
      );
    }
    unawaited(_persistDiscoveredContacts());
    notifyListeners();
  }

  Future<void> removeDiscoveredContact(Contact contact) async {
    if (!isConnected) return;
    _discoveredContacts.removeWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    unawaited(_persistDiscoveredContacts());
    notifyListeners();
  }

  Future<bool> importDiscoveredContact(Contact contact) async {
    if (!isConnected) return false;

    // Manual saves must bypass the firmware's auto-add discovery policy.
    // CMD_IMPORT_CONTACT replays an advert and may remain discovery-only.
    final encodedPathLen = _encodePathLenForCurrentMode(
      contact.pathLength,
      contact.path,
    );
    if (encodedPathLen == null) return false;
    await sendFrame(
      buildUpdateContactPathFrame(
        contact.publicKey,
        contact.path,
        encodedPathLen,
        type: contact.type,
        flags: contact.flags,
        name: contact.name,
        lat: contact.latitude,
        lon: contact.longitude,
        lastModified: contact.lastSeen,
      ),
      waitForGenericAck: true,
    );

    // Update the discovered contact to mark it as active (imported)
    final discoveredIndex = _discoveredContacts.indexWhere(
      (c) => c.publicKeyHex == contact.publicKeyHex,
    );
    if (discoveredIndex >= 0) {
      _discoveredContacts[discoveredIndex] =
          _discoveredContacts[discoveredIndex].copyWith(isActive: true);
    }

    _handleContactAdvert(
      Contact(
        publicKey: contact.publicKey,
        name: contact.name,
        type: contact.type,
        pathLength: contact.pathLength,
        path: contact.path,
        latitude: contact.latitude,
        longitude: contact.longitude,
        lastSeen: DateTime.now(),
        flags: contact.flags,
      ),
    );
    notifyListeners();
    unawaited(_persistDiscoveredContacts());
    return true;
  }

  Future<void> clearContactPath(Contact contact) async {
    // Serialize path operations to prevent interleaved async calls.
    final prev = _pathOpLock;
    final completer = Completer<void>();
    _pathOpLock = completer.future;
    await prev;
    try {
      if (!isConnected) return;

      await sendFrame(buildResetPathFrame(contact.publicKey));
      if (_activeTransport == MeshCoreTransportType.usb) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      final existingIndex = _contacts.indexWhere(
        (c) => c.publicKeyHex == contact.publicKeyHex,
      );
      if (existingIndex >= 0) {
        final existing = _contacts[existingIndex];
        // Preserve pathOverride and pathOverrideBytes — only reset device path
        _contacts[existingIndex] = existing.copyWith(
          pathLength: -1,
          path: Uint8List(0),
        );
        notifyListeners();
        unawaited(_persistContacts());
      }
    } finally {
      completer.complete();
    }
  }

  void updateContactInMemory(
    String publicKeyHex, {
    Uint8List? pathBytes,
    int? pathLength,
  }) {
    final existingIndex = _contacts.indexWhere(
      (c) => c.publicKeyHex == publicKeyHex,
    );
    if (existingIndex >= 0) {
      final existing = _contacts[existingIndex];
      _contacts[existingIndex] = existing.copyWith(
        pathLength: pathLength,
        path: pathBytes,
      );
      notifyListeners();
      unawaited(_persistContacts());
    }
  }

  Future<void> syncTime() async {
    if (!isConnected) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await sendFrame(buildSetDeviceTimeFrame(now));
  }

  Future<void> syncQueuedMessages({bool force = false}) async {
    if (!isConnected) return;
    if (!force && _isSyncingQueuedMessages) return;
    if (_isProcessingDeferredQueuedContactMessages) {
      _pendingQueueSync = true;
      return;
    }
    if (_awaitingSelfInfo || _isLoadingContacts) {
      _pendingQueueSync = true;
      return;
    }
    if (_isSyncingChannels || _channelSyncInFlight) {
      _pendingQueueSync = true;
      return;
    }
    _isSyncingQueuedMessages = true;
    notifyListeners();
    await _requestNextQueuedMessage();
  }

  Future<void> sendCliCommand(String command) async {
    if (!isConnected) return;
    final selfKey = _selfPublicKey;
    if (selfKey == null) return;
    _lastSentWasCliCommand = true;
    await sendFrame(buildSendCliCommandFrame(selfKey, command));
  }

  Future<void> setNodeName(String name) async {
    if (!isConnected) return;
    await sendFrame(buildSetAdvertNameFrame(name));
  }

  Future<void> setNodeLocation({
    required double lat,
    required double lon,
  }) async {
    if (!isConnected) return;
    await sendFrame(buildSetAdvertLatLonFrame(lat, lon));
  }

  Future<void> setCustomVar(String value) async {
    if (!isConnected) return;
    await sendFrame(buildSetCustomVarFrame(value));
    final sep = value.indexOf(':');
    if (sep > 0) {
      final key = value.substring(0, sep);
      final val = value.substring(sep + 1);
      (_currentCustomVars ??= <String, String>{})[key] = val;
      notifyListeners();
    }
    if (value == 'gps:1') {
      _startGpsLocationPolling();
    } else if (value == 'gps:0') {
      _stopGpsLocationPolling();
    }
  }

  /// Runs [command] on the connected companion's text CLI (firmware v14+)
  /// and returns the reply text. Throws [TimeoutException] if no reply
  /// arrives; commands like `reboot` never reply.
  Future<String> runCliCommand(
    String command, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final previous = _cliLock;
    final done = Completer<void>();
    _cliLock = done.future;
    await previous;

    // "xy|command" makes the firmware echo "xy|" before its reply.
    final n = _cliPrefixCounter++ % (26 * 26);
    final prefix =
        String.fromCharCode(0x61 + n ~/ 26) +
        String.fromCharCode(0x61 + n % 26);
    final reply = Completer<String>();
    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty || frame[0] != respCodeCliReply || reply.isCompleted) {
        return;
      }
      final text = utf8.decode(frame.sublist(1), allowMalformed: true);
      if (text.startsWith('$prefix|')) {
        reply.complete(text.substring(3));
      } else if (text.length < 3 || text[2] != '|') {
        // Short commands aren't prefixed; commands are serialized anyway.
        reply.complete(text);
      }
    });
    try {
      await sendFrame(buildRunCliCommandFrame('$prefix|$command'));
      return await reply.future.timeout(timeout);
    } finally {
      await subscription.cancel();
      done.complete();
    }
  }

  /// Reads the radio's identity private key (CMD_EXPORT_PRIVATE_KEY), for
  /// a backup. Throws [IdentityKeyException]; firmware built without key
  /// export answers [IdentityKeyFailure.disabled].
  Future<Uint8List> exportIdentityKey({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final reply = await _identityKeyRequest(
      buildExportPrivateKeyFrame(),
      const {respCodePrivateKey, respCodeDisabled, respCodeErr},
      timeout,
    );
    final key = parsePrivateKeyFrame(reply);
    if (key == null) {
      throw const IdentityKeyException(IdentityKeyFailure.rejected);
    }
    return key;
  }

  /// Gives the radio the identity in [key] (CMD_IMPORT_PRIVATE_KEY), then
  /// asks for its self info again so the new public key shows. Throws
  /// [IdentityKeyException].
  Future<void> importIdentityKey(
    Uint8List key, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final reply = await _identityKeyRequest(
      buildImportPrivateKeyFrame(key),
      const {respCodeOk, respCodeDisabled, respCodeErr},
      timeout,
    );
    if (reply[0] != respCodeOk) {
      throw const IdentityKeyException(IdentityKeyFailure.rejected);
    }
    await sendFrame(buildAppStartFrame());
  }

  Future<Uint8List> _identityKeyRequest(
    Uint8List frame,
    Set<int> answers,
    Duration timeout,
  ) async {
    if (!isConnected) {
      throw const IdentityKeyException(IdentityKeyFailure.notConnected);
    }
    final reply = Completer<Uint8List>();
    final subscription = receivedFrames.listen((f) {
      if (f.isNotEmpty && answers.contains(f[0]) && !reply.isCompleted) {
        reply.complete(f);
      }
    });
    try {
      try {
        await sendFrame(frame);
      } on Exception {
        throw const IdentityKeyException(IdentityKeyFailure.notConnected);
      }
      final f = await reply.future.timeout(
        timeout,
        onTimeout: () =>
            throw const IdentityKeyException(IdentityKeyFailure.timeout),
      );
      // Firmware too old for the command says "unsupported"; to the user
      // that's the same as a build with the feature turned off.
      if (f[0] == respCodeDisabled ||
          (f[0] == respCodeErr &&
              f.length > 1 &&
              f[1] == errCodeUnsupportedCmd)) {
        throw const IdentityKeyException(IdentityKeyFailure.disabled);
      }
      return f;
    } finally {
      await subscription.cancel();
    }
  }

  /// Signs [data] with the radio's own Ed25519 key via CMD_SIGN_START,
  /// CMD_SIGN_DATA and CMD_SIGN_FINISH, and returns the 64-byte signature.
  /// The private key never leaves the radio. Each reply must arrive within
  /// [timeout]. Throws [RadioSigningException].
  Future<Uint8List> signWithRadio(
    Uint8List data, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final writer = debugSignFrameWriter;
    if (writer == null && !isConnected) {
      throw const RadioSigningException(RadioSigningFailure.notConnected);
    }
    final previous = _signLock;
    final done = Completer<void>();
    _signLock = done.future;
    await previous;

    final replies = <Uint8List>[];
    Completer<void>? arrived;
    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty) return;
      final code = frame[0];
      if (code == respCodeOk ||
          code == respCodeErr ||
          code == respCodeSignStart ||
          code == respCodeSignature) {
        replies.add(frame);
        arrived?.complete();
        arrived = null;
      }
    });
    // Start and finish answer with their own codes; an OK seen while waiting
    // for them belongs to an earlier command.
    Future<Uint8List> reply({required bool acceptOk}) async {
      while (true) {
        while (replies.isEmpty) {
          final wait = arrived = Completer<void>();
          await wait.future.timeout(
            timeout,
            onTimeout: () =>
                throw const RadioSigningException(RadioSigningFailure.timeout),
          );
        }
        final frame = replies.removeAt(0);
        if (frame[0] != respCodeOk || acceptOk) return frame;
      }
    }

    Never fail(Uint8List frame) {
      final unsupported =
          frame[0] == respCodeErr &&
          frame.length > 1 &&
          frame[1] == errCodeUnsupportedCmd;
      throw RadioSigningException(
        unsupported
            ? RadioSigningFailure.unsupported
            : RadioSigningFailure.rejected,
      );
    }

    try {
      Future<void> send(Uint8List frame, {bool expectsAck = false}) async {
        if (writer != null) return writer(frame);
        try {
          await sendFrame(frame, expectsGenericAck: expectsAck);
        } on Exception {
          throw const RadioSigningException(RadioSigningFailure.notConnected);
        }
      }

      await send(buildSignStartFrame());
      final start = await reply(acceptOk: false);
      final maxLength = parseSignStartFrame(start);
      if (maxLength == null) fail(start);
      if (data.length > maxLength) {
        throw const RadioSigningException(RadioSigningFailure.tooLong);
      }
      for (var at = 0; at < data.length; at += signDataChunkSize) {
        final end = math.min(at + signDataChunkSize, data.length);
        await send(
          buildSignDataFrame(Uint8List.sublistView(data, at, end)),
          expectsAck: true,
        );
        final ack = await reply(acceptOk: true);
        if (ack[0] != respCodeOk) fail(ack);
      }
      await send(buildSignFinishFrame());
      final finish = await reply(acceptOk: false);
      return parseSignatureFrame(finish) ?? fail(finish);
    } finally {
      await subscription.cancel();
      done.complete();
    }
  }

  Future<void> sendSelfAdvert({bool flood = true}) async {
    if (!isConnected) return;
    await sendFrame(buildSendSelfAdvertFrame(flood: flood));
    if (!flood) {
      _lastZeroHopAdvertAt = DateTime.now();
      _lastZeroHopAdvertLatitude = _selfLatitude;
      _lastZeroHopAdvertLongitude = _selfLongitude;
    }
  }

  Future<void> rebootDevice() async {
    if (!isConnected) return;
    await sendFrame(buildRebootFrame());
  }

  Future<void> setPrivacyMode(bool enabled) async {
    await sendCliCommand('set privacy ${enabled ? 'on' : 'off'}');
  }

  Future<void> setTelemetryModeBase(
    int base,
    int location,
    int env,
    int advert,
    int multiAcks,
  ) async {
    if (!isConnected) return;
    _telemetryModeBase = base.clamp(teleModeDeny, teleModeAllowAll).toInt();
    _telemetryModeLoc = location.clamp(teleModeDeny, teleModeAllowAll).toInt();
    _telemetryModeEnv = env.clamp(teleModeDeny, teleModeAllowAll).toInt();
    _advertLocPolicy = advert.clamp(0, 1).toInt();
    _multiAcks = multiAcks.clamp(0, 2).toInt();
    await sendFrame(
      buildSetOtherParamsFrame(
        (_telemetryModeEnv << 4) |
            (_telemetryModeLoc << 2) |
            _telemetryModeBase,
        _advertLocPolicy,
        _multiAcks,
      ),
    );
    notifyListeners();
  }

  Future<void> getChannels({int? maxChannels, bool force = false}) async {
    if (!isConnected) return;
    if (_isSyncingChannels) {
      debugPrint('[ChannelSync] Already syncing channels, ignoring request');
      return;
    }

    // Skip fetching if already loaded and not forced
    if (_hasLoadedChannels && !force) {
      debugPrint(
        '[ChannelSync] Channels already loaded, skipping fetch (use force=true to reload)',
      );
      return;
    }

    _isLoadingChannels = true;
    _isSyncingChannels = true;
    _hasLoadedChannels = false;
    _previousChannelsCache = List<Channel>.from(_channels);
    _channels.clear();
    _nextChannelIndexToRequest = 0;
    _totalChannelsToRequest = maxChannels ?? _maxChannels;
    _channelSyncRetries = 0;
    notifyListeners();

    debugPrint(
      '[ChannelSync] Starting sync for $_totalChannelsToRequest channels',
    );

    // Start sequential sync
    await _requestNextChannel();
  }

  Future<void> setChannel(int index, String name, Uint8List psk) async {
    if (!isConnected) return;

    await sendFrame(buildSetChannelFrame(index, name, psk));
    // Refresh channels after setting
    await getChannels(force: true);
  }

  Future<void> deleteChannel(int index) async {
    if (!isConnected) return;

    // Delete by setting empty name and zero PSK
    await sendFrame(buildSetChannelFrame(index, '', Uint8List(16)));
    // Clear stored messages for this channel
    await _channelMessageStore.clearChannelMessages(index);
    // Clear in-memory messages for this channel
    _channelMessages.remove(index);
    // Refresh channels after deleting
    await getChannels(force: true);
  }

  @visibleForTesting
  void handleFrameForTest(List<int> data) => _handleFrame(data);

  @visibleForTesting
  void debugSetContacts(List<Contact> contacts) => _contacts
    ..clear()
    ..addAll(contacts);

  @visibleForTesting
  void debugSetChannels(List<Channel> channels) => _channels
    ..clear()
    ..addAll(channels);

  @visibleForTesting
  void debugSetSelfIdentity(Uint8List publicKey, String name) {
    _selfPublicKey = publicKey;
    _selfName = name;
  }

  Future<void> _probeFloodCorridorSupport() async {
    if (!isConnected || _floodCorridorSupported != null) return;
    if (_floodCorridorProbePending || _pendingGenericAckQueue.isNotEmpty) {
      return;
    }
    _floodCorridorProbePending = true;
    try {
      await sendFrame(buildGetCorridorRegionFrame());
    } catch (e) {
      _floodCorridorProbePending = false;
      appLogger.warn('Flood corridor probe failed: $e');
      return;
    }
    await Future<void>.delayed(_commandAckTimeout);
    if (_floodCorridorProbePending) {
      _floodCorridorProbePending = false;
      _floodCorridorSupported ??= false;
      notifyListeners();
    }
  }

  /// Asks the radio which corridor it would use toward [lat]/[lon], built
  /// from the positions of known repeaters. Null on timeout or unsupported
  /// firmware; the radio rejects the request while its own position is unknown.
  Future<CorridorProposal?> proposeCorridor(
    double lat,
    double lon, {
    bool dense = false,
  }) async {
    if (!isConnected || _floodCorridorSupported != true) return null;
    final completer = Completer<CorridorProposal?>();
    final subscription = receivedFrames.listen((frame) {
      if (frame.isEmpty || completer.isCompleted) return;
      if (frame[0] == respCodeProposeCorridor) {
        completer.complete(parseCorridorProposalFrame(frame));
      } else if (frame[0] == respCodeErr) {
        completer.complete(null);
      }
    });
    final timer = Timer(_commandAckTimeout, () {
      if (!completer.isCompleted) completer.complete(null);
    });
    try {
      await sendFrame(buildProposeCorridorFrame(lat, lon, dense: dense));
      return await completer.future;
    } finally {
      timer.cancel();
      await subscription.cancel();
    }
  }

  /// Sets the region corridor packets are tagged with, so stock repeaters that
  /// allow that region still forward them. Empty resets to "#corridor".
  Future<void> setCorridorRegion(String region) async {
    if (!isConnected || _floodCorridorSupported != true) return;
    await _sendFrameAndWaitForCommandAck(buildSetCorridorRegionFrame(region));
    _corridorRegion = region.startsWith('#') ? region.substring(1) : region;
    notifyListeners();
  }

  /// Estimate single-packet airtime in ms from radio settings, or a fallback.
  int _estimateAirtimeMs(int messageBytes) {
    if (_currentFreqHz != null &&
        _currentBwHz != null &&
        _currentSf != null &&
        _currentCr != null) {
      final cr = _currentCr! <= 4 ? _currentCr! : _currentCr! - 4;
      return calculateLoRaAirtime(
        payloadBytes: messageBytes,
        spreadingFactor: _currentSf!,
        bandwidthHz: _currentBwHz!,
        codingRate: cr,
        lowDataRateOptimize: _currentSf! >= 11,
      );
    }
    return 50; // fallback: ~SF7/BW125 for 100 bytes
  }

  /// Physics-based worst-case timeout (ceiling).
  int _physicsMaxTimeout(int pathLength, int airtime) {
    if (pathLength < 0) {
      // Match firmware: SEND_TIMEOUT_BASE_MILLIS + (FLOOD_SEND_TIMEOUT_FACTOR * airtime)
      return 500 + (16 * airtime);
    } else {
      return 500 + ((airtime * 6 + 250) * (pathLength + 1));
    }
  }

  int _physicsMinTimeout(int pathLength, int airtime) {
    if (pathLength < 0) {
      // Same as max for flood — firmware uses a single formula
      return 500 + (16 * airtime);
    } else {
      // Include firmware base (500ms) and per-hop processing (6*airtime+250)
      // so ML cannot clamp below a physically plausible round-trip.
      return 500 + ((airtime * 6 + 250) * pathLength);
    }
  }

  /// Hard ceiling on any ML-derived or physics-fallback timeout (ms).
  /// Prevents the flood formula (500 + 16·airtime at SF12 ≈ 150s) and an
  /// unstable OLS model from producing multi-minute waits.
  static const int _hardMaxTimeoutMs = 45000;

  /// Calculate timeout for a message based on radio settings and path length.
  /// Returns timeout in milliseconds, considering number of hops.
  ///
  /// [deviceTimeoutMs] is the firmware's own est_timeout from RESP_CODE_SENT.
  /// When ML is absent it is used as the fallback (clamped to physicsMin).
  /// When ML is present it is used as an additional ceiling alongside physicsMax.
  int calculateTimeout({
    required int pathLength,
    int messageBytes = 100,
    String? contactKey,
    int? deviceTimeoutMs,
  }) {
    final airtime = _estimateAirtimeMs(messageBytes);
    final physicsMin = _physicsMinTimeout(pathLength, airtime);
    final physicsMax = _physicsMaxTimeout(pathLength, airtime);

    // Try ML-based prediction
    final secSinceRx = DateTime.now().difference(_lastRxTime).inSeconds;
    final mlTimeout = _timeoutPredictionService?.predictTimeout(
      contactKey: contactKey,
      pathLength: pathLength,
      messageBytes: messageBytes,
      secondsSinceLastRx: secSinceRx,
    );
    if (mlTimeout != null) {
      // Use device est_timeout as a baseline floor when available —
      // the firmware computed it from real airtime. Let the learned ML
      // estimate widen above it up to the hard cap, but never below it.
      final floor = deviceTimeoutMs != null && deviceTimeoutMs > physicsMin
          ? deviceTimeoutMs.clamp(physicsMin, _hardMaxTimeoutMs)
          : physicsMin.clamp(0, _hardMaxTimeoutMs);
      if (pathLength < 0) {
        // Flood: trust ML, only enforce firmware estimate as floor
        if (mlTimeout < floor) {
          return floor.clamp(0, _hardMaxTimeoutMs);
        }
      }
      return mlTimeout.clamp(floor, _hardMaxTimeoutMs);
    }

    // No ML data — prefer device est_timeout (it used real airtime), then physics.
    // Cap the floor to the hard maximum so slow-flood physicsMin cannot exceed
    // the upper bound and make clamp() throw.
    if (deviceTimeoutMs != null && deviceTimeoutMs > 0) {
      final floor = physicsMin.clamp(0, _hardMaxTimeoutMs);
      return deviceTimeoutMs.clamp(floor, _hardMaxTimeoutMs);
    }
    return physicsMax.clamp(0, _hardMaxTimeoutMs);
  }

  /// Sets the contact-table limits as the radio reports them; for tests.
  @visibleForTesting
  void debugSetContactTable({
    required int maxContacts,
    bool overwriteOldest = false,
    bool autoAddUsers = false,
    bool autoAddRepeaters = false,
  }) {
    _maxContacts = maxContacts;
    _maxContactsReported = true;
    _overwriteOldest = overwriteOldest;
    _autoAddUsers = autoAddUsers;
    _autoAddRepeaters = autoAddRepeaters;
  }

  @visibleForTesting
  Message? parseContactMessageForTest(Uint8List frame) =>
      _parseContactMessage(frame);

  Message? _parseContactMessage(Uint8List frame) {
    if (frame.isEmpty) {
      appLogger.warn('Received empty frame, ignoring');
      return null;
    }
    final reader = BufferReader(frame);

    try {
      final code = reader.readByte();
      if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
        appLogger.warn(
          'Unexpected message code: $code, expected contact message receive codes',
        );
        return null;
      }

      // Companion radio layout:
      // [code][snr?][res?][res?][prefix x6][path_len][txt_type][timestamp x4][extra?][text...]
      // double snr = 0;
      if (code == respCodeContactMsgRecvV3) {
        // Older firmware layout with SNR as a signed byte after the code
        // snr = reader.readInt8().toDouble() * 4; // SNR in dB, scaled by 4
        reader.skipBytes(1); // Skip SNR byte
        reader.skipBytes(2); // Skip reserved bytes
      }

      final senderPrefix = reader.readBytes(6);
      final pathLength = reader.readByte();
      final txtType = reader.readByte();
      final timestampRaw = reader.readUInt32LE();
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        timestampRaw * 1000,
      );

      final flags = txtType;
      final shiftedType = flags >> 2;
      final rawType = flags;
      final isSigned = shiftedType == txtTypeSigned || rawType == txtTypeSigned;
      final Uint8List? roomAuthorPrefix;
      if (isSigned) {
        // Room-server pushed posts use signed/plain contact messages where this
        // 4-byte "signature" field is actually the original author's pubkey
        // prefix. Keep it as metadata; the text starts after these bytes.
        roomAuthorPrefix = reader.readBytes(4);
      } else {
        roomAuthorPrefix = null;
      }

      final msgText = reader.readCString();

      final isPlain =
          shiftedType == txtTypePlain || rawType == txtTypePlain || isSigned;
      final isCli = shiftedType == txtTypeCliData || rawType == txtTypeCliData;
      if (shiftedType == txtTypeCliCommand || rawType == txtTypeCliCommand) {
        // Our radio only passes a remote command up when it refused to run
        // it: the sender lacks the remote command line permission.
        final from = contacts.cast<Contact?>().firstWhere(
          (c) => c != null && _matchesPrefix(c.publicKey, senderPrefix),
          orElse: () => null,
        );
        _blockedRemoteCommand(from, msgText);
        return null;
      }
      if (!isPlain && !isCli) {
        appLogger.warn(
          'Unknown message type received: txtType=$txtType, shifted=$shiftedType, raw=$rawType',
        );
        return null;
      }

      if (msgText.isEmpty) {
        appLogger.warn('Received message with empty text, ignoring');
        return null;
      }
      final decodedText = isCli
          ? msgText
          : (Smaz.tryDecodePrefixed(msgText) ?? msgText);

      final contact = _contacts.cast<Contact?>().firstWhere(
        (c) => c != null && _matchesPrefix(c.publicKey, senderPrefix),
        orElse: () => null,
      );
      if (contact == null) {
        appLogger.warn(
          'Received message from unknown contact with prefix: ${senderPrefix.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join('')}',
        );
        return null;
      }

      return Message(
        senderKey: contact.publicKey,
        text: decodedText,
        timestamp: timestamp,
        isOutgoing: false,
        isCli: isCli,
        status: MessageStatus.delivered,
        pathLength: pathLength == 0xFF ? -1 : (pathLength & 0x3F),
        pathBytes: Uint8List(0),
        fourByteRoomContactKey: roomAuthorPrefix,
      );
    } catch (e) {
      appLogger.warn('Error parsing contact direct message: $e');
      return null;
    }
  }

  /// Recent commands our radio refused to run, newest first.
  final List<BlockedRemoteCommand> blockedRemoteCommands = [];

  void _blockedRemoteCommand(Contact? from, String command) {
    // Strip the optional "NN|" request tag the sender's app adds.
    final text = command.length > 3 && command[2] == '|'
        ? command.substring(3)
        : command;
    final name = from?.name ?? 'An unknown contact';
    blockedRemoteCommands.insert(
      0,
      BlockedRemoteCommand(
        contactKey: from?.publicKeyHex,
        name: name,
        command: text,
        at: DateTime.now(),
      ),
    );
    if (blockedRemoteCommands.length > 20) blockedRemoteCommands.removeLast();
    appLogger.warn('Blocked remote command from $name: $text');
    unawaited(
      _notificationService.showFieldAlert(
        '$name tried to run "$text" on your radio. Blocked: they don\'t have remote command line permission.',
      ),
    );
    notifyListeners();
  }

  bool _matchesPrefix(Uint8List fullKey, Uint8List prefix) {
    if (fullKey.length < prefix.length) return false;
    for (int i = 0; i < prefix.length; i++) {
      if (fullKey[i] != prefix[i]) return false;
    }
    return true;
  }

  String? getChannelCyr2LatProfileId(int channelIndex) {
    _ensureChannelCyr2LatProfileLoaded(channelIndex);
    return _channelCyr2LatProfileId[channelIndex];
  }

  Future<void> setChannelCyr2LatProfileId(
    int channelIndex,
    String? profileId,
  ) async {
    if (_channelCyr2LatProfileId[channelIndex] == profileId) return;
    _channelCyr2LatProfileId[channelIndex] = profileId;
    await _channelSettingsStore.saveCyr2LatProfileId(channelIndex, profileId);
    notifyListeners();
  }

  String? getContactCyr2LatProfileId(String contactKeyHex) {
    _ensureContactCyr2LatProfileLoaded(contactKeyHex);
    return _contactCyr2LatProfileId[contactKeyHex];
  }

  Future<void> setContactCyr2LatProfileId(
    String contactKeyHex,
    String? profileId,
  ) async {
    if (_contactCyr2LatProfileId[contactKeyHex] == profileId) return;
    _contactCyr2LatProfileId[contactKeyHex] = profileId;
    await _contactSettingsStore.saveCyr2LatProfileId(contactKeyHex, profileId);
    notifyListeners();
  }

  /// Prepares contact outbound text by applying SMAZ encoding if enabled.
  /// This should be used to transform text before computing ACK hashes.
  String prepareContactOutboundText(Contact contact, String text) {
    final trimmed = text.trim();
    final isStructuredPayload =
        trimmed.startsWith('g:') ||
        trimmed.startsWith('m:') ||
        trimmed.startsWith('V1|');
    if (!isStructuredPayload) {
      if (isContactSmazEnabled(contact.publicKeyHex)) {
        return Smaz.encodeIfSmaller(text);
      } else if (isContactCyr2LatEnabled(contact.publicKeyHex)) {
        final profileId = getContactCyr2LatProfileId(contact.publicKeyHex);
        final profile = profileId != null && _appSettingsService != null
            ? _appSettingsService!.getCyr2LatProfileById(profileId)
            : null;
        if (profile != null) {
          Cyr2Lat.setCharMap(profile.charMap);
        } else {
          // Use global profile
          final globalProfile = _appSettingsService
              ?.getSelectedCyr2LatProfile();
          if (globalProfile != null) {
            Cyr2Lat.setCharMap(globalProfile.charMap);
          }
        }
        return Cyr2Lat.encode(text);
      }
    }
    return text;
  }

  String prepareChannelOutboundText(int channelIndex, String text) {
    final trimmed = text.trim();
    final isStructuredPayload =
        trimmed.startsWith('g:') || trimmed.startsWith('m:');
    if (!isStructuredPayload) {
      if (isChannelSmazEnabled(channelIndex)) {
        return Smaz.encodeIfSmaller(text);
      } else if (isChannelCyr2LatEnabled(channelIndex)) {
        final profileId = getChannelCyr2LatProfileId(channelIndex);
        final profile = profileId != null && _appSettingsService != null
            ? _appSettingsService!.getCyr2LatProfileById(profileId)
            : null;
        if (profile != null) {
          Cyr2Lat.setCharMap(profile.charMap);
        } else {
          // Use global profile
          final globalProfile = _appSettingsService
              ?.getSelectedCyr2LatProfile();
          if (globalProfile != null) {
            Cyr2Lat.setCharMap(globalProfile.charMap);
          }
        }
        return Cyr2Lat.encode(text);
      }
    }
    return text;
  }

  final PendingSignatures _heldSignatures = PendingSignatures();

  /// Applies a held signature to [message] when one was waiting for it.
  Future<void> _claimHeldSignature(ChannelMessage message) async {
    final channel = message.channelIndex;
    if (channel == null) return;
    final held = _heldSignatures.candidates(
      channel,
      message.timestamp.millisecondsSinceEpoch ~/ 1000,
      DateTime.now(),
    );
    for (final payload in held) {
      if (await verifySignedPost(
        payload,
        senderName: message.senderName,
        text: message.text,
      )) {
        _heldSignatures.remove(payload);
        _updateChannelMessage(
          channel,
          message.messageId,
          (m) => m.copyWith(
            signature: ChannelSignature.valid,
            signerKey: payload.publicKey,
          ),
        );
        return;
      }
    }
  }

  /// Every raw packet the radio hears, for MQTT observer sharing.
  Stream<RadioRxPacket> get rxPackets => _rxPacketsController.stream;

  /// Adds a channel message from a raw packet an MQTT observer heard.
  ///
  /// Unlike radio RX, a message the app already has is left alone instead of
  /// counted as a repeat, so internet copies don't inflate RF repeat counts.
  void ingestMqttRawPacket(Uint8List raw) =>
      _handleRawRxPacket(raw, viaMqtt: true);

  void _handleRawRxPacket(Uint8List raw, {bool viaMqtt = false}) {
    try {
      final packet = _parseRawPacket(raw);
      if (packet == null || packet.payloadType != _payloadTypeGroupText) return;

      final payload = BufferReader(packet.payload);
      final channelHash = payload.readByte();
      final encrypted = Uint8List.fromList(payload.readRemainingBytes());

      // Use cached channels as fallback if live channels not yet loaded
      final channelsToSearch = _channels.isNotEmpty
          ? _channels
          : _cachedChannels;
      for (final channel in channelsToSearch) {
        if (channel.isEmpty) continue;
        final hash = _computeChannelHash(channel.psk);
        if (hash != channelHash) continue;
        try {
          final decryptedBytes = _decryptPayload(channel.psk, encrypted);
          if (decryptedBytes == null || decryptedBytes.length < 6) return;
          final decrypted = BufferReader(decryptedBytes);

          final timestampRaw = decrypted.readUInt32LE();
          final txtType = decrypted.readByte();
          if ((txtType >> 2) != 0) {
            return;
          }

          final text = decrypted.readCString();
          final parsed = _splitSenderText(text);
          final decodedText =
              Smaz.tryDecodePrefixed(parsed.text) ?? parsed.text;
          if (_shouldDropSelfChannelMessage(
            parsed.senderName,
            packet.pathBytes,
          )) {
            return;
          }

          final pktHash = _computePacketHash(
            packet.payloadType,
            packet.payload,
          );

          final message = ChannelMessage(
            senderKey: null,
            senderName: parsed.senderName,
            text: decodedText,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestampRaw * 1000),
            isOutgoing: false,
            status: ChannelMessageStatus.sent,
            pathLength: packet.isFlood ? packet.hopCount : 0,
            pathHashWidth: packet.pathHashWidth,
            pathBytes: packet.pathBytes,
            channelIndex: channel.index,
            packetHash: pktHash,
            viaMqtt: viaMqtt,
            region: matchRegion(
              packet.transportCode,
              packet.payloadType,
              packet.payload,
              _knownRegionNames(),
            ),
          );
          if (viaMqtt &&
              _findChannelRepeatIndex(
                    _channelMessages[channel.index] ?? const [],
                    message,
                  ) >=
                  0) {
            return;
          }

          _updateContactLastMessageAtByName(
            parsed.senderName,
            message.timestamp,
            pathBytes: message.pathBytes,
            pathHashWidth: message.pathHashWidth,
          );
          final isNew = _addChannelMessage(channel.index, message);
          _maybeIncrementChannelUnread(message, isNew: isNew);
          notifyListeners();
          if (isNew) {
            // Run translation + notification asynchronously to avoid blocking
            unawaited(() async {
              final translationResult = await translateChannelMessage(
                channel.index,
                message,
              );
              final label = channel.name.isEmpty
                  ? 'Channel ${channel.index}'
                  : channel.name;
              _maybeNotifyChannelMessage(
                message,
                channelName: label,
                translationResult: translationResult,
              );
            }());
          }
          return;
        } catch (e) {
          appLogger.warn('Decryption failed for channel ${channel.index}: $e');
        }
      }
    } catch (e) {
      appLogger.warn('Error handling log RX data frame: $e');
    }
  }

  Future<void> setChannelOrder(List<int> order) async {
    _channelOrder = List<int>.from(order);
    _applyChannelOrder();
    notifyListeners();
    await _channelOrderStore.saveChannelOrder(_channelOrder);
  }

  void _setReactionStatus(
    String pubKeyHex,
    ReactionInfo reactionInfo,
    MessageStatus status,
  ) {
    final messages = _conversations[pubKeyHex];
    if (messages == null) return;
    final contact = getContactByPubKeyHex(pubKeyHex);
    final isRoomServer = contact?.type == advTypeRoom;
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      final timestampSecs = msg.timestamp.millisecondsSinceEpoch ~/ 1000;
      final msgHash = ReactionHelper.computeReactionHash(
        timestampSecs,
        _resolveContactSenderName(msg, contact, isRoomServer == true),
        msg.text,
      );
      if (msgHash == reactionInfo.targetHash) {
        final statuses = Map<String, MessageStatus>.from(msg.reactionStatuses);
        statuses[reactionInfo.emoji] = status;
        messages[i] = msg.copyWith(reactionStatuses: statuses);
        break;
      }
    }
  }

  _RawPacket? _parseRawPacket(Uint8List raw) {
    try {
      final reader = BufferReader(raw);
      final header = reader.readByte();
      final routeType = header & _phRouteMask;
      final hasTransport =
          routeType == _routeTransportFlood ||
          routeType == _routeTransportDirect;
      var transportCode = 0;
      if (hasTransport) {
        // Two u16 transport codes, little-endian; the first is the region's.
        transportCode = reader.readByte() | (reader.readByte() << 8);
        reader.skipBytes(2);
      }
      final pathLenRaw = reader.readByte();
      final pathByteLen = _decodePathByteLen(pathLenRaw);
      final pathBytes = reader.readBytes(pathByteLen);
      final payload = reader.readBytes(reader.remaining);

      return _RawPacket(
        header: header,
        routeType: routeType,
        payloadType: (header >> _phTypeShift) & _phTypeMask,
        payloadVer: (header >> _phVerShift) & _phVerMask,
        pathLenRaw: pathLenRaw,
        pathBytes: pathBytes,
        payload: payload,
        transportCode: transportCode,
      );
    } catch (e) {
      appLogger.warn('Error parsing raw packet: $e');
      return null;
    }
  }

  /// True when the connected radio can transmit a packet the app hands it
  /// unchanged (CMD_SEND_RAW_PACKET, firmware v1.16+).
  bool get supportsRawPacketSend =>
      isConnected && (_firmwareVerCode ?? 0) >= minFirmwareVerCodeForRawPacket;

  /// Transmits [raw], a packet the radio heard, byte for byte: same header,
  /// path, region code and payload, so a signature in it still verifies and
  /// repeaters that already forwarded it drop the copy.
  Future<void> sendRawPacket(Uint8List raw) async {
    if (!supportsRawPacketSend) {
      throw StateError('This radio cannot send raw packets');
    }
    await _sendFrameAndWaitForCommandAck(buildSendRawPacketFrame(raw));
  }

  /// [raw] decrypted as a flood channel text or signed-post signature on one
  /// of this radio's channels; null for anything else, including direct
  /// packets and channels this radio doesn't have.
  HeardChannelPacket? decodeHeardChannelPacket(Uint8List raw) {
    final packet = _parseRawPacket(raw);
    if (packet == null || !packet.isFlood || packet.payload.isEmpty) {
      return null;
    }
    final isText = packet.payloadType == _payloadTypeGroupText;
    if (!isText && packet.payloadType != payloadTypeGRPDATA) return null;
    final channelHash = packet.payload[0];
    final encrypted = Uint8List.sublistView(packet.payload, 1);
    final channels = _channels.isNotEmpty ? _channels : _cachedChannels;
    for (final channel in channels) {
      if (channel.isEmpty || _computeChannelHash(channel.psk) != channelHash) {
        continue;
      }
      final decrypted = _decryptPayload(channel.psk, encrypted);
      if (decrypted == null) continue;
      final hash = _computePacketHash(packet.payloadType, packet.payload);
      try {
        final reader = BufferReader(decrypted);
        if (isText) {
          final timestamp = reader.readUInt32LE();
          if ((reader.readByte() >> 2) != 0) return null; // not plain text
          final parsed = _splitSenderText(reader.readCString());
          return HeardChannelPacket(
            packetHash: hash,
            hopCount: packet.hopCount,
            channelIndex: channel.index,
            senderName: parsed.senderName,
            text: Smaz.tryDecodePrefixed(parsed.text) ?? parsed.text,
            timestamp: timestamp,
          );
        }
        final dataType = reader.readByte() | (reader.readByte() << 8);
        final length = reader.readByte();
        if (dataType != dataTypeSignedPost) return null;
        final post = SignedPostPayload.decode(reader.readBytes(length));
        if (post == null) return null;
        return HeardChannelPacket(
          packetHash: hash,
          hopCount: packet.hopCount,
          channelIndex: channel.index,
          timestamp: post.timestamp,
          signedPost: post,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// The channel hash of [raw] when it's a group text message, else null.
  int? groupChannelHash(Uint8List raw) {
    final packet = _parseRawPacket(raw);
    if (packet == null ||
        packet.payloadType != _payloadTypeGroupText ||
        packet.payload.isEmpty) {
      return null;
    }
    return packet.payload[0];
  }

  /// Whether [raw] is a group text message on the channel keyed by [psk]:
  /// its channel hash matches and its MAC checks out, so a one-byte hash
  /// collision isn't mistaken for the channel.
  bool groupPacketMatches(Uint8List raw, Uint8List psk) {
    final packet = _parseRawPacket(raw);
    if (packet == null ||
        packet.payloadType != _payloadTypeGroupText ||
        packet.payload.isEmpty ||
        _computeChannelHash(psk) != packet.payload[0]) {
      return false;
    }
    return _decryptPayload(psk, Uint8List.sublistView(packet.payload, 1)) !=
        null;
  }

  /// The one-byte hash group messages carry for the channel keyed by [psk].
  static int channelHashOf(Uint8List psk) =>
      crypto.sha256.convert(psk).bytes[0];

  int _computeChannelHash(Uint8List psk) {
    final digest = crypto.sha256.convert(psk).bytes;
    return digest[0];
  }

  /// Content-based dedup hash for sync queue messages (no raw payload available).
  /// Prefixed with 'c:' to avoid collisions with packet hashes.
  String _computeContentHash(
    int channelIdx,
    int timestampSecs,
    String fullText,
  ) {
    final textBytes = utf8.encode(fullText);
    final input = Uint8List(5 + textBytes.length);
    input[0] = channelIdx;
    input[1] = timestampSecs & 0xFF;
    input[2] = (timestampSecs >> 8) & 0xFF;
    input[3] = (timestampSecs >> 16) & 0xFF;
    input[4] = (timestampSecs >> 24) & 0xFF;
    input.setRange(5, 5 + textBytes.length, textBytes);
    final digest = crypto.sha256.convert(input).bytes;
    return 'c:${digest.sublist(0, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  _ParsedText _splitSenderText(String text) {
    final colonIndex = text.indexOf(':');
    if (colonIndex > 0 && colonIndex < text.length - 1 && colonIndex < 50) {
      final potentialSender = text.substring(0, colonIndex);
      if (RegExp(r'[:\[\]]').hasMatch(potentialSender)) {
        return _ParsedText(senderName: 'Unknown', text: text);
      }
      final offset =
          (colonIndex + 1 < text.length && text[colonIndex + 1] == ' ')
          ? colonIndex + 2
          : colonIndex + 1;
      return _ParsedText(
        senderName: potentialSender,
        text: text.substring(offset),
      );
    }
    return _ParsedText(senderName: 'Unknown', text: text);
  }

  void _processReaction(
    List<ChannelMessage> messages,
    ReactionInfo reactionInfo,
  ) {
    ReactionHelper.applyReaction<ChannelMessage>(
      messages: messages,
      reactionInfo: reactionInfo,
      shouldSkip: (_) => false,
      getTimestampSecs: (msg) => msg.timestamp.millisecondsSinceEpoch ~/ 1000,
      getSenderName: (msg) => msg.senderName,
      getMessageText: (msg) => msg.text,
      getReactions: (msg) => msg.reactions,
      updateMessage: (i, reactions) {
        messages[i] = messages[i].copyWith(reactions: reactions);
        notifyListeners();
      },
    );
  }

  _PendingCommandAck? _trackPendingGenericAck(
    Uint8List data, {
    String? channelSendQueueId,
    required bool expectsGenericAck,
    required bool waitForAck,
  }) {
    if (!expectsGenericAck || data.isEmpty) return null;
    final pendingAck = _PendingCommandAck(
      commandCode: data[0],
      channelSendQueueId: channelSendQueueId,
      completer: waitForAck ? Completer<void>() : null,
    );
    if (pendingAck.completer != null) {
      // sendFrame awaits this future after transport I/O; attach an error
      // handler immediately in case USB returns an error response first.
      unawaited(pendingAck.completer!.future.catchError((_) {}));
    }
    _pendingGenericAckQueue.add(pendingAck);
    return pendingAck;
  }

  Map<String, String> _parseKeyValueString(String input) {
    final result = <String, String>{};

    // Split on commas first – empty entries are ignored.
    for (final pair in input.split(',')) {
      final trimmedPair = pair.trim();
      if (trimmedPair.isEmpty) continue;

      // Each pair must contain exactly one ':'.
      final separatorIndex = trimmedPair.indexOf(':');
      if (separatorIndex == -1) continue; // malformed, skip

      final key = trimmedPair.substring(0, separatorIndex).trim();
      final value = trimmedPair.substring(separatorIndex + 1).trim();

      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }

  void _setState(MeshCoreConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void markNotifyDirty() {
    if (_notifyListenersDirty && _notifyListenersTimer != null) {
      return;
    }

    _notifyListenersDirty = true;
    _notifyListenersTimer ??= Timer(
      _notifyListenersDebounce,
      _flushBatchedNotify,
    );
  }

  void _flushBatchedNotify() {
    _notifyListenersTimer = null;
    if (!_notifyListenersDirty) {
      return;
    }

    _notifyListenersDirty = false;
    super.notifyListeners();

    if (_notifyListenersDirty && _notifyListenersTimer == null) {
      _notifyListenersTimer = Timer(
        _notifyListenersDebounce,
        _flushBatchedNotify,
      );
    }
  }

  @override
  void notifyListeners() {
    markNotifyDirty();
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanNotifyTimer?.cancel();
    _isScanningSubscription?.cancel();
    _connectionSubscription?.cancel();
    _usbFrameSubscription?.cancel();
    _notifySubscription?.cancel();
    _notifyListenersTimer?.cancel();
    _reconnectTimer?.cancel();
    _batteryPollTimer?.cancel();
    _gpsLocationPollTimer?.cancel();
    _radioStatsPollTimer?.cancel();
    radioStatsNotifier.dispose();
    _receivedFramesController.close();
    _rxPacketsController.close();
    _receivedDirectMessagesController.close();
    _receivedChannelMessagesController.close();
    _radioChannelMessagesController.close();
    _usbManager.dispose();
    _tcpConnector.dispose();

    // Flush pending unread writes before disposal
    _unreadStore.flush();

    super.dispose();
  }

  void importContact(Uint8List frame) {
    final packet = BufferReader(frame);
    int payloadType = 0;
    Uint8List pathBytes = Uint8List(0);
    int pathHashWidth = 1;
    try {
      packet.skipBytes(1); // Skip frame type byte
      packet.skipBytes(1); // Skip SNR byte
      packet.skipBytes(1); // Skip RSSI byte
      final header = packet.readByte();
      final routeType = header & 0x03;
      payloadType = (header >> 2) & 0x0F;
      if (routeType == _routeTransportFlood ||
          routeType == _routeTransportDirect) {
        packet.skipBytes(4); // Skip transport-specific bytes
      }
      //final payloadVer = (header >> 6) & 0x03;
      final pathLenRaw = packet.readByte();
      final pathByteLen = _decodePathByteLen(pathLenRaw);
      pathHashWidth = _decodePathHashWidth(pathLenRaw);
      pathBytes = packet.readBytes(pathByteLen);
    } catch (e) {
      appLogger.warn('Malformed RX frame: $e', tag: 'Connector');
      return;
    }
    double? latitude;
    double? longitude;
    String name = '';
    Uint8List publicKey = Uint8List(0);
    int type = 0;
    int timestamp = 0;
    bool hasLocation = false;
    bool hasName = false;
    if (payloadType != payloadTypeADVERT) {
      appLogger.warn('Unexpected payload type: $payloadType', tag: 'Connector');
      return;
    }
    try {
      publicKey = packet.readBytes(32);
      timestamp = packet.readInt32LE();
      //TODO add signature verification
      packet.skipBytes(64); // Skip signature for now
      final flags = packet.readByte();
      type = flags & 0x0F;
      hasLocation = (flags & 0x10) != 0;
      // For future use:
      //final hasFeature1 = (flags & 0x20) != 0;
      //final hasFeature2 = (flags & 0x40) != 0;
      hasName = (flags & 0x80) != 0;
      if (hasLocation && packet.remaining >= 8) {
        latitude = packet.readInt32LE() / 1e6;
        longitude = packet.readInt32LE() / 1e6;
      }
      if (hasName && packet.remaining > 0) {
        name = packet.readCString();
      }
    } catch (e) {
      appLogger.warn('Malformed advert frame: $e', tag: 'Connector');
      return;
    }

    importDiscoveredContact(
      Contact(
        rawPacket: frame,
        publicKey: publicKey,
        name: name,
        type: type,
        pathLength: pathBytes.isEmpty
            ? -1
            : (pathBytes.length ~/ pathHashWidth),
        // Store hop order reversed for easier outgoing messages; keep bytes
        // inside each multi-byte hop in their original order.
        path: _reversePathByHop(pathBytes, pathHashWidth),
        latitude: latitude,
        longitude: longitude,
        lastSeen: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      ),
    );
  }

  bool hasValidLocation(double? latitude, double? longitude) {
    const double epsilon = 1e-6;
    final lat = latitude ?? 0.0;
    final lon = longitude ?? 0.0;
    return (lat.abs() > epsilon || lon.abs() > epsilon) &&
        lat >= -90.0 &&
        lat <= 90.0 &&
        lon >= -180.0 &&
        lon <= 180.0;
  }

  final VerifiedAdverts _verifiedAdverts = VerifiedAdverts();

  void removeAllDiscoveredContacts() {
    _discoveredContacts.clear();
    unawaited(_persistDiscoveredContacts());
    notifyListeners();
  }

  void clearMessagesForContact(Contact contact) {
    final contactKeyHex = contact.publicKeyHex;
    final messages = _conversations[contactKeyHex];
    if (messages == null) return;
    messages.clear();
    unawaited(_messageStore.saveMessages(contactKeyHex, messages));
    markContactRead(contactKeyHex);
    notifyListeners();
  }

  void clearMessagesForChannel(int channelIndex) {
    final messages = _channelMessages[channelIndex];
    if (messages == null) return;
    messages.clear();
    unawaited(_channelMessageStore.saveChannelMessages(channelIndex, messages));
    markChannelRead(channelIndex);
    notifyListeners();
  }

  void deleteAllPaths() {
    _pathHistoryService?.clearAllHistories();
  }
}

const int _phRouteMask = 0x03;
const int _phTypeShift = 2;
const int _phTypeMask = 0x0F;
const int _phVerShift = 6;
const int _phVerMask = 0x03;

const int _routeTransportFlood = 0x00;
const int _routeFlood = 0x01;
const int _routeTransportDirect = 0x03;

const int _payloadTypeGroupText = 0x05;
const int _cipherMacSize = 2;

/// Decodes the firmware's encoded path_len byte into actual byte length.
/// Bits 0-5: hash count (0-63), Bits 6-7: hash size code (0=1byte ... 3=4bytes).
int _decodePathByteLen(int pathLenRaw) {
  if (pathLenRaw == 0xFF || pathLenRaw == 0) return 0;
  final hashCount = pathLenRaw & 63;
  final hashSize = _decodePathHashWidth(pathLenRaw);
  return hashCount * hashSize;
}

int _decodePathHashWidth(int pathLenRaw) {
  if (pathLenRaw == 0xFF) return 1;
  return ((pathLenRaw >> 6) & 0x03) + 1;
}

bool _isPathLenValidForMode(
  int pathLen,
  List<int> pathBytes,
  int pathHashWidth,
) {
  if (pathLen < 0 || pathLen > 0x3F) return false;
  final width = pathHashWidth.clamp(1, 4).toInt();
  final maxHopCountByBytes = maxPathSize ~/ width;
  if (pathLen > maxHopCountByBytes) return false;
  return pathBytes.length <= maxPathSize && pathBytes.length == pathLen * width;
}

Uint8List _reversePathByHop(Uint8List pathBytes, int pathHashWidth) {
  if (pathBytes.isEmpty) return Uint8List(0);
  final width = pathHashWidth.clamp(1, 4).toInt();
  final reversed = <int>[];
  for (var i = pathBytes.length; i > 0; i -= width) {
    final start = (i - width).clamp(0, pathBytes.length).toInt();
    reversed.addAll(pathBytes.sublist(start, i));
  }
  return Uint8List.fromList(reversed);
}

class _RawPacket {
  final int header;
  final int routeType;
  final int payloadType;
  final int payloadVer;
  final int pathLenRaw;
  final Uint8List pathBytes;
  final Uint8List payload;

  /// The region transport code of a scoped flood, else 0.
  final int transportCode;

  _RawPacket({
    required this.header,
    required this.routeType,
    required this.payloadType,
    required this.payloadVer,
    required this.pathLenRaw,
    required this.pathBytes,
    required this.payload,
    this.transportCode = 0,
  });

  bool get isFlood =>
      routeType == _routeFlood || routeType == _routeTransportFlood;

  int get hopCount => pathLenRaw & 63;
  int get pathHashWidth => ((pathLenRaw >> 6) & 0x03) + 1;
}

class _ParsedText {
  final String senderName;
  final String text;

  _ParsedText({required this.senderName, required this.text});
}

class _RepeaterAckContext {
  final String contactKeyHex;
  final PathSelection selection;
  final int pathLength;
  final int messageBytes;
  Timer? timeout;

  _RepeaterAckContext({
    required this.contactKeyHex,
    required this.selection,
    required this.pathLength,
    required this.messageBytes,
  });
}

class _PendingCommandAck {
  final int commandCode;
  final String? channelSendQueueId;
  final Completer<void>? completer;

  _PendingCommandAck({
    required this.commandCode,
    this.channelSendQueueId,
    this.completer,
  });
}

/// A command another radio sent us that our radio refused to run.
/// [messages] without those sent before [cutoff], in their original order.
List<ChannelMessage> keepChannelMessagesSince(
  List<ChannelMessage> messages,
  DateTime cutoff,
) => messages.where((m) => !m.timestamp.isBefore(cutoff)).toList();

/// An incoming channel message with the channel's display name.
class ReceivedChannelMessage {
  final ChannelMessage message;
  final String channelName;
  const ReceivedChannelMessage(this.message, this.channelName);
}

/// Thrown inside a BLE connect attempt that a newer connect or a disconnect
/// replaced while it awaited the platform.
class _ConnectSuperseded implements Exception {
  const _ConnectSuperseded();
}
