// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'NOTORYX Core';

  @override
  String get nav_contacts => 'Kontakter';

  @override
  String get nav_channels => 'Kanaler';

  @override
  String get nav_map => 'Karta';

  @override
  String get nav_messages => 'Meddelanden';

  @override
  String get nav_nodes => 'Noder';

  @override
  String get nav_radio => 'Radio';

  @override
  String get messages_title => 'Meddelanden';

  @override
  String get messages_filterAll => 'Alla';

  @override
  String get messages_filterDirect => 'Direkt';

  @override
  String get messages_filterChannels => 'Kanaler';

  @override
  String messages_filterWithUnread(String label, int count) {
    return '$label · $count';
  }

  @override
  String get messages_search => 'Sök meddelanden';

  @override
  String get messages_searchHint => 'Sök konversationer';

  @override
  String get messages_closeSearch => 'Stäng sökning';

  @override
  String get messages_manageChannels => 'Hantera kanaler';

  @override
  String get messages_new => 'Ny';

  @override
  String get messages_newDirect => 'Skriv till en nod';

  @override
  String get messages_newChannel => 'Lägg till eller gå med i en kanal';

  @override
  String get messages_empty => 'Inga konversationer än';

  @override
  String get messages_emptyHint =>
      'Meddelanden från noder och kanaler visas här.';

  @override
  String get messages_noMatches => 'Inga konversationer matchar sökningen';

  @override
  String messages_you(String text) {
    return 'Du: $text';
  }

  @override
  String get messages_yesterday => 'Igår';

  @override
  String messages_unreadCount(int count) {
    return '$count olästa';
  }

  @override
  String radioStatus_connectedVia(String transport) {
    return 'Ansluten via $transport';
  }

  @override
  String get radioStatus_bluetooth => 'Bluetooth';

  @override
  String get radioStatus_usb => 'USB';

  @override
  String get radioStatus_tcp => 'Wi‑Fi (TCP)';

  @override
  String radioStatus_battery(int percent) {
    return 'Batteri $percent %';
  }

  @override
  String get radioStatus_openRadio => 'Öppna radiodetaljer';

  @override
  String get radioOverview_battery => 'Batteri';

  @override
  String radioOverview_firmware(String version) {
    return 'Firmware $version';
  }

  @override
  String get radioOverview_sendAdvert => 'Skicka advert';

  @override
  String get radioOverview_stats => 'Radiostatistik';

  @override
  String get accessControl_title => 'Åtkomstkontroll';

  @override
  String get accessControl_hubSubtitle => 'Vem som kan logga in utan lösenord';

  @override
  String get accessControl_explainRepeater =>
      'Personer på listan loggar in utan lösenord. Administratörer kan ändra inställningar; Endast läsa och Läsa och skriva får också full telemetri.';

  @override
  String get accessControl_explainRoom =>
      'Administratörer på listan loggar in utan lösenord och kan hantera rummet. Rummets medlemmar går med med rummets lösenord i stället.';

  @override
  String get accessControl_roleReadOnly => 'Endast läsa';

  @override
  String get accessControl_roleReadWrite => 'Läsa och skriva';

  @override
  String get accessControl_roleAdmin => 'Administratör';

  @override
  String get accessControl_you => 'Du';

  @override
  String get accessControl_unknownNode => 'Okänd nod';

  @override
  String get accessControl_add => 'Lägg till';

  @override
  String get accessControl_addTitle => 'Lägg till i åtkomstlistan';

  @override
  String get accessControl_pickContact => 'Välj en kontakt';

  @override
  String get accessControl_noContacts =>
      'Inga kontakter att lägga till. Noder visas här när du har hört deras advert.';

  @override
  String get accessControl_changeRole => 'Ändra roll';

  @override
  String get accessControl_remove => 'Ta bort åtkomst';

  @override
  String accessControl_removeConfirm(String name) {
    return 'Ta bort $name från åtkomstlistan? Då behövs lösenordet för att logga in.';
  }

  @override
  String get accessControl_removeSelfWarning =>
      'Det här är du. Om du tar bort dig själv behöver du administratörslösenordet för att hantera noden igen.';

  @override
  String get accessControl_unknownKeyNote =>
      'Finns inte bland dina kontakter. Att ändra rollen kräver nyare nodfirmware; att ta bort fungerar alltid.';

  @override
  String get accessControl_prefixUnsupported =>
      'Nodens firmware kan inte ändra rollen för någon som inte finns bland dina kontakter. Du kan fortfarande ta bort dem.';

  @override
  String get accessControl_empty => 'Ingen finns på åtkomstlistan';

  @override
  String get accessControl_emptyHint =>
      'Lägg till personer så att de kan logga in utan lösenord.';

  @override
  String get accessControl_loading => 'Frågar noden efter åtkomstlistan…';

  @override
  String get accessControl_timeout =>
      'Noden svarade inte. Kontrollera vägen och försök igen.';

  @override
  String get accessControl_maybeIncomplete =>
      'Noden skickade en full sida och dess firmware kan inte skicka fler, så vissa poster kan saknas.';

  @override
  String get accessControl_saved => 'Åtkomstlistan uppdaterad';

  @override
  String accessControl_failed(String reply) {
    return 'Noden avvisade ändringen: $reply';
  }

  @override
  String get companionCli_title => 'Kommandorad';

  @override
  String get companionCli_tileSubtitle => 'Kör kommandon på din radio';

  @override
  String get companionCli_warning =>
      'Kommandon körs på den anslutna radion och kan ändra dess inställningar eller starta om den.';

  @override
  String get companionCli_hint => 'Skriv ett kommando, t.ex. ver';

  @override
  String get companionCli_send => 'Kör kommando';

  @override
  String get companionCli_noReply => 'Inget svar. Radion startar kanske om.';

  @override
  String get companionCli_empty =>
      'Prova ett av kommandona ovan eller skriv ett eget.';

  @override
  String get wifi_title => 'Wi‑Fi';

  @override
  String get wifi_tileSubtitle => 'Anslut radion till ett Wi‑Fi-nätverk';

  @override
  String get wifi_unsupported => 'Radions firmware har inget Wi‑Fi.';

  @override
  String get wifi_enabled => 'Använd Wi‑Fi';

  @override
  String get wifi_status => 'Status';

  @override
  String get wifi_connected => 'Ansluten';

  @override
  String wifi_connectedIp(String ip) {
    return 'Ansluten · $ip';
  }

  @override
  String get wifi_disconnected => 'Inte ansluten';

  @override
  String get wifi_network => 'Nätverksnamn (SSID)';

  @override
  String get wifi_password => 'Lösenord';

  @override
  String get wifi_passwordKeep =>
      'Lämna tomt för att behålla nuvarande lösenord';

  @override
  String get wifi_save => 'Spara';

  @override
  String get wifi_forget => 'Glöm nätverk';

  @override
  String get wifi_forgetConfirm =>
      'Ta bort det sparade nätverket och lösenordet från radion?';

  @override
  String get wifi_rebootNeeded =>
      'Sparat. Starta om radion för att tillämpa Wi‑Fi-ändringarna.';

  @override
  String get wifi_rebootNow => 'Starta om radion';

  @override
  String get wifi_rebootConfirm =>
      'Starta om radion nu? Appen kopplas från och du behöver ansluta igen.';

  @override
  String get wifi_loadFailed =>
      'Kunde inte läsa Wi‑Fi-inställningarna från radion.';

  @override
  String get wifi_retry => 'Försök igen';

  @override
  String wifi_saveFailed(String reply) {
    return 'Radion accepterade inte ändringen: $reply';
  }

  @override
  String get accessControl_refresh => 'Uppdatera';

  @override
  String get common_cancel => 'Avbryt';

  @override
  String get common_ok => 'OK';

  @override
  String get common_connect => 'Anslut';

  @override
  String get common_unknownDevice => 'Okänd enhet';

  @override
  String get common_save => 'Spara';

  @override
  String get common_delete => 'Radera';

  @override
  String get common_deleteAll => 'Ta bort alla';

  @override
  String get common_close => 'Stäng';

  @override
  String get common_done => 'Klar';

  @override
  String get common_edit => 'Redigera';

  @override
  String get common_add => 'Lägg till';

  @override
  String get common_settings => 'Inställningar';

  @override
  String get common_disconnect => 'Koppla från';

  @override
  String get common_connected => 'Ansluten';

  @override
  String get common_disconnected => 'Frånkopplad';

  @override
  String get common_create => 'Skapa';

  @override
  String get common_continue => 'Fortsätt';

  @override
  String get common_share => 'Dela';

  @override
  String get common_copy => 'Kopiera';

  @override
  String get common_retry => 'Försök igen';

  @override
  String get common_hide => 'Dölj';

  @override
  String get common_remove => 'Ta bort';

  @override
  String get common_enable => 'Aktivera';

  @override
  String get common_disable => 'Inaktivera';

  @override
  String get common_undo => 'Ångra';

  @override
  String get messageStatus_sent => 'Skickat';

  @override
  String get messageStatus_delivered => 'Levererat';

  @override
  String get messageStatus_pending => 'Skickar';

  @override
  String get messageStatus_failed => 'Misslyckades med att skicka';

  @override
  String get messageStatus_repeated => 'Hördes upprepade gånger';

  @override
  String get urlImage_enable => 'Aktivera URL-bilder';

  @override
  String get urlImage_possible =>
      'Möjlig URL-bild; aktivera den i Inställningar.';

  @override
  String get common_reboot => 'Starta om';

  @override
  String get common_loading => 'Laddar...';

  @override
  String get common_notAvailable => '—';

  @override
  String common_voltageValue(String volts) {
    return '$volts V';
  }

  @override
  String common_percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get common_autoRefresh => 'Automatisk uppdatering';

  @override
  String get common_interval => 'Intervall';

  @override
  String get scanner_title => 'MeshCore – Öppen version';

  @override
  String get connectionChoiceUsbLabel => 'USB';

  @override
  String get connectionChoiceBluetoothLabel => 'Bluetooth';

  @override
  String get connectionChoiceTcpLabel => 'TCP';

  @override
  String get tcpScreenTitle => 'Anslut via TCP';

  @override
  String get tcpHostLabel => 'IP-adress';

  @override
  String get tcpHostHint => '192.168.40.10';

  @override
  String get tcpPortLabel => 'Port';

  @override
  String get tcpPortHint => '5000';

  @override
  String get tcpStatus_notConnected => 'Ange slutpunkt och anslut';

  @override
  String tcpStatus_connectingTo(String endpoint) {
    return 'Anslutning till $endpoint...';
  }

  @override
  String get tcpErrorHostRequired => 'IP-adress krävs.';

  @override
  String get tcpErrorPortInvalid => 'Porten måste vara mellan 1 och 65535.';

  @override
  String get tcpErrorUnsupported =>
      'TCP-transport fungerar inte på denna plattform.';

  @override
  String get tcpErrorTimedOut => 'Tidsgränsen för TCP-anslutningen överskreds.';

  @override
  String tcpConnectionFailed(String error) {
    return 'Fel vid TCP-anslutning: $error';
  }

  @override
  String get usbScreenTitle => 'Anslut via USB';

  @override
  String get usbScreenSubtitle =>
      'Välj en detekterad seriell enhet och anslut direkt till din MeshCore-nod.';

  @override
  String get usbScreenStatus => 'Välj en USB-enhet';

  @override
  String get usbScreenNote =>
      'USB-seriell kommunikation är aktiv på stödda Android-enheter och på skrivbordsplattformar.';

  @override
  String get usbScreenEmptyState =>
      'Inga USB-enheter hittades. Anslut en och uppdatera.';

  @override
  String get usbErrorPermissionDenied => 'Tillgången via USB nekas.';

  @override
  String get usbErrorDeviceMissing =>
      'Den valda USB-enheten är inte längre tillgänglig.';

  @override
  String get usbErrorInvalidPort => 'Välj en giltig USB-enhet.';

  @override
  String get usbErrorBusy =>
      'En annan förfrågan om USB-anslutning är redan pågående.';

  @override
  String get usbErrorNotConnected => 'Ingen USB-enhet är ansluten.';

  @override
  String get usbErrorOpenFailed =>
      'Det gick inte att öppna den valda USB-enheten.';

  @override
  String get usbErrorConnectFailed =>
      'Det gick inte att ansluta till den valda USB-enheten.';

  @override
  String get usbErrorUnsupported =>
      'USB-seriell kommunikation stöds inte på denna plattform.';

  @override
  String get usbErrorAlreadyActive => 'En USB-anslutning är redan aktiv.';

  @override
  String get usbErrorNoDeviceSelected => 'Ingen USB-enhet valdes.';

  @override
  String get usbErrorPortClosed => 'USB-anslutningen är inte aktiv.';

  @override
  String get usbErrorConnectTimedOut =>
      'Anslutningen tog för lång tid. Kontrollera att enheten har USB Companion-firmware.';

  @override
  String get usbFallbackDeviceName => 'Web Serial-enhet';

  @override
  String get usbStatus_notConnected => 'Välj en USB-enhet';

  @override
  String get usbStatus_connecting => 'Anslutning till USB-enhet...';

  @override
  String get usbStatus_searching => 'Söker efter USB-enheter...';

  @override
  String usbConnectionFailed(String error) {
    return 'Fel vid USB-anslutning: $error';
  }

  @override
  String get scanner_scanning => 'Söker efter enheter...';

  @override
  String get scanner_connecting => 'Ansluter...';

  @override
  String get scanner_disconnecting => 'Anslutning bryts...';

  @override
  String get scanner_notConnected => 'Inte ansluten';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Ansluten till $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Söker efter MeshCore-enheter...';

  @override
  String get scanner_tapToScan => 'Tryck Skanna för att hitta MeshCore-enheter';

  @override
  String scanner_connectionFailed(String error) {
    return 'Anslutning misslyckades: $error';
  }

  @override
  String get scanner_stop => 'Stoppa';

  @override
  String get scanner_scan => 'Skanna';

  @override
  String get scanner_bluetoothOff => 'Bluetooth är avstängt';

  @override
  String get scanner_bluetoothOffMessage =>
      'Vänligen aktivera Bluetooth för att söka efter enheter.';

  @override
  String get scanner_chromeRequired => 'Chrome-webbläsare krävs';

  @override
  String get scanner_chromeRequiredMessage =>
      'Den här webbappen kräver Google Chrome eller en Chromium-baserad webbläsare för Bluetooth-stöd.';

  @override
  String get scanner_enableBluetooth => 'Aktivera Bluetooth';

  @override
  String get scanner_bluetoothWebUnsupported =>
      'Bluetooth är inte tillgängligt i webbläsaren. Anslut istället via USB.';

  @override
  String get device_quickSwitch => 'Snabb växling';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Inställningar';

  @override
  String get settings_deviceInfo => 'Enhetsinformation';

  @override
  String get settings_appSettings => 'Appinställningar';

  @override
  String get settings_appSettingsSubtitle =>
      'Notifieringar, meddelanden och kartinställningar';

  @override
  String get settings_nodeSettings => 'Nodinställningar';

  @override
  String get settings_nodeName => 'Nodnamn';

  @override
  String get settings_nodeNameNotSet => 'Inte angivet';

  @override
  String get settings_nodeNameHint => 'Ange nodnamn';

  @override
  String get settings_nodeNameUpdated => 'Namn uppdaterat';

  @override
  String get settings_radioSettings => 'Radioinställningar';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frekvens, effekt, spridningsfaktor';

  @override
  String get settings_radioSettingsUpdated =>
      'Radioinställningarna har uppdaterats';

  @override
  String get settings_regionSettings => 'Regioner';

  @override
  String get settings_regionSettingsSubtitle => 'Hämtade regioner';

  @override
  String get settings_corridorRegion => 'Korridorregion';

  @override
  String get settings_corridorRegionDefault => '#corridor (standard)';

  @override
  String get settings_corridorRegionHelp =>
      'Flood corridor-paket märks med den här regionen. Repeatrar utan korridorfirmware vidarebefordrar dem bara om de tillåter regionen. Lämna tomt för standardtaggen #corridor.';

  @override
  String get settings_corridorRegionHint => 'Regionnamn';

  @override
  String get settings_corridorRegionUseDefault => 'Använd standard';

  @override
  String get settings_corridorRegionUpdated => 'Korridorregionen uppdaterad';

  @override
  String get settings_corridorRegionFailed =>
      'Kunde inte uppdatera korridorregionen';

  @override
  String get settings_regionManagement_screenTitle => 'Regionhantering';

  @override
  String get settings_regionNameHint => 'Ange regionnamn';

  @override
  String get settings_regionAddRegion => 'Lägg till region';

  @override
  String get settings_regionFetchRegions => 'Hämta regioner från repeaters';

  @override
  String get settings_regionFetchRegionsFail => 'Ingen region hittades';

  @override
  String get settings_regionFetchRegionsAlreadyExists =>
      'Den här regionen har redan lagts till';

  @override
  String get settings_regionName => 'Regionnamn';

  @override
  String get settings_regionDeleted => 'Regionen har tagits bort';

  @override
  String get settings_deleteRegion => 'Radera region';

  @override
  String settings_deleteRegionConfirm(String region) {
    return 'Ta bort “$region” från regionlistan?';
  }

  @override
  String get settings_location => 'Plats';

  @override
  String get settings_locationSubtitle => 'GPS-koordinater';

  @override
  String get settings_locationUpdated => 'Plats uppdaterad';

  @override
  String get settings_locationBothRequired => 'Ange både latitud och longitud.';

  @override
  String get settings_locationInvalid => 'Ogiltig latitud eller longitud.';

  @override
  String get settings_locationGPSEnable => 'Aktivera GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Aktivera automatiska uppdateringar av platsen med hjälp av GPS.';

  @override
  String get settings_locationIntervalSec => 'Interval för GPS (Sekunder)';

  @override
  String get settings_locationIntervalInvalid =>
      'Intervalet måste vara minst 60 sekunder och mindre än 86400 sekunder.';

  @override
  String get settings_latitude => 'Latitud';

  @override
  String get settings_longitude => 'Longitud';

  @override
  String get settings_contactSettings => 'Kontaktinställningar';

  @override
  String get settings_contactSettingsSubtitle =>
      'Inställningar för hur kontakter läggs till.';

  @override
  String get settings_privacyMode => 'Privatläge';

  @override
  String get settings_privacyModeSubtitle => 'Dölj namn/plats i annonser';

  @override
  String get settings_privacyModeToggle =>
      'Aktivera privatläge för att dölja ditt namn och din plats i annonser.';

  @override
  String get settings_privacyModeEnabled => 'Privatläget är aktiverat';

  @override
  String get settings_privacyModeDisabled => 'Privatläge är avstängt';

  @override
  String get settings_privacy => 'Inställningar för sekretess';

  @override
  String get settings_privacySubtitle =>
      'Kontrollera vilken information som delas.';

  @override
  String get settings_privacySettingsDescription =>
      'Välj vilken information din enhet delar med andra.';

  @override
  String get settings_denyAll => 'Neka alla';

  @override
  String get settings_allowByContact => 'Tillåt via kontaktflaggor';

  @override
  String get settings_allowAll => 'Tillåt alla';

  @override
  String get settings_telemetryBaseMode => 'Telemetribasläge';

  @override
  String get settings_telemetryLocationMode => 'Telemetriläge för position';

  @override
  String get settings_telemetryEnvironmentMode => 'Telemetriläge för miljö';

  @override
  String get settings_advertLocation => 'Annonsplacering';

  @override
  String get settings_advertLocationSubtitle => 'Inkludera plats i annonsen';

  @override
  String get settings_autoZeroHopAdvertOnGpsUpdate =>
      'Automatisk nollhoppsannons vid GPS-uppdatering';

  @override
  String get settings_autoZeroHopAdvertOnGpsUpdateSubtitle =>
      'När GPS-positionen ändras skickas en nollhoppsannons (kräver plats i annonsen).';

  @override
  String get settings_multiAck => 'Flera bekräftelser';

  @override
  String get settings_telemetryModeUpdated => 'Telemetri-läge uppdaterat';

  @override
  String get settings_actions => 'Åtgärder';

  @override
  String get settings_deleteAllPaths => 'Radera alla rutter';

  @override
  String get settings_deleteAllPathsSubtitle =>
      'Rensa all ruttdata från kontakter.';

  @override
  String get settings_sendAdvertisement => 'Skicka annons';

  @override
  String get settings_sendAdvertisementSubtitle => 'Sänd din närvaro nu';

  @override
  String get settings_advertisementSent => 'Annons skickad';

  @override
  String get settings_syncTime => 'Synkronisera tid';

  @override
  String get settings_syncTimeSubtitle => 'Ställ enheten till telefonens tid';

  @override
  String get settings_timeSynchronized => 'Tidssynkroniserat';

  @override
  String get settings_refreshContacts => 'Uppdatera Kontakter';

  @override
  String get settings_refreshContactsSubtitle =>
      'Ladda om kontaktlistan från enheten';

  @override
  String get settings_rebootDevice => 'Starta om enheten';

  @override
  String get settings_rebootDeviceSubtitle => 'Starta om MeshCore-enheten';

  @override
  String get settings_rebootDeviceConfirm =>
      'Är du säker på att du vill starta om enheten? Du kommer att bli avkopplad.';

  @override
  String get settings_debug => 'Felsök';

  @override
  String get settings_companionDebugLog => 'Companion-felsökningslogg';

  @override
  String get settings_companionDebugLogSubtitle =>
      'BLE/TCP/USB-kommandon, svar och rådata';

  @override
  String get settings_appDebugLog => 'Appens felsökningslogg';

  @override
  String get settings_appDebugLogSubtitle =>
      'Felsökningsmeddelanden från appen';

  @override
  String get settings_about => 'Om';

  @override
  String settings_aboutVersion(String version) {
    return 'NOTORYX Core version $version';
  }

  @override
  String get settings_aboutLegalese => '2026 MeshCore Open Source Project';

  @override
  String get settings_aboutDescription =>
      'En Flutter-klient med öppen källkod för MeshCore-enheter i LoRa-meshnät.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'LOS-höjddata: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Namn';

  @override
  String get settings_infoId => 'ID';

  @override
  String get settings_infoStatus => 'Status';

  @override
  String get settings_infoBattery => 'Batteri';

  @override
  String get settings_infoPublicKey => 'Publik nyckel';

  @override
  String get settings_infoContactsCount => 'Antal kontakter';

  @override
  String get settings_infoChannelCount => 'Antal kanaler';

  @override
  String get settings_infoHardware => 'Hardware';

  @override
  String get settings_infoFirmware => 'Firmware';

  @override
  String get settings_presets => 'Fördefinierade inställningar';

  @override
  String get settings_frequency => 'Frekvens (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 - 2500,0';

  @override
  String get settings_frequencyInvalid => 'Ogiltig frekvens (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Bandbredd';

  @override
  String get settings_spreadingFactor => 'Spridningsfaktor';

  @override
  String get settings_codingRate => 'Kodningsgrad';

  @override
  String get settings_txPower => 'TX-effekt (dBm)';

  @override
  String get settings_txPowerHelper => '0 – 22';

  @override
  String get settings_txPowerInvalid => 'Ogiltig TX-effekt (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Upprepa utan elnät';

  @override
  String get settings_clientRepeatSubtitle =>
      'Låt enheten repetera nätpaket för andra användare.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'För att kunna kommunicera utanför elnätet krävs frekvenserna 433, 869 eller 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Fel: $message';
  }

  @override
  String get appSettings_title => 'Appinställningar';

  @override
  String get appSettings_appearance => 'Utseende';

  @override
  String get appSettings_theme => 'Tema';

  @override
  String get appSettings_themeSystem => 'Systemstandard';

  @override
  String get appSettings_themeLight => 'Ljust';

  @override
  String get appSettings_themeDark => 'Mörkt';

  @override
  String get appSettings_language => 'Språk';

  @override
  String get appSettings_languageSystem => 'Systemstandard';

  @override
  String get appSettings_languageEn => 'Engelska';

  @override
  String get appSettings_languageFr => 'Franska';

  @override
  String get appSettings_languageEs => 'Spanska';

  @override
  String get appSettings_languageDe => 'Tyska';

  @override
  String get appSettings_languagePl => 'Polska';

  @override
  String get appSettings_languageSl => 'Sloveniska';

  @override
  String get appSettings_languagePt => 'Portugisiska';

  @override
  String get appSettings_languageIt => 'Italienska';

  @override
  String get appSettings_languageZh => 'Kinesiska';

  @override
  String get appSettings_languageSv => 'Svenska';

  @override
  String get appSettings_languageNl => 'Nederländska';

  @override
  String get appSettings_languageSk => 'Slovakiska';

  @override
  String get appSettings_languageBg => 'Bulgariska';

  @override
  String get appSettings_languageRu => 'Ryska';

  @override
  String get appSettings_languageUk => 'Ukrainska';

  @override
  String get repeater_pathHashModeOption0 => '0 - 1 byte';

  @override
  String get repeater_pathHashModeOption1 => '1 - 2 byte';

  @override
  String get repeater_pathHashModeOption2 => '2 - 3 byte';

  @override
  String get repeater_pathHashModeOption3 => '3 - 4 byte';

  @override
  String get appSettings_enableMessageTracing => 'Aktivera meddelandespårning';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Visa detaljerad routing- och tidsmetadata för meddelanden';

  @override
  String get appSettings_notifications => 'Notifieringar';

  @override
  String get appSettings_enableNotifications => 'Aktivera notifieringar';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Ta emot notifieringar för meddelanden och annonser';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Tillåtelse för notifikationer nekad';

  @override
  String get appSettings_notificationsEnabled => 'Notifieringar aktiverade';

  @override
  String get appSettings_notificationsDisabled => 'Notifieringar inaktiverade';

  @override
  String get appSettings_messageNotifications => 'Meddelandenotifieringar';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Visa en notifiering när nya meddelanden tas emot';

  @override
  String get appSettings_channelMessageNotifications => 'Kanalnotifieringar';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Visa en notifiering när kanalmeddelanden tas emot';

  @override
  String get appSettings_advertisementNotifications => 'Annonsnotifieringar';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Visa en notifiering när nya noder upptäcks';

  @override
  String get appSettings_messaging => 'Meddelanden';

  @override
  String get appSettings_clearPathOnMaxRetry =>
      'Rensa rutt efter maximalt antal försök';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Återställ kontaktens rutt efter 5 misslyckade sändningsförsök';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Rutter rensas efter 5 misslyckade försök';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Rutter rensas inte automatiskt';

  @override
  String get appSettings_autoRouteRotation => 'Automatisk ruttrotation';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Växla mellan de bästa rutterna och flood-läge';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatisk ruttrotation är aktiverad';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatisk ruttrotation är avstängd';

  @override
  String get appSettings_maxRouteWeight => 'Maximal ruttvikt';

  @override
  String get appSettings_maxRouteWeightSubtitle =>
      'Maximal vikt som en rutt kan samla efter lyckade leveranser';

  @override
  String get appSettings_initialRouteWeight => 'Initial vikt för rutt';

  @override
  String get appSettings_initialRouteWeightSubtitle =>
      'Startvikt för nyligen upptäckta rutter';

  @override
  String get appSettings_routeWeightSuccessIncrement =>
      'Ökning av vikt för framgång';

  @override
  String get appSettings_routeWeightSuccessIncrementSubtitle =>
      'Vikt som läggs till en rutt efter en lyckad leverans';

  @override
  String get appSettings_routeWeightFailureDecrement =>
      'Minskning av vikten för misslyckande';

  @override
  String get appSettings_routeWeightFailureDecrementSubtitle =>
      'Vikt som tas bort från en rutt efter en misslyckad leverans';

  @override
  String get appSettings_maxMessageRetries => 'Maximalt antal försök';

  @override
  String get appSettings_maxMessageRetriesSubtitle =>
      'Antal försök att skicka om ett meddelande innan det markeras som misslyckat.';

  @override
  String get appSettings_battery => 'Batteri';

  @override
  String get appSettings_batteryChemistry => 'Batterikemi';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Ställ in per enhet ($deviceName)';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Anslut till en enhet för att välja';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0-4,2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6–3,65V)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3,0-4,2V)';

  @override
  String get appSettings_batteryLipoHv => 'LiPo HV (3,0-4,35 V)';

  @override
  String get appSettings_mapDisplay => 'Kartvisning';

  @override
  String get appSettings_showRepeaters => 'Visa repeaters';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Visa repeaternoder på kartan';

  @override
  String get appSettings_showChatNodes => 'Visa Chattnoder';

  @override
  String get appSettings_showChatNodesSubtitle => 'Visa chattnoder på kartan';

  @override
  String get appSettings_showOtherNodes => 'Visa andra noder';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Visa andra nodtyper på kartan';

  @override
  String get appSettings_timeFilter => 'Tidsfilter';

  @override
  String get appSettings_timeFilterShowAll => 'Visa alla noder';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Visa noder från de senaste $hours timmarna';
  }

  @override
  String get appSettings_mapTimeFilter => 'Tidsfilter för kartan';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Visa noder som upptäckts inom:';

  @override
  String get appSettings_allTime => 'Alla tider';

  @override
  String get appSettings_lastHour => 'Sista timmen';

  @override
  String get appSettings_last6Hours => 'De senaste 6 timmarna';

  @override
  String get appSettings_last24Hours => 'De senaste 24 timmarna';

  @override
  String get appSettings_lastWeek => 'Förra veckan';

  @override
  String get appSettings_rasterTileSource => 'Källa för rasterplattor';

  @override
  String get appSettings_stadiaEndpoint => 'Stadia-slutpunkt';

  @override
  String get appSettings_stadiaApiKey => 'Stadia API-nyckel';

  @override
  String get appSettings_stadiaApiKeyRequired =>
      'Krävs för att använda Stadia Maps';

  @override
  String appSettings_stadiaApiKeyConfigured(String maskedKey) {
    return 'Konfigurerad: $maskedKey';
  }

  @override
  String get appSettings_stadiaApiKeyDialogDescription =>
      'Ange din Stadia Maps API-nyckel. Appen använder den för förfrågningar om rasterplattor.';

  @override
  String get appSettings_offlineMapCache => 'Offline Kartcache';

  @override
  String get appSettings_unitsTitle => 'Enheter';

  @override
  String get appSettings_unitsMetric => 'Metriskt (m/km/°C)';

  @override
  String get appSettings_unitsImperial => 'Imperialt (ft / mi / °F)';

  @override
  String get appSettings_noAreaSelected => 'Ingen area markerad';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Område markerat (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Felsök';

  @override
  String get appSettings_appDebugLogging => 'App-felsökning och loggning';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Logga appens felsökningsmeddelanden för felsökning';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'App felsökning loggning aktiverad';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'App felsökning är avstängd';

  @override
  String get contacts_title => 'Kontakter';

  @override
  String get contacts_noContacts => 'Inga kontakter ännu';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakter kommer att visas när enheter annonserar.';

  @override
  String get contacts_unread => 'Oläst';

  @override
  String get contacts_searchContactsNoNumber => 'Sök kontakter...';

  @override
  String contacts_searchContacts(int number, String str) {
    return 'Sök $number$str kontakter…';
  }

  @override
  String contacts_searchFavorites(int number, String str) {
    return 'Sök $number$str Favoriter...';
  }

  @override
  String contacts_searchUsers(int number, String str) {
    return 'Sök $number$str användare...';
  }

  @override
  String contacts_searchRepeaters(int number, String str) {
    return 'Sök $number$str repeaters…';
  }

  @override
  String contacts_searchRoomServers(int number, String str) {
    return 'Sök $number$str rumsservrar…';
  }

  @override
  String get contacts_noUnreadContacts => 'Inga oinlästa kontakter';

  @override
  String get contacts_noContactsFound =>
      'Inga kontakter eller grupper hittades.';

  @override
  String get contacts_deleteContact => 'Ta bort Kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Ta bort $contactName från kontakter?';
  }

  @override
  String get contacts_manageRepeater => 'Hantera repeater';

  @override
  String get contacts_manageRoom => 'Hantera rumsserver';

  @override
  String get contacts_roomLogin => 'Inloggning på rumsserver';

  @override
  String get contacts_openChat => 'Öppna chatt';

  @override
  String get contacts_editGroup => 'Redigera Grupp';

  @override
  String get contacts_deleteGroup => 'Ta bort Grupp';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Ta bort $groupName?';
  }

  @override
  String get contacts_newGroup => 'Ny grupp';

  @override
  String get contacts_moreOptions => 'Fler alternativ';

  @override
  String get contacts_searchOpen => 'Sök efter kontakter';

  @override
  String get contacts_searchClose => 'Stäng sökning';

  @override
  String get contacts_groupName => 'Gruppnamn';

  @override
  String get contacts_groupNameRequired => 'Gruppnamnet är obligatoriskt';

  @override
  String get contacts_groupNameReserved => 'Detta gruppnamn är reserverat';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Gruppen \"$name\" finns redan.';
  }

  @override
  String get contacts_filterContacts => 'Filtrera kontakter...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Inga kontakter matchar ditt filter';

  @override
  String get contacts_noMembers => 'Inga medlemmar';

  @override
  String get contacts_lastSeenNow => 'Senast synlig nu';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Senast sedd $minutes min sedan';
  }

  @override
  String get contacts_lastSeenHourAgo => 'Senast sedd för 1 timme sedan';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Senast sedd $hours timmar sedan';
  }

  @override
  String get contacts_lastSeenDayAgo => 'Senast sedd för 1 dag sedan';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Senast synlig $days dagar sedan';
  }

  @override
  String get contact_info => 'Kontaktinformation';

  @override
  String get contact_settings => 'Kontaktinställningar';

  @override
  String get contact_telemetry => 'Telemetri';

  @override
  String get contact_lastSeen => 'Senast sedd';

  @override
  String get contact_clearChat => 'Rensa Chatt';

  @override
  String get contact_teleBase => 'Telemetribas';

  @override
  String get contact_teleBaseSubtitle =>
      'Tillåt delning av batterinivå och grundläggande telemetri';

  @override
  String get contact_teleLoc => 'Telemetridata plats';

  @override
  String get contact_teleLocSubtitle => 'Tillåt delning av platsdata';

  @override
  String get contact_teleEnv => 'Telemetri Miljö';

  @override
  String get contact_teleEnvSubtitle => 'Tillåt delning av miljösensordata';

  @override
  String get channels_title => 'Kanaler';

  @override
  String get channels_noChannelsConfigured => 'Inga kanaler konfigurerade';

  @override
  String get channels_addPublicChannel => 'Lägg till publik kanal';

  @override
  String get channels_searchChannels => 'Sök kanaler...';

  @override
  String get channels_noChannelsFound => 'Inga kanaler hittades';

  @override
  String channels_channelIndex(int index) {
    return 'Kanal $index';
  }

  @override
  String get channels_public => 'Publik';

  @override
  String channels_via(String path) {
    return 'via $path';
  }

  @override
  String get channels_viaMqtt => 'via MQTT';

  @override
  String get channels_viaMqttSemantics =>
      'Mottaget via MQTT, inte hört av din radio';

  @override
  String get channels_private => 'Privat';

  @override
  String get channels_editChannel => 'Redigera kanal';

  @override
  String get channels_muteChannel => 'Tysta kanal';

  @override
  String get channels_unmuteChannel => 'Slå på ljud för kanal';

  @override
  String get channels_notifyMode => 'Aviseringar';

  @override
  String get channels_notifyAll => 'Alla meddelanden';

  @override
  String get channels_notifyMentions => 'Bara när jag nämns';

  @override
  String get channels_notifyMuted => 'Tystad';

  @override
  String get channels_deleteChannel => 'Ta bort kanal';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Radera \"$name\"? Detta kan inte ångras.';
  }

  @override
  String channels_channelDeleteFailed(String name) {
    return 'Det gick inte att ta bort kanalen \"$name\"';
  }

  @override
  String channels_channelDeleted(String name) {
    return 'Kanalen \"$name\" raderad';
  }

  @override
  String get channels_addChannel => 'Lägg till kanal';

  @override
  String get channels_channelIndexLabel => 'Kanalindex';

  @override
  String get channels_channelName => 'Kanalnamn';

  @override
  String get channels_usePublicChannel => 'Använd publik kanal';

  @override
  String get channels_standardPublicPsk => 'Standard-PSK för publik kanal';

  @override
  String get channels_pskHex => 'PSK (hex)';

  @override
  String get channels_generateRandomPsk => 'Generera slumpmässig PSK';

  @override
  String get channels_enterChannelName => 'Ange ett kanalnamn';

  @override
  String get channels_pskMustBe32Hex => 'PSK måste vara 32 hexadecimala tecken';

  @override
  String channels_channelAdded(String name) {
    return 'Kanalen \"$name\" har lagts till';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Redigera Kanal $index';
  }

  @override
  String get channels_smazCompression => 'SMAZ-komprimering';

  @override
  String get channels_cyr2latCompression => 'Cyr2Lat-komprimering';

  @override
  String get channels_cyr2latCompressionDscr =>
      'Ersätter vissa kyrilliska tecken med latinska tecken när du skickar.';

  @override
  String get channels_cyr2latSettingsHeading => 'Inställningar för Cyr2Lat';

  @override
  String get channels_cyr2latSettingsSubheading => 'Ersättningslista';

  @override
  String get channels_cyr2latSettingsDscr =>
      'Redigera JSON-konfigurationen för teckenersättning';

  @override
  String get channels_cyr2latSettingsDialogHint => 'JSON-ersättningskarta';

  @override
  String channels_cyr2latSettingsDialogWrongJSON(Object error) {
    return 'Felaktig JSON: $error';
  }

  @override
  String channels_channelUpdated(String name) {
    return 'Kanalen \"$name\" har uppdaterats';
  }

  @override
  String get settings_cyr2latProfileAdd => 'Lägg till Cyr2Lat-profil';

  @override
  String get settings_cyr2latProfileName => 'Profilnamn';

  @override
  String get settings_cyr2latProfileNameEmpty =>
      'Profilnamnet får inte vara tomt';

  @override
  String get settings_cyr2latProfileAdded => 'Profilen har lagts till';

  @override
  String get settings_cyr2latProfileUpdated => 'Profilen har uppdaterats';

  @override
  String get settings_cyr2latProfileEdit => 'Redigera Cyr2Lat-profil';

  @override
  String get settings_cyr2latProfileDelete => 'Ta bort Cyr2Lat-profil';

  @override
  String get settings_cyr2latProfileDeleted => 'Profilen har tagits bort';

  @override
  String settings_cyr2latProfileDeleteDscr(String name) {
    return 'Är du säker på att du vill ta bort profilen \"$name\"?';
  }

  @override
  String get channels_publicChannelAdded => 'Publik kanal har lagts till';

  @override
  String get channels_sortBy => 'Sortera efter';

  @override
  String get channels_sortManual => 'Manuell';

  @override
  String get channels_sortAZ => 'A-Ö';

  @override
  String get channels_sortLatestMessages => 'Senaste meddelanden';

  @override
  String get channels_sortUnread => 'Oläst';

  @override
  String get channels_createPrivateChannel => 'Skapa en privat kanal';

  @override
  String get channels_createPrivateChannelDesc =>
      'Säkrad med en hemlig nyckel.';

  @override
  String get channels_joinPrivateChannel => 'Gå med i en privat kanal';

  @override
  String get channels_joinPrivateChannelDesc => 'Skriv in nyckeln manuellt.';

  @override
  String get channels_joinPublicChannel => 'Gå med i den publika kanalen';

  @override
  String get channels_joinPublicChannelDesc =>
      'Alla kan gå med i den här kanalen.';

  @override
  String get channels_joinHashtagChannel => 'Gå med i en hashtagkanal';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Vem som helst kan gå med i hashtagkanaler.';

  @override
  String get channels_scanQrCode => 'Skanna en QR-kod';

  @override
  String get channels_scanQrCodeComingSoon => 'Kommer snart';

  @override
  String get channels_enterHashtag => 'Ange hashtag';

  @override
  String get channels_hashtagHint => 't.ex. #team';

  @override
  String channels_regionSetTo(String region) {
    return 'Region: $region';
  }

  @override
  String get channels_regionNotSet => 'Region: ingen';

  @override
  String get channels_regionSelect_Title => 'Välj en region';

  @override
  String get channels_clearRegion => 'Rensa region';

  @override
  String get chat_noMessages => 'Inga meddelanden ännu';

  @override
  String get chat_sendMessage => 'Skicka meddelande';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Skicka ett meddelande till $contactName';
  }

  @override
  String get chat_sendMessageToStart =>
      'Skicka ett meddelande för att komma igång';

  @override
  String get chat_originalMessageNotFound =>
      'Originalt meddelande hittades inte';

  @override
  String chat_replyingTo(String name) {
    return 'Svara till $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Svara till $name';
  }

  @override
  String get chat_location => 'Plats';

  @override
  String get chat_typeMessage => 'Skriv ett meddelande...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Meddelandet är för långt (max $maxBytes byte).';
  }

  @override
  String chat_airtimeEstimate(String seconds) {
    return '≈$seconds s sändtid';
  }

  @override
  String get chat_messageCopied => 'Meddelandet kopierades';

  @override
  String get chat_messageDeleted => 'Meddelandet raderat';

  @override
  String get chat_retryingMessage => 'Försöker igen';

  @override
  String chat_retryCount(int current, int max) {
    return 'Försök igen $current/$max';
  }

  @override
  String get chat_selectSendAction => 'Välj sändningsåtgärd';

  @override
  String get chat_sendGif => 'Skicka GIF';

  @override
  String get chat_limitToArea => 'Begränsa till ett område';

  @override
  String get chat_limitToAreaTitle => 'Skicka bara inom…';

  @override
  String get chat_limitToAreaHelp =>
      'Repeatrar med flood corridor-firmware vidarebefordrar bara meddelandet inom området. Andra repeatrar släpper det om de inte tillåter din korridorregion.';

  @override
  String chat_limitToAreaRadius(int km) {
    return '$km km från dig';
  }

  @override
  String chat_limitToAreaActive(int km) {
    return 'Bara inom $km km från dig';
  }

  @override
  String get chat_limitToAreaOff => 'Ingen gräns';

  @override
  String get chat_limitToAreaNeedsPosition =>
      'Ange radions position för att begränsa meddelanden till ett område.';

  @override
  String get chat_sendImageLora => 'Skicka bild via MeshCore';

  @override
  String get chat_imagePickFailed => 'Kunde inte öppna bilden';

  @override
  String get chat_receivedGif => 'Mottagit en GIF';

  @override
  String get chat_reply => 'Svara';

  @override
  String get chat_addReaction => 'Lägg till reaktion';

  @override
  String get chat_me => 'Mig';

  @override
  String get reaction_report => 'Emoji-reaktioner';

  @override
  String get emojiCategorySmileys => 'Emojis';

  @override
  String get emojiCategoryGestures => 'Gestikuleringar';

  @override
  String get emojiCategoryHearts => 'Hjärtan';

  @override
  String get emojiCategoryObjects => 'Objekt';

  @override
  String get gifPicker_title => 'Välj en GIF';

  @override
  String get gifPicker_searchHint => 'Sök GIF:ar...';

  @override
  String get gifPicker_poweredBy => 'Drivet av GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Inga GIF-filer hittades';

  @override
  String get gifPicker_failedLoad => 'Kunde inte ladda GIF-filer';

  @override
  String get gifPicker_failedSearch => 'Sökningen misslyckades.';

  @override
  String get gifPicker_noInternet => 'Ingen internetanslutning';

  @override
  String get debugLog_appTitle => 'Appfelsökning';

  @override
  String get debugLog_bleTitle => 'BLE-felsökning';

  @override
  String get debugLog_copyLog => 'Kopiera logg';

  @override
  String get debugLog_clearLog => 'Rensa logg';

  @override
  String get debugLog_copied => 'Felsökningslogg kopierad';

  @override
  String get debugLog_bleCopied => 'BLE-logg kopierad';

  @override
  String get debugLog_noEntries => 'Inga felsökningsloggar ännu';

  @override
  String get debugLog_enableInSettings =>
      'Aktivera appens felsökningsloggning i inställningarna';

  @override
  String get debugLog_frames => 'Ramar';

  @override
  String get debugLog_rawLogRx => 'Rå Log-RX';

  @override
  String get debugLog_noBleActivity => 'Ingen BLE-aktivitet ännu';

  @override
  String debugFrame_length(int count) {
    return 'Ramstorlek: $count byte';
  }

  @override
  String debugFrame_command(String value) {
    return 'Kommando: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Textmeddelandefält:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '– Destination PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Tidsstämpel: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Flaggor: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Texttyp: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'Kommandorad';

  @override
  String get debugFrame_textTypePlain => 'Enkel';

  @override
  String debugFrame_text(String text) {
    return '- Text: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hexdump:';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hopp',
      one: 'hopp',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_removePath => 'Ta bort rutt';

  @override
  String get chat_noPathHistoryYet =>
      'Ingen rutthistorik ännu.\nSkicka ett meddelande för att upptäcka rutter.';

  @override
  String get chat_pathCleared =>
      'Rutten rensades. Nästa meddelande kommer att upptäcka rutten på nytt.';

  @override
  String get chat_fullPath => 'Fullständig rutt';

  @override
  String get routing_title => 'Ruttplanering';

  @override
  String get routing_modeAuto => 'Automatisk';

  @override
  String get routing_modeFlood => 'Flood-trafik';

  @override
  String get routing_modeManual => 'Manuell';

  @override
  String get routing_modeAutoHint =>
      'Väljer automatiskt den bästa kända rutten och använder flood när ingen rutt är känd.';

  @override
  String get routing_modeFloodHint =>
      'Sänder via alla repeatrar. Mest tillförlitligt, men använder mer sändningstid.';

  @override
  String get routing_modeManualHint =>
      'Skickar alltid längs exakt den rutt du anger.';

  @override
  String get routing_currentRoute => 'Nuvarande rutt';

  @override
  String get routing_directNoHops => 'Direkt — inga repeaterhopp';

  @override
  String get routing_noPathYet =>
      'Ingen rutt ännu. Nästa meddelande floodas tills en rutt hittas.';

  @override
  String get routePick_open => 'Ruttvy och ruttval';

  @override
  String get routePick_openHint =>
      'Länkkvalitet per hopp och val av en pålitligare rutt';

  @override
  String routePick_title(String name) {
    return 'Rutt till $name';
  }

  @override
  String get routePick_current => 'Nuvarande rutt';

  @override
  String get routePick_flooding =>
      'Ingen fast rutt: meddelanden översvämmar meshen tills en rutt lärts in.';

  @override
  String get routePick_direct => 'Direkt';

  @override
  String routePick_hopUnknown(String id) {
    return 'Repeater $id';
  }

  @override
  String get routePick_notMeasured => 'Inte mätt än';

  @override
  String get routePick_measure => 'Mät den här rutten';

  @override
  String get routePick_measuring => 'Spårar…';

  @override
  String get routePick_measured => 'Uppmätt nyss.';

  @override
  String get routePick_noAnswer =>
      'Inget svar på spårningen. En repeater på rutten kan vara utom räckhåll.';

  @override
  String get routePick_floodDone =>
      'Rutten rensad. Nästa meddelande översvämmar för att hitta en ny.';

  @override
  String get routePick_suggested => 'Föreslagen';

  @override
  String routePick_suggestBody(String route, int score) {
    return 'En pålitligare rutt: $route (poäng $score).';
  }

  @override
  String get routePick_use => 'Använd';

  @override
  String routePick_useLabel(String route) {
    return 'Använd rutten $route';
  }

  @override
  String get routePick_options => 'Rutter att välja bland';

  @override
  String get routePick_optionsHint =>
      'Varje hörd rutt till kontakten, poängsatt 0–100 efter länksignal, leveranser, längd och hur ny den är.';

  @override
  String get routePick_none =>
      'Inga rutter ännu. Skicka ett meddelande för att hitta en.';

  @override
  String get routePick_other => 'Andra val';

  @override
  String get routePick_build => 'Bygg en rutt';

  @override
  String get routePick_flood => 'Låt meshen hitta en rutt';

  @override
  String get routePick_explainer =>
      'Mätningen skickar en spårning längs rutten och tillbaka, så varje länk mellan repeatrar mäts åt båda hållen. Sista länken till kontakten kan inte spåras. Mätvärden sparas i 30 dagar och gäller för varje rutt som använder samma länk.';

  @override
  String routePick_score(int score) {
    return 'Poäng $score av 100';
  }

  @override
  String routePick_hopLabel(
    int number,
    String name,
    String quality,
    String out,
    String back,
  ) {
    return 'Hopp $number: $name. Länk $quality, ut $out decibel, tillbaka $back decibel.';
  }

  @override
  String get routePick_lastLink =>
      'Sista länken till kontakten: kan inte mätas med spårning';

  @override
  String routePick_linkLine(String out, String back) {
    return 'Ut $out dB · tillbaka $back dB';
  }

  @override
  String routePick_optionLine(int score, int hops) {
    return 'Poäng $score · hopp: $hops';
  }

  @override
  String routePick_record(int ok, int tries) {
    return 'levererade $ok av $tries';
  }

  @override
  String routePick_weakest(String snr) {
    return 'svagaste länk $snr dB';
  }

  @override
  String get routePick_inUse => 'Används';

  @override
  String get routing_floodBroadcast => 'Sänd via varje repeater';

  @override
  String get routing_editPath => 'Redigera rutt';

  @override
  String get routing_forgetPath => 'Glöm rutt';

  @override
  String get routing_knownPaths => 'Kända rutter';

  @override
  String get routing_knownPathsHint =>
      'Tryck på en rutt för att byta till den.';

  @override
  String get routing_inUse => 'I användning';

  @override
  String get routing_qualityStrong => 'Starkt första hopp';

  @override
  String get routing_qualityGood => 'Bra första hopp';

  @override
  String get routing_qualityFair => 'Bra första hopp';

  @override
  String get routing_qualityWorked => 'Har levererat';

  @override
  String get routing_qualityFlood => 'Hörd via flood';

  @override
  String get routing_qualityUntested => 'Ej testat';

  @override
  String routing_lastWorked(String when) {
    return 'fungerade $when';
  }

  @override
  String get routing_neverWorked => 'aldrig bekräftat';

  @override
  String routing_deliveryCounts(int successes, int failures) {
    return '$successes levererade, $failures misslyckade';
  }

  @override
  String get routing_floodDelivery => 'Flood-leverans';

  @override
  String get pathEditor_title => 'Skapa rutt';

  @override
  String pathEditor_hopCounter(int count) {
    return '$count av 64 hopp';
  }

  @override
  String get pathEditor_noHops =>
      'Inga hopp ännu. Tryck på repeaters nedan för att lägga till dem i ordning, eller spara utan hopp för att skicka direkt.';

  @override
  String get pathEditor_addHops => 'Lägg till hopp i ordning';

  @override
  String get pathEditor_searchRepeaters => 'Sök repeaters';

  @override
  String get pathEditor_advancedHex => 'Avancerat: rå rutt i hexformat';

  @override
  String get pathEditor_hexLabel => 'Hex-prefikser';

  @override
  String get pathEditor_hexHelper =>
      'Två hextecken per hopp, separerade med kommatecken';

  @override
  String pathEditor_invalidTokens(String tokens) {
    return 'Ogiltigt: $tokens';
  }

  @override
  String get pathEditor_tooManyHops => 'Maximalt 64 hopp';

  @override
  String get pathEditor_usePath => 'Använd den här rutten';

  @override
  String get pathEditor_removeHop => 'Ta bort hopp';

  @override
  String get pathEditor_unknownHop => 'Okänd repeater';

  @override
  String get chat_pathSavedLocally =>
      'Sparat lokalt. Anslut för att synkronisera.';

  @override
  String get chat_pathDeviceConfirmed => 'Enheten bekräftad.';

  @override
  String get chat_pathDeviceNotConfirmed => 'Enheten har inte bekräftats ännu.';

  @override
  String get chat_type => 'Typ';

  @override
  String get chat_path => 'Rutt';

  @override
  String get chat_publicKey => 'Publik nyckel';

  @override
  String get chat_compressOutgoingMessages => 'Komprimera utgående meddelanden';

  @override
  String get chat_floodForced => 'Flood (tvingad)';

  @override
  String get chat_directForced => 'Direkt (tvingad)';

  @override
  String chat_hopsForced(int count) {
    return '$count hopp (tvingat)';
  }

  @override
  String get chat_floodAuto => 'Flood (automatisk)';

  @override
  String get chat_direct => 'Direkt';

  @override
  String get chat_poiShared => 'Delad POI';

  @override
  String chat_unread(int count) {
    return 'Olästa: $count';
  }

  @override
  String get chat_markAsUnread => 'Markera som oläst';

  @override
  String get chat_newMessages => 'Nya meddelanden';

  @override
  String get chat_openLink => 'Öppna länk?';

  @override
  String get chat_openLinkConfirmation =>
      'Vill du öppna den här länken i din webbläsare?';

  @override
  String get chat_open => 'Öppna';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Kunde inte öppna länken: $url';
  }

  @override
  String get chat_invalidLink => 'Ogiltigt länkformat';

  @override
  String get map_title => 'Nodkarta';

  @override
  String get map_searchHint => 'Sök efter nodens namn eller ID';

  @override
  String get map_activity => 'Aktivitet';

  @override
  String get map_online => 'Online';

  @override
  String get map_recent => 'Nyligen';

  @override
  String get map_stale => 'Inaktuell';

  @override
  String get map_visible => 'Synlig';

  @override
  String get map_hidden => 'Dold';

  @override
  String get map_centerOnNode => 'Centrera på nod';

  @override
  String get map_details => 'Detaljer';

  @override
  String get map_noGps => 'Ingen GPS';

  @override
  String get map_noResults => 'Inga matchande noder';

  @override
  String get map_lineOfSight => 'Siktlinje';

  @override
  String get map_losScreenTitle => 'Siktlinje';

  @override
  String get map_noNodesWithLocation => 'Inga noder med platsinformation';

  @override
  String get map_nodesNeedGps =>
      'Noder måste dela sina GPS-koordinater\nför att visas på kartan';

  @override
  String map_nodesCount(int count) {
    return 'Noder: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Markörer: $count';
  }

  @override
  String get map_chat => 'Chatt';

  @override
  String get map_repeater => 'Repeater';

  @override
  String get map_room => 'Rum';

  @override
  String get map_sensor => 'Sensor';

  @override
  String get map_pinDm => 'Markör (DM)';

  @override
  String get map_pinPrivate => 'Markör (privat)';

  @override
  String get map_pinPublic => 'Markör (offentlig)';

  @override
  String get map_lastSeen => 'Senast sedd';

  @override
  String get map_disconnectConfirm =>
      'Är du säker på att du vill koppla från enheten?';

  @override
  String get map_from => 'Från';

  @override
  String get map_source => 'Källa';

  @override
  String get map_flags => 'Flaggor';

  @override
  String get map_type => 'Typ';

  @override
  String get map_path => 'Rutt';

  @override
  String get map_location => 'Plats';

  @override
  String get map_estLocation => 'Uppskattad plats';

  @override
  String get map_publicKey => 'Publik nyckel';

  @override
  String get map_publicKeyPrefixHint => 't.ex. ab12';

  @override
  String get map_shareMarkerHere => 'Dela markeringen här';

  @override
  String get map_setAsMyLocation => 'Ange som min plats';

  @override
  String get floodCorridor_title => 'Flood corridor';

  @override
  String get floodCorridor_previewToHere =>
      'Förhandsgranska flood corridor hit';

  @override
  String get floodCorridor_requesting => 'Ber radion om en korridor…';

  @override
  String get floodCorridor_unsupported =>
      'Radions firmware stöder inte flood corridors.';

  @override
  String get floodCorridor_noProposal =>
      'Radion kunde inte föreslå en korridor. Se till att den har en position.';

  @override
  String floodCorridor_circleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cirklar',
      one: '1 cirkel',
    );
    return '$_temp0';
  }

  @override
  String floodCorridor_repeatersInside(int inside, int total) {
    return '$inside av $total kända repeatrar innanför';
  }

  @override
  String get floodCorridor_straightLine =>
      'Rak linje: inga kända repeatrar längs vägen';

  @override
  String get floodCorridor_followsRepeaters => 'Följer dina kända repeatrar';

  @override
  String get floodCorridor_horizonLimited =>
      'Kända repeatrar når inte målet; resten är en rak linje';

  @override
  String get floodCorridor_thinStretch =>
      'En del av korridoren har få kända repeatrar';

  @override
  String get floodCorridor_moreCoverage => 'Kräv mer repeatertäckning';

  @override
  String get floodCorridor_previewNote =>
      'Endast förhandsvisning. Repeatrar utan korridorfirmware tillämpar inte korridorer.';

  @override
  String get map_pinLabel => 'Fästetikett';

  @override
  String get map_label => 'Etikett';

  @override
  String get map_pointOfInterest => 'Plats av intresse';

  @override
  String get map_sendToContact => 'Skicka till kontakt';

  @override
  String get map_sendToChannel => 'Skicka till kanal';

  @override
  String get map_noChannelsAvailable => 'Inga kanaler tillgängliga';

  @override
  String get map_publicLocationShare => 'Dela offentlig plats';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Du håller på att dela en plats i $channelLabel. Denna kanal är offentlig och alla med PSK kan se den.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Anslut till en enhet för att dela markörer';

  @override
  String get map_filterNodes => 'Filtrera noder';

  @override
  String get map_nodeTypes => 'Nodtyper';

  @override
  String get map_chatNodes => 'Chatnoder';

  @override
  String get map_repeaters => 'Repeatrar';

  @override
  String get map_otherNodes => 'Andra noder';

  @override
  String get map_showOverlaps => 'Repeater-nyckelöverlappningar';

  @override
  String get map_keyPrefix => 'Nyckelprefix';

  @override
  String get map_filterByKeyPrefix => 'Filtrera efter nyckelprefix';

  @override
  String get map_publicKeyPrefix => 'Prefix för publik nyckel';

  @override
  String get map_markers => 'Markörer';

  @override
  String get map_showSharedMarkers => 'Visa delade markörer';

  @override
  String get map_showGuessedLocations =>
      'Visa upp de antagna nodernas placeringar';

  @override
  String get map_showDiscoveryContacts => 'Visa Discovery-kontakter';

  @override
  String get map_guessedLocation => 'Gissad plats';

  @override
  String get map_lastSeenTime => 'Senast sedd';

  @override
  String get map_sharedPin => 'Delad PIN';

  @override
  String get map_sharedAt => 'Delad';

  @override
  String get map_joinRoom => 'Gå med i rum';

  @override
  String get map_manageRepeater => 'Hantera repeater';

  @override
  String get map_tapToAdd => 'Tryck på noder för att lägga till dem i rutten.';

  @override
  String get map_runTrace => 'Kör ruttspårning';

  @override
  String get map_runTraceWithReturnPath => 'Återvänd längs samma rutt.';

  @override
  String get map_removeLast => 'Ta bort sista';

  @override
  String get map_pathTraceCancelled => 'Ruttspårningen avbröts.';

  @override
  String get mapCache_title => 'Offline Kartcache';

  @override
  String get mapCache_selectAreaFirst => 'Välj ett område att cachera först';

  @override
  String get mapCache_noTilesToDownload =>
      'Inga kartplattor att ladda ned för det här området';

  @override
  String get mapCache_downloadTilesTitle => 'Ladda ned kartplattor';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Ladda ned $count kartplattor för offlineanvändning?';
  }

  @override
  String get mapCache_downloadAction => 'Ladda ned';

  @override
  String mapCache_cachedTiles(int count) {
    return '$count kartplattor cachelagrade';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return '$downloaded kartplattor cachelagrade ($failed misslyckades)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Rensa offline-cache';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Ta bort alla cachelagrade kartplattor?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline-cache rensad';

  @override
  String get mapCache_noAreaSelected => 'Ingen area markerad';

  @override
  String get mapCache_cacheArea => 'Cacheområde';

  @override
  String get mapCache_useCurrentView => 'Använd Aktuell Visning';

  @override
  String get mapCache_zoomRange => 'Zoombegränsning';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Uppskattat antal kartplattor: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Nedladdade $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Ladda ned kartplattor';

  @override
  String get mapCache_clearCacheButton => 'Rensa Cache';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Misslyckade nedladdningar: $count';
  }

  @override
  String get mapCache_cachedTilesLabel => 'Cachelagrade kartplattor';

  @override
  String get mapCache_cachedTileSummaryLabel =>
      'Sammanfattning av cachelagrade kartplattor';

  @override
  String mapCache_bulkDownloadDisabledForSource(String source) {
    return 'Massnedladdning för offlinebruk är inaktiverad för $source.';
  }

  @override
  String mapCache_bulkDownloadDisabledInConfig(String source) {
    return 'Massnedladdning för offlinebruk är inaktiverad för $source i appens konfiguration.';
  }

  @override
  String mapCache_summarySource(String source) {
    return 'Källa: $source';
  }

  @override
  String mapCache_summaryCachedTilesForSource(int count) {
    return 'Cachelagrade kartplattor för källan: $count';
  }

  @override
  String mapCache_summaryCachedInSelection(int count) {
    return 'Cachelagrat i valt område/zoom: $count';
  }

  @override
  String mapCache_summaryApproxCacheSize(String size) {
    return 'Ungefärlig cachestorlek: $size';
  }

  @override
  String mapCache_boundsLabel(
    String north,
    String south,
    String east,
    String west,
  ) {
    return 'N $north, S $south, E $east, W $west';
  }

  @override
  String get time_justNow => 'Precis nu';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes min sedan';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours timmar sedan';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dagar sedan';
  }

  @override
  String get time_hour => 'timme';

  @override
  String get time_hours => 'timmar';

  @override
  String get time_day => 'dag';

  @override
  String get time_days => 'dagar';

  @override
  String get time_week => 'vecka';

  @override
  String get time_weeks => 'veckor';

  @override
  String get time_month => 'månad';

  @override
  String get time_months => 'månader';

  @override
  String get time_minutes => 'minuter';

  @override
  String get time_allTime => 'Alla tider';

  @override
  String get dialog_disconnect => 'Koppla från';

  @override
  String get dialog_disconnectConfirm =>
      'Är du säker på att du vill koppla från enheten?';

  @override
  String get login_repeaterLogin => 'Repeaterinloggning';

  @override
  String get login_roomLogin => 'Inloggning på rumsserver';

  @override
  String get login_password => 'Lösenord';

  @override
  String get login_enterPassword => 'Ange lösenord';

  @override
  String get login_savePassword => 'Spara lösenord';

  @override
  String get login_savePasswordSubtitle =>
      'Lösenord kommer att lagras säkert på enheten.';

  @override
  String get login_repeaterDescription =>
      'Ange repeaterns lösenord för gäst- eller administratörsåtkomst.';

  @override
  String get login_roomDescription =>
      'Ange rummets lösenord för att komma åt inställningar och status.';

  @override
  String get login_routing => 'Ruttning';

  @override
  String get login_routingMode => 'Ruttläge';

  @override
  String get login_autoUseSavedPath => 'Automatisk (använd sparad rutt)';

  @override
  String get login_forceFloodMode => 'Tvinga flood-läge';

  @override
  String get login_managePaths => 'Hantera rutter';

  @override
  String get login_login => 'Logga in';

  @override
  String login_attempt(int current, int max) {
    return 'Försök $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Inloggning misslyckades: $error';
  }

  @override
  String get login_failedMessage =>
      'Inloggning misslyckades. Antingen är lösenordet fel eller så går det inte att nå repeatern.';

  @override
  String get common_reload => 'Ladda om';

  @override
  String get common_clear => 'Rensa';

  @override
  String get path_currentPathLabel => 'Aktuell rutt';

  @override
  String get path_noRepeatersFound =>
      'Inga repeatrar eller rumsservrar hittades.';

  @override
  String get repeater_management => 'Repeaterhantering';

  @override
  String get room_management => 'Rumsserverhantering';

  @override
  String get repeater_guest => 'Repeaterinformation';

  @override
  String get room_guest => 'Rumsserverinformation';

  @override
  String get repeater_managementTools => 'Administrationsverktyg';

  @override
  String get repeater_guestTools => 'Gästverktyg';

  @override
  String get repeater_status => 'Status';

  @override
  String get repeater_statusSubtitle =>
      'Visa repeaterstatus, statistik och grannar';

  @override
  String get repeater_telemetry => 'Telemetri';

  @override
  String get repeater_telemetrySubtitle =>
      'Visa telemetri för sensorer och systemstatistik';

  @override
  String get repeater_cli => 'Kommandoradgränssnitt';

  @override
  String get repeater_cliSubtitle => 'Skicka kommandon till repeatern';

  @override
  String get repeater_neighbors => 'Grannar';

  @override
  String get repeater_neighborsSubtitle => 'Visa nollhoppsgrannar.';

  @override
  String get repeater_settings => 'Inställningar';

  @override
  String get repeater_settingsSubtitle => 'Konfigurera repeaterparametrar';

  @override
  String get repeater_clockSyncAfterLogin =>
      'Synkronisera klockan efter inloggning';

  @override
  String get repeater_clockSyncAfterLoginSubtitle =>
      'Automatiskt skicka \"klocksynkronisering\" efter en lyckad inloggning.';

  @override
  String get repeater_statusTitle => 'Repeaterstatus';

  @override
  String get repeater_routingMode => 'Ruttläge';

  @override
  String get repeater_refresh => 'Uppdatera';

  @override
  String get repeater_statusRequestTimeout =>
      'Statusförfrågan gick inte att hämta.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Fel vid inläsning av status: $error';
  }

  @override
  String get repeater_systemInformation => 'Systeminformation';

  @override
  String get repeater_battery => 'Batteri';

  @override
  String get repeater_clockAtLogin => 'Klocka (vid inloggning)';

  @override
  String get repeater_uptime => 'Drifttid';

  @override
  String get repeater_queueLength => 'Kölängd';

  @override
  String get repeater_debugFlags => 'Debugflaggor';

  @override
  String get repeater_radioStatistics => 'Radiostatistik';

  @override
  String get repeater_lastRssi => 'Senaste RSSI';

  @override
  String get repeater_lastSnr => 'Senaste SNR';

  @override
  String get repeater_noiseFloor => 'Brusgolv';

  @override
  String get repeater_txAirtime => 'TX-sändningstid';

  @override
  String get repeater_rxAirtime => 'RX-sändningstid';

  @override
  String get repeater_chanUtil => 'Användning av kanal';

  @override
  String get repeater_packetStatistics => 'Paketstatistik';

  @override
  String get repeater_sent => 'Skickat';

  @override
  String get repeater_received => 'Mottaget';

  @override
  String get repeater_duplicates => 'Dubbletter';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dagar $hours timmar $minutes minuter $seconds sekunder';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Totalt: $total, Flood: $flood, Direkt: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Totalt: $total, Flood: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Flood: $flood, Direkt: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Totalt: $total';
  }

  @override
  String get repeater_settingsTitle => 'Repeaterinställningar';

  @override
  String get repeater_basicSettings => 'Grundinställningar';

  @override
  String get repeater_repeaterName => 'Repeaternamn';

  @override
  String get repeater_repeaterNameHelper =>
      'Visningsnamn för den här repeatern';

  @override
  String get repeater_adminPassword => 'Administratörslösenord';

  @override
  String get repeater_adminPasswordHelper => 'Fullständig åtkomstlösenord';

  @override
  String get repeater_guestPassword => 'Gästlösenord';

  @override
  String get repeater_guestPasswordHelper =>
      'Lösenord för skrivskyddad åtkomst';

  @override
  String get repeater_radioSettings => 'Radioinställningar';

  @override
  String get repeater_frequencyMhz => 'Frekvens (MHz)';

  @override
  String get repeater_frequencyHelper => '300–2500 MHz';

  @override
  String get repeater_txPower => 'TX-effekt';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Bandbredd';

  @override
  String get repeater_spreadingFactor => 'Spridningsfaktor';

  @override
  String get repeater_codingRate => 'Kodningsgrad';

  @override
  String get repeater_locationSettings => 'Platsinställningar';

  @override
  String get repeater_latitude => 'Latitud';

  @override
  String get repeater_latitudeHelper => 'Decimalgrader (t.ex. 37.7749)';

  @override
  String get repeater_longitude => 'Longitud';

  @override
  String get repeater_longitudeHelper => 'Decimalgrader (t.ex. -122.4194)';

  @override
  String get repeater_features => 'Funktioner';

  @override
  String get repeater_packetForwarding => 'Vidarebefordran av paket';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Låt repeatern vidarebefordra paket';

  @override
  String get repeater_guestAccess => 'Gäståtkomst';

  @override
  String get repeater_guestAccessSubtitle =>
      'Tillåt läsbehörigheter för gäster.';

  @override
  String get repeater_privacyMode => 'Privatläge';

  @override
  String get repeater_privacyModeSubtitle => 'Dölj namn/plats i annonser';

  @override
  String get repeater_advertisementSettings => 'Annonsinställningar';

  @override
  String get repeater_localAdvertInterval => 'Intervall för lokal annonsering';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minuter';
  }

  @override
  String get repeater_floodAdvertInterval => 'Intervall för flood-annonsering';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours timmar';
  }

  @override
  String get repeater_encryptedAdvertInterval =>
      'Intervall för krypterad annonsering';

  @override
  String get repeater_dangerZone => 'Faraområde';

  @override
  String get repeater_rebootRepeater => 'Starta om repeater';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Starta om repeatern';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Är du säker på att du vill starta om denna repeater?';

  @override
  String get repeater_regenerateIdentityKey => 'Generera Identitetsknyckel';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Generera ny publik/privat nyckelpar';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Detta genererar en ny identitet för repeatern. Fortsätta?';

  @override
  String get repeater_eraseFileSystem => 'Radera Filsystem';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formatera repeaterns filsystem';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'VARNING: Detta kommer att radera all data på repeatern. Detta kan inte ångras!';

  @override
  String get repeater_eraseSerialOnly =>
      'Rensa är endast tillgängligt via seriell konsol.';

  @override
  String repeater_commandSent(String command) {
    return 'Kommandot skickades: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Fel vid skickande av kommando: $error';
  }

  @override
  String get repeater_confirm => 'Bekräfta';

  @override
  String get repeater_settingsSaved =>
      'Inställningarna sparades framgångsrikt.';

  @override
  String get repeater_rxGain => 'Ökad RX-vinst';

  @override
  String get repeater_rxGainHelper =>
      'Ökad känslighet, högre strömförbrukning (endast för SX1262/SX1268)';

  @override
  String get repeater_refreshRxGain => 'Uppdatera förstärkt RX-gain';

  @override
  String get repeater_multiAcks => 'Flera bekräftelser';

  @override
  String get repeater_multiAcksSubtitle =>
      'Kvittera meddelanden via flera rutter för säkrare leverans';

  @override
  String get repeater_refreshMultiAcks => 'Uppdatera multi-ACK';

  @override
  String get repeater_networkHealth => 'Nätverkets hälsa';

  @override
  String get repeater_loopDetect => 'Identifiering av loopar';

  @override
  String get repeater_loopDetectHelper =>
      'Släpp flood-paket som ser ut att ingå i routingloopar';

  @override
  String get repeater_loopDetectOff => 'Av';

  @override
  String get repeater_loopDetectMinimal => 'Minimal';

  @override
  String get repeater_loopDetectModerate => 'Måttlig';

  @override
  String get repeater_loopDetectStrict => 'Strikt';

  @override
  String get repeater_dutyCycle => 'Arbetscykel';

  @override
  String get repeater_dutyCycleHelper => 'Maximal procentandel av sändningstid';

  @override
  String repeater_dutyCyclePercent(int percent) {
    return '$percent%';
  }

  @override
  String get repeater_ownerInfo => 'Operatörsinformation';

  @override
  String get repeater_ownerInfoHelper =>
      'Publik metadata för den här repeatern';

  @override
  String get repeater_refreshOwnerInfo => 'Uppdatera operatörsinformation';

  @override
  String get repeater_floodMax => 'Max antal flood-hopp';

  @override
  String get repeater_floodMaxHelper =>
      'Maximalt antal hopp som ett flood-paket får färdas (0–64)';

  @override
  String get repeater_advancedSettings => 'Avancerad';

  @override
  String get repeater_advancedSettingsSubtitle =>
      'Ställjusteringsknappar för erfarna användare';

  @override
  String get repeater_pathHashMode => 'Läge för rutthash';

  @override
  String get repeater_pathHashModeHelper =>
      'Byte som används för att koda repeaterns ID i flood-ruttens/loopdetekteringens taggar. 0=1 byte (256 ID:n, upp till 64 hopp), 1=2 byte (65K ID:n, upp till 32 hopp), 2=3 byte (16M ID:n, upp till 21 hopp). Firmware före v1.14 använde alltid 1-byte-rutter; v1.14 och senare kan konfigureras för 2- eller 3-byte-rutter.';

  @override
  String get repeater_keySettings => 'Ändra identitetsnyckel';

  @override
  String get repeater_keySettingsSubtitle =>
      'Ändra det publika/privata nyckelparet';

  @override
  String get repeater_prvKey => 'Privat nyckel';

  @override
  String get repeater_prvKeyHelper =>
      'En ny privat nyckel för repeatern, en hexsträng med 128 tecken.';

  @override
  String get repeater_generatePrvKey => 'Generera ett slumpmässigt nyckelpar';

  @override
  String get repeater_stopGeneratingPrvKey => 'Avbryt sökning efter nyckelpar';

  @override
  String get repeater_pubKey => 'Publik nyckel';

  @override
  String get repeater_pubKeyHelper =>
      'Det här är den publika nyckeln som hör till den genererade privata nyckeln. Den kan inte anges direkt.';

  @override
  String get repeater_pubKeyPrefix => 'Önskad prefix';

  @override
  String repeater_pubKeyPrefixHelper(int tries) {
    return 'Hitta en publik nyckel som börjar med dessa hexsiffror. Förväntat antal försök: $tries.';
  }

  @override
  String get repeater_txDelay => 'Flood-TX-fördröjning';

  @override
  String get repeater_txDelayHelper =>
      'Intervall mellan vidarebefordringar för flood-trafik, som en multiplikator av paketets sändningstid (0–2, standard 0,5). Högre = färre kollisioner men långsammare leverans.';

  @override
  String get repeater_directTxDelay => 'Direkt TX-fördröjning';

  @override
  String get repeater_directTxDelayHelper =>
      'Intervall mellan vidarebefordringar för direkt trafik (icke-flood), som en multiplikator av paketets sändningstid (0–2, standard 0,3).';

  @override
  String get repeater_intThresh => 'Tröskelvärde för störning';

  @override
  String get repeater_intThreshHelper =>
      'Tröskelvärdet har ställts in så att den filtrerar bort störningar som överstiger detta värde. 0 stänger av – aktivera endast om du ser RX-fel i ett störningsfyllt frekvensområde.';

  @override
  String get repeater_agcResetInterval => 'Återställningsintervall för AGC';

  @override
  String get repeater_agcResetIntervalHelper =>
      'Hur ofta ska man återställa radioens automatiska förstärkning för att återhämta sig från ett tillstånd där förstärkningen är fast? Sekunder, inställda till en multipel av 4. 0 stänger av periodiska återställningar.';

  @override
  String get repeater_actionsTitle => 'Åtgärder';

  @override
  String get repeater_sendAdvert => 'Skicka flood-annonsering';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Sänd en flood-annonsering genom nätverket';

  @override
  String get repeater_sendAdvertZeroHop => 'Skicka nollhoppsannons';

  @override
  String get repeater_sendAdvertZeroHopSubtitle =>
      'Sänd en nollhoppsannons (inga vidarebefordringar)';

  @override
  String get repeater_clockSync => 'Synkronisera klockan nu';

  @override
  String get repeater_clockSyncSubtitle =>
      'Ställ din telefons tid till repeatern.';

  @override
  String repeater_actionSucceeded(String action) {
    return '$action lyckades';
  }

  @override
  String repeater_actionFailed(String action, String error) {
    return '$action misslyckades: $error';
  }

  @override
  String get repeater_settingsSavedRebootNeeded =>
      'Inställningarna har sparats — starta om repeatern för att tillämpa dem';

  @override
  String repeater_settingsPartialFailure(String failures) {
    return 'Vissa inställningar misslyckades: $failures';
  }

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Fel vid sparande av inställningar: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Uppdatera grundinställningar';

  @override
  String get repeater_refreshRadioSettings => 'Uppdatera radioinställningar';

  @override
  String get repeater_refreshTxPower => 'Uppdatera TX-effekt';

  @override
  String get repeater_refreshPacketForwarding =>
      'Uppdatera paketvidarebefordran';

  @override
  String get repeater_refreshGuestAccess => 'Uppdatera gäståtkomst';

  @override
  String get repeater_refreshPrivacyMode => 'Uppdatera privatläge';

  @override
  String repeater_refreshed(String label) {
    return '$label har uppdaterats';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Fel vid uppdatering av $label';
  }

  @override
  String get repeater_cliTitle => 'Repeater-CLI';

  @override
  String get repeater_debugNextCommand => 'Felsök Nästa Kommando';

  @override
  String get repeater_commandHelp => 'Kommandohjälp';

  @override
  String get repeater_clearHistory => 'Rensa Historik';

  @override
  String get repeater_noCommandsSent => 'Inga kommandon skickats ännu';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Skriv en kommando nedan eller använd snabba kommandon';

  @override
  String get repeater_enterCommandHint => 'Ange kommando...';

  @override
  String get repeater_previousCommand => 'Tidigare kommando';

  @override
  String get repeater_nextCommand => 'Nästa kommando';

  @override
  String get repeater_enterCommandFirst => 'Ange en kommando först';

  @override
  String get repeater_cliCommandFrameTitle => 'Kommandofönster';

  @override
  String repeater_cliCommandError(String error) {
    return 'Fel: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Hämta namn';

  @override
  String get repeater_cliQuickGetRadio => 'Få Radio';

  @override
  String get repeater_cliQuickGetTx => 'Hämta TX';

  @override
  String get repeater_cliQuickNeighbors => 'Grannar';

  @override
  String get repeater_cliQuickVersion => 'Version';

  @override
  String get repeater_cliQuickAdvertise => 'Annonsera';

  @override
  String get repeater_cliQuickClock => 'Klocka';

  @override
  String get repeater_cliQuickClockSync => 'Synkronisera klocka';

  @override
  String get repeater_cliQuickDiscovery => 'Upptäck grannar';

  @override
  String get repeater_cliHelpAdvert => 'Skickar ett annonspaket';

  @override
  String get repeater_cliHelpReboot =>
      'Startar om enheten. (notera, du får kanske \'Timeout\' vilket är normalt)';

  @override
  String get repeater_cliHelpClock => 'Visar aktuell tid per enhetens klocka.';

  @override
  String get repeater_cliHelpPassword =>
      'Ställer in ett nytt administratörslösenord för enheten.';

  @override
  String get repeater_cliHelpVersion =>
      'Visar enhetsversion och firmwarebyggnadsdatum.';

  @override
  String get repeater_cliHelpClearStats =>
      'Återställer olika statistikräknare till noll.';

  @override
  String get repeater_cliHelpSetAf => 'Ställer in lufttidsfaktor.';

  @override
  String get repeater_cliHelpSetTx =>
      'Ställer LoRa-sändningseffekten i dBm. (starta om för att tillämpa)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Aktiverar eller inaktiverar repeaterrollen för den här noden.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Rumsserver) Om detta är på tillåts inloggning med tomt lösenord, men det går inte att posta till rummet (endast läsning).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Anger maximalt antal hopp för inkommande flood-paket (om >= max vidarebefordras inte paketet).';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Ställer Interferensgränsen (i dB). Standardvärdet är 14. Ställ in den på 0 för att inaktivera detektion av kanalinterferens.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Ställer in intervallet för att återställa Auto Gain-kontrollen. Ställ in till 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Aktiverar eller inaktiverar funktionen \'dubbla ACKs\'.';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Anger tidsintervallet i minuter för att skicka ett lokalt nollhopps-annonseringspaket. Ange 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Anger tidsintervallet i timmar för att skicka ett flood-annonseringspaket. Ange 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Anger/uppdaterar gästlösenordet. (För repeatrar kan gästinloggningar skicka begäran \"Get Stats\".)';

  @override
  String get repeater_cliHelpSetName =>
      'Anger namnet som används i annonseringen.';

  @override
  String get repeater_cliHelpSetLat =>
      'Ställer in annonskartans latitud. (decimalgrader)';

  @override
  String get repeater_cliHelpSetLon =>
      'Ställer in annonskartans longitud (decimalgrader).';

  @override
  String get repeater_cliHelpSetRadio =>
      'Ställer helt nya radioparametrar och sparar dem i inställningar. Kräver en \"omstart\" för att tillämpa.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Ställer (experimentell) basvärde (måste vara > 1 för effekt) för att applicera en liten fördröjning på mottagna paket, baserat på signalstyrka/poäng. Ställ in på 0 för att inaktivera.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Anger en faktor som multipliceras med sändningstiden för ett paket i flood-läge och används med ett slumpmässigt slotsystem för att fördröja vidarebefordran (för att minska risken för kollisioner).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Samma som txdelay, men för att applicera en slumpmässig fördröjning vid vidarebefordran av direktlägespaket.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Aktivera/Inaktivera brygga.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Ställ in fördröjning innan paket åter sänder.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Välj om bron ska återända mottagna paket eller sända paket.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Ställ baudgränsen för rs232-bryggarna.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Ställ bro-hemlighet för espnow-broar.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Ställer in anpassad faktor för att justera rapporterad batterispänning (endast stödd på utvalda kort).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Ställer temporära radioparametrar för det angivna antalet minuter, vilket återgår till de ursprungliga radioparametrarna efteråt. (sparar inte i inställningar).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Modifierar ACL. Tar bort matchande post (genom pubkey-prefiks) om \"permissions\" är noll. Lägger till ny post om pubkey-hex är full längd och inte redan finns i ACL. Uppdaterar posten genom matchande pubkey-prefiks. Tillståndsbiten varierar per firmware-roll, men de låga 2 bitarna är: 0 (Gäst), 1 (endast läsa), 2 (läs- och skrivskydd), 3 (administratör).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Får brotyperna ingen, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart => 'Starta paketloggning till filsystem.';

  @override
  String get repeater_cliHelpLogStop => 'Stoppar paketloggning till filsystem.';

  @override
  String get repeater_cliHelpLogErase =>
      'Raderar pakets loggar från filsystemet.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Visar en lista över andra repeaternoder som hörts via nollhoppsannonser. Varje rad är id-prefix-hex:timestamp:snr-times-4.';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Tar bort det första matchande inlägget (genom pubkey-prefiks (hex)) från grannlistan.';

  @override
  String get repeater_cliHelpRegion =>
      '(Endast seriell anslutning) Listar alla definierade regioner och aktuella behörigheter för flood-trafik.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'MEDDELANDE: detta är ett specialkommando med flera kommandon. Varje efterföljande kommando är ett regionsnamn (indenterat med blanksteg för att indikera en hierarkisk relation, med minst ett blanksteg). Avslutas genom att skicka en tom rad/kommando.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Söker efter region med given namnprefiks (eller \"\" för det globala scopet). Svarar med \"-> regionnamn (föräldernamn) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Lägger till eller uppdaterar en regionsdefinition med det angivna namnet.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Tar bort en regionsdefinition med det angivna namnet. (måste matcha exakt och inte ha några barnregioner)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Ställer \'Flöde\'-behörighet för det angivna området. (\'\' för det globala/gamla scopet)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Tar bort \'F\'lood-behörigheten för det angivna området. (OBS: rekommenderas inte att använda detta i detta skede på den globala/gamla omfattningen!!).';

  @override
  String get repeater_cliHelpRegionHome =>
      'Svarar med den aktuella \'hem\'-regionen. (Notera att detta ännu inte har tillämpats, reserverat för framtida användning).';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Ställer in \'hemregionen\'.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Sparar regionlistan/kartan till lagring.';

  @override
  String get repeater_cliHelpGps =>
      'Visar GPS-status. Om GPS är avstängd svarar den endast med \"av\", annars svarar den med \"på\", status, fix, antal satelliter.';

  @override
  String get repeater_cliHelpGpsOnOff =>
      'Aktiverar/inaktiverar GPS-strömsättningen.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synkroniserar nätverks tid med GPS-klockan.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Ställer nodens position till GPS-koordinater och sparar inställningar.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Ger platsannonskonfigurationen för noden:\n- ingen: inkludera inte plats i annonser\n- dela: dela gps-plats (från SensorManager)\n- inställningar: annonsera platsen som sparats i inställningar';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Anger konfigurationen för plats i annonser.';

  @override
  String get repeater_commandsListTitle => 'Inställningslista';

  @override
  String get repeater_commandsListNote =>
      'OBS: för de olika \"set ...\" -kommandon finns det även ett \"get ...\" -kommando.';

  @override
  String get repeater_general => 'Allmänt';

  @override
  String get repeater_settingsCategory => 'Inställningar';

  @override
  String get repeater_bridge => 'Bro';

  @override
  String get repeater_logging => 'Logga';

  @override
  String get repeater_neighborsRepeaterOnly => 'Grannar (endast repeater)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Regionhantering (endast repeater)';

  @override
  String get repeater_regionNote =>
      'Regionkommandon har införts för att hantera regiondefinitioner och behörigheter.';

  @override
  String get repeater_gpsManagement => 'GPS Hantering';

  @override
  String get repeater_gpsNote =>
      'GPS-kommando har introducerats för att hantera platsrelaterade ämnen.';

  @override
  String get repeater_getCategory => 'Hämta värden';

  @override
  String get repeater_powerMgmt => 'Effektstyrning';

  @override
  String get repeater_sensors => 'Sensorer';

  @override
  String get repeater_cliHelpPowerOff =>
      'Stänger av enheten. (ingen respons förväntas)';

  @override
  String get repeater_cliHelpClkReboot =>
      'Återställer klockan till en känd tidpunkt och startar om enheten.';

  @override
  String get repeater_cliHelpAdvertZeroHop =>
      'Skickar en nollhoppsannons (endast direkta grannar).';

  @override
  String get repeater_cliHelpStartOta =>
      'Startar en firmware-uppdatering via luft, på kompatibla enheter.';

  @override
  String get repeater_cliHelpTime =>
      'Ställer enheten till den angivna Unix-epokens tid. Klockan kan inte gå bakåt.';

  @override
  String get repeater_cliHelpBoard =>
      'Visar tillverkaren av moderkortet / hårdvaru-identifieraren.';

  @override
  String get repeater_cliHelpDiscoverNeighbors =>
      'Skickar en begäran om nodupptäckt till närliggande grannar. (Endast repeater.)';

  @override
  String get repeater_cliHelpPowersaving =>
      'Visar om energisparläget är aktiverat eller avstängt.';

  @override
  String get repeater_cliHelpPowersavingOnOff =>
      'Aktiverar eller inaktiverar energisparläget (om det stöds).';

  @override
  String get repeater_cliHelpErase =>
      '(Endast för seriell kommunikation) Formaterar enhetens filsystem. Raderar alla inställningar och kontakter.';

  @override
  String get repeater_cliHelpSetDutyCycle =>
      'Anger den maximala tillåtna överföringsfrekvensen som en procent (1-100). Justerar automatiskt tidsfaktorn.';

  @override
  String get repeater_cliHelpSetPrvKey =>
      '(Endast för seriell användning) Ersätter enhetsens privata nyckel. Återstart krävs för att tillämpa. Genererar en ny publik nyckel.';

  @override
  String get repeater_cliHelpSetRadioRxGain =>
      '(Endast SX126x) Aktiverar förstärkt mottagargain för förbättrad känslighet vid högre strömförbrukning.';

  @override
  String get repeater_cliHelpSetOwnerInfo =>
      'Anger kontaktinformationen som ska inkluderas i annonserna. Använd \'|\' för att separera olika fält.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Definierar läget för hash-baserad ruttning. 0 = äldre läge, 1 = standard, 2 = strikt. Påverkar hur ruttvägar matchas.';

  @override
  String get repeater_cliHelpSetLoopDetect =>
      'Ställer in känsligheten för detektering av routingloopar: av, minimal, måttlig eller strikt.';

  @override
  String get repeater_cliHelpSetFreq =>
      '(Endast för seriell kommunikation) Ställer snabbt bara frekvensen. Kräver omstart. Föredrar \"ställ radio\" för att få full kontroll över radioinställningarna.';

  @override
  String get repeater_cliHelpSetBridgeChannel =>
      '(Endast ESPNow-brygga) Anger WiFi-kanalen (1-14) som används av bryggan.';

  @override
  String get repeater_cliHelpGetName => 'Visar det konfigurerade nodnamnet.';

  @override
  String get repeater_cliHelpGetRole =>
      'Visar firmware-rollen (repeater, rumsserver osv.).';

  @override
  String get repeater_cliHelpGetPublicKey => 'Visar enhetens publika nyckel.';

  @override
  String get repeater_cliHelpGetPrvKey =>
      '(Endast för seriell användning) Visar enheters privata nyckel. Behandla detta som en hemlighet.';

  @override
  String get repeater_cliHelpGetRepeat =>
      'Visar om funktionen för att vidarebefordra paket (som en repeater) är aktiverad eller inaktiverad.';

  @override
  String get repeater_cliHelpGetTx => 'Visar aktuell TX-effekt i dBm.';

  @override
  String get repeater_cliHelpGetFreq =>
      'Visar den konfigurerade radiofrekvensen i MHz.';

  @override
  String get repeater_cliHelpGetRadio =>
      'Visar alla radioparametrar: frekvens, bandbredd, spridningsfaktor, kodningshastighet.';

  @override
  String get repeater_cliHelpGetRadioRxGain =>
      '(Endast för SX126x) Visar RX:s förstärkningstillstånd.';

  @override
  String get repeater_cliHelpGetAf => 'Visar aktuell tidssats.';

  @override
  String get repeater_cliHelpGetDutyCycle =>
      'Visar den aktuella tillåtna arbetscykeln i procent.';

  @override
  String get repeater_cliHelpGetIntThresh =>
      'Visar gränsen för kanalinterferens i dB.';

  @override
  String get repeater_cliHelpGetAgcResetInterval =>
      'Visar återställningsintervallet för AGC i sekunder.';

  @override
  String get repeater_cliHelpGetMultiAcks =>
      'Visar om dubbelbekräftelseläget är aktiverat (1) eller avstängt (0).';

  @override
  String get repeater_cliHelpGetAllowReadOnly =>
      'Visar om gäst har tillåtelse att endast läsa.';

  @override
  String get repeater_cliHelpGetAdvertInterval =>
      'Visar intervallet för lokala annonseringar i minuter.';

  @override
  String get repeater_cliHelpGetFloodAdvertInterval =>
      'Visar intervallet för flood-annonseringar i timmar.';

  @override
  String get repeater_cliHelpGetGuestPassword => 'Visar det angivna gästlösen.';

  @override
  String get repeater_cliHelpGetLat => 'Visar den angivna latituden.';

  @override
  String get repeater_cliHelpGetLon => 'Visar den angivna longituden.';

  @override
  String get repeater_cliHelpGetRxDelay => 'Visar grundvärdet för rxdelay.';

  @override
  String get repeater_cliHelpGetTxDelay =>
      'Visar txdelay-faktorn för flood-läge.';

  @override
  String get repeater_cliHelpGetDirectTxDelay =>
      'Visar faktorn för fördröjning i direktläge.';

  @override
  String get repeater_cliHelpGetFloodMax => 'Visar maximalt antal flood-hopp.';

  @override
  String get repeater_cliHelpGetOwnerInfo =>
      'Visar strängen med kontaktinformation för ägaren.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Visar läget för rutthash (0/1/2).';

  @override
  String get repeater_cliHelpGetLoopDetect =>
      'Visar känsligheten för att detektera loopar.';

  @override
  String get repeater_cliHelpGetAcl =>
      'Visar åtkomstkontrollposterna på en repeater. (Endast seriell anslutning.)';

  @override
  String get repeater_cliHelpGetBridgeEnabled => 'Visar om bron är aktiverad.';

  @override
  String get repeater_cliHelpGetBridgeDelay =>
      'Visar fördröjningen i bron i millisekunder.';

  @override
  String get repeater_cliHelpGetBridgeSource =>
      'Visar om bron skickar RX- eller TX-paket.';

  @override
  String get repeater_cliHelpGetBridgeBaud =>
      '(Enbart RS232-brygga) Visar bryggans baud-hastighet.';

  @override
  String get repeater_cliHelpGetBridgeChannel =>
      '(Endast ESPNow-brygga) Visar WiFi-kanal för bryggan.';

  @override
  String get repeater_cliHelpGetBridgeSecret =>
      '(Endast ESPNow-brygga) Visar bryggans delade hemlighet.';

  @override
  String get repeater_cliHelpGetBootloaderVer =>
      '(Endast för NRF52) Visar versionen av bootloadern.';

  @override
  String get repeater_cliHelpGetAdcMultiplier =>
      'Visar ADC-multiplikatorn (skalning av batterispänning).';

  @override
  String get repeater_cliHelpGetPwrMgtSupport =>
      'Anger om kortet har stöd för strömhantering.';

  @override
  String get repeater_cliHelpGetPwrMgtSource =>
      'Visar aktuell strömkälla: extern eller batteri.';

  @override
  String get repeater_cliHelpGetPwrMgtBootReason =>
      'Visar de senaste orsakerna till återställning och avstängning.';

  @override
  String get repeater_cliHelpGetPwrMgtBootMv =>
      'Visar batterispänningen vid start i millivolt (mV).';

  @override
  String get repeater_cliHelpSensorGet =>
      'Läser en anpassad sensorinställning via nyckel.';

  @override
  String get repeater_cliHelpSensorSet =>
      'Skapar en anpassad inställning för en sensor.';

  @override
  String get repeater_cliHelpSensorList =>
      'Visar alla anpassade sensorinställningar, sorterade från ett valfritt startindex.';

  @override
  String get repeater_cliHelpRegionDefault =>
      'Visar det aktuella standardområde.';

  @override
  String get repeater_cliHelpRegionDefaultSet =>
      'Definierar standardområde. Använd \"<null>\" för att återställa till standard.';

  @override
  String get repeater_cliHelpRegionListAllowed =>
      'Listar regioner som tillåter flood-trafik.';

  @override
  String get repeater_cliHelpRegionListDenied =>
      'Listar regioner som blockerar flood-trafik.';

  @override
  String get repeater_cliHelpStatsPackets =>
      '(Endast för seriell kommunikation) Visar statistik på paketnivå.';

  @override
  String get repeater_cliHelpStatsRadio =>
      '(Endast seriell anslutning) Visar radiostatistik.';

  @override
  String get repeater_cliHelpStatsCore =>
      '(Enbart för seriell kommunikation) Visar grundläggande firmware-statistik.';

  @override
  String get telemetry_receivedData => 'Mottagen Telemetridata';

  @override
  String get telemetry_requestTimeout => 'Telemetryförfrågan gick ut.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Fel vid laddning av telemetri: $error';
  }

  @override
  String get telemetry_noData => 'Inga telemetridata tillgängliga.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanal $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batteri';

  @override
  String get telemetry_voltageLabel => 'Spänning';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU Temperatur';

  @override
  String get telemetry_temperatureLabel => 'Temperatur';

  @override
  String get telemetry_currentLabel => 'Ström';

  @override
  String telemetry_batteryValue(int percent, String volts) {
    return '$percent% / ${volts}V';
  }

  @override
  String telemetry_voltageValue(String volts) {
    return '${volts}V';
  }

  @override
  String telemetry_currentValue(String amps) {
    return '${amps}A';
  }

  @override
  String telemetry_temperatureValue(String celsius, String fahrenheit) {
    return '$celsius°C / $fahrenheit°F';
  }

  @override
  String get telemetry_digitalInputLabel => 'Digital ingång';

  @override
  String get telemetry_digitalOutputLabel => 'Digital utgång';

  @override
  String get telemetry_analogInputLabel => 'Analog ingång';

  @override
  String get telemetry_analogOutputLabel => 'Analog utgång';

  @override
  String get telemetry_genericLabel => 'Allmän sensor';

  @override
  String get telemetry_luminosityLabel => 'Ljusstyrka';

  @override
  String get telemetry_presenceLabel => 'Närvaro';

  @override
  String get telemetry_humidityLabel => 'Luftfuktighet';

  @override
  String get telemetry_accelerometerLabel => 'Accelerometer';

  @override
  String get telemetry_pressureLabel => 'Tryck';

  @override
  String get telemetry_altitudeLabel => 'Höjd';

  @override
  String get telemetry_frequencyLabel => 'Frekvens';

  @override
  String get telemetry_percentageLabel => 'Procent';

  @override
  String get telemetry_concentrationLabel => 'Koncentration';

  @override
  String get telemetry_powerLabel => 'Effekt';

  @override
  String get telemetry_distanceLabel => 'Avstånd';

  @override
  String get telemetry_energyLabel => 'Energi';

  @override
  String get telemetry_directionLabel => 'Riktning';

  @override
  String get telemetry_timeLabel => 'Tid';

  @override
  String get telemetry_gyrometerLabel => 'Gyrometer';

  @override
  String get telemetry_colourLabel => 'Färg';

  @override
  String get telemetry_gpsLabel => 'GPS';

  @override
  String get telemetry_switchLabel => 'Brytare';

  @override
  String get telemetry_polylineLabel => 'Polylinje';

  @override
  String telemetry_altitudeValue(String meters) {
    return '$meters m';
  }

  @override
  String telemetry_frequencyValue(String hertz) {
    return '$hertz Hz';
  }

  @override
  String telemetry_pressureValue(String hpa) {
    return '$hpa hPa';
  }

  @override
  String telemetry_luminosityValue(String lux) {
    return '$lux lx';
  }

  @override
  String telemetry_powerValue(String watts) {
    return '$watts W';
  }

  @override
  String telemetry_distanceValue(String meters) {
    return '$meters m';
  }

  @override
  String telemetry_energyValue(String kilowattHours) {
    return '$kilowattHours kWh';
  }

  @override
  String telemetry_directionValue(String degrees) {
    return '$degrees°';
  }

  @override
  String telemetry_concentrationValue(String ppm) {
    return '$ppm ppm';
  }

  @override
  String telemetry_percentageValue(String percent) {
    return '$percent%';
  }

  @override
  String telemetry_analogValue(String value) {
    return '$value';
  }

  @override
  String get telemetry_autoFetchQuantity => 'Antal förfrågningar';

  @override
  String get telemetry_error => 'Det gick inte att hämta data';

  @override
  String get neighbors_receivedData => 'Mottagna grannars data';

  @override
  String get neighbors_requestTimedOut =>
      'Tidsgränsen för grannförfrågan överskreds.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Fel vid inläsning av grannar: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Repeatergrannar';

  @override
  String get neighbors_noData => 'Inga grannuppgifter finns tillgängliga.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Okänd $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Hördes: $time sedan';
  }

  @override
  String get channelPath_title => 'Paketrutt';

  @override
  String get channelPath_viewMap => 'Visa karta';

  @override
  String get channelPath_otherObservedPaths => 'Andra observerade rutter';

  @override
  String get channelPath_repeaterHops => 'Repeaterhopp';

  @override
  String get channelPath_noHopDetails =>
      'Hoppdetaljer anges inte för det här paketet.';

  @override
  String get channelPath_sourceLabel => 'Källa';

  @override
  String get channelPath_sourceMqtt => 'MQTT';

  @override
  String get channelPath_viaMqttNoRfPath =>
      'Meddelandet kom via MQTT. Din radio har inte hört det, så det finns ingen radioväg från din radio.';

  @override
  String get channelPath_messageDetails => 'Meddelandets detaljer';

  @override
  String get channelPath_senderLabel => 'Avsändare';

  @override
  String get channelPath_timeLabel => 'Tid';

  @override
  String get channelPath_repeatsLabel => 'Upprepa';

  @override
  String channelPath_pathLabel(int index) {
    return 'Rutt $index';
  }

  @override
  String get channelPath_observedLabel => 'Observerat';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Observerad rutt $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Ingen platsdata';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month kl. $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Okänd';

  @override
  String get channelPath_floodPath => 'Flood-trafik';

  @override
  String get channelPath_directPath => 'Direkt';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 av $total hopp';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed av $total hopp';
  }

  @override
  String get channelPath_mapTitle => 'Ruttkarta';

  @override
  String get channelPath_noRepeaterLocations =>
      'Inga repeaterpositioner är tillgängliga för den här rutten.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Rutt $index (primär)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Rutt';

  @override
  String get channelPath_observedPathHeader => 'Observerad rutt';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Inga hoppdetaljer finns tillgängliga för detta paket.';

  @override
  String get channelPath_unknownRepeater => 'Okänd repeater';

  @override
  String get community_title => 'Gemenskap';

  @override
  String get community_create => 'Skapa Gemenskap';

  @override
  String get community_createDesc =>
      'Skapa en ny gemenskap och dela via QR-kod.';

  @override
  String get community_join => 'Gå med';

  @override
  String get community_joinTitle => 'Gå med i gemenskapen';

  @override
  String community_joinConfirmation(String name) {
    return 'Vill du gå med i communityn \"$name\"?';
  }

  @override
  String get community_scanQr => 'Skanna Gemenskapens QR';

  @override
  String get community_scanInstructions =>
      'Rikta kameran mot en QR-kod i communityn';

  @override
  String get community_showQr => 'Visa QR-kod';

  @override
  String get community_publicChannel => 'Publik communitykanal';

  @override
  String get community_hashtagChannel => 'Hashtag för gemenskapen';

  @override
  String get community_name => 'Gemenskapens namn';

  @override
  String get community_enterName => 'Ange communityns namn';

  @override
  String community_created(String name) {
    return 'Community \"$name\" har skapats';
  }

  @override
  String community_joined(String name) {
    return 'Medlem i communityn \"$name\"';
  }

  @override
  String get community_qrTitle => 'Dela Gemenskap';

  @override
  String community_qrInstructions(String name) {
    return 'Skanna denna QR-kod för att gå med i \"$name\"';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Community-hashtagkanaler kan endast nås av medlemmar i communityn';

  @override
  String get community_invalidQrCode => 'Ogiltig community QR-kod';

  @override
  String get community_alreadyMember => 'Är redan medlem';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Du är redan medlem av \"$name\".';
  }

  @override
  String get community_addPublicChannel => 'Lägg till publik communitykanal';

  @override
  String get community_addPublicChannelHint =>
      'Lägg automatiskt till den publika kanalen för den här communityn';

  @override
  String get community_noCommunities => 'Inga gemenskaper har anslutats ännu';

  @override
  String get community_scanOrCreate =>
      'Skanna en QR-kod eller skapa en community för att komma igång';

  @override
  String get community_manageCommunities => 'Hantera Gemenskaper';

  @override
  String get community_delete => 'Lämna Gemenskap';

  @override
  String community_deleteConfirm(String name) {
    return 'Lämna \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Detta kommer också att radera $count kanal/kanaler och deras meddelanden.';
  }

  @override
  String community_deleted(String name) {
    return 'Lämnade community \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Regenerera hemlig kod';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Regenerera den hemliga nyckeln för \"$name\"? Alla medlemmar måste scanna den nya QR-koden för att fortsätta kommunicera.';
  }

  @override
  String get community_regenerate => 'Regenerera';

  @override
  String community_secretRegenerated(String name) {
    return 'Hemligheten har genererats om för “$name”';
  }

  @override
  String get community_updateSecret => 'Uppdatera hemlighet';

  @override
  String community_secretUpdated(String name) {
    return 'Hemlighet uppdaterad för \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Skanna den nya QR-koden för att uppdatera hemligheten för \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Lägg till Gemenskapens Hashtag';

  @override
  String get community_addHashtagChannelDesc =>
      'Lägg till en hashtag-kanal för denna community';

  @override
  String get community_selectCommunity => 'Välj Gemenskap';

  @override
  String get community_regularHashtag => 'Vanlig Hash Tag';

  @override
  String get community_regularHashtagDesc =>
      'Offentlig hashtag (alla kan gå med)';

  @override
  String get community_communityHashtag => 'Gemenskaps-hashtag';

  @override
  String get community_communityHashtagDesc => 'Endast för medlemmar';

  @override
  String community_forCommunity(String name) {
    return 'För $name';
  }

  @override
  String get listFilter_tooltip => 'Filtrera och sortera';

  @override
  String get listFilter_sortBy => 'Sortera efter';

  @override
  String get listFilter_latestMessages => 'Senaste meddelanden';

  @override
  String get listFilter_heardRecently => 'Nyligen hörd';

  @override
  String get listFilter_az => 'A-Ö';

  @override
  String get listFilter_filters => 'Filteralternativ';

  @override
  String get listFilter_all => 'Alla';

  @override
  String get listFilter_favorites => 'Favoriter';

  @override
  String get listFilter_addToFavorites => 'Lägg till i favoriter';

  @override
  String get listFilter_removeFromFavorites => 'Ta bort från favoriter';

  @override
  String get listFilter_users => 'Användare';

  @override
  String get listFilter_repeaters => 'Repeatrar';

  @override
  String get listFilter_roomServers => 'Rumsservrar';

  @override
  String get listFilter_unreadOnly => 'Endast oinlästa';

  @override
  String get listFilter_newGroup => 'Ny grupp';

  @override
  String get traceCard_title => 'Spårkort';

  @override
  String get traceCard_open => 'Dela spårkort';

  @override
  String traceCard_from(String name) {
    return 'Från $name';
  }

  @override
  String traceCard_to(String name) {
    return 'Till $name';
  }

  @override
  String traceCard_sentAt(String time) {
    return 'Skickat $time';
  }

  @override
  String traceCard_roundTrip(String seconds) {
    return 'Tur och retur $seconds s';
  }

  @override
  String traceCard_hops(int count) {
    return 'Hopp: $count';
  }

  @override
  String get traceCard_backToYou => 'Tillbaka till dig';

  @override
  String traceCard_distance(String distance) {
    return 'Rutt $distance';
  }

  @override
  String traceCard_weakest(String snr) {
    return 'Svagaste länken $snr';
  }

  @override
  String get traceCard_noMap =>
      'Inga kända positioner för rutten, så ingen karta.';

  @override
  String get traceCard_guessed => 'uppskattad position';

  @override
  String get traceCard_mapLabel => 'Karta över tur och retur';

  @override
  String get traceCard_shareImage => 'Dela bild';

  @override
  String get traceCard_shareText => 'Dela text';

  @override
  String get traceCard_shareFailed => 'Kunde inte dela spårkortet.';

  @override
  String get traceCard_snrUnknown => 'ingen SNR';

  @override
  String get pathTrace_you => 'Du';

  @override
  String get pathTrace_failed => 'Ruttspårningen misslyckades.';

  @override
  String get pathTrace_notAvailable => 'Ruttspårning är inte tillgänglig.';

  @override
  String get pathTrace_refreshTooltip => 'Uppdatera ruttspårning.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Ett eller flera hopp saknar position!';

  @override
  String get pathTrace_clearTooltip => 'Rensa rutt';

  @override
  String get losSelectStartEnd => 'Välj start- och slutnoder för LOS.';

  @override
  String losRunFailed(String error) {
    return 'Synlinjekontroll misslyckades: $error';
  }

  @override
  String get losClearAllPoints => 'Rensa alla punkter';

  @override
  String get losRunToViewElevationProfile => 'Kör LOS för att se höjdprofil';

  @override
  String get losMenuTitle => 'LOS-menyn';

  @override
  String get losMenuSubtitle =>
      'Tryck på noder eller tryck länge på kartan för anpassade punkter';

  @override
  String get losShowDisplayNodes => 'Visa displaynoder';

  @override
  String get losCustomPoints => 'Anpassade punkter';

  @override
  String losCustomPointLabel(int index) {
    return 'Anpassad $index';
  }

  @override
  String get losPointA => 'Punkt A';

  @override
  String get losPointB => 'Punkt B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Antenn A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Antenn B: $value $unit';
  }

  @override
  String get losRun => 'Kör LOS';

  @override
  String get losNoElevationData => 'Inga höjddata';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, fri siktlinje, minsta frigång $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, blockerad av $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: kollar...';

  @override
  String get losStatusNoData => 'LOS: inga data';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total fria, $blocked blockerade, $unknown okända';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Höjddata är inte tillgänglig för ett eller flera prover.';

  @override
  String get losErrorInvalidInput =>
      'Ogiltiga poäng/höjddata för LOS-beräkning.';

  @override
  String get losRenameCustomPoint => 'Byt namn på anpassad punkt';

  @override
  String get losPointName => 'Punktnamn';

  @override
  String get losShowPanelTooltip => 'Visa LOS-panelen';

  @override
  String get losHidePanelTooltip => 'Dölj LOS-panelen';

  @override
  String get losElevationAttribution => 'Höjddata: Open-Meteo (CC BY 4.0)';

  @override
  String get losLegendRadioHorizon => 'Radiohorisont';

  @override
  String get losLegendLosBeam => 'Siktlinje';

  @override
  String get losLegendTerrain => 'Terräng';

  @override
  String get losBlockedSpotsTitle => 'Blockerade punkter';

  @override
  String get losBlockedSpotsHint =>
      'Klicka på en markerad plats för att framhäva den på kartan.';

  @override
  String losBlockedSpotChip(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit • $obstruction $heightUnit';
  }

  @override
  String get losSelectedObstructionTitle => 'Valt hinder';

  @override
  String losSelectedObstructionDetails(
    String obstruction,
    String heightUnit,
    String distanceFromA,
    String distanceUnit,
    String distanceFromB,
  ) {
    return 'Blockerad av $obstruction $heightUnit, $distanceFromA från A och $distanceFromB från B ($distanceUnit).';
  }

  @override
  String get losFrequencyLabel => 'Frekvens';

  @override
  String get losFrequencyInfoTooltip => 'Visa detaljer om beräkningen';

  @override
  String get losFrequencyDialogTitle => 'Beräkning av radiohorisonten';

  @override
  String losFrequencyDialogDescription(
    double baselineK,
    double baselineFreq,
    double frequencyMHz,
    double kFactor,
  ) {
    return 'Med start från k=$baselineK vid $baselineFreq MHz, justerar beräkningen k-faktorn för det aktuella $frequencyMHz MHz-bandet, som definierar den böjda radiohorisonten.';
  }

  @override
  String get contacts_pathTrace => 'Ruttspårning';

  @override
  String get contacts_ping => 'Pinga';

  @override
  String get contacts_repeaterPathTrace => 'Ruttspårning till repeater';

  @override
  String get contacts_repeaterPing => 'Ping-repeater';

  @override
  String get contacts_roomPathTrace => 'Ruttspårning till rumsserver';

  @override
  String get contacts_roomPing => 'Pinga rumsserver';

  @override
  String get contacts_chatTraceRoute => 'Spåra rutt';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Spåra rutt till $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Urklipp är tomt.';

  @override
  String get contacts_pasteNotContact =>
      'Det är ingen MeshCore-kontakt. Kopiera en meshcore://-kontaktlänk eller annons och försök igen.';

  @override
  String get contacts_invalidAdvertFormat => 'Ogiltiga kontaktuppgifter';

  @override
  String get contacts_contactImported => 'Kontakt har importerats.';

  @override
  String get contacts_contactImportFailed => 'Kontakt kunde inte importeras.';

  @override
  String get contacts_zeroHopAdvert => 'Nollhoppsannons';

  @override
  String get contacts_floodAdvert => 'Flood-annonsering';

  @override
  String get contacts_copyAdvertToClipboard => 'Kopiera annons till urklipp';

  @override
  String get contacts_addContactFromClipboard =>
      'Lägg till kontakt från urklipp';

  @override
  String get contacts_ShareContact => 'Kopiera kontakt till Urklipp';

  @override
  String get contacts_ShareContactZeroHop => 'Dela kontakt via annons';

  @override
  String get contacts_zeroHopContactAdvertSent => 'Skickat kontakt via annons.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Misslyckades med att skicka kontakt.';

  @override
  String get contacts_contactAdvertCopied => 'Annons kopierad till Urklipp.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopiering av annons till Urklipp misslyckades.';

  @override
  String get notification_activityTitle => 'MeshCore Aktivitet';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'meddelanden',
      one: 'meddelande',
    );
    return '$count $_temp0';
  }

  @override
  String notification_channelMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kanalmeddelanden',
      one: 'kanalmeddelande',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nya noder',
      one: 'ny nod',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Ny $contactType upptäckt';
  }

  @override
  String get notification_receivedNewMessage => 'Nytt meddelande mottaget';

  @override
  String get settings_gpxExportRepeaters =>
      'Exportera repeatrar/rumsservrar till GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exporterar repeatrar/rumsservrar med position till en GPX-fil.';

  @override
  String get settings_gpxExportContacts =>
      'Exportera Companion-kontakter till GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exporterar Companion-enheter med position till en GPX-fil.';

  @override
  String get settings_gpxExportAll => 'Exportera alla kontakter till GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exporterar alla kontakter med en plats till GPX-fil.';

  @override
  String get settings_gpxExportSuccess => 'Har exporterat GPX-fil med framgång';

  @override
  String get settings_gpxExportNoContacts => 'Inga kontakter att exportera.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Stöds inte på din enhet/operativsystem';

  @override
  String get settings_gpxExportError =>
      'Det uppstod ett fel när data exporterades.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Repeater- och rumsserverplatser';

  @override
  String get settings_gpxExportChat => 'Companion-positioner';

  @override
  String get settings_gpxExportAllContacts => 'Alla kontakters platser';

  @override
  String get settings_gpxExportShareText =>
      'Kartdata exporterad från NOTORYX Core';

  @override
  String get settings_gpxExportShareSubject =>
      'NOTORYX Core export av GPX-kartdata';

  @override
  String get snrIndicator_nearByRepeaters => 'Närliggande repeatrar';

  @override
  String get snrIndicator_lastSeen => 'Senast sedd';

  @override
  String get contactsSettings_title => 'Kontaktinställningar';

  @override
  String get contactsSettings_autoAddTitle => 'Automatisk upptäckt';

  @override
  String get contactsSettings_otherTitle =>
      'Andra inställningar relaterade till kontakt';

  @override
  String get contactsSettings_autoAddUsersTitle =>
      'Lägg till användare automatiskt';

  @override
  String get contactsSettings_autoAddUsersSubtitle =>
      'Tillåt Companion-enheten att automatiskt lägga till upptäckta användare.';

  @override
  String get contactsSettings_autoAddRepeatersTitle =>
      'Lägg till repeatrar automatiskt';

  @override
  String get contactsSettings_autoAddRepeatersSubtitle =>
      'Tillåt Companion-enheten att automatiskt lägga till upptäckta repeatrar.';

  @override
  String get contactsSettings_autoAddRoomServersTitle =>
      'Lägg automatiskt till rumsservrar';

  @override
  String get contactsSettings_autoAddRoomServersSubtitle =>
      'Tillåt Companion-enheten att automatiskt lägga till upptäckta rumsservrar.';

  @override
  String get contactsSettings_autoAddSensorsTitle =>
      'Lägg till sensorer automatiskt';

  @override
  String get contactsSettings_autoAddSensorsSubtitle =>
      'Tillåt Companion-enheten att automatiskt lägga till upptäckta sensorer.';

  @override
  String get contactsSettings_overwriteOldestTitle => 'Skriv över äldsta';

  @override
  String get contactsSettings_overwriteOldestSubtitle =>
      'När kontaktlistan är full ersätts den äldsta icke-favoriterade kontakten.';

  @override
  String get discoveredContacts_Title => 'Upptäckta kontakter';

  @override
  String get discoveredContacts_noMatching => 'Inga matchande kontakter';

  @override
  String get discoveredContacts_searchHint => 'Sök bland upptäckta kontakter';

  @override
  String get discoveredContacts_contactAdded => 'Kontakt tillagd';

  @override
  String get discoveredContacts_addContact => 'Lägg till kontakt';

  @override
  String get discoveredContacts_copyContact => 'Kopiera kontakt till urklipp';

  @override
  String get discoveredContacts_deleteContact => 'Ta bort kontakt';

  @override
  String get discoveredContacts_deleteContactAll =>
      'Ta bort alla upptäckta kontakter';

  @override
  String get discoveredContacts_deleteContactAllContent =>
      'Är du säker på att du vill ta bort alla upptäckta kontakter?';

  @override
  String get chat_sendCooldown =>
      'Vänligen vänta en stund innan du skickar igen.';

  @override
  String get appSettings_jumpToOldestUnread => 'Gå till äldsta olästa';

  @override
  String get appSettings_jumpToOldestUnreadSubtitle =>
      'När du öppnar en chatt med oinlästa meddelanden, scrolla till det första oinlästa meddelandet istället för det senaste.';

  @override
  String get appSettings_languageHu => 'Ungerska';

  @override
  String get appSettings_languageJa => 'Japanska';

  @override
  String get appSettings_languageKo => 'Koreanska';

  @override
  String get radioStats_tooltip => 'Radio- och mesh-statistik';

  @override
  String get radioStats_screenTitle => 'Radiostatistik';

  @override
  String get radioStats_notConnected =>
      'Anslut till en enhet för att visa radiostatistik.';

  @override
  String get radioStats_firmwareTooOld =>
      'Radiostatistik kräver Companion-firmware v8 eller senare.';

  @override
  String get radioStats_waiting => 'Väntar på data…';

  @override
  String radioStats_noiseFloor(int noiseDbm) {
    return 'Bakgrundsnivå: $noiseDbm dBm';
  }

  @override
  String radioStats_lastRssi(int rssiDbm) {
    return 'Senaste RSSI-värde: $rssiDbm dBm';
  }

  @override
  String radioStats_lastSnr(String snr) {
    return 'Senaste SNR: $snr dB';
  }

  @override
  String radioStats_txAir(int seconds) {
    return 'TX-tid (total): $seconds sekunder';
  }

  @override
  String radioStats_rxAir(int seconds) {
    return 'RX-tid (total): $seconds s';
  }

  @override
  String get radioStats_chartCaption =>
      'Brusgolv (dBm) för de senaste mätningarna.';

  @override
  String radioStats_stripNoise(int noiseDbm) {
    return 'Bakgrundsnivå: $noiseDbm dBm';
  }

  @override
  String get radioStats_stripWaiting => 'Hämtar radiostatistik…';

  @override
  String get radioStats_settingsTile => 'Radiostatistik';

  @override
  String get radioStats_settingsSubtitle =>
      'Brusgolv, RSSI, SNR och sändningstid';

  @override
  String get translation_title => 'Översättning';

  @override
  String get imageMessages_enableTitle => 'Aktivera bildmeddelanden';

  @override
  String get imageMessages_enableSubtitle =>
      'Skicka bilder över meshnätet. Kräver en engångsnedladdning av bildmodellen.';

  @override
  String get imageMessages_modelSectionTitle => 'Bildmodell';

  @override
  String get imageMessages_downloadModel => 'Ladda ned';

  @override
  String get imageMessages_cancelDownload => 'Avbryt';

  @override
  String get imageMessages_removeModel => 'Ta bort modellen';

  @override
  String get imageMessages_modelReady => 'Färdig';

  @override
  String get imageMessages_modelNotPublished =>
      'Inte publicerad ännu — den här versionen kan inte ladda ned den.';

  @override
  String get imageMessages_downloadFailed =>
      'Bildmodellen kunde inte laddas ner.';

  @override
  String get imageMessages_autoProcessTitle => 'Bearbeta bilder automatiskt';

  @override
  String get imageMessages_autoProcessSubtitle =>
      'Rekonstruera varje bild så snart den kommer. Använder cirka 2 GB minne i ungefär en sekund varje gång; låt detta vara avstängt om du hellre vill rekonstruera med ett tryck.';

  @override
  String get translation_enableTitle => 'Aktivera översättning';

  @override
  String get translation_enableSubtitle =>
      'Översätt inkommande meddelanden och möjliggör översättning före avsändning.';

  @override
  String get translation_composerTitle => 'Översätt innan du skickar';

  @override
  String get translation_composerSubtitle =>
      'Styr standardtillståndet för kompositorns översättningsikon.';

  @override
  String get translation_autoIncomingTitle =>
      'Översätt meddelanden automatiskt';

  @override
  String get translation_autoIncomingSubtitle =>
      'Översätter meddelanden automatiskt för notifieringar samt för chattar och kanaler.';

  @override
  String get translation_translateMessage => 'Översätt meddelande';

  @override
  String get translation_targetLanguage => 'Målspråk';

  @override
  String get translation_useAppLanguage => 'Använd appens språk';

  @override
  String get translation_downloadedModelLabel => 'Nedladdad modell';

  @override
  String get translation_presetModelLabel =>
      'Fördefinierad Hugging Face-modell';

  @override
  String get translation_manualUrlLabel => 'Manuell modell-URL';

  @override
  String get translation_downloadModel => 'Ladda ner modellen';

  @override
  String get translation_downloading => 'Nedladdning...';

  @override
  String get translation_working => 'Arbetar…';

  @override
  String get translation_stop => 'Stopp';

  @override
  String get translation_mergingChunks =>
      'Slå samman de nedladdade delarna till en slutlig fil...';

  @override
  String get translation_downloadedModels => 'Nedladdade modeller';

  @override
  String get translation_deleteModel => 'Ta bort modell';

  @override
  String get translation_modelDownloaded =>
      'Översättningsmodellen har laddats ner.';

  @override
  String get translation_downloadStopped => 'Nedladdningen avbruten.';

  @override
  String translation_downloadFailed(String error) {
    return 'Nedladdning misslyckades: $error';
  }

  @override
  String get translation_enterUrlFirst =>
      'Ange först en URL för en specifik modell.';

  @override
  String get scanner_linuxPairingShowPin => 'Visa PIN';

  @override
  String get scanner_linuxPairingHidePin => 'Dölj PIN';

  @override
  String get scanner_linuxPairingPinTitle => 'Bluetooth‑parnings‑PIN';

  @override
  String scanner_linuxPairingPinPrompt(String deviceName) {
    return 'Ange PIN för $deviceName (lämna tomt om ingen).';
  }

  @override
  String get translation_messageTranslation => 'Meddelandets översättning';

  @override
  String get translation_translateBeforeSending => 'Översätt innan du skickar';

  @override
  String get translation_composerEnabledHint =>
      'Meddelandena kommer att översättas innan de skickas.';

  @override
  String get translation_composerDisabledHint =>
      'Skicka meddelanden på det ursprungliga, stavade språket.';

  @override
  String translation_translateTo(String language) {
    return 'Översätt till $language';
  }

  @override
  String get translation_translationOptions => 'Översättningsalternativ';

  @override
  String get translation_systemLanguage => 'Språk för systemet';

  @override
  String get background_serviceTitle => 'MeshCore körs';

  @override
  String get background_serviceText => 'Håller BLE-anslutningen aktiv';

  @override
  String appSettings_translationModelDeleted(String name) {
    return 'Tog bort $name';
  }

  @override
  String appSettings_translationModelDeleteFailed(String error) {
    return 'Det gick inte att ta bort: $error';
  }

  @override
  String channels_channelUpdateFailed(String error) {
    return 'Det gick inte att uppdatera kanalen: $error';
  }

  @override
  String get contact_typeChat => 'Chatt';

  @override
  String get contact_typeRepeater => 'Repeater';

  @override
  String get contact_typeRoom => 'Rum';

  @override
  String get contact_typeSensor => 'Sensor';

  @override
  String get contact_typeUnknown => 'Okänd';

  @override
  String get map_zoomIn => 'Zooma in';

  @override
  String get map_zoomOut => 'Zooma ut';

  @override
  String get map_centerMap => 'Centrera kartan';

  @override
  String get chrome_bluetoothRequiresChromium =>
      'Web Bluetooth kräver en Chromium-baserad webbläsare.';

  @override
  String channels_communityShortId(String id) {
    return 'ID: $id...';
  }

  @override
  String get pathTrace_legendGpsConfirmed => 'GPS-verifierat';

  @override
  String get pathTrace_legendInferred => 'Antagen position';

  @override
  String get pathMap_viewSingle => 'Enkel';

  @override
  String get pathMap_viewCombined => 'Kombinerat';

  @override
  String get pathMap_play => 'Spela';

  @override
  String get pathMap_pause => 'Pausa';

  @override
  String get pathMap_replay => 'Återspela';

  @override
  String get pathMap_stepBack => 'Föregående hopp';

  @override
  String get pathMap_stepForward => 'Nästa hopp';

  @override
  String get pathMap_animationOn => 'Visa paketanimering';

  @override
  String get pathMap_animationOff => 'Dölj paketanimering';

  @override
  String pathMap_hopOf(int current, int total) {
    return 'Hopp $current av $total';
  }

  @override
  String pathMap_observedPaths(int count) {
    return 'Observerade rutter: $count';
  }

  @override
  String get pathMap_primary => 'Primär';

  @override
  String pathMap_alternate(int index) {
    return 'Alternativ $index';
  }

  @override
  String pathMap_hopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hopp',
      one: '1 hopp',
    );
    return '$_temp0';
  }

  @override
  String pathMap_gpsCount(int confirmed, int total) {
    return '$confirmed/$total GPS';
  }

  @override
  String get pathMap_legendShared => 'Delat segment';

  @override
  String get pathMap_legendEstimated => 'Uppskattat segment';

  @override
  String pathMap_sharedNodeCount(int count) {
    return 'Används av $count rutter';
  }

  @override
  String pathMap_partialAnimation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hopp saknar position — den visade rutten är ofullständig',
      one: '1 hopp saknar position — den visade rutten är ofullständig',
    );
    return '$_temp0';
  }

  @override
  String get pathMap_showAllPaths => 'Visa allt';

  @override
  String get pathMap_hidePath => 'Dölj rutt';

  @override
  String get pathMap_showPath => 'Visa rutt';

  @override
  String get pathMap_collapsePanel => 'Fäll ihop panel';

  @override
  String get pathMap_expandPanel => 'Expandera panel';

  @override
  String get pathMap_noLocation => 'Ingen position';

  @override
  String get pathMap_followPacket => 'Lås vy till paket';

  @override
  String get pathMap_unfollowPacket => 'Lås upp vy från paket';

  @override
  String get imageSend_title => 'Skicka bild';

  @override
  String get imageSend_cropNote =>
      'Storleksändrad till 512 × 512 · bildförhållandet bevaras inte';

  @override
  String get imageSend_originalSize => 'Original';

  @override
  String get imageSend_onAirSize => 'Överförd storlek';

  @override
  String get imageSend_quality => 'Kvalitet';

  @override
  String get imageSend_qualityStandard => 'Standard';

  @override
  String get imageSend_qualityHigh => 'Hög';

  @override
  String get imageSend_packetsLabel => 'Paket';

  @override
  String get imageSend_airtimeLabel => 'Sändningstid';

  @override
  String get imageSend_sizeLabel => 'Nyttolast';

  @override
  String imageSend_packetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'paket',
      one: 'paket',
    );
    return '$count $_temp0';
  }

  @override
  String imageSend_range(String min, String max) {
    return '$min–$max';
  }

  @override
  String get imageSend_unknownValue => '—';

  @override
  String get imageSend_radioUnknownTitle => 'Radioindikatorer inte kända';

  @override
  String get imageSend_radioUnknownBody =>
      'Anslut till en enhet så att sändningstiden kan beräknas.';

  @override
  String get imageSend_longSendTitle => 'Lång överföring';

  @override
  String imageSend_longSendBody(String duration) {
    return 'Det här kommer att hålla kanalen upptagen i ungefär $duration.';
  }

  @override
  String get imageSend_floodNote =>
      'Flood-routing: varje repeater inom räckvidd sänder om varje paket, så kanalen hålls upptagen längre än så här.';

  @override
  String get imageSend_parityTitle => 'Lägg till återställningspaket';

  @override
  String get imageSend_paritySubtitle =>
      'Ett extra paket. Gruppmeddelanden kvitteras inte, så mottagaren kan återskapa bilden om ett enda paket går förlorat.';

  @override
  String get imageSend_send => 'Sänd';

  @override
  String get imageSend_cancel => 'Avbryt';

  @override
  String get imageSend_encodeFailed => 'Denna bild kan inte kodas.';

  @override
  String get imageSend_codecDownloading =>
      'Bildmodellen laddas fortfarande ned.';

  @override
  String get imageSend_codecUnavailable =>
      'Bildsändning är inte tillgänglig på den här enheten.';

  @override
  String get imageSend_codecDisabled =>
      'Bildmeddelanden är avstängda i inställningarna.';

  @override
  String get imageSend_deviceUnsupported =>
      'Den här radion kan inte skicka bildpaket. Anslut en enhet med Companion-firmware 13 eller senare.';

  @override
  String get imageSend_directMessagesUnsupported =>
      'Bilder skickas som gruppdata och kan därför bara skickas till en kanal — inte som direktmeddelande.';

  @override
  String get imageSend_tooLarge =>
      'Bilden kodades till mer paket än meshformaten tillåter.';

  @override
  String imageSend_sentConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'paket',
      one: 'paket',
    );
    return 'Bilden skickades som $count $_temp0.';
  }

  @override
  String imageSend_sendFailed(String error) {
    return 'Bilden kunde inte skickas: $error';
  }

  @override
  String imageSend_sendingProgress(int sent, int total) {
    return 'Skickar bild — paket $sent av $total';
  }

  @override
  String receivedImage_senderPrefix(String prefix) {
    return 'Nod $prefix';
  }

  @override
  String receivedImage_incoming(int received, int total) {
    return '$received av $total paket';
  }

  @override
  String get receivedImage_queued => 'Väntar på avkodning';

  @override
  String get receivedImage_tapToDecode => 'Tryck för att avkoda';

  @override
  String get receivedImage_decoding => 'Rekonstruktion… om 1 sekund';

  @override
  String receivedImage_incomplete(int received, int total) {
    return 'Bilden är ofullständig — $received av $total paket kom fram';
  }

  @override
  String get receivedImage_corrupt => 'Bilden kunde inte rekonstrueras';

  @override
  String get receivedImage_decoderMissing =>
      'Bild mottagen — bildavkodning är avstängd';

  @override
  String get receivedImage_evicted => 'Bild inte lagrad längre';

  @override
  String get receivedImage_retry => 'Försök igen';

  @override
  String get receivedImage_decodeAgain => 'Avkoda igen';

  @override
  String get receivedImage_openSettings => 'Konfigurera';

  @override
  String get receivedImage_tapToProcess => 'Tryck för att bearbeta';

  @override
  String receivedImage_awaiting(int bytes, int packets) {
    String _temp0 = intl.Intl.pluralLogic(
      packets,
      locale: localeName,
      other: 'paket',
      one: 'paket',
    );
    return '$bytes byte · $packets $_temp0';
  }

  @override
  String imageSend_secondsValue(String seconds) {
    return '$seconds sekunder';
  }

  @override
  String imageSend_minutesSecondsValue(String minutes, String seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get bastion_tagline => 'Kommunikation utan infrastruktur.';

  @override
  String get bastion_nodes => 'Noder';

  @override
  String get bastion_repeaters => 'Repeatrar';

  @override
  String get bastion_active1h => 'Aktiva 1 h';

  @override
  String get bastion_mapCoverage => 'Karta + täckning';

  @override
  String get bastion_routeIntelligence => 'Ruttanalys';

  @override
  String get bastion_repeaterTools => 'Repeaterverktyg';

  @override
  String get bastion_fieldStats => 'Fältstatistik';

  @override
  String get bastion_fieldOps => 'Tur + fältarbete';

  @override
  String get bastion_coverageCapture => 'Täckningsinsamling';

  @override
  String get bastion_mapAttribution =>
      'Kartdata © OpenStreetMap-bidragsgivare; kartrutor från vald leverantör';

  @override
  String bastion_observationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observationer',
      one: '1 observation',
    );
    return '$_temp0';
  }

  @override
  String bastion_uniqueNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unika noder',
      one: '1 unik nod',
    );
    return '$_temp0';
  }

  @override
  String bastion_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hopp',
      one: '1 hopp',
    );
    return '$_temp0';
  }

  @override
  String bastion_minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuter',
      one: '1 minut',
    );
    return '$_temp0';
  }

  @override
  String get sos_holdHint =>
      'Håll in i 2 sekunder. Skickar din position till dina turkontakter var 5:e minut tills någon svarar.';

  @override
  String sos_holdHintChannel(String channel) {
    return 'Håll in i 2 sekunder. Skickar din position till dina turkontakter och $channel var 5:e minut tills någon svarar.';
  }

  @override
  String sos_notSent(String error) {
    return 'SOS skickades inte: $error';
  }

  @override
  String sos_acknowledged(String name) {
    return 'Bekräftat av $name. Upprepningar stoppade.';
  }

  @override
  String get sos_waitingForRadio => 'Väntar på att radion ska skicka…';

  @override
  String sos_repeatsFinished(int sends, int max) {
    return 'Skickat $sends av $max gånger. Upprepningar klara; inget svar än.';
  }

  @override
  String sos_nextAt(int sends, int max, String time) {
    return 'Skickat $sends av $max gånger. Nästa kl. $time.';
  }

  @override
  String get sos_active => 'SOS AKTIVT';

  @override
  String get sos_stop => 'STOPPA';

  @override
  String get sos_imSafe => 'JAG ÄR I SÄKERHET';

  @override
  String get sos_holdSemantics => 'SOS. Håll in för att skicka.';

  @override
  String get sos_keepHolding => 'FORTSÄTT HÅLLA…';

  @override
  String get sos_holdForSos => 'HÅLL FÖR SOS';

  @override
  String get sos_blockStorage => 'Åtgärda först fältloggens lagringsfel.';

  @override
  String get sos_blockNotConnected =>
      'Anslut din MeshCore-radio för att skicka ett SOS.';

  @override
  String get sos_blockNoTarget =>
      'Välj turkontakter eller en SOS-kanal under Planera tur.';

  @override
  String get checkIn_labelOk => 'Jag mår bra';

  @override
  String get checkIn_labelAtCamp => 'I lägret';

  @override
  String get checkIn_labelDelayed => 'Försenad';

  @override
  String get checkIn_labelHeadingBack => 'På väg tillbaka';

  @override
  String get checkIn_blockLoading => 'Laddar din tur…';

  @override
  String get checkIn_blockStorage =>
      'Åtgärda fältloggens lagringsfel innan du skickar.';

  @override
  String get checkIn_blockBusy => 'En incheckning skickas. Vänta.';

  @override
  String get checkIn_blockNoContacts => 'Välj turkontakter under Planera tur.';

  @override
  String get checkIn_blockRosterIncomplete =>
      'Vissa turkontakter är inte tillgängliga. Granska din lista.';

  @override
  String get checkIn_blockNotConnected =>
      'Anslut din MeshCore-radio för att checka in.';

  @override
  String get checkIn_blockNotActive =>
      'Starta din tur för att aktivera incheckningar.';

  @override
  String get checkIn_notSent => 'Inte skickad';

  @override
  String checkIn_deliveredToOne(String name) {
    return 'Levererad till $name';
  }

  @override
  String checkIn_deliveredToAll(int count) {
    return 'Levererad till alla $count kontakter';
  }

  @override
  String checkIn_deliveredSome(String delivered, String total) {
    return 'Levererad till $delivered av $total';
  }

  @override
  String checkIn_notDeliveredTo(String names) {
    return 'Inte levererad: $names';
  }

  @override
  String get checkIn_waitingForRest => 'Väntar på resten';

  @override
  String get checkIn_aContact => 'en kontakt';

  @override
  String get checkIn_statusPending => 'Väntar';

  @override
  String get checkIn_statusSent => 'Skickad';

  @override
  String get checkIn_statusDelivered => 'Levererad';

  @override
  String get checkIn_statusFailed => 'Misslyckad';

  @override
  String get checkIn_explainPending =>
      'Köad lokalt. Detta bekräftar varken radiosändning eller mottagning.';

  @override
  String get checkIn_explainSent =>
      'Radion tog emot sändningen. Ingen leveranskvittens har registrerats.';

  @override
  String get checkIn_explainDelivered =>
      'Appen registrerade en leveranskvittens. Det bevisar inte att personen har läst den.';

  @override
  String get checkIn_explainFailed =>
      'Ingen bekräftad leverans. Kontrollera radioanslutning, mottagarens nåbarhet och historik för nya försök.';

  @override
  String get checkIn_explainUnknown =>
      'Leveransstatus är inte tillgänglig. Utgå inte från att meddelandet kom fram.';

  @override
  String get tripBrief_heading => 'NOTORYX • MeshCore-turöversikt';

  @override
  String tripBrief_trip(String name) {
    return 'Tur: $name';
  }

  @override
  String tripBrief_status(String status) {
    return 'Status: $status';
  }

  @override
  String get tripBrief_active => 'Aktiv';

  @override
  String get tripBrief_stopped => 'Stoppad';

  @override
  String tripBrief_contacts(String names) {
    return 'Kontakter: $names';
  }

  @override
  String get tripBrief_noneSelected => 'Inga valda';

  @override
  String get tripBrief_unavailableContact =>
      'Otillgänglig kontakt (granska listan)';

  @override
  String tripBrief_overdueAfter(int minutes) {
    return 'Aktivitet försenad efter: $minutes minuter (den här telefonen varnar när en kontakt blir tyst)';
  }

  @override
  String tripBrief_reminder(String value) {
    return 'Påminnelse om incheckning: $value';
  }

  @override
  String tripBrief_reminderEvery(int minutes) {
    return 'var $minutes:e minut utan incheckning';
  }

  @override
  String tripBrief_choices(String choices) {
    return 'Incheckningsval: $choices';
  }

  @override
  String tripBrief_position(String value) {
    return 'Radioposition i incheckningar: $value';
  }

  @override
  String get tripBrief_includedMayBeStale => 'Ingår; kan vara inaktuell';

  @override
  String tripBrief_battery(String value) {
    return 'Radiobatteri i incheckningar: $value';
  }

  @override
  String get tripBrief_included => 'Ingår';

  @override
  String get tripBrief_off => 'Av';

  @override
  String get tripBrief_review =>
      'Granska mottagare och meddelande innan du skickar en incheckning.';

  @override
  String get tripBrief_noProof =>
      'Köad eller skickad bevisar inte leverans. En kvittens bevisar inte att den lästs.';

  @override
  String get tripBrief_overdueMeaning =>
      'Försenad betyder ingen ny kontaktaktivitet; det är inte en bekräftad nödsituation.';

  @override
  String get tripBrief_automations =>
      'Fältautomatiseringar körs bara medan appen är aktiv. Kom överens om en separat plan för missad kontakt.';

  @override
  String get tripBrief_sharesOnly =>
      'Den här översikten delar bara information; den skickar inget radiomeddelande och startar ingen tur.';

  @override
  String get fieldOps_title => 'NOTORYX Core fältarbete';

  @override
  String get fieldOps_tabTrip => 'Tur';

  @override
  String get fieldOps_tabReady => 'Redo';

  @override
  String get fieldOps_tabLog => 'Logg';

  @override
  String get fieldOps_tabAuto => 'Auto';

  @override
  String get fieldOps_tabCoverage => 'Täckning';

  @override
  String get fieldOps_tabConnection => 'Anslutning';

  @override
  String get fieldOps_diagnostics => 'Diagnostik';

  @override
  String get fieldOps_storageLoadError =>
      'Fältdata kunde inte laddas. Sparade data behölls; automatiseringar förblir avstängda.';

  @override
  String get fieldOps_storageSaveError =>
      'Fältdata kunde inte sparas. Automatiseringar stoppade; befintliga sparade data behålls.';

  @override
  String get fieldOps_regionHint =>
      'Välj ett område och zoomnivåer under Offlinekartor.';

  @override
  String fieldOps_regionLabel(String source, String minZoom, String maxZoom) {
    return '$source • zoom $minZoom–$maxZoom';
  }

  @override
  String fieldOps_mapVerifyFailed(String error) {
    return 'Kartområdet kunde inte verifieras: $error';
  }

  @override
  String fieldOps_tripActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tur aktiv • $count kontakter',
      one: 'Tur aktiv • 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_tripStopped =>
      'Turen är stoppad. Starta den när du är redo.';

  @override
  String fieldOps_reminderAt(String time) {
    return 'Påminnelse om incheckning kl. $time';
  }

  @override
  String fieldOps_quietTooLong(String names) {
    return 'Tyst för länge: $names';
  }

  @override
  String get fieldOps_planTrip => 'Planera tur';

  @override
  String get fieldOps_endTrip => 'Avsluta tur';

  @override
  String get fieldOps_startTrip => 'Starta tur';

  @override
  String get fieldOps_tripBrief => 'Turöversikt';

  @override
  String get fieldOps_connectRadio => 'Anslut radio';

  @override
  String get fieldOps_previewedCheckIns => 'Incheckningar med förhandsvisning';

  @override
  String get fieldOps_previewedCheckInsHint =>
      'Välj en status, granska de faktiska mottagarna och meddelandet och skicka sedan. Köad betyder inte levererad.';

  @override
  String get fieldOps_tripRoster => 'Turlista';

  @override
  String get fieldOps_rosterEmpty =>
      'Välj upp till sex kända chattkontakter under Planera tur.';

  @override
  String get fieldOps_rosterCaveat =>
      'Senast hörd är bevis på tidigare aktivitet. Det fastställer inte nuvarande nåbarhet. Försenad-märken betyder ingen ny kontaktaktivitet, inte en bekräftad nödsituation.';

  @override
  String get fieldOps_offlineMaps => 'Offlinekartor';

  @override
  String get fieldOps_checkingTiles => 'Kontrollerar sparade kartrutor…';

  @override
  String fieldOps_cachedTiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cachade kartrutor.',
      one: '1 cachad kartruta.',
    );
    return '$_temp0 Det garanterar inte att hela din rutt täcks.';
  }

  @override
  String get fieldOps_downloadAreas => 'Ladda ned / granska offlineområden';

  @override
  String fieldOps_lastCheckIn(String time) {
    return 'Senaste incheckning, $time';
  }

  @override
  String fieldOps_deliveryChip(String name, String status) {
    return '$name: $status';
  }

  @override
  String get fieldOps_contactFallback => 'Kontakt';

  @override
  String fieldOps_resendFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skicka igen till $count ej levererade',
      one: 'Skicka igen till 1 ej levererad',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_memberUnavailable => 'Vald kontakt är inte tillgänglig';

  @override
  String get fieldOps_memberUnavailableHint =>
      'Granska turen innan du skickar.';

  @override
  String fieldOps_lastActivity(int minutes) {
    return 'Senaste aktivitet för $minutes min sedan';
  }

  @override
  String fieldOps_lastActivityOverdue(int minutes) {
    return 'Senaste aktivitet för $minutes min sedan • försenad';
  }

  @override
  String get fieldOps_noCheckInRecorded =>
      'Ingen incheckning registrerad i den här loggen.';

  @override
  String get fieldOps_tripMap => 'Turkarta';

  @override
  String get fieldOps_tripMapEmpty =>
      'Inga valda kontakter har annonserat koordinater än.';

  @override
  String get fieldOps_lastPositions => 'Senast annonserade positioner';

  @override
  String get fieldOps_positionsCaveat =>
      'Positioner kan vara inaktuella. Kartan spårar inte telefonens GPS och bevisar inte att medlemmarna är här nu.';

  @override
  String get fieldOps_briefPreviewTitle => 'Förhandsvisa turöversikt';

  @override
  String get fieldOps_briefPreviewHint =>
      'Innehåller tur- och kontaktnamn. Granska innan du delar. Koordinater, nycklar och meddelandehistorik utelämnas.';

  @override
  String get fieldOps_shareBrief => 'Dela översikt';

  @override
  String get fieldOps_briefSubject => 'NOTORYX-Core-turöversikt';

  @override
  String get fieldOps_tripName => 'Turnamn';

  @override
  String get fieldOps_defaultTripName => 'Min tur';

  @override
  String get fieldOps_includePosition =>
      'Inkludera radions annonserade position';

  @override
  String get fieldOps_includePositionHint =>
      'Kan vara inaktuell; delning är av som standard.';

  @override
  String get fieldOps_includeBattery => 'Inkludera radiobatteri';

  @override
  String get fieldOps_overdueLabel => 'Varna mig när en kontakt varit tyst i';

  @override
  String get fieldOps_reminderLabel => 'Påminn mig att checka in';

  @override
  String get fieldOps_reminderHelper =>
      'En telefonavisering, även om NOTORYX Core är stängt.';

  @override
  String get fieldOps_reminderOff => 'Av';

  @override
  String fieldOps_reminderAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Efter $count minuter utan incheckning',
      one: 'Efter 1 minut utan incheckning',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_sosChannelLabel => 'SOS går också till kanal';

  @override
  String get fieldOps_sosChannelNone => 'Ingen';

  @override
  String get fieldOps_selectContacts =>
      'Välj upp till sex kända chattkontakter';

  @override
  String get fieldOps_sendCheckInTitle => 'Skicka incheckning?';

  @override
  String fieldOps_recipients(String names) {
    return 'Till: $names';
  }

  @override
  String get fieldOps_sendCheckInHint =>
      'Använder vanliga direktmeddelanden. Leveransen följs i fältloggen.';

  @override
  String get fieldOps_send => 'Skicka';

  @override
  String get sosRelay_title => 'SOS-vidarebefordran';

  @override
  String get sosRelay_enable =>
      'Vidarebefordra SOS som ingen repeater skickade vidare';

  @override
  String get sosRelay_needsFirmware =>
      'Kräver radiofirmware v1.16 eller senare';

  @override
  String get sosRelay_noneYet => 'Inga SOS vidarebefordrade än';

  @override
  String sosRelay_relayedCount(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SOS-paket vidarebefordrade, senast $time',
      one: '1 SOS-paket vidarebefordrat, senast $time',
    );
    return '$_temp0';
  }

  @override
  String get sosRelay_explainer =>
      'När radion hör ett SOS direkt från avsändaren och ingen repeater skickar det vidare inom ungefär 15 sekunder, skickar NOTORYX det en gång till, oförändrat, så att det når en repeater som du hör men avsändaren inte gör. Bara SOS i dina kanaler vidarebefordras. Använder lite batteri och sändtid, så det är av som standard.';

  @override
  String get fieldOps_beforeYouLeave => 'Innan du ger dig av';

  @override
  String get fieldOps_radioConnected => 'Radio ansluten';

  @override
  String get fieldOps_connectHint => 'Anslut via Bluetooth, USB eller TCP.';

  @override
  String get fieldOps_radioBattery => 'Radiobatteri';

  @override
  String get fieldOps_batteryUnknown => 'Okänt; kontrollera radion.';

  @override
  String fieldOps_batteryDetail(String percent) {
    return '$percent % • ladda inför din planerade tur.';
  }

  @override
  String get fieldOps_tripContacts => 'Turkontakter';

  @override
  String fieldOps_tripContactsDetail(String available, String selected) {
    return '$available/$selected tillgängliga. Kontrollera att de har kompatibla radioapparater och kanaler.';
  }

  @override
  String get fieldOps_offlineArea => 'Valt offlinekartområde';

  @override
  String get fieldOps_checkingFiles => 'Kontrollerar lokala filer…';

  @override
  String fieldOps_regionStatus(
    String available,
    String expected,
    String missing,
  ) {
    return '$available/$expected kartrutefiler tillgängliga; $missing saknas. Detta är en ögonblicksbild; öppna området offline innan du ger dig av.';
  }

  @override
  String get fieldOps_locationChoice => 'Platsdelning';

  @override
  String get fieldOps_locationOptedIn =>
      'På: radions annonserade koordinater kan vara inaktuella.';

  @override
  String get fieldOps_locationOff =>
      'Delning är av. Dina incheckningar utelämnar koordinater.';

  @override
  String get fieldOps_automationAvailability =>
      'Automatiseringens tillgänglighet';

  @override
  String get fieldOps_automationAvailabilityDetail =>
      'Körs bara medan appen är aktiv. Viloläge, stängning eller förlorad radio kan förhindra schemalagda åtgärder.';

  @override
  String get fieldOps_readinessCaveat =>
      'Beredskapskontrollerna är vägledande; de bevisar inte radioräckvidd och garanterar inte leverans.';

  @override
  String get fieldOps_radio => 'Radio';

  @override
  String get fieldOps_refreshChecks => 'Uppdatera kontroller';

  @override
  String get fieldOps_searchLog => 'Sök i fältloggen';

  @override
  String get fieldOps_kindAll => 'Alla';

  @override
  String get fieldOps_kindCheckIn => 'Incheckning';

  @override
  String get fieldOps_kindReceived => 'Mottagen';

  @override
  String get fieldOps_kindNote => 'Anteckning';

  @override
  String get fieldOps_kindDeadZone => 'Täckningslucka';

  @override
  String get fieldOps_kindRadio => 'Radio';

  @override
  String get fieldOps_kindAutomation => 'Automatisering';

  @override
  String get fieldOps_kindMissed => 'Missad';

  @override
  String get fieldOps_kindSos => 'SOS';

  @override
  String get fieldOps_kindTrip => 'Tur';

  @override
  String get fieldOps_kindOverdue => 'Försenad';

  @override
  String get fieldOps_addNote => 'Lägg till anteckning';

  @override
  String get fieldOps_exportJson => 'Exportera JSON';

  @override
  String get fieldOps_deleteLog => 'Radera logg';

  @override
  String get fieldOps_logSubject => 'NOTORYX-Core-fältlogg';

  @override
  String get fieldOps_logCaveat =>
      'Lagras lokalt, upp till 1 000 poster. Exporter kan innehålla kontaktnycklar, meddelanden och platser; granska innan du delar.';

  @override
  String get fieldOps_noEntries => 'Inga matchande poster.';

  @override
  String get fieldOps_tripUnspecified => 'Tur ej angiven';

  @override
  String fieldOps_entryStatus(String status, String explanation) {
    return '$status: $explanation';
  }

  @override
  String fieldOps_entryPosition(String latitude, String longitude) {
    return 'Registrerad annonserad radioposition $latitude, $longitude (kan vara inaktuell)';
  }

  @override
  String get fieldOps_noteTitle => 'Fältobservation';

  @override
  String get fieldOps_noteLabel => 'Vad observerade du?';

  @override
  String get fieldOps_deadZone => 'Rapporterad täckningslucka';

  @override
  String get fieldOps_deadZoneHint =>
      'Din observation, inte en verifierad täckningsprognos.';

  @override
  String get fieldOps_savePosition => 'Spara radions annonserade position';

  @override
  String fieldOps_positionDetail(String latitude, String longitude) {
    return '$latitude, $longitude • kan vara inaktuell; inte telefonens GPS';
  }

  @override
  String get fieldOps_noPosition => 'Inga användbara annonserade koordinater';

  @override
  String get fieldOps_deleteLogTitle => 'Radera fältloggen?';

  @override
  String get fieldOps_deleteLogBody =>
      'Detta tar bort alla sparade poster på den här telefonen. Turinställningarna behålls.';

  @override
  String get fieldOps_localAutomations => 'Lokala automatiseringar';

  @override
  String get fieldOps_enableForTrip => 'Aktivera för den här turen';

  @override
  String get fieldOps_automationsCaveat =>
      'Avstängda efter varje omstart av appen. Regler körs bara medan appen är aktiv. Missade schemalagda åtgärder visas i fältloggen och spelas aldrig upp i en skur. Automatiska incheckningar är begränsade till en omgång per 10 minuter.';

  @override
  String get fieldOps_openBotMode => 'Öppna NOTORYX botläge';

  @override
  String get fieldOps_ruleEnabled => 'Regel aktiverad';

  @override
  String get fieldOps_dryRun => 'Testkörning';

  @override
  String get fieldOps_dryRunHint =>
      'Registrera åtgärden utan att skicka eller avisera.';

  @override
  String get fieldOps_then => 'Då';

  @override
  String get fieldOps_actionLog => 'Skriv till fältloggen';

  @override
  String get fieldOps_actionNotify => 'Visa lokal avisering';

  @override
  String get fieldOps_actionCheckIn => 'Skicka ”I\'m OK” till turkontakter';

  @override
  String get fieldOps_batteryThreshold => 'Batteri på eller under';

  @override
  String fieldOps_nextDue(String time) {
    return 'Nästa: $time';
  }

  @override
  String get fieldOps_nextDueNone => 'Nästa: inte schemalagd';

  @override
  String get fieldOps_previewInLog => 'Förhandsvisa i loggen';

  @override
  String get fieldOps_allowNotifications => 'Tillåt aviseringar';

  @override
  String get fieldOps_triggerReconnect => 'NÄR radion återansluter';

  @override
  String get fieldOps_triggerDisconnect => 'NÄR radion kopplas från';

  @override
  String get fieldOps_triggerLowBattery =>
      'NÄR radiobatteriet passerar tröskeln';

  @override
  String get fieldOps_triggerNewNode => 'NÄR en ny nod läggs till';

  @override
  String get fieldOps_triggerRepeater => 'NÄR en ny repeater läggs till';

  @override
  String get fieldOps_triggerScheduled =>
      'NÄR en schemalagd incheckning ska göras';

  @override
  String get fieldOps_explainConnection => 'Förklara min anslutning';

  @override
  String fieldOps_connectionState(String state, String transport) {
    return 'Läge: $state • $transport';
  }

  @override
  String get fieldOps_connectedCaveat =>
      'Telefonen har en radioanslutning. Det i sig fastställer ingen rutt till dina mottagare.';

  @override
  String get fieldOps_disconnectedHint =>
      'Ingen aktiv radioanslutning. Kontrollera Bluetooth-behörigheter, radions ström och räckvidd; USB/TCP finns under Anslut radio.';

  @override
  String fieldOps_awaitingConfirmation(int count) {
    return 'Turincheckningar som väntar på bekräftelse: $count';
  }

  @override
  String get fieldOps_staleCaveat =>
      'Nodernas senast sedda tider och annonserade positioner kan vara inaktuella. Ruttanalysen visar rutter som lärts från observerade försök; den hittar inte på vägar.';

  @override
  String get fieldOps_routeIntelligence => 'Ruttanalys';

  @override
  String get fieldOps_coverageIntelligence => 'Täckningsanalys';

  @override
  String get fieldOps_coverageIntelligenceHint =>
      'Jämför registrerade observationer mellan två fältsessioner. Punkterna markerar registrerarens annonserade radiopositioner där noder hördes. De innebär inte sammanhängande täckning. RSSI/SNR-ögonblicksbilder är inte mätningar per nod.';

  @override
  String get fieldOps_captureSession => 'Samla in en session';

  @override
  String get fieldOps_refreshHistory => 'Uppdatera historik';

  @override
  String get fieldOps_noCoverageSessions =>
      'Inga sparade täckningssessioner än.';

  @override
  String get fieldOps_sessionA => 'Session A • blågrön';

  @override
  String get fieldOps_sessionB => 'Session B • bärnsten';

  @override
  String fieldOps_uniqueCompare(String a, String b) {
    return 'A: $a unika noder • B: $b unika noder';
  }

  @override
  String fieldOps_overlap(String shared, String onlyA, String onlyB) {
    return 'Gemensamma: $shared • Bara A: $onlyA • Bara B: $onlyB';
  }

  @override
  String get fieldOps_compareCaveat =>
      'Att inte höra en nod under en session fastställer ingen täckningslucka. Förhållanden och observationstid skiljer sig.';

  @override
  String get fieldOps_heardTooltip =>
      'Observation av hörd nod; inte bevis på en lyckad länk';

  @override
  String get fieldOps_noteTooltip =>
      'Lokal anteckning vid radions annonserade koordinater; kan vara inaktuell.';

  @override
  String get bastionHome_aboutTooltip => 'Om NOTORYX Core';

  @override
  String get bastionHome_getStarted => 'Kom igång';

  @override
  String get bastionHome_getStartedHint =>
      'Anslut din radio och verifiera ditt första meddelande';

  @override
  String get bastionHome_planYourTrip => 'Planera din tur';

  @override
  String get bastionHome_tripActive => 'Tur aktiv';

  @override
  String get bastionHome_tripStopped => 'Tur stoppad';

  @override
  String bastionHome_tripSummary(String state, String contacts, String unread) {
    return '$state • $contacts kontakter • $unread olästa meddelanden';
  }

  @override
  String get bastionHome_checkInOk => 'Checka in: jag mår bra';

  @override
  String get bastionHome_checkInHint =>
      'Granska kontakter och meddelande innan du skickar. Följ kvittenser i fältloggen.';

  @override
  String bastionHome_lastCheckIn(String summary) {
    return 'Senaste incheckning: $summary';
  }

  @override
  String get bastionHome_connectRadio => 'Anslut radio';

  @override
  String get bastionHome_connectRadioHint =>
      'MeshCore-anslutningar via Bluetooth, USB och TCP';

  @override
  String get bastionHome_liveDiagnostics => 'Livediagnostik';

  @override
  String get bastionHome_liveDiagnosticsHint =>
      'Radiohälsa, signal, enhet och ramverktyg';

  @override
  String get bastionHome_meshDiscovery => 'Mesh-upptäckt';

  @override
  String get bastionHome_meshDiscoveryHint =>
      'Hitta noder och granska meshnätet omkring dig';

  @override
  String get bastionHome_fieldOpsHint =>
      'Turöversikt, beredskap, fältlogg, automatiseringar och täckningsjämförelse';

  @override
  String get bastionHome_fieldTools => 'NOTORYX fältverktyg';

  @override
  String get bastionHome_statusActive => 'AKTIV';

  @override
  String get bastionHome_consoleOnline => 'Fältkonsol online';

  @override
  String get bastionHome_consoleReady => 'Fältkonsol redo';

  @override
  String get bastionHome_consoleHint =>
      'Anslut en radio för att aktivera livepanelen.';

  @override
  String bastionHome_battery(String value) {
    return 'Bat $value';
  }

  @override
  String get bastionTools_title => 'Fältverktyg';

  @override
  String get bastionTools_backup => 'Krypterad säkerhetskopia';

  @override
  String get bastionTools_backupHint =>
      'Spara inställningar, kontakter och nycklar, med valfri chatthistorik';

  @override
  String get bastionTools_fieldOpsHint =>
      'Incheckningar, beredskap, fältlogg, automatiseringar och jämförelser';

  @override
  String get bastionTools_mapHint =>
      'Livekarta, insamlingssessioner, offlinekartverktyg och regioner';

  @override
  String get bastionTools_pathAnalysis => 'Väganalys';

  @override
  String get bastionTools_pathHint => 'Rutter, upptäckt och väganalys';

  @override
  String get bastionTools_repeaterHint =>
      'Status, inloggning, telemetri, grannar och administration';

  @override
  String get bastionTools_statsHint =>
      'Live-antal i meshnätet och kontaktaktivitet';

  @override
  String get bastionTools_diagnostics => 'Diagnostik';

  @override
  String get bastionTools_diagnosticsHint =>
      'Radiohälsa, enhetsinformation, råa ramar och export';

  @override
  String get bastionTools_about => 'Om + tack';

  @override
  String get bastionTools_aboutHint =>
      'NOTORYX-Core-version, oberoendeförklaring och licenser för öppen källkod';

  @override
  String get bastionAbout_title => 'Om + Tack';

  @override
  String get bastionAbout_intro =>
      'En oberoende community-app för MeshCore-nätverk. NOTORYX Core är inte en officiell MeshCore-app, och att communityresurser ingår innebär inget partnerskap eller stöd.';

  @override
  String get bastionAbout_version => 'Version';

  @override
  String get bastionAbout_openSource => 'Grund i öppen källkod';

  @override
  String get bastionAbout_openSourceBody =>
      'NOTORYX Core bygger på och modifierar öppen källkod från MeshCore Open under MIT-licensen. Arbetet med täckningsflödet krediterar även, där det är tillämpligt, den MIT-licensierade MeshMapper Flutter App.';

  @override
  String get bastionAbout_community => 'Communityn först';

  @override
  String get bastionAbout_communityBody =>
      'Resurser från tredjepartsskapare förblir respektive skapares egendom. Inget ägarskap eller partnerskap antyds.';

  @override
  String get bastionAbout_legalese =>
      'NOTORYX Core • Oberoende MeshCore-följeslagare';

  @override
  String get bastionAbout_licenses => 'Licenser för öppen källkod';

  @override
  String get bastionSetup_title => 'Kom igång med NOTORYX Core';

  @override
  String get bastionSetup_intro =>
      'Anslut, välj en kontakt och verifiera sedan ett meddelande. Du kan när som helst återvända till guiden från panelen.';

  @override
  String get bastionSetup_step1 => '1. Anslut din MeshCore-radio';

  @override
  String bastionSetup_connectedTo(String device, String transport) {
    return 'Ansluten till $device via $transport.';
  }

  @override
  String get bastionSetup_noRadio => 'Ingen radio ansluten än.';

  @override
  String get bastionSetup_step1Power =>
      'Slå på en MeshCore-följeslagarradio. Öppna Anslut radio och välj Bluetooth, USB eller TCP. Tillåt de behörigheter som begärs för din anslutning.';

  @override
  String get bastionSetup_step1Bluetooth =>
      'Om Bluetooth-sökningen är tom, kontrollera att Bluetooth är på och att NOTORYX Core har behörigheten Enheter i närheten i Androids appinställningar. Följ eventuella ytterligare behörighetsfrågor från skannern.';

  @override
  String get bastionSetup_connectionDiagnostics => 'Anslutningsdiagnostik';

  @override
  String get bastionSetup_step2 => '2. Välj en chattkontakt';

  @override
  String get bastionSetup_step2Body =>
      'Be en partner i närheten med kompatibla MeshCore-radioinställningar att annonsera sin nod. Välj en känd chattkontakt nedan; repeatrar hanteras separat.';

  @override
  String get bastionSetup_noContacts =>
      'Inga chattkontakter tillgängliga. Anslut din radio och öppna Mesh-upptäckt.';

  @override
  String get bastionSetup_testRecipient => 'Testmottagare';

  @override
  String get bastionSetup_meshDiscovery => 'Mesh-upptäckt';

  @override
  String get bastionSetup_step3 => '3. Skicka och verifiera ett meddelande';

  @override
  String get bastionSetup_step3Body =>
      'Öppna chatten, skriv ett kort testmeddelande, granska mottagaren och tryck på Skicka. Kom tillbaka hit för att se det senaste utgående meddelandet som registrerats sedan guiden öppnades.';

  @override
  String get bastionSetup_openTestChat => 'Öppna testchatt';

  @override
  String get bastionSetup_connectFirst =>
      'Anslut din radio för att öppna testchatten.';

  @override
  String get bastionSetup_chooseRecipient => 'Välj en mottagare först.';

  @override
  String get bastionSetup_noTestMessage =>
      'Inget utgående testmeddelande registrerat under den här guidesessionen.';

  @override
  String bastionSetup_latestMessage(String status, String time) {
    return 'Senaste meddelande: $status • $time';
  }

  @override
  String get bastionSetup_confirmReceipt =>
      'Be din partner bekräfta mottagandet eller svara. En registrerad kvittens bevisar inte att det lästs. Kontrollera anslutning och mottagare igen om ett meddelande misslyckas.';

  @override
  String get bastionSetup_step4 => '4. Förbered dig för fältet';

  @override
  String get bastionSetup_step4Body =>
      'Planera dina turkontakter och granska nedladdade kartområden. Botläge och fältautomatiseringar är av från början; fältautomatiseringar körs bara medan appen är aktiv.';

  @override
  String get bastionSetup_tripTools => 'Tur- och beredskapsverktyg';

  @override
  String get bastionDiag_title => 'Diagnostik';

  @override
  String get bastionDiag_export => 'Exportera diagnostik';

  @override
  String get bastionDiag_channels => 'Kanaler';

  @override
  String get bastionDiag_radio => 'Radio';

  @override
  String get bastionDiag_frequency => 'Frekvens';

  @override
  String get bastionDiag_bandwidth => 'Bandbredd';

  @override
  String get bastionDiag_spreadingFactor => 'Spridningsfaktor';

  @override
  String get bastionDiag_codingRate => 'Kodningsgrad';

  @override
  String get bastionDiag_txPower => 'Sändeffekt';

  @override
  String get bastionDiag_noiseFloor => 'Brusgolv';

  @override
  String get bastionDiag_device => 'Enhet';

  @override
  String get bastionDiag_name => 'Namn';

  @override
  String get bastionDiag_manufacturer => 'Tillverkare';

  @override
  String get bastionDiag_firmware => 'Firmware';

  @override
  String get bastionDiag_battery => 'Batteri';

  @override
  String get bastionDiag_transport => 'Anslutning';

  @override
  String get bastionDiag_deepTools => 'Avancerade verktyg';

  @override
  String get bastionDiag_liveStats => 'Live radiostatistik';

  @override
  String get bastionDiag_liveStatsHint => 'Brus, RSSI, SNR och sändtid';

  @override
  String get bastionDiag_frameDebug => 'Ram- / BLE-felsökning';

  @override
  String get bastionDiag_frameDebugHint =>
      'Granska avkodade och råa mottagna ramar';

  @override
  String get bastionDiag_appLog => 'Appens felsökningslogg';

  @override
  String get bastionDiag_appLogHint => 'Granska appens diagnostikhändelser';

  @override
  String get bastionDiag_online => 'Radio online';

  @override
  String get bastionDiag_offline => 'Radio offline';

  @override
  String get bastionDiag_offlineHint =>
      'Anslut en MeshCore-följeslagare för att fylla livediagnostiken.';

  @override
  String get coverage_title => 'Täckningsinsamling';

  @override
  String get coverage_leaveBlocked =>
      'Stoppa och spara sessionen innan du lämnar.';

  @override
  String get coverage_savedSessions => 'Sparade sessioner';

  @override
  String get coverage_caveat =>
      'RSSI/SNR är ögonblicksbilder från radion och kan tillhöra ett annat paket. Positioner är radions annonserade koordinater, inte telefonens GPS eller bevis på täckning. Cyan: registrerare; bärnsten: annonserad nod. Ingen interpolering görs.';

  @override
  String get coverage_captureActive => 'Insamling aktiv';

  @override
  String get coverage_fieldSession => 'Fälttäckningssession';

  @override
  String get coverage_connectedBody =>
      'NOTORYX Core registrerar nyss hörda noder under sessionen, inklusive ruttdata, nod-/platsmetadata och radions närmaste tillgängliga RSSI/SNR-ögonblicksbild.';

  @override
  String get coverage_disconnectedBody =>
      'Anslut en radio innan du startar. Täckningsinsamlingen registrerar liveobservationer i meshnätet från den anslutna följeslagarradion.';

  @override
  String get coverage_observations => 'Observationer';

  @override
  String get coverage_uniqueNodes => 'Unika noder';

  @override
  String get coverage_elapsed => 'Förfluten tid';

  @override
  String get coverage_radioConnected => 'Radio ansluten';

  @override
  String get coverage_noRadio => 'Ingen radio';

  @override
  String get coverage_gpsReady => 'Radio-GPS redo';

  @override
  String get coverage_noGps => 'Ingen radio-GPS';

  @override
  String get coverage_stopSave => 'Stoppa + spara session';

  @override
  String get coverage_start => 'Starta täckningssession';

  @override
  String get coverage_exportJson => 'Exportera JSON';

  @override
  String get coverage_exportCsv => 'Exportera CSV';

  @override
  String get coverage_liveObservations => 'Liveobservationer';

  @override
  String get coverage_waiting => 'Väntar på meshaktivitet';

  @override
  String get coverage_waitingBody =>
      'Starta en session så visas nyss hörda aktiva noder här. RSSI/SNR-värden är radioögonblicksbilder och kan inte alltid knytas till ett specifikt paket.';

  @override
  String get coverage_signalNa => 'signal saknas';

  @override
  String get coverage_snrNa => 'SNR saknas';

  @override
  String get coverage_gpsUnavailable => 'radio-GPS ej tillgänglig';

  @override
  String coverage_pathLine(String path, String location) {
    return 'Väg: $path  •  $location';
  }

  @override
  String get coverage_pathFlood => 'flood';

  @override
  String get coverage_pathDirect => 'direkt';

  @override
  String get coverage_shareSubject => 'NOTORYX-Core-täckningssession';

  @override
  String get coverage_shareText => 'NOTORYX-Core-export av täckningsinsamling';

  @override
  String get coverage_historyTitle => 'Sparade täckningssessioner';

  @override
  String coverage_loadFailed(String error) {
    return 'Sessionerna kunde inte laddas: $error';
  }

  @override
  String get coverage_deleteTitle => 'Radera sparad session?';

  @override
  String coverage_deleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observationer tas bort från den här enheten.',
      one: '1 observation tas bort från den här enheten.',
    );
    return '$_temp0';
  }

  @override
  String coverage_deleteFailed(String error) {
    return 'Sessionen kunde inte raderas: $error';
  }

  @override
  String get coverage_retention =>
      'De 20 senaste slutförda sessionerna behålls. Dela sessioner du vill spara. Avbrutna insamlingar kan öppnas igen nedan.';

  @override
  String get coverage_noSessions =>
      'Inga sparade sessioner än. Stoppa en insamling för att spara den.';

  @override
  String get coverage_interrupted => 'Avbruten insamling';

  @override
  String get coverage_saved => 'Sparad';

  @override
  String get coverage_deleteTooltip => 'Radera session';

  @override
  String coverage_exportFailed(String error) {
    return 'Exporten misslyckades: $error';
  }

  @override
  String get coverage_sessionTitle => 'Täckningssession';

  @override
  String get coverage_shareJson => 'Dela JSON';

  @override
  String get coverage_shareCsv => 'Dela CSV';

  @override
  String coverage_snapshotDetail(String rssi, String snr, String age) {
    return '$rssi dBm • SNR $snr dB • ögonblicksbildens ålder $age ms';
  }

  @override
  String get coverage_unknown => 'okänd';

  @override
  String coverage_pathValue(String path) {
    return 'väg $path';
  }

  @override
  String get coverage_recorder => 'Registrerare';

  @override
  String get coverage_noCoordinates =>
      'Inga användbara koordinater i den här sessionen. Observationerna finns kvar nedan.';

  @override
  String get coverage_osmAttribution =>
      '© OpenStreetMap-bidragsgivare • onlinebaskarta';

  @override
  String get fieldStats_title => 'Fältanalys';

  @override
  String get fieldStats_chatNodes => 'Chattnoder';

  @override
  String get fieldStats_rooms => 'Rum';

  @override
  String get fieldStats_sensors => 'Sensorer';

  @override
  String get fieldStats_direct => 'Direkta';

  @override
  String get mapHub_title => 'NOTORYX fältkarta';

  @override
  String get mapHub_intro =>
      'Livekartor, offlineområden, regionala profiler och NOTORYX Cores fälttäckningssessioner.';

  @override
  String get mapHub_captureHint => 'Starta och stoppa en fälttäckningssession';

  @override
  String get mapHub_badgeNew => 'NY';

  @override
  String get mapHub_liveMap => 'Live meshkarta';

  @override
  String get mapHub_liveMapHint =>
      'Noder, repeatrar, positioner, rutter och kartverktyg';

  @override
  String get mapHub_badgeLive => 'LIVE';

  @override
  String get mapHub_offlinePacks => 'Offlinekartpaket';

  @override
  String get mapHub_offlinePacksHint =>
      'Cacha kartrutor för turer och områden utan täckning';

  @override
  String get mapHub_badgeOffline => 'OFFLINE';

  @override
  String get mapHub_regions => 'Regionprofiler';

  @override
  String get mapHub_regionsHint =>
      'Hantera och hämta regionala meshdefinitioner';

  @override
  String get mapHub_badgeRegions => 'REGIONER';

  @override
  String get routes_title => 'Ruttanalys';

  @override
  String get routes_headline => 'Se hur trafiken rör sig genom meshnätet.';

  @override
  String get routes_body =>
      'NOTORYX Core rangordnar sparade rutter med hjälp av väghistorik som redan lärts från verkliga meddelandeförsök och upptäckter.';

  @override
  String get routes_routes => 'Rutter';

  @override
  String get routes_success => 'Lyckade';

  @override
  String get routes_failed => 'Misslyckade';

  @override
  String get routes_routeMap => 'Ruttkarta';

  @override
  String get routes_routeMapHint => 'Granska noder och vägar';

  @override
  String get routes_discover => 'Upptäck';

  @override
  String get routes_discoverHint => 'Hitta nya rutter';

  @override
  String get routes_learned => 'Inlärda rutter';

  @override
  String get routes_none => 'Ingen rutthistorik än';

  @override
  String get routes_noneBody =>
      'Använd meshnätet som vanligt eller kör en upptäckt. NOTORYX Core visar inlärda rutter här när väghistorik blir tillgänglig.';

  @override
  String get routes_direct => 'DIREKT';

  @override
  String routes_routeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutter',
      one: '1 rutt',
    );
    return '$_temp0';
  }

  @override
  String routes_best(String path) {
    return 'BÄST  $path';
  }

  @override
  String routes_bestDetail(
    String hops,
    String weight,
    String success,
    String fail,
  ) {
    return '$hops  •  vikt $weight  •  $success lyckade / $fail misslyckade';
  }

  @override
  String routes_fastest(String ms) {
    return 'Snabbaste kända: $ms ms';
  }

  @override
  String routes_flood(String success, String fail) {
    return 'Flood: $success lyckade / $fail misslyckade';
  }

  @override
  String get repeaterTools_unnamed => 'Namnlös repeater';

  @override
  String get repeaterTools_empty =>
      'Inga repeatrar upptäckta än. Anslut en radio och upptäck meshnätet först.';

  @override
  String get rptTest_title => 'Test av närliggande repeatrar';

  @override
  String get rptTest_subtitle => 'Ett tryck: vilka repeatrar hör dig direkt';

  @override
  String get rptTest_start => 'Testa nu';

  @override
  String get rptTest_listening => 'Lyssnar efter svar…';

  @override
  String rptTest_wait(int seconds) {
    return 'Nästa test om $seconds s';
  }

  @override
  String rptTest_found(int count) {
    return 'Repeatrar som svarade: $count';
  }

  @override
  String get rptTest_none =>
      'Ingen repeater inom direkt räckvidd svarade. Försök från högre mark eller igen om en minut. Repeatrar med äldre firmware svarar inte på detta test.';

  @override
  String get rptTest_strong => 'Stark';

  @override
  String get rptTest_usable => 'Användbar';

  @override
  String get rptTest_weak => 'Svag';

  @override
  String rptTest_unknown(String prefix) {
    return 'Repeater $prefix';
  }

  @override
  String rptTest_line(String there, String here, String rssi) {
    return 'Hörde dig på $there dB · du hörde den på $here dB, $rssi dBm';
  }

  @override
  String rptTest_rowLabel(
    String name,
    String quality,
    String there,
    String here,
    String rssi,
  ) {
    return '$name, $quality. Den hörde dig på $there decibel. Du hörde den på $here decibel, $rssi dBm.';
  }

  @override
  String get rptTest_notConnected => 'Anslut din radio för att köra testet.';

  @override
  String get rptTest_explainer =>
      'Skickar en upptäcktsförfrågan utan hopp, så bara repeatrar som hör din radio direkt svarar. Första talet visar hur väl repeatern hörde dig, det andra hur väl du hörde den. Det går 30 sekunder mellan testerna eftersom repeatrar begränsar hur ofta de svarar.';

  @override
  String get notification_fieldAlertTitle => 'NOTORYX fältvarning';

  @override
  String get notification_checkInReminderTitle =>
      'NOTORYX Core påminnelse om incheckning';

  @override
  String notification_checkInReminderBody(int minutes, String trip) {
    return 'Ingen incheckning på $minutes minuter på $trip. Öppna NOTORYX Core för att checka in.';
  }

  @override
  String notification_overdueBody(String name, int minutes) {
    return '$name har inte hörts på $minutes minuter. Detta är inte en bekräftad nödsituation.';
  }

  @override
  String get notification_aTripContact => 'En turkontakt';

  @override
  String notification_checkInNotDelivered(String name) {
    return 'Incheckningen levererades inte till $name. Du kan skicka den igen från Tur.';
  }

  @override
  String notification_sosAcknowledged(String name) {
    return 'SOS bekräftat av $name';
  }

  @override
  String get settings_batterySaver => 'Batterisparläge';

  @override
  String get settings_batterySaverOn =>
      'På: radiobatteri var 10:e min, GPS var 5:e min, statistik högst en gång per minut, turkontroller var 1–2 min. Meddelanden, varningar och SOS påverkas inte.';

  @override
  String get settings_batterySaverOff =>
      'Kontrollera radion och turen mer sällan för att spara telefonens och radions batteri. Meddelanden, varningar och SOS påverkas inte.';

  @override
  String get settings_readAloud => 'Läs upp nya meddelanden';

  @override
  String get settings_readAloudHelper =>
      'Medan NOTORYX Core är öppet. Tystade kanaler förblir tysta. Alla meddelanden kan också läsas upp från sin meny.';

  @override
  String get settings_readAloudOff => 'Av';

  @override
  String get settings_readAloudDirect => 'Direktmeddelanden';

  @override
  String get settings_readAloudAll => 'Direkt- och kanalmeddelanden';

  @override
  String get chat_readAloud => 'Läs upp';

  @override
  String get messageSearch_title => 'Sök i meddelanden';

  @override
  String get messageSearch_intro =>
      'Sök i alla direkt- och kanalmeddelanden som sparats på den här telefonen.';

  @override
  String messageSearch_noResults(String query) {
    return 'Inga meddelanden innehåller ”$query”.';
  }

  @override
  String messageSearch_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count träffar',
      one: '1 träff',
    );
    return '$_temp0';
  }

  @override
  String messageSearch_capped(int count) {
    return 'Visar de $count senaste träffarna';
  }

  @override
  String get shortcuts_checkIn => 'Checka in';

  @override
  String get shortcuts_trip => 'Tur';

  @override
  String get shortcuts_chats => 'Chattar';

  @override
  String get shortcuts_map => 'Karta';

  @override
  String get sensor_liveUpdates => 'Liveuppdateringar';

  @override
  String get sensor_intro =>
      'Låt sensorn skicka mätvärden själv när de ändras, i stället för att fråga varje gång. Kräver inloggning med läsbehörighet.';

  @override
  String get sensor_watch => 'Bevaka ändringar';

  @override
  String get sensor_loadFirst =>
      'Ladda telemetrin först för att välja mätvärden.';

  @override
  String sensor_watching(String readings, String time) {
    return 'Bevakar $readings till $time.';
  }

  @override
  String sensor_watchingRegion(String readings, String time, String region) {
    return 'Bevakar $readings till $time • region $region.';
  }

  @override
  String get sensor_noChanges => 'Inga ändringar rapporterade än.';

  @override
  String sensor_lastUpdate(String time, int count) {
    return 'Senaste uppdatering $time • $count mottagna';
  }

  @override
  String get sensor_stop => 'Stoppa liveuppdateringar';

  @override
  String sensor_stopUnconfirmed(String error) {
    return 'Stoppad här; sensorn bekräftade inte och slutar när tiden går ut. $error';
  }

  @override
  String get sensor_dialogBody =>
      'Sensorn kontrollerar ungefär en gång i minuten och skickar en uppdatering när ett valt mätvärde ändras mer än sin tröskel.';

  @override
  String sensor_readingTitle(String label, String channel) {
    return '$label (kanal $channel)';
  }

  @override
  String sensor_readingValue(String label, String channel, String value) {
    return '$label (kanal $channel): $value';
  }

  @override
  String sensor_watchItem(String label, String channel, String delta) {
    return '$label (kanal $channel) ±$delta';
  }

  @override
  String sensor_updateOn(String delta) {
    return 'Uppdatera vid en ändring på $delta';
  }

  @override
  String get sensor_changeThreshold => 'Ändra tröskel';

  @override
  String sensor_capacity(int max, String used) {
    return 'Sensorn kan bevaka upp till $max byte mätvärden ($used använda).';
  }

  @override
  String get sensor_for => 'Under';

  @override
  String sensor_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count timmar',
      one: '1 timme',
    );
    return '$_temp0';
  }

  @override
  String get sensor_start => 'Starta';

  @override
  String sensor_thresholdTitle(String label) {
    return 'Tröskel för $label';
  }

  @override
  String get sensor_typeTemperature => 'Temperatur';

  @override
  String get sensor_typeHumidity => 'Luftfuktighet';

  @override
  String get sensor_typePressure => 'Lufttryck';

  @override
  String get sensor_typeVoltage => 'Spänning';

  @override
  String get sensor_typeCurrent => 'Ström';

  @override
  String get sensor_typeLight => 'Ljus';

  @override
  String get sensor_typeConcentration => 'Koncentration';

  @override
  String get sensor_typePercentage => 'Procent';

  @override
  String get sensor_typeAnalogInput => 'Analog ingång';

  @override
  String get sensor_typeAltitude => 'Höjd';

  @override
  String get setupWizard_title => 'Anslut din radio';

  @override
  String get setupWizard_choose => '1. Välj en anslutning';

  @override
  String get setupWizard_prepare => '2. Förbered radion';

  @override
  String get setupWizard_intro =>
      'Välj hur den här telefonen eller datorn ska ansluta till din radio. Radion bär meddelandena över meshnätet.';

  @override
  String get setupWizard_bluetooth =>
      'Trådlös anslutning till en kompatibel radio i närheten.';

  @override
  String get setupWizard_noBluetooth =>
      'Bluetooth är inte tillgängligt i den här webbläsaren. Använd den inbyggda appen eller en USB-anslutning som stöds.';

  @override
  String get setupWizard_usb => 'Trådbunden anslutning med en USB-datakabel.';

  @override
  String get setupWizard_noUsb =>
      'USB-seriell är inte tillgänglig här. Använd en dator- eller Android-app som stöds, eller Chrome med Web Serial.';

  @override
  String get setupWizard_bluetoothSteps =>
      'Slå på radion och håll den nära. Aktivera Bluetooth och ge appen behörighet. Stäng andra appar som är anslutna till radion, öppna enhetslistan och sök.';

  @override
  String get setupWizard_usbSteps =>
      'Anslut en påslagen radio med en USB-datakabel; en laddkabel fungerar inte. Stäng andra seriella appar. Öppna USB-enhetslistan, välj radion och tillåt åtkomst om du blir tillfrågad.';

  @override
  String get setupWizard_firmwareTitle =>
      'Kontrollera kompatibiliteten innan du byter firmware';

  @override
  String get setupWizard_firmware =>
      'Radion behöver MeshCore companion-firmware som stöder den valda anslutningen. Stödet varierar mellan kort och firmwarebyggen; ett USB-uttag betyder inte i sig att USB-seriell stöds. Läs instruktionerna för ditt kort och installerade bygge. Repeater- eller room server-firmware är inte companion. En misslyckad anslutning betyder inte i sig att du måste flasha om.';

  @override
  String get setupWizard_settings =>
      'Guiden flashar ingen firmware och ändrar inga radioinställningar. Efter anslutning använder du Inställningar för region, frekvens och avancerade alternativ. Stäm av inställningar med ditt lokala mesh innan du ändrar dem.';

  @override
  String get setupWizard_openBluetooth => 'Öppna Bluetooth-enheter';

  @override
  String get setupWizard_openUsb => 'Öppna USB-enheter';

  @override
  String get setupWizard_change => 'Byt anslutningstyp';

  @override
  String get setupWizard_later => 'Konfigurera senare';

  @override
  String get setupWizard_bluetoothError =>
      'Kunde inte ansluta till radion. Håll den påslagen och nära, kontrollera Bluetooth-behörigheter och stäng andra anslutna appar. Sök sedan igen.';

  @override
  String get setupWizard_scanError =>
      'Kunde inte söka efter radioenheter. Slå på Bluetooth och tillåt åtkomst till Bluetooth eller Enheter i närheten i systeminställningarna, och sök igen.';

  @override
  String get setupWizard_usbError =>
      'Kunde inte ansluta via USB. Kontrollera datakabeln och vald enhet, tillåt USB-åtkomst och stäng andra seriella appar. Anslut kabeln igen och försök på nytt.';

  @override
  String get connections_title => 'Anslutningar';

  @override
  String get connections_radioTitle => 'Radioanslutning';

  @override
  String get connections_bluetoothOffNotice =>
      'Bluetooth är avstängt. Slå på det för att ansluta igen; appen försöker igen när det är tillbaka.';

  @override
  String get connections_transport => 'Anslutningssätt';

  @override
  String connections_lastError(String error) {
    return 'Senaste fel: $error';
  }

  @override
  String get connections_disconnectRadio => 'Koppla från radion';

  @override
  String connections_reconnectTo(String name) {
    return 'Anslut igen till $name';
  }

  @override
  String get connections_forgetRadio => 'Glöm radion';

  @override
  String get connections_connectAnother => 'Anslut en annan radio';

  @override
  String get connections_usbSerial => 'USB-seriell';

  @override
  String get connections_tcpIp => 'TCP/IP';

  @override
  String get connections_device => 'Enhet';

  @override
  String get connections_publicKey => 'Publik nyckel';

  @override
  String get connections_firmware => 'Firmware';

  @override
  String connections_firmwareProtocol(String code) {
    return 'protokoll v$code';
  }

  @override
  String get connections_battery => 'Batteri';

  @override
  String get connections_lastRx => 'Senast mottaget';

  @override
  String get connections_reconnectFailed =>
      'Kunde inte ansluta igen till radion';

  @override
  String get connections_statusBluetoothOff => 'Bluetooth är avstängt';

  @override
  String get connections_statusConnected => 'Ansluten';

  @override
  String get connections_statusConnecting => 'Ansluter…';

  @override
  String get connections_statusDisconnecting => 'Kopplar från…';

  @override
  String get connections_statusScanning => 'Söker efter radioenheter…';

  @override
  String get connections_statusReconnectingSoon => 'Ansluter igen snart…';

  @override
  String get connections_statusNotConnected => 'Inte ansluten';

  @override
  String get mqtt_cardTitle => 'MQTT-anslutning';

  @override
  String get mqtt_statusNotConfigured => 'Inte konfigurerad';

  @override
  String get mqtt_statusDisconnected => 'Frånkopplad';

  @override
  String get mqtt_statusConnecting => 'Ansluter';

  @override
  String get mqtt_statusConnected => 'Ansluten';

  @override
  String get mqtt_statusReconnecting => 'Ansluter igen';

  @override
  String get mqtt_statusError => 'Anslutningsfel';

  @override
  String mqtt_broker(String host, int port, String transport) {
    return 'Broker: $host:$port ($transport)';
  }

  @override
  String get mqtt_tokenSignIn => 'Loggar in med en token signerad av radion';

  @override
  String mqtt_tokenSignInAs(String username) {
    return 'Loggar in med en token signerad av radion som $username…';
  }

  @override
  String get mqtt_connectRadioToSignIn => 'Anslut radion för att logga in';

  @override
  String mqtt_tokenRenewsAt(String time) {
    return 'Token förnyas kl. $time';
  }

  @override
  String mqtt_signedInAs(String username) {
    return 'Inloggad som $username';
  }

  @override
  String mqtt_listeningOn(String topic) {
    return 'Lyssnar på $topic';
  }

  @override
  String mqtt_packetCounts(int accepted, int duplicate, int invalid) {
    return 'Paket: $accepted nya, $duplicate dubbletter, $invalid ogiltiga';
  }

  @override
  String mqtt_retryCount(int attempt, int max) {
    return 'Försök $attempt av $max';
  }

  @override
  String get mqtt_sharingWaitsForRadio =>
      'Delning väntar på en radioanslutning';

  @override
  String mqtt_sharingOn(String topic) {
    return 'Delar på $topic';
  }

  @override
  String mqtt_willShareOn(String topic) {
    return 'Kommer att dela på $topic';
  }

  @override
  String mqtt_onlineStatusOn(String topic) {
    return 'Onlinestatus på $topic';
  }

  @override
  String mqtt_sharedCounts(int shared, int held) {
    return 'Delade $shared, kvarhållna $held';
  }

  @override
  String get mqtt_addBrokerHint =>
      'Lägg till en broker för att koppla MeshCore-trafik över internet. Radioanslutningen fungerar oberoende av den.';

  @override
  String get mqtt_disconnect => 'Koppla från MQTT';

  @override
  String get mqtt_connect => 'Anslut MQTT';

  @override
  String get mqtt_packetFeed => 'Paketflöde';

  @override
  String get mqtt_setUpBroker => 'Konfigurera broker';

  @override
  String get mqtt_brokerSettings => 'Brokerinställningar';

  @override
  String get mqtt_settingsTitle => 'MQTT-brokerinställningar';

  @override
  String get mqtt_presetLabel => 'Börja från en förinställning';

  @override
  String get mqtt_presetCustom => 'Egen broker';

  @override
  String get mqtt_presetLocal => 'Lokal broker (ange adress)';

  @override
  String get mqtt_presetLetsMeshUs => 'LetsMesh-analysator (USA, community)';

  @override
  String get mqtt_presetLetsMeshEu => 'LetsMesh-analysator (EU, community)';

  @override
  String get mqtt_presetLetsMeshNote =>
      'LetsMesh är en communitydriven paketanalysator för MeshCore, inte en del av NOTORYX och inte rekommenderad av NOTORYX. Delning kräver att radion är ansluten och är av tills du slår på den.';

  @override
  String get mqtt_hostname => 'Brokerns värdnamn';

  @override
  String get mqtt_port => 'Port';

  @override
  String get mqtt_useTls => 'Använd TLS';

  @override
  String get mqtt_allowCleartext => 'Tillåt okrypterat till en lokal broker';

  @override
  String get mqtt_allowCleartextHint =>
      'Bara localhost, .local och privata 10.x- / 192.168.x-värdar.';

  @override
  String get mqtt_useWebSocket => 'Använd WebSocket';

  @override
  String get mqtt_webSocketPath => 'WebSocket-sökväg';

  @override
  String get mqtt_topicPrefix => 'Topic-prefix';

  @override
  String get mqtt_region => 'Region (valfritt)';

  @override
  String get mqtt_regionHelp =>
      'Observatörens regionkod, t.ex. PHL. Lämna tomt för alla.';

  @override
  String get mqtt_deliverChannel => 'Lägg till kanalmeddelanden hörda via MQTT';

  @override
  String get mqtt_deliverChannelHint =>
      'Meddelanden i dina kanaler som observatörer har hört visas i dina chattar. De skickas inte via din radio.';

  @override
  String get mqtt_sharingTitle => 'Dela som observatör';

  @override
  String get mqtt_share => 'Dela paket som min radio hör';

  @override
  String get mqtt_shareHint =>
      'Publicerar adverts och kanaltrafik som radion tar emot, med dess publika nyckel, signalstyrka och region. Kanalmeddelanden förblir krypterade. Kräver en region.';

  @override
  String get mqtt_shareDirect => 'Ta med trafik från direktmeddelanden';

  @override
  String get mqtt_shareDirectHint =>
      'Förfrågningar, svar och direktmeddelanden. Innehållet förblir krypterat, men det visar vilka noder som pratar med varandra.';

  @override
  String get mqtt_shareOwn => 'Ta med mina egna meddelanden och adverts';

  @override
  String get mqtt_signInTitle => 'Inloggning';

  @override
  String get mqtt_authPassword => 'Användarnamn och lösenord';

  @override
  String get mqtt_authToken => 'Token signerad av radion';

  @override
  String get mqtt_tokenExplain =>
      'Radion signerar en inloggningstoken som gäller en timme med sin egen nyckel, och appen förnyar den innan den går ut. Nyckeln lämnar aldrig radion. Användarnamnet är v1_ följt av radions publika nyckel.';

  @override
  String get mqtt_radioReady => 'Radio ansluten: redo att logga in.';

  @override
  String get mqtt_radioNeeded =>
      'Anslut radion för att logga in. MQTT väntar på den.';

  @override
  String get mqtt_username => 'Användarnamn (valfritt)';

  @override
  String get mqtt_password => 'Lösenord';

  @override
  String get mqtt_keepPassword =>
      'Lämna tomt för att behålla det sparade lösenordet.';

  @override
  String get mqtt_credentialsWeb =>
      'I webbläsaren sparas inloggningsuppgifter bara tills sidan stängs.';

  @override
  String get mqtt_credentialsKeychain =>
      'Inloggningsuppgifter lagras i systemets nyckelring, aldrig i appinställningar eller loggar.';

  @override
  String get mqtt_saveSettings => 'Spara inställningar';

  @override
  String get mqtt_feedTitle => 'MQTT-paketflöde';

  @override
  String get mqtt_feedConnect =>
      'Anslut till en broker för att se paket från observatörer.';

  @override
  String mqtt_feedWaiting(String topic) {
    return 'Väntar på paket på $topic';
  }

  @override
  String get mqtt_feedUnknownObserver => 'Okänd observatör';

  @override
  String mqtt_feedHeardBy(String observer) {
    return 'Hört av $observer';
  }

  @override
  String mqtt_feedHopsBytes(int hops, int bytes) {
    return '$hops hopp · $bytes byte';
  }

  @override
  String get mqtt_packetRequest => 'Förfrågan';

  @override
  String get mqtt_packetResponse => 'Svar';

  @override
  String get mqtt_packetDirectMessage => 'Direktmeddelande';

  @override
  String get mqtt_packetAck => 'Kvittens';

  @override
  String get mqtt_packetAdvert => 'Advert';

  @override
  String get mqtt_packetChannelMessage => 'Kanalmeddelande';

  @override
  String get mqtt_packetChannelData => 'Kanaldata';

  @override
  String get mqtt_packetAnonymousRequest => 'Anonym förfrågan';

  @override
  String get mqtt_packetPath => 'Väg';

  @override
  String get mqtt_packetTrace => 'Spårning';

  @override
  String get mqtt_packetMultipart => 'Flerdelad';

  @override
  String get mqtt_packetControl => 'Styrning';

  @override
  String mqtt_packetType(int type) {
    return 'Typ $type';
  }

  @override
  String get mqtt_routeTransportFlood => 'Transport-flood';

  @override
  String get mqtt_routeFlood => 'Flood';

  @override
  String get mqtt_routeDirect => 'Direkt';

  @override
  String get mqtt_routeTransportDirect => 'Transport-direkt';

  @override
  String get mqtt_noticeInvalidHost =>
      'Ange ett värdnamn eller en IPv4-adress utan schema eller port.';

  @override
  String get mqtt_noticeInvalidPort => 'Porten måste vara mellan 1 och 65535.';

  @override
  String get mqtt_noticeInvalidWebSocketPath =>
      'WebSocket-sökvägen måste börja med / och får inte innehålla query eller fragment.';

  @override
  String get mqtt_noticeInvalidTopicPrefix =>
      'Topic-prefixet måste vara en icke-tom MQTT-sökväg utan jokertecken.';

  @override
  String get mqtt_noticeInvalidRegion =>
      'Regionen måste vara 2–8 bokstäver eller siffror, t.ex. PHL.';

  @override
  String get mqtt_noticeTlsRequired =>
      'TLS krävs om inte osäker åtkomst till en lokal broker uttryckligen är tillåten.';

  @override
  String get mqtt_noticeCleartextLocalOnly =>
      'Okrypterad MQTT är begränsad till uttryckligen godkända lokala värdar.';

  @override
  String get mqtt_noticeRegionNeededToShare =>
      'Ange en region för att dela paket som observatör.';

  @override
  String mqtt_noticePasswordNeeded(String username) {
    return 'Ange lösenordet för $username.';
  }

  @override
  String get mqtt_noticeNoNetwork =>
      'Ingen nätverksanslutning. MQTT ansluter igen när den är tillbaka.';

  @override
  String get mqtt_noticeSubscriptionRefused =>
      'Brokern nekade paketprenumerationen.';

  @override
  String get mqtt_noticeBadCredentials =>
      'Brokern avvisade användarnamnet eller lösenordet.';

  @override
  String get mqtt_noticeNotAuthorized =>
      'Kontot har inte behörighet på brokern.';

  @override
  String get mqtt_noticeConnectionRefused => 'Brokern nekade anslutningen.';

  @override
  String get mqtt_noticeUnreachable => 'Brokern gick inte att nå.';

  @override
  String get mqtt_noticeTlsFailed =>
      'Den säkra (TLS-)anslutningen kunde inte upprättas.';

  @override
  String get mqtt_noticeWebSocketOnly =>
      'Den här plattformen stöder bara MQTT över WebSocket.';

  @override
  String get mqtt_noticeRadioNotConnected =>
      'Anslut radion för att logga in med dess nyckel.';

  @override
  String get mqtt_noticeSigningUnsupported =>
      'Radions firmware stöder inte signering med dess nyckel.';

  @override
  String get mqtt_noticeSigningTimeout =>
      'Radion svarade inte på signeringsförfrågan. Dess firmware kanske inte stöder signering.';

  @override
  String get mqtt_noticeSigningTooLong =>
      'Datan är för lång för att radion ska kunna signera den.';

  @override
  String get mqtt_noticeSigningRejected => 'Radion vägrade signera datan.';

  @override
  String get scanner_signalStrong => 'Stark';

  @override
  String get scanner_signalGood => 'Bra';

  @override
  String get scanner_signalFair => 'Medel';

  @override
  String get scanner_signalWeak => 'Svag';

  @override
  String get scanner_nearbyRadios => 'Radioenheter i närheten';

  @override
  String get scanner_lastRadio => 'Senaste radio';

  @override
  String get scanner_reconnect => 'Anslut igen';

  @override
  String get scanner_tcpHint => 'En radio med Wi‑Fi-firmware i ditt nätverk.';

  @override
  String get scanner_otherWays => 'Andra sätt att ansluta';

  @override
  String scanner_radiosFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count radioenheter i närheten',
      one: '1 radio i närheten',
    );
    return '$_temp0';
  }

  @override
  String get scanner_searchingTitle => 'Letar efter radioenheter…';

  @override
  String get scanner_findTitle => 'Hitta din radio';

  @override
  String get scanner_heroHint =>
      'Slå på radion och håll den inom några meter. Den behöver MeshCore companion-firmware.';

  @override
  String get scanner_tipsTitle => 'Ser du inte din radio?';

  @override
  String get scanner_tipPower => 'Kontrollera att den är påslagen och vaken.';

  @override
  String get scanner_tipFirmware =>
      'Den behöver MeshCore companion-firmware. Repeatrar och rumsservrar visas inte här.';

  @override
  String get scanner_tipOtherDevice =>
      'En radio ansluter till en enhet i taget. Koppla bort den från andra telefoner eller datorer.';

  @override
  String get connections_internetBridge => 'Internetbrygga';

  @override
  String get connections_noRadio => 'Ingen radio';

  @override
  String get connections_radioSettings => 'Radioinställningar';

  @override
  String get connections_viewDashboard => 'Visa anslutningsöversikt';

  @override
  String get radios_title => 'Radioenheter';

  @override
  String radios_number(int number) {
    return 'Radio $number';
  }

  @override
  String get radios_active => 'Används';

  @override
  String get radios_switch => 'Använd den här radion';

  @override
  String get radios_add => 'Lägg till en radio';

  @override
  String get radios_switcher => 'Byt radio';

  @override
  String get radios_hint =>
      'Du kan vara ansluten till mer än en radio, till exempel en handenhet och en basstation. Appen visar och skickar via radion som används. De andra förblir anslutna och deras meddelanden sparas tills du byter.';

  @override
  String get radios_switchNote =>
      'När du byter radio kommer du tillbaka till startskärmen. Bottar, automatisering, aviseringar, spårning och SOS-vidarebefordran körs på radion som används.';

  @override
  String radios_removeTitle(String name) {
    return 'Ta bort $name?';
  }

  @override
  String get radios_removeBody =>
      'Radion kopplas från och glöms. Dess meddelanden och kontakter förblir sparade.';

  @override
  String radios_unread(int count) {
    return '$count olästa';
  }

  @override
  String radios_backgroundUnread(int count) {
    return '$count olästa på andra radioenheter';
  }

  @override
  String get radios_continueOn => 'Fortsätt på en annan radio';

  @override
  String radios_continueOnName(String name) {
    return 'Fortsätt på $name';
  }

  @override
  String get radios_routeDirect => 'Direkt';

  @override
  String radios_routeHops(int count) {
    return 'Hopp: $count';
  }

  @override
  String get radios_routeFlood => 'Ingen känd rutt';

  @override
  String get channelDirectory_title => 'Kanalkatalog';

  @override
  String get channelDirectory_subtitle =>
      'Hitta offentliga hashtaggkanaler nära dig';

  @override
  String get channelDirectory_search => 'Sök kanaler eller platser';

  @override
  String get channelDirectory_nearYou => 'Nära dig';

  @override
  String get channelDirectory_all => 'Alla kanaler';

  @override
  String get channelDirectory_catAll => 'Alla';

  @override
  String get channelDirectory_catEmergency => 'Nödläge';

  @override
  String get channelDirectory_catLocal => 'Lokalt';

  @override
  String get channelDirectory_catGeneral => 'Allmänt';

  @override
  String get channelDirectory_catInterest => 'Intressen';

  @override
  String get channelDirectory_catTest => 'Test';

  @override
  String get channelDirectory_join => 'Gå med';

  @override
  String get channelDirectory_joined => 'Med';

  @override
  String get channelDirectory_noMatches => 'Inga kanaler matchar sökningen.';

  @override
  String get channelDirectory_connectFirst =>
      'Anslut radion för att gå med i kanaler.';

  @override
  String get channelDirectory_slotsFull =>
      'Alla kanalplatser på radion används. Ta bort en kanal först.';

  @override
  String get channelDirectory_joinFailed =>
      'Kunde inte lägga till kanalen. Försök igen.';

  @override
  String get channelDirectory_addHint =>
      'Saknas en kanal? Vem som helst kan föreslå en genom att redigera den delade listan på GitHub.';

  @override
  String get prefixTool_title => 'Repeater-ID:n';

  @override
  String get prefixTool_subtitle =>
      'Vem som använder ett ID, vilka ID:n som krockar och lediga ID:n för en ny repeater';

  @override
  String get prefixTool_width => 'Storlek på väg-ID';

  @override
  String prefixTool_widthBytes(int bytes) {
    return '$bytes byte';
  }

  @override
  String get prefixTool_includeCompanions => 'Ta med companions och sensorer';

  @override
  String prefixTool_summary(int nodes, int used, int shared) {
    return '$nodes kända noder · $used ID:n används · $shared delade';
  }

  @override
  String prefixTool_freeOfSpace(int free, int space) {
    return '$free av $space ID:n lediga';
  }

  @override
  String get prefixTool_lookupHint => 'Slå upp ett ID, t.ex. 3D';

  @override
  String prefixTool_lookupFree(String id) {
    return 'Ingen känd nod använder $id.';
  }

  @override
  String prefixTool_lookupUsed(int count, String id) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count noder använder $id',
      one: '1 nod använder $id',
    );
    return '$_temp0';
  }

  @override
  String get prefixTool_shared => 'Delade ID:n';

  @override
  String get prefixTool_sharedHint =>
      'Vägar via dessa ID:n ser likadana ut om inte meshet använder längre ID:n.';

  @override
  String get prefixTool_noShared =>
      'Inga delade ID:n bland noderna du känner till.';

  @override
  String get prefixTool_free => 'Lediga ID:n';

  @override
  String get prefixTool_shuffle => 'Fler förslag';

  @override
  String get prefixTool_makeKey => 'Skapa en nyckel';

  @override
  String get prefixTool_onlyKnown =>
      'Bygger bara på noder som radion har hört. Ett ledigt ID här kan ändå tillhöra en repeater du inte hört.';

  @override
  String prefixTool_inUseWarning(String id, String name) {
    return '$id används redan av $name.';
  }

  @override
  String get prefixTool_pickFree => 'Välj ett ledigt ID';

  @override
  String keyGen_title(String id) {
    return 'Nyckel för ID $id';
  }

  @override
  String keyGen_searching(int tries) {
    return 'Söker… $tries nycklar provade';
  }

  @override
  String get keyGen_publicKey => 'Publik nyckel';

  @override
  String get keyGen_privateKey => 'Privat nyckel';

  @override
  String get keyGen_copy => 'Kopiera';

  @override
  String get keyGen_copied => 'Kopierat';

  @override
  String get keyGen_secretWarning =>
      'Håll den privata nyckeln hemlig. Den som har den kan utge sig för att vara den här noden.';

  @override
  String get keyGen_howToUse =>
      'För en repeater: öppna dess inställningar, klistra in den som privat nyckel och spara. Companion-radioenheter behöver firmware som tillåter nyckelimport.';

  @override
  String get keyGen_tryAgain => 'Skapa en till';

  @override
  String get regionSetup_title => 'Ställ in regioner';

  @override
  String get regionSetup_hubSubtitle =>
      'Placera repeatern i regionträdet för ditt område';

  @override
  String get regionSetup_intro =>
      'Regioner håller ett meddelande inom ett område i stället för att översvämma hela meshet. En repeater vidarebefordrar bara en regions meddelanden om den bär regionen, så ge den sin egen region och alla regioner ovanför.';

  @override
  String get regionSetup_where => 'Var står repeatern?';

  @override
  String get regionSetup_tree => 'Regionträd';

  @override
  String get regionSetup_custom => 'Anpassat';

  @override
  String get regionSetup_region => 'Mest lokal region';

  @override
  String get regionSetup_customLabel => 'Regioner, bredast först';

  @override
  String regionSetup_invalidName(String name) {
    return '\"$name\" är inte ett giltigt regionnamn. Använd gemener, siffror och bindestreck, högst 29 tecken.';
  }

  @override
  String regionSetup_tooMany(int max) {
    return 'En repeater kan bära högst $max regioner.';
  }

  @override
  String get regionSetup_options => 'Alternativ';

  @override
  String get regionSetup_setDefault =>
      'Gör den mest lokala regionen till standard';

  @override
  String get regionSetup_setDefaultBody =>
      'Repeaterns egna adverts stannar i den regionen.';

  @override
  String get regionSetup_legacy => 'Firmware 1.14';

  @override
  String get regionSetup_legacyBody =>
      'Lägger till region allowf efter varje region. Behövs inte från 1.15.';

  @override
  String get regionSetup_denyUnscoped =>
      'Sluta vidarebefordra meddelanden utan region';

  @override
  String get regionSetup_denyUnscopedBody =>
      'Slå bara på detta när hela området använder regioner, annars kommer meddelanden från äldre appar inte fram.';

  @override
  String get regionSetup_commands => 'Kommandon';

  @override
  String get regionSetup_copyAll => 'Kopiera alla';

  @override
  String get regionSetup_copied => 'Kopierat';

  @override
  String get regionSetup_pickFirst => 'Välj en region för att se kommandona.';

  @override
  String regionSetup_sendTo(String name) {
    return 'Skicka till $name';
  }

  @override
  String get regionSetup_howToSend =>
      'Logga in på repeatern och öppna Ställ in regioner i dess meny för att skicka, eller klistra in dem på dess kommandorad.';

  @override
  String get regionSetup_noReply => 'Inget svar. Stoppade här.';

  @override
  String get regionSetup_addToMine => 'Lägg till regionerna i min lista';

  @override
  String regionSetup_addedToMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regioner tillagda i din lista',
      one: '1 region tillagd i din lista',
    );
    return '$_temp0';
  }

  @override
  String get trackLog_title => 'Spårlogg';

  @override
  String get trackLog_subtitle => 'Spela in ett spår från radions GPS';

  @override
  String get trackLog_recording => 'Spelar in';

  @override
  String get trackLog_notRecording => 'Spelar inte in';

  @override
  String get trackLog_noGps =>
      'Radion rapporterar ingen GPS-position. Spårloggen behöver en radio med GPS påslagen.';

  @override
  String get trackLog_start => 'Starta inspelning';

  @override
  String get trackLog_stop => 'Stoppa inspelning';

  @override
  String get trackLog_howItWorks =>
      'Använder positionen som radion rapporterar, ungefär en gång i minuten, medan NOTORYX Core är öppen. En punkt läggs till när du rört dig 25 m, eller var 15:e minut när du står still.';

  @override
  String get trackLog_snap => 'Avrunda positioner till cirka 100 m';

  @override
  String get trackLog_snapBody => 'För integriteten när du delar ett spår.';

  @override
  String get trackLog_saved => 'Sparade spår';

  @override
  String get trackLog_none => 'Inga spår ännu.';

  @override
  String get trackLog_export => 'Exportera som GPX';

  @override
  String get trackLog_exportFailed => 'Kunde inte exportera spåret.';

  @override
  String get trackLog_deleteTitle => 'Ta bort spåret?';

  @override
  String get trackLog_deleteBody =>
      'Det tas bort från den här enheten. Exporterade GPX-filer påverkas inte.';

  @override
  String trackLog_stats(String km, String duration, int points) {
    return '$km km · $duration · $points punkter';
  }

  @override
  String trackLog_gpxName(String when) {
    return 'NOTORYX-spår $when';
  }

  @override
  String get routes_nearbyTitle => 'Bästa repeatrar nära dig';

  @override
  String get routes_nearbyEmptyTitle => 'Inga repeatrar hörda än';

  @override
  String get routes_nearbyEmpty =>
      'Repeatrar som radion hör direkt visas här, starkast först, allteftersom den tar emot trafik. Listan gäller den senaste timmen.';

  @override
  String get routes_unknownRepeater => 'Okänd repeater';

  @override
  String routes_nearbyDetail(int count, String ago) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hörd $count gånger',
      one: 'hörd en gång',
    );
    return '$_temp0 · $ago';
  }

  @override
  String routes_minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'för $minutes min sedan',
      one: 'för 1 min sedan',
      zero: 'nyss',
    );
    return '$_temp0';
  }

  @override
  String routes_via(String names) {
    return 'via $names';
  }

  @override
  String get nav_home => 'Hem';

  @override
  String get nav_chats => 'Chattar';

  @override
  String get nav_tools => 'Verktyg';

  @override
  String get nav_settings => 'Inställningar';

  @override
  String get nav_more => 'Mer';

  @override
  String get tools_groupApp => 'App och inställningar';

  @override
  String get tools_groupField => 'I fält';

  @override
  String get tools_groupMaps => 'Kartor och täckning';

  @override
  String get tools_groupRouting => 'Rutter och repeatrar';

  @override
  String get tools_pathGraph => 'Väggraf';

  @override
  String get tools_pathGraphHint =>
      'Hur meddelanden når dig: varje hörd väg, med de mest belastade repeatrarna';

  @override
  String get tools_antenna => 'Antenntäckning';

  @override
  String get tools_antennaHint =>
      'Uppskatta hur långt en antenn når över terrängen';

  @override
  String routes_repeaterWithId(String id) {
    return 'Repeater $id';
  }

  @override
  String get signedCov_section => 'Signerade rapporter';

  @override
  String get signedCov_share => 'Dela signerad rapport';

  @override
  String get signedCov_shareHint =>
      'Varje hexagon signeras med telefonens täckningsnyckel, så ändrade eller påhittade upptäcks. Inget lämnar telefonen om du inte delar det.';

  @override
  String get signedCov_check => 'Kontrollera en rapport';

  @override
  String get signedCov_checkHint =>
      'Klistra in en signerad rapport för att se vilka observationer som är äkta';

  @override
  String get signedCov_paste => 'Signerad rapport (JSON)';

  @override
  String get signedCov_verify => 'Kontrollera';

  @override
  String signedCov_yourKey(String fingerprint) {
    return 'Din täckningsnyckel: $fingerprint';
  }

  @override
  String signedCov_result(int accepted, int rejected) {
    return '$accepted observationer verifierade, $rejected avvisade';
  }

  @override
  String signedCov_signer(String fingerprint) {
    return 'Signerad med nyckel $fingerprint';
  }

  @override
  String get signedCov_unreadable =>
      'Det här är ingen signerad täckningsrapport.';

  @override
  String signedCov_rBadSignature(int count) {
    return '$count utan eller med fel signatur';
  }

  @override
  String signedCov_rMalformed(int count) {
    return '$count skadade';
  }

  @override
  String signedCov_rImpossible(int count) {
    return '$count med omöjliga signalvärden';
  }

  @override
  String signedCov_rFuture(int count) {
    return '$count daterade i framtiden';
  }

  @override
  String get signedCov_empty => 'Inga täckningsprover att dela än.';

  @override
  String get signedCov_shareFailed => 'Kunde inte dela rapporten.';

  @override
  String get coverageHex_title => 'Täckningshexagoner';

  @override
  String get coverageHex_toolSubtitle =>
      'Kartlägg var radion hör meshen och dela det';

  @override
  String get coverageHex_mapCoverage => 'Kartlägg täckning';

  @override
  String get coverageHex_statusOff =>
      'Av. Slå på när du kör eller går för att kartlägga var radion hör meshen.';

  @override
  String get coverageHex_waitingGps => 'Väntar på GPS…';

  @override
  String coverageHex_gpsTooRough(String meters) {
    return 'GPS-noggrannhet $meters m: för grov, spelar inte in.';
  }

  @override
  String coverageHex_recording(String meters) {
    return 'Spelar in. GPS-noggrannhet $meters m.';
  }

  @override
  String get coverageHex_hexagons => 'Hexagoner';

  @override
  String get coverageHex_samples => 'Prover';

  @override
  String get coverageHex_privacyNote =>
      'Använder telefonens GPS medan reglaget är på. Endast hexagon-ID:n (cirka 0,9 km) delas, aldrig din exakta position.';

  @override
  String get coverageHex_uploadSection => 'Ladda upp till täckningskartor';

  @override
  String get coverageHex_wifiOnly => 'Ladda upp endast via Wi-Fi';

  @override
  String get coverageHex_wifiOnlyHint =>
      'Proverna väntar i telefonen (upp till 7 dagar) på Wi-Fi.';

  @override
  String coverageHex_waiting(String count) {
    return '$count väntar';
  }

  @override
  String get coverageHex_addMap => 'Lägg till täckningskarta';

  @override
  String get coverageHex_addMapHint =>
      'Valfri HTTPS-adress som tar emot täckningsdata.';

  @override
  String get coverageHex_uploadNow => 'Ladda upp nu';

  @override
  String get coverageHex_mapDialogTitle => 'Täckningskarta';

  @override
  String get coverageHex_nameMissing => 'Ge den ett namn.';

  @override
  String get coverageHex_url => 'Uppladdnings-URL';

  @override
  String get coverageHex_urlInvalid => 'Måste vara en https://-URL.';

  @override
  String get coverageHex_apiKey => 'API-nyckel (valfri)';

  @override
  String get coverageHex_apiKeyHint => 'Skickas som X-API-Key.';

  @override
  String get coverageHex_format => 'Format';

  @override
  String get coverageHex_formatHex => 'Hexagon-ID:n (NOTORYX)';

  @override
  String get coverageHex_formatMeshMapper => 'MeshMapper-kompatibel';

  @override
  String get coverageHex_privacy => 'Integritet';

  @override
  String get coverageHex_privacyLive => 'Live';

  @override
  String get coverageHex_privacyDelayed => 'Fördröjt 3 h';

  @override
  String get coverageHex_privacyAnonymous => 'Anonymt, 24 h';

  @override
  String get coverageHex_privacyLiveHint => 'Skickas inom cirka 15 minuter.';

  @override
  String get coverageHex_privacyDelayedHint =>
      'Hålls kvar 3 timmar så att kartan inte visar var du är nu.';

  @override
  String get coverageHex_privacyAnonymousHint =>
      'Hålls kvar 24 timmar, daterat per dag och osignerat så att uppladdningar inte kan kopplas ihop.';

  @override
  String get coverageHex_uploadsOn => 'Uppladdning på';

  @override
  String coverageHex_sent(String count, String time) {
    return 'Skickade $count celler kl. $time.';
  }

  @override
  String coverageHex_httpError(String code) {
    return 'Kartan svarade $code; försöker igen.';
  }

  @override
  String get coverageHex_unreachable => 'Kunde inte nå kartan; försöker igen.';

  @override
  String get coverageHex_noPermission => 'Platsbehörighet beviljades inte.';

  @override
  String get coverageHex_noGps => 'GPS är inte tillgänglig.';

  @override
  String get coverageHex_loadFailed =>
      'Sparad täckning kunde inte läsas; börjar om.';

  @override
  String get mqttExtra_wifiOnly => 'Anslut endast via Wi-Fi';

  @override
  String mqttExtra_backlog(String count) {
    return '$count paket väntar på uppladdning (sparas i upp till 72 timmar).';
  }

  @override
  String get mqttExtra_add => 'Lägg till en broker till';

  @override
  String get mqttExtra_addBody =>
      'Delar det radion hör med ytterligare en MQTT-broker utöver huvudbrokern. Den laddar bara upp och skickar aldrig paket tillbaka till appen.';

  @override
  String get mqttExtra_separateKey => 'Använd en separat nyckel';

  @override
  String get mqttExtra_separateKeyHint =>
      'Loggar in med en nyckel skapad på den här telefonen i stället för radions, så att brokern inte kan koppla uppladdningar till din radio.';

  @override
  String mqttExtra_removeTitle(String name) {
    return 'Ta bort $name?';
  }

  @override
  String get mqttExtra_removeBody =>
      'Kopplar från och glömmer inställningar, lösenord, nyckel och väntande paket.';

  @override
  String mqttExtra_ownKey(String key) {
    return 'Loggar in med egen nyckel: $key…';
  }

  @override
  String get botWx_title => 'Publicera vädervarningar i en kanal';

  @override
  String get botWx_body =>
      'Kontrollerar var 10:e minut den amerikanska vädertjänsten efter allvarliga och extrema varningar vid radions GPS-position (avrundad till cirka 1 km) och publicerar varje ny en gång. Kräver internet i telefonen.';

  @override
  String get botWx_channel => 'Publicera i kanal';

  @override
  String get botWx_moderate => 'Ta med måttliga varningar';

  @override
  String get botWx_moderateHint => 'Råd såväl som varningar. Fler meddelanden.';

  @override
  String botWx_lastChecked(String time) {
    return 'Senast kontrollerad $time.';
  }

  @override
  String get botWx_noPosition =>
      'Radion har inte rapporterat någon GPS-position än.';

  @override
  String get botWx_noChannel => 'Välj en kanal för varningarna.';

  @override
  String get botWx_channelGone => 'Den valda kanalen finns inte längre.';

  @override
  String botWx_httpError(String code) {
    return 'Vädertjänsten svarade $code.';
  }

  @override
  String get botWx_unreachable => 'Kunde inte nå vädertjänsten.';

  @override
  String get botCmd_sun =>
      'Soluppgång och solnedgång vid radions GPS-position.';

  @override
  String get botCmd_moon => 'Månfas och hur mycket som är upplyst.';

  @override
  String get botCmd_weather =>
      'Aktuellt väder vid radion (Open-Meteo). Skickar positionen avrundad till cirka 1 km.';

  @override
  String get botCmd_dice => 'Slår tärning: !dice, !dice 20 eller !dice 2d6.';

  @override
  String get botCmd_trace => 'Listar repeatrarna som meddelandet gick via.';

  @override
  String get ping_title => 'Repeater-ping';

  @override
  String get ping_toolSubtitle =>
      'Tur och retur-tid och signal åt båda håll till en närliggande repeater';

  @override
  String get ping_noRepeaters => 'Inga kända repeatrar än';

  @override
  String get ping_choose => 'Välj en repeater';

  @override
  String get ping_avgMs => 'ms tur och retur';

  @override
  String get ping_snrThere => 'SNR där';

  @override
  String get ping_snrBack => 'SNR tillbaka';

  @override
  String get ping_loss => 'Förlorade';

  @override
  String ping_running(int done, int total) {
    return 'Pingar $done av $total…';
  }

  @override
  String ping_start(int count) {
    return 'Pinga $count gånger';
  }

  @override
  String get ping_results => 'Prober';

  @override
  String get ping_noReply => 'Inget svar';

  @override
  String ping_resultLine(String ms, String snr) {
    return '$ms ms · SNR där $snr';
  }

  @override
  String get ping_explainer =>
      'Varje prob är en spårning över ett hopp: repeatern noterar hur väl den hörde dig och skickar tillbaka det. Fungerar för repeatrar som radion hör direkt.';

  @override
  String get hunt_title => 'Antennjakt';

  @override
  String get hunt_toolSubtitle =>
      'Stor live-signalmätare som klickar snabbare när signalen blir starkare';

  @override
  String get hunt_noSignal => 'Ingen signal än';

  @override
  String get hunt_noReply => 'Inget svar – flytta eller vrid antennen';

  @override
  String get hunt_heardHere => 'dB hört här';

  @override
  String get hunt_best => 'Bästa';

  @override
  String get hunt_sound => 'Klicka när den blir starkare';

  @override
  String get hunt_soundHint =>
      'Med vibration vid varje klick, så att du kan rikta utan att titta.';

  @override
  String get hunt_stop => 'Stoppa';

  @override
  String get hunt_start => 'Börja leta';

  @override
  String get hunt_explainer =>
      'Probar repeatern ungefär en gång per sekund. Rikta en riktantenn eller gå runt: siffran är hur väl radion hör den.';

  @override
  String get settings_refreshRate => 'Uppdateringstakt';

  @override
  String get settings_refreshFast => 'Snabb';

  @override
  String get settings_refreshNormal => 'Normal';

  @override
  String get settings_refreshSlow => 'Långsam';

  @override
  String get settings_refreshFastHint =>
      'Batteri varje minut, GPS var 30:e s. Färskare värden, mer batteri.';

  @override
  String get settings_refreshNormalHint =>
      'Batteri varannan minut, GPS varje minut.';

  @override
  String get settings_refreshSlowHint =>
      'Batteri var 6:e minut, GPS var 3:e. Sparar batteri.';

  @override
  String get settings_refreshSaverOn =>
      'Batterisparläget är på och styr takten (batteri var 10:e minut).';

  @override
  String get reach_check => 'Kontrollera räckvidd hos observatörer';

  @override
  String get reach_title => 'Räckvidd hos observatörer';

  @override
  String get reach_noHash =>
      'Det här meddelandet kan inte slås upp än: ingen repeater har skickat tillbaka det till radion, så paket-ID:t är okänt.';

  @override
  String get reach_unreachable =>
      'Kunde inte nå analysatorn. Kontrollera internet eller analysatorns adress i inställningarna.';

  @override
  String get reach_none =>
      'Ingen observatör har hört det än. Observatörer laddar upp en stund efter, kontrollera igen om en minut.';

  @override
  String get reach_observers => 'observatörer';

  @override
  String get reach_maxHops => 'max hopp';

  @override
  String get reach_bestSnr => 'bästa SNR';

  @override
  String reach_hops(int count) {
    return '$count hopp bort';
  }

  @override
  String get reach_explainer =>
      'Från onlineanalysatorn: observatörer som hörde och laddade upp paketet.';

  @override
  String get reach_checkAgain => 'Kontrollera igen';

  @override
  String get analyzer_title => 'Onlineanalysator';

  @override
  String get analyzer_url => 'Analysatoradress';

  @override
  String get analyzer_urlHint =>
      'En CoreScope-analysator (https://). Använd den som täcker din region.';

  @override
  String get analyzer_reset => 'Standard';

  @override
  String get analyzer_hint =>
      'Används för att se vilka observatörer som hörde dina meddelanden. Endast paket-ID:t skickas.';

  @override
  String get analyzer_hopLookup => 'Namnge okända repeatrar online';

  @override
  String get analyzer_hopLookupHint =>
      'När ett repeater-ID inte finns bland kontakterna frågas analysatorn om namnet. Endast korta ID:n skickas. Ett namn med ”?” betyder att flera repeatrar delar ID:t.';

  @override
  String discovered_tray(int count) {
    return 'Kanaler hörda i närheten: $count';
  }

  @override
  String get discovered_title => 'Hörda i närheten, inte anslutna';

  @override
  String discovered_heard(int count, String time) {
    return 'Hörd $count× · senast $time';
  }

  @override
  String get discovered_ignore => 'Ignorera';

  @override
  String get discovered_ignoreAll => 'Ignorera alla';

  @override
  String get discovered_joinAll => 'Gå med i alla';

  @override
  String get discovered_explainer =>
      'Det här är offentliga kanaler från kanalkatalogen som radion har hört trafik på. Var och en bekräftades genom att ett meddelande dekrypterades med dess nyckel. Ignorerade kanaler förblir dolda.';

  @override
  String get mqtt_presetMeshRank => 'MeshRank (community)';

  @override
  String get mqtt_presetMeshRankNote =>
      'MeshRank är en communitydriven rankning av MeshCore-nät, inte en del av NOTORYX och inte rekommenderad av det. Ingen inloggning: paket delas under radions nyckel och regionkod, först när du slår på delning.';

  @override
  String get pathFilter_title => 'Filter för vägbredd';

  @override
  String get pathFilter_firmwareNote =>
      'Kräver repeaterfirmware med vidarebefordringsregler (mikecarper/MeshCore). Officiell MeshCore-firmware avvisar dessa kommandon.';

  @override
  String get pathFilter_width => 'Vägbredd';

  @override
  String get pathFilter_anyWidth => 'Valfri bredd';

  @override
  String pathFilter_bytes(int n) {
    return 'Vägar med $n byte';
  }

  @override
  String get pathFilter_twoOrMore => '2 eller 3 byte (2+)';

  @override
  String get pathFilter_path => 'Gäller för';

  @override
  String get pathFilter_radio => 'Radioflöden';

  @override
  String get pathFilter_bridge => 'Brygga';

  @override
  String get pathFilter_cross => 'Övergång';

  @override
  String get pathFilter_bridgeCross => 'Brygga och övergång';

  @override
  String get pathFilter_limit => 'Begränsa i stället för att släppa';

  @override
  String get pathFilter_limitOn =>
      'Vidarebefordrar upp till ett visst antal per minut.';

  @override
  String get pathFilter_drop => 'Matchande flöden släpps.';

  @override
  String get pathFilter_perMinute => 'Per minut';

  @override
  String get pathFilter_rateInvalid => 'Ange 1 till 65534.';

  @override
  String get pathFilter_reviewNote =>
      'Detta fyller bara i kommandoraden. Kontrollera och tryck på Skicka. Använd först ”get fr” för att se reglerna.';

  @override
  String get pathFilter_useCommand => 'Använd kommando';

  @override
  String get settings_linkPreviews => 'Länkförhandsvisningar';

  @override
  String get settings_linkPreviewsHint =>
      'Visar titeln på en länk i ett meddelande. Av som standard: att hämta sidan visar webbplatsen din IP-adress.';

  @override
  String get guide_title => 'Fälthandbok';

  @override
  String get guide_subtitle => 'Grunder, batterier i kyla, sol och antenner';

  @override
  String get guide_secMesh => 'Kom med i meshen';

  @override
  String get guide_mesh1 =>
      'Telefonen pratar med radion via Bluetooth, USB eller Wi-Fi; radion med meshen via LoRa. Meddelanden fungerar utan mobiltäckning.';

  @override
  String get guide_mesh2 =>
      'Repeatrar skickar vidare meddelanden; varje vidaresändning är ett hopp. Färre hopp ger snabbare och säkrare leverans.';

  @override
  String get guide_mesh3 =>
      'Håll meddelanden korta och översvämma inte fulla kanaler: varje meddelande använder delad sändtid.';

  @override
  String get guide_secCold => 'Batterier i kyla';

  @override
  String get guide_cold1 =>
      'Ladda inte litiumbatterier under fryspunkten (0 °C): det skadar dem permanent.';

  @override
  String get guide_cold2 =>
      'Bär radion innanför jackan. Kyla sänker kapaciteten, som kommer tillbaka när batteriet blir varmt.';

  @override
  String get guide_cold3 =>
      'För fasta platser i kallt klimat klarar LiFePO4 sig bättre än litiumjon; en uppvärmd eller isolerad låda hjälper båda.';

  @override
  String get guide_secSolar => 'Sol för repeatrar';

  @override
  String get guide_solar1 =>
      'En repeater drar mycket lite, men dimensionera panel och batteri för din mörkaste vintervecka, inte en sommardag.';

  @override
  String get guide_solar2 =>
      'Rikta panelen mot ekvatorn och luta den brant på vintern; håll den fri från snö och skugga.';

  @override
  String get guide_secAntenna => 'Antenner och placering';

  @override
  String get guide_ant1 =>
      'Höjd slår effekt: en radio några meter upp når mycket längre än en på skrivbordet.';

  @override
  String get guide_ant2 =>
      'Håll antennen lodrät och borta från metall, och använd en för ditt band (till exempel 868 MHz i Europa).';

  @override
  String get guide_secMore => 'Läs mer';

  @override
  String get guide_moreMeshcore => 'Det officiella MeshCore-projektet';

  @override
  String get guide_moreCascadia =>
      'Communityguider: kom igång, wardriving, regioner, sol';

  @override
  String get post_signed => 'Signerat';

  @override
  String get post_unverified => 'Ej bekräftat';

  @override
  String post_signedKnown(String name) {
    return 'Signerat av $name, en av dina kontakter.';
  }

  @override
  String get post_signedUnknownKey =>
      'Signerat, men inte av någon av dina kontakter. Lägg till avsändaren som kontakt för att se vem det är.';

  @override
  String get post_unverifiedHint =>
      'Med inlägget kom en signatur som inte stämmer. Det kan ha ändrats på vägen eller inte vara från den det påstår.';

  @override
  String get settings_signPosts => 'Signera alla mina kanalinlägg';

  @override
  String get settings_signPostsHint =>
      'Ett SOS i en kanal signeras alltid. Detta signerar varje inlägg så att andra NOTORYX-användare ser att det verkligen är du. Varje signatur är ett extra paket i luften.';

  @override
  String get tools_search => 'Sök verktyg och inställningar';

  @override
  String get tools_noMatches => 'Inga verktyg matchar sökningen.';

  @override
  String get tools_bot => 'Botläge';

  @override
  String get tools_botHint =>
      'Autosvar, !kommandon och vädervarningar i kanaler';

  @override
  String get botChannels_title => 'Kanaler';

  @override
  String get botChannels_hint =>
      'Boten svarar också på !kommandon i kanalerna du slår på, i samma kanal. Frånvarosvar skickas aldrig där.';

  @override
  String get botChannels_none => 'Inga kanaler på den här radion än.';

  @override
  String get advert_zeroHopHint =>
      'Bara radioapparater som hör dig direkt. Repeatrar skickar inte vidare.';

  @override
  String get advert_floodHint =>
      'Repeatrar sprider den i hela nätet. Tar mer sändningstid.';

  @override
  String get radioPresets_custom => 'Anpassad';

  @override
  String get radioPresets_search => 'Sök förinställningar';

  @override
  String get radioPresets_suggested => 'Föreslaget för din region';

  @override
  String get radioPresets_community => 'Gemenskapens förinställningar';

  @override
  String get radioPresets_hint =>
      'Detta är förinställningarna som MeshCore-gemenskapen föreslår. Välj den ditt lokala nät använder. Den sätter frekvens, bandbredd, spridningsfaktor och kodningsgrad; din sändeffekt är oförändrad.';

  @override
  String get mySensors_title => 'Sensorer';

  @override
  String get mySensors_refresh => 'Läs sensorer';

  @override
  String get mySensors_reading => 'Läser radions sensorer…';

  @override
  String get mySensors_failed =>
      'Radion svarade inte. Tryck på uppdatera för att försöka igen.';

  @override
  String get mySensors_none => 'Inga sensorvärden från radion.';

  @override
  String get activeChannels_title => 'Aktiva online';

  @override
  String activeChannels_messages(int count) {
    return '$count meddelanden';
  }

  @override
  String activeChannels_source(String host) {
    return 'Kanaler som används, enligt observatörerna hos $host. Byt analysator i inställningarna för ditt område.';
  }

  @override
  String get fieldOps_checkInChannelLabel =>
      'Incheckningar går också till kanal';

  @override
  String get fieldOps_checkInChannelHint =>
      'Signerad med radions nyckel så att andra i kanalen ser att det verkligen är du. Resekontakterna får den fortfarande direkt.';

  @override
  String get channels_regionUnknown => 'Regional';

  @override
  String channels_regionSemantics(String region) {
    return 'Skickat till region $region';
  }

  @override
  String get channels_regionUnknownSemantics =>
      'Skickat till en region appen inte känner';

  @override
  String get timeline_title => 'Tidslinje';

  @override
  String get timeline_toolSubtitle =>
      'Meddelanden, nya noder, signaländringar och platser i ett flöde';

  @override
  String get timeline_refresh => 'Ladda om';

  @override
  String get timeline_search => 'Sök i tidslinjen';

  @override
  String get timeline_kindMessages => 'Meddelanden';

  @override
  String get timeline_kindNodes => 'Nya noder';

  @override
  String get timeline_kindSignal => 'Signal';

  @override
  String get timeline_kindPlaces => 'Platser';

  @override
  String timeline_messageFrom(String sender, String where) {
    return '$sender i $where';
  }

  @override
  String timeline_nodeJoined(String name) {
    return 'Hörd för första gången: $name';
  }

  @override
  String timeline_signalUp(String name, String from, String to) {
    return '$name: signalen steg från $from till $to dB';
  }

  @override
  String timeline_signalDown(String name, String from, String to) {
    return '$name: signalen sjönk från $from till $to dB';
  }

  @override
  String timeline_placeSaved(String name) {
    return 'Plats sparad: $name';
  }

  @override
  String timeline_placeShared(String sender, String where) {
    return '$sender delade en plats i $where';
  }

  @override
  String get timeline_empty =>
      'Inget än. Meddelanden, nyhörda noder, signaländringar och platser visas här.';

  @override
  String get wardrive_title => 'Wardrive';

  @override
  String get wardrive_hint =>
      'Pinga där du är och kartlägg vilka repeatrar som hör dig';

  @override
  String get wardrive_start => 'Starta';

  @override
  String get wardrive_stop => 'Stoppa';

  @override
  String get wardrive_pings => 'pingar';

  @override
  String get wardrive_heard => 'hörda';

  @override
  String get wardrive_pinging => 'Pingar…';

  @override
  String get wardrive_waitPosition =>
      'Väntar på GPS-position från telefonen eller radion.';

  @override
  String get wardrive_waitRadio => 'Anslut en radio för att pinga.';

  @override
  String get wardrive_history => 'Historik';

  @override
  String get wardrive_noSessions => 'Inga turer än.';

  @override
  String wardrive_sessionSummary(int pings, int heard) {
    return '$pings pingar · $heard hörda';
  }

  @override
  String get wardrive_delete => 'Ta bort';

  @override
  String get wardrive_recentre => 'Tillbaka till min position';

  @override
  String get wardrive_youAreHere => 'Du är här';

  @override
  String get wardrive_backToLive => 'Tillbaka till pågående';

  @override
  String get wardrive_noReplies => 'Ingen repeater hörde den här pingen.';

  @override
  String wardrive_replyDetail(String there, String here) {
    return 'Hörde dig på $there dB · du hörde den på $here dB';
  }

  @override
  String get wardrive_explainer =>
      'Varje ping är en upptäcktsförfrågan utan vidarebefordran: bara repeatrar inom direkt räckvidd svarar och inget postas i en kanal. Positioner kommer från telefonens GPS, annars från radion.';

  @override
  String get mapTelemetry_policy =>
      'Sparade mätvärden tonas ned efter 1 timme och döljs efter 24 timmar. Uppdatera skickar en begäran; noden måste tillåta telemetri och sensorer kan kräva inloggning. Kartan begär aldrig uppdateringar automatiskt.';

  @override
  String get autoConnect_title => 'Anslut automatiskt till min radio';

  @override
  String get autoConnect_hint =>
      'När appen öppnas återansluter den till din senaste radio utan att du trycker. Den försöker några gånger om radion inte är inom räckhåll än.';

  @override
  String get networks_title => 'Nätverk';

  @override
  String get networks_hint => 'Sök efter nätverk i närheten och för logg';

  @override
  String get networks_yourNetwork => 'Ditt nätverk';

  @override
  String get networks_scanTitle => 'Sök efter nätverk';

  @override
  String get networks_scanExplainer =>
      'Radion hör bara nätverk med exakt samma inställningar, så en sökning ställer om den till varje nätverk i tur och ordning, lyssnar och ställer tillbaka den. Under sökningen är du utanför ditt eget mesh.';

  @override
  String get networks_listenFor => 'Lyssna på varje';

  @override
  String networks_choose(int count) {
    return 'Nätverk att söka: $count';
  }

  @override
  String get networks_suggested => 'Förslag';

  @override
  String get networks_start => 'Starta sökning';

  @override
  String get networks_cancel => 'Stoppa sökning';

  @override
  String networks_listening(String name, int step, int steps) {
    return 'Lyssnar på $name ($step av $steps)';
  }

  @override
  String get networks_blockNoRadio => 'Anslut en radio för att söka.';

  @override
  String get networks_blockSettings => 'Väntar på radions inställningar.';

  @override
  String get networks_blockSos =>
      'Inte under ett SOS: en sökning tar dig ur ditt mesh.';

  @override
  String get networks_blockTrip =>
      'Inte under en tur: en sökning tar dig ur ditt mesh.';

  @override
  String get networks_nearby => 'Nätverk i närheten';

  @override
  String get networks_nothingYet =>
      'Inga nätverk hörda ännu. Starta en sökning.';

  @override
  String networks_heardSummary(int nodes, int packets, String snr) {
    return 'Noder $nodes · paket $packets · SNR $snr dB';
  }

  @override
  String networks_lastHeard(String time) {
    return 'Senast hörd $time';
  }

  @override
  String networks_timesHeard(int count) {
    return 'Antal gånger hörd: $count';
  }

  @override
  String get networks_saved => 'Sparade nätverk';

  @override
  String get networks_noSaved => 'Inga sparade nätverk ännu.';

  @override
  String get networks_add => 'Lägg till nätverk';

  @override
  String get networks_join => 'Gå med';

  @override
  String networks_joinConfirm(String name) {
    return 'Ställa om radion till $name? Du lämnar ditt nuvarande nätverk. Sändeffekten är oförändrad.';
  }

  @override
  String networks_joined(String name) {
    return 'Radion är nu på $name.';
  }

  @override
  String get networks_log => 'Nätverkslogg';

  @override
  String get networks_logEmpty => 'Inget loggat ännu.';

  @override
  String get networks_showMap => 'Karta';

  @override
  String get networks_exportCsv => 'Exportera CSV';

  @override
  String get networks_exportGpx => 'Exportera GPX';

  @override
  String get networks_clearLog => 'Rensa loggen';

  @override
  String get networks_clearLogConfirm => 'Radera alla loggade nätverk?';

  @override
  String get networks_name => 'Namn';

  @override
  String get networks_invalid =>
      'Kontrollera inställningarna: de ligger utanför vad MeshCore-radior accepterar.';

  @override
  String get networks_nodesHeard => 'Hörda noder';

  @override
  String get chat_resendNeedsRadio =>
      'Inte skickat: anslut radion och försök igen. Meddelandet sparas.';

  @override
  String get quick_title => 'Snabbmeddelanden';

  @override
  String get quick_ok => 'OK';

  @override
  String get quick_onMyWay => 'På väg';

  @override
  String get quick_atCamp => 'Vid lägret';

  @override
  String get quick_runningLate => 'Blir sen';

  @override
  String get quick_needHelp => 'Behöver hjälp';

  @override
  String get quick_copyThat => 'Uppfattat';

  @override
  String get quick_empty =>
      'Inga snabbmeddelanden. Tryck på Redigera för att lägga till ett.';

  @override
  String get quick_add => 'Nytt snabbmeddelande';

  @override
  String get quick_reset => 'Återställ standard';

  @override
  String get chat_stopRetrying => 'Sluta försöka igen';

  @override
  String chat_addFirstBanner(String name) {
    return '$name kan läsa och svara på dina direktmeddelanden först när hen har lagt till dig som kontakt. Om inte, skicka din annons eller dela din kontakt.';
  }

  @override
  String get map_goToMyPosition => 'Gå till min position';

  @override
  String get map_positionUnavailable =>
      'Din position är inte tillgänglig. Slå på plats eller ange radions position.';

  @override
  String get contact_forgetAdvert => 'Glöm senaste annons';

  @override
  String get contact_forgetAdvertHint =>
      'Om nodens annonser slutat uppdateras efter att dess klocka återställts, släpper Glöm senaste annons igenom nästa.';

  @override
  String get contact_forgetAdvertDone =>
      'Klart. Nästa annons från noden accepteras.';

  @override
  String get networks_modeQuick => 'Snabb';

  @override
  String get networks_modeThorough => 'Grundlig';

  @override
  String get networks_modeQuickHint =>
      'Skickar en kort ping utan vidarebefordran på varje nätverk och lyssnar några sekunder. Hittar nätverk med en repeater inom räckvidd.';

  @override
  String get networks_modeThoroughHint =>
      'Lyssnar bara, längre på varje nätverk. Skickar inget och hittar även nätverk utan repeater inom räckvidd om någon sänder.';

  @override
  String networks_estimate(String time) {
    return 'cirka $time';
  }

  @override
  String discoveredContacts_selected(int count) {
    return '$count markerade';
  }

  @override
  String get discoveredContacts_selectAll => 'Markera alla';

  @override
  String get discoveredContacts_addSelected => 'Lägg till markerade';

  @override
  String discoveredContacts_addAllShown(int count) {
    return 'Lägg till alla som visas ($count)';
  }

  @override
  String discoveredContacts_addManyTitle(int count) {
    return 'Lägga till $count kontakter?';
  }

  @override
  String discoveredContacts_roomLeft(int room) {
    return 'Radion har plats för $room kontakter till.';
  }

  @override
  String discoveredContacts_roomLimit(int room, int count) {
    return 'Radion har plats för $room kontakter till, så bara de första $room av $count läggs till.';
  }

  @override
  String discoveredContacts_adding(int done, int total) {
    return 'Lägger till $done av $total…';
  }

  @override
  String discoveredContacts_addedMany(int count) {
    return 'Tillagda kontakter: $count';
  }

  @override
  String discoveredContacts_addedSome(int added, int failed) {
    return 'Tillagda kontakter: $added. Inte tillagda: $failed.';
  }

  @override
  String get discoveredContacts_radioFull =>
      'Radions kontaktlista är full. Ta bort några kontakter först.';

  @override
  String get fieldIntel_radioNow => 'Radion just nu';

  @override
  String get fieldIntel_noRadio => 'Anslut radion för livevärden.';

  @override
  String get fieldIntel_noise => 'brus dBm';

  @override
  String get fieldIntel_lastSnr => 'senaste SNR';

  @override
  String get fieldIntel_lastRssi => 'senaste RSSI';

  @override
  String get fieldIntel_battery => 'batteri V';

  @override
  String fieldIntel_airtime(String sent, String received) {
    return 'Sändtid sedan radion startade: skickat $sent, mottaget $received';
  }

  @override
  String get fieldIntel_whoAround => 'Vilka finns i närheten';

  @override
  String get fieldIntel_m15 => '15 min';

  @override
  String get fieldIntel_h1 => '1 timme';

  @override
  String get fieldIntel_h24 => '24 timmar';

  @override
  String get fieldIntel_older => 'Äldre';

  @override
  String get fieldIntel_lastHour => 'Senaste timmen';

  @override
  String get fieldIntel_chartHint =>
      'När varje nod senast hördes, timme för timme under det senaste dygnet. Tryck på en stapel för att se vilka.';

  @override
  String get fieldIntel_mix => 'Nodtyper';

  @override
  String get fieldIntel_reach => 'Räckvidd';

  @override
  String get fieldIntel_hops1 => '1 hopp';

  @override
  String get fieldIntel_hops2 => '2 hopp';

  @override
  String get fieldIntel_hops3 => '3+ hopp';

  @override
  String get fieldIntel_noRoute => 'Ingen rutt än';

  @override
  String get fieldIntel_distance => 'Närmast och längst bort';

  @override
  String get fieldIntel_noneLocated =>
      'Ingen av dina kontakter har en position.';

  @override
  String get fieldIntel_noPosition =>
      'Radion har ingen position än, så avstånd kan inte räknas ut.';

  @override
  String get fieldIntel_bestRepeaters => 'Bästa repeatrar du hör direkt';

  @override
  String get fieldIntel_noneDirect =>
      'Ingen repeater hörd direkt de senaste 30 minuterna.';

  @override
  String get fieldIntel_attention => 'Behöver uppmärksamhet';

  @override
  String get fieldIntel_allGood => 'Inget behöver uppmärksamhet.';

  @override
  String fieldIntel_lowBattery(String volts) {
    return 'Svagt batteri: $volts V';
  }

  @override
  String fieldIntel_quietFavorite(String ago) {
    return 'Favorit inte hörd sedan $ago';
  }

  @override
  String get fieldIntel_moreTools => 'Fler verktyg';

  @override
  String fieldIntel_nodeCount(int count) {
    return 'Noder: $count';
  }

  @override
  String get fieldIntel_none => 'Inga noder.';

  @override
  String fieldIntel_lastHeard(String ago) {
    return 'Senast hörd $ago';
  }

  @override
  String get fieldIntel_showOnMap => 'Visa på karta';

  @override
  String get fieldIntel_openChat => 'Öppna chatt';

  @override
  String get repeaterTools_login => 'Logga in';

  @override
  String get repeaterTools_heardDirect => 'Hörd direkt';

  @override
  String get repeaterTools_filterAll => 'Alla';

  @override
  String get repeaterTools_filterLowBattery => 'Svagt batteri';

  @override
  String get repeaterTools_hint =>
      'Tryck på en repeater för detaljer och logga in därifrån för status, grannar, telemetri och kommandoraden.';

  @override
  String get repeaterTools_noneMatch => 'Inga repeatrar här.';

  @override
  String get repeaterTools_toolsTitle => 'Verktyg';

  @override
  String get repeaterTools_regionSetupHint =>
      'Slå upp regionträdet för ditt område och kopiera dess kommandon';

  @override
  String get routes_failingOnly => 'Endast misslyckade rutter';

  @override
  String get routes_contactDetails => 'Kontaktuppgifter';

  @override
  String get links_contactTitle => 'Lägga till en kontakt?';

  @override
  String get links_importAdvert => 'Lägga till den här kontakten i radion?';

  @override
  String get links_connectFirst =>
      'Anslut radion först och öppna sedan länken igen.';

  @override
  String get links_added => 'Kontakt tillagd';

  @override
  String get links_notContact => 'Den här länken är ingen MeshCore-kontakt.';

  @override
  String get radioBuzzer_title => 'Radions summer';

  @override
  String get radioBuzzer_hint =>
      'Radion piper vid nya meddelanden. Visas bara för radior med summer.';

  @override
  String get radioBuzzer_failed => 'Radion godtog inte ändringen. Försök igen.';

  @override
  String get appSettings_floodAttempts => 'Flood-försök';

  @override
  String get appSettings_floodAttemptsSubtitle =>
      'Extra försök som skickas som flood när de direkta misslyckas, ifall rutten har ändrats. Varje försök tar mer sändtid. 0 stänger av dem.';

  @override
  String get pathGraph_you => 'Du';

  @override
  String pathGraph_relayed(int count) {
    return 'Vidarebefordrade $count meddelanden';
  }

  @override
  String get pathGraph_ambiguousNote =>
      'Det här korta ID:t matchar mer än en repeater och kan inte knytas till en.';

  @override
  String get pathGraph_comesFrom => 'Kommer från';

  @override
  String get pathGraph_goesTo => 'Går till';

  @override
  String get pathGraph_repeaterDetails => 'Repeaterdetaljer';

  @override
  String get pathGraph_days7 => '7 dagar';

  @override
  String get pathGraph_empty =>
      'Inga kanalmeddelandevägar under perioden än. Vägar samlas från mottagna kanalmeddelanden medan spårning är på.';

  @override
  String pathGraph_summary(int paths, int repeaters) {
    return '$paths vägar hörda · $repeaters repeatrar';
  }

  @override
  String get pathGraph_hashOnly =>
      'Varje hopp visas med sitt hashprefix, eller namnet om du känner repeatern.';

  @override
  String pathGraph_matched(int count) {
    return '$count korta (1-byte) hopp kopplade till en viss repeater via längre vägar.';
  }

  @override
  String pathGraph_matchedAmbiguous(int matched, int ambiguous) {
    return '$matched korta (1-byte) hopp kopplade till en viss repeater via längre vägar · $ambiguous fortfarande tvetydiga (markerade ?).';
  }

  @override
  String get pathGraph_chartHint =>
      'Vänster: repeatrar längre bort. Höger: du. Bandets bredd är hur många meddelanden som tog det hoppet. Tryck på en ruta för att se repeatern.';

  @override
  String get pathGraph_busiest => 'Mest belastade repeatrar';

  @override
  String pathGraph_chartSemantics(String name, int count) {
    return 'Väggraf. Mest belastad repeater $name, vidarebefordrade $count meddelanden.';
  }

  @override
  String diag_copied(String label) {
    return 'Kopierat: $label';
  }

  @override
  String get diag_noChannels => 'Inga kanaler på radion.';

  @override
  String get diag_tapToCopy =>
      'Tryck på ett värde för att kopiera det. Dra nedåt för att uppdatera.';

  @override
  String get diag_storage => 'Lagring';

  @override
  String diag_storageValue(int used, int total) {
    return '$used av $total KB';
  }

  @override
  String get rxLog_title => 'RX-logg';

  @override
  String get rxLog_hint => 'Varje paket din radio hör, live';

  @override
  String get rxLog_empty =>
      'Inga paket än. Paket som din radio hör visas här när de kommer in.';

  @override
  String get rxLog_note =>
      'Bara i minnet, de senaste 2 000 paketen. Inget sparas eller skickas.';

  @override
  String get rxLog_pause => 'Pausa';

  @override
  String get rxLog_resume => 'Fortsätt';

  @override
  String get rxLog_export => 'Exportera CSV';

  @override
  String get rxLog_clearConfirm => 'Rensa RX-loggen?';

  @override
  String rxLog_count(int shown, int total) {
    return '$shown visade · $total hörda';
  }

  @override
  String get rxLog_paused => 'Pausad: nya paket loggas inte';

  @override
  String get rxLog_kindAll => 'Alla';

  @override
  String get rxLog_kindAdvert => 'Adverts';

  @override
  String get rxLog_kindChannel => 'Kanal';

  @override
  String get rxLog_kindDirect => 'Direkt';

  @override
  String get rxLog_kindAck => 'ACK';

  @override
  String get rxLog_kindPath => 'Vägar';

  @override
  String get rxLog_kindTrace => 'Spårningar';

  @override
  String get rxLog_kindControl => 'Styrning';

  @override
  String get rxLog_kindOther => 'Övrigt';

  @override
  String get rxLog_routeFlood => 'Flood';

  @override
  String get rxLog_routeDirect => 'Direkt rutt';

  @override
  String get rxLog_heardDirectly => 'Hörd direkt';

  @override
  String rxLog_hops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hopp',
      one: '1 hopp',
    );
    return '$_temp0';
  }

  @override
  String rxLog_bytes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count byte',
      one: '1 byte',
    );
    return '$_temp0';
  }

  @override
  String get rxLog_own => 'Din radio';

  @override
  String rxLog_signal(String snr, int rssi) {
    return 'SNR $snr · $rssi dBm';
  }

  @override
  String get rxLog_signalTitle => 'Signal';

  @override
  String get rxLog_route => 'Rutt';

  @override
  String get rxLog_path => 'Väg';

  @override
  String get rxLog_payloadType => 'Nyttolasttyp';

  @override
  String get rxLog_hash => 'Pakethash';

  @override
  String get rxLog_raw => 'Råpaket';

  @override
  String get rxLog_copyHex => 'Kopiera hex';

  @override
  String get deliv_title => 'Leveransdetaljer';

  @override
  String get deliv_note => 'Beräknat från det som sparats med meddelandet.';

  @override
  String get deliv_queued => 'I kö';

  @override
  String get deliv_sent => 'Skickat av din radio';

  @override
  String get deliv_notSent => 'Inte mottaget av din radio';

  @override
  String get deliv_attempts => 'Försök';

  @override
  String deliv_attemptsValue(int made, int total) {
    return '$made av $total';
  }

  @override
  String deliv_plan(int direct, int flood) {
    return 'Plan: $direct direkt, sedan $flood via flood';
  }

  @override
  String get deliv_lastRoute => 'Senaste rutt';

  @override
  String get deliv_routeFlood => 'Flood via alla repeatrar';

  @override
  String get deliv_routeNeighbor => 'Direkt, inga repeatrar';

  @override
  String deliv_routeVia(String path) {
    return 'Direkt via $path';
  }

  @override
  String get deliv_confirmed => 'Mottagning bekräftad';

  @override
  String deliv_tripTime(String seconds) {
    return 'Tur och retur $seconds s';
  }

  @override
  String get deliv_waiting => 'Väntar på bekräftelse';

  @override
  String get deliv_noConfirm => 'Ingen bekräftelse';

  @override
  String deliv_lastHeard(String name) {
    return '$name senast hörd';
  }

  @override
  String deliv_hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'för $hours timmar sedan',
      one: 'för 1 timme sedan',
    );
    return '$_temp0';
  }

  @override
  String deliv_vDelivered(String name) {
    return 'Levererat. $name bekräftade det.';
  }

  @override
  String deliv_vDeliveredFlood(String name) {
    return 'Levererat via flood efter att de direkta försöken misslyckats. Den sparade rutten till $name kan vara inaktuell.';
  }

  @override
  String deliv_vPending(int attempt, int total) {
    return 'Försöker fortfarande: försök $attempt av $total.';
  }

  @override
  String get deliv_vNotSent =>
      'Din radio tog aldrig emot meddelandet. Kontrollera att den är ansluten och försök igen.';

  @override
  String deliv_vQuiet(String name, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours timmar',
      one: '1 timme',
    );
    return 'Ingen bekräftelse. $name har inte hörts på $_temp0 och kan vara utom räckvidd eller avstängd.';
  }

  @override
  String get deliv_vNoFlood =>
      'Ingen bekräftelse via den sparade rutten, och flood-försök är avstängda. Slå på dem i Inställningar → Appinställningar → Meddelanden, eller försök igen.';

  @override
  String get deliv_vNoAck =>
      'Ingen bekräftelse från någon rutt. Utom räckvidd, eller så kom bekräftelsen inte tillbaka till dig.';

  @override
  String get favReturn_setting => 'Favoriter tillbaka inom räckvidd';

  @override
  String get favReturn_settingHint =>
      'Meddela när en favorit hörs igen efter en tyst period';

  @override
  String get favReturn_off => 'Av';

  @override
  String favReturn_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Efter $count timmar',
      one: 'Efter 1 timme',
    );
    return '$_temp0';
  }

  @override
  String get favReturn_title => 'Tillbaka inom räckvidd';

  @override
  String favReturn_body(String name, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours timmars',
      one: '1 timmes',
    );
    return '$name hörs igen efter $_temp0 tystnad';
  }

  @override
  String get batteryOpt_title => 'Batterioptimering';

  @override
  String get batteryOpt_off =>
      'Av för NOTORYX Core, så aviseringar fungerar i bakgrunden.';

  @override
  String get batteryOpt_on =>
      'På. Android kan stoppa appen i bakgrunden, så SOS-, incheckning- och meddelandeaviseringar kan bli sena eller utebli.';

  @override
  String get batteryOpt_fix => 'Stäng av';

  @override
  String block_sender(String name) {
    return 'Blockera $name';
  }

  @override
  String get block_confirmBody =>
      'Personens kanalmeddelanden döljs på den här enheten och ger aldrig aviseringar. Personen ser fortfarande dina meddelanden. Du kan häva blockeringen i Inställningar.';

  @override
  String get block_action => 'Blockera';

  @override
  String block_done(String name) {
    return '$name blockerad';
  }

  @override
  String get mention_suggestions => 'Namnförslag';

  @override
  String get block_listTitle => 'Blockerade avsändare';

  @override
  String get block_listHint =>
      'Meddelanden från de här namnen döljs i kanaler och ger aldrig aviseringar.';

  @override
  String get block_listEmpty => 'Ingen är blockerad.';

  @override
  String get block_unblock => 'Häv blockering';

  @override
  String block_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blockerade',
      one: '1 blockerad',
      zero: 'Ingen blockerad',
    );
    return '$_temp0';
  }

  @override
  String contactTable_nearlyFull(int percent) {
    return 'Radions kontaktlista $percent % full';
  }

  @override
  String get contactTable_full => 'Radions kontaktlista är full';

  @override
  String contactTable_count(int used, int max) {
    return '$used av $max kontakter';
  }

  @override
  String get contactTable_overwriteHint =>
      'När den är full ersätter radion den kontakt som hörts för längst sedan. Favoriter behålls.';

  @override
  String get contactTable_stopHint =>
      'När den är full slutar radion lägga till nya kontakter den hör.';

  @override
  String get contactTable_freeUp => 'Frigör utrymme';

  @override
  String get contactTable_sheetBody =>
      'Hörda för längst sedan först. Favoriter visas inte.';

  @override
  String contactTable_lastHeard(String when) {
    return 'Senast hörd $when';
  }

  @override
  String contactTable_remove(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ta bort $count kontakter',
      one: 'Ta bort 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get contactTable_confirmBody =>
      'De tas bort från radion och deras meddelanden på den här enheten raderas. Det går inte att ångra.';

  @override
  String contactTable_removed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tog bort $count kontakter',
      one: 'Tog bort 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get contactTable_noneToSuggest =>
      'Alla kontakter är favoriter, så det finns inget att föreslå.';

  @override
  String get adminWait_waiting => 'Väntar på svar';

  @override
  String adminWait_retrying(int attempt, int total) {
    return 'Inget svar än. Försöker igen ($attempt av $total)';
  }

  @override
  String adminWait_direct(int hops) {
    String _temp0 = intl.Intl.pluralLogic(
      hops,
      locale: localeName,
      other: 'Direkt, $hops hopp',
      one: 'Direkt, 1 hopp',
      zero: 'Direkt',
    );
    return '$_temp0';
  }

  @override
  String adminWait_upTo(int seconds) {
    return 'upp till $seconds s';
  }

  @override
  String get theme_descBlaze => 'Kol och skiffer med signalorange';

  @override
  String get theme_descNeonAnarchy => 'Giftgrönt och elektriskt lila på svart';

  @override
  String get theme_descTactical => 'Oliv, gunmetal och jordtoner';

  @override
  String get theme_descPinkOverload => 'Klarrosa, tuggummirosa och lavendel';

  @override
  String get theme_descBareBeauty => 'Varm nude, gammelrosa, kakao och salvia';

  @override
  String get theme_descOkabeIto => 'Säker vid färgblindhet, mycket tydlig';

  @override
  String get theme_descNightOps => 'Dämpat rött på nästan svart för svagt ljus';

  @override
  String get theme_descSeasonal => 'Växlar med årstider och högtider';

  @override
  String get theme_selected => 'Vald';

  @override
  String get seasonal_season => 'Årstid';

  @override
  String seasonal_auto(String season) {
    return 'Automatisk (nu $season)';
  }

  @override
  String get seasonal_autoHint =>
      'Följer enhetens datum, med norra halvklotets årstider';

  @override
  String get season_spring => 'Vår';

  @override
  String get season_summer => 'Sommar';

  @override
  String get season_autumn => 'Höst';

  @override
  String get season_winter => 'Vinter';

  @override
  String get season_halloween => 'Halloween';

  @override
  String get season_christmas => 'Jul';

  @override
  String get season_valentine => 'Alla hjärtans dag';

  @override
  String get seasonal_holidays => 'Högtidsfärger';

  @override
  String get seasonal_holidaysHint =>
      'Halloween, jul och alla hjärtans dag på sina datum';

  @override
  String get coords_setting => 'Koordinatformat';

  @override
  String get coords_decimal => 'Decimalgrader';

  @override
  String get coords_dms => 'Grader, minuter, sekunder';

  @override
  String get coords_utm => 'UTM';

  @override
  String get coords_mgrs => 'MGRS';

  @override
  String get coords_copyTitle => 'Kopiera position';

  @override
  String coords_copied(String format) {
    return 'Kopierad som $format';
  }

  @override
  String pathHash_badge(int width) {
    return 'Rutten använder $width-byte sökvägshashar';
  }

  @override
  String pathHash_mismatch(int width) {
    return 'Din radio använder $width byte';
  }

  @override
  String get lite_qrPasteHint =>
      'Den här versionen har ingen kameraskanner. Klistra in texten från QR-koden i stället.';

  @override
  String get lite_qrPasteLabel => 'QR-kodens text';

  @override
  String get theme_darkMode => 'Annat tema i mörkt läge';

  @override
  String get theme_darkModeHint =>
      'Använd ett annat tema när enheten är i mörkt läge';

  @override
  String get theme_darkModeTheme => 'Tema i mörkt läge';

  @override
  String get batteryWatch_title => 'Batteribevakning';

  @override
  String get batteryWatch_toolSubtitle =>
      'Repeaterbatterier de senaste 30 dagarna';

  @override
  String get batteryWatch_empty =>
      'Inga batterivärden från repeatrar än. Öppna Status eller Telemetri för en repeater så sparas dess värden här i 30 dagar.';

  @override
  String get batteryWatch_note =>
      'Värdena kommer från Status- och Telemetrisvar som du begär. Inget extra sänds ut.';

  @override
  String get batteryWatch_statusLow => 'Lågt batteri';

  @override
  String get batteryWatch_statusFalling => 'Sjunker snabbt';

  @override
  String get batteryWatch_statusQuiet => 'Inget nytt värde';

  @override
  String get batteryWatch_statusOk => 'Ser bra ut';

  @override
  String get batteryWatch_statusUnknown => 'Inte tillräckligt med värden än';

  @override
  String batteryWatch_emptyIn(String days) {
    return 'Tomt om ungefär $days dagar i den här takten';
  }

  @override
  String batteryWatch_trend(String volts) {
    return '$volts V per dag den senaste veckan';
  }

  @override
  String batteryWatch_lastReading(String age) {
    return 'Senaste värde: $age';
  }

  @override
  String batteryWatch_readings(int count) {
    return 'Värden på 30 dagar: $count';
  }

  @override
  String get batteryWatch_history => 'Batterihistorik';

  @override
  String batteryWatch_chartLabel(int count, String low, String high) {
    return 'Batteridiagram: $count värden, mellan $low V och $high V';
  }

  @override
  String get batteryWatch_clear => 'Rensa historik';

  @override
  String get batteryWatch_unknownRepeater => 'Okänd repeater';

  @override
  String get batteryWatch_cleared => 'Historiken rensad';

  @override
  String get a11y_clear => 'Rensa';

  @override
  String get a11y_showOnMap => 'Visa på kartan';

  @override
  String get a11y_showHide => 'Visa eller dölj';

  @override
  String get a11y_flash => 'Blixt';

  @override
  String get a11y_switchCamera => 'Byt kamera';

  @override
  String get a11y_pauseGif => 'Spela upp eller pausa GIF';

  @override
  String get a11y_chooseGif => 'Välj denna GIF';

  @override
  String get privacy_title => 'Integritet';

  @override
  String get privacy_toolSubtitle =>
      'Vad meshen, den här telefonen och internet kan se';

  @override
  String get privacy_meshHeading => 'På meshen';

  @override
  String get privacy_dmTitle => 'Direktmeddelanden';

  @override
  String get privacy_dmBody =>
      'Krypterade mellan din radio och mottagarens. Repeatrar skickar dem vidare men kan inte läsa dem. Korta avsändar- och mottagar-ID:n och vägen går okrypterat.';

  @override
  String get privacy_channelTitle => 'Kanaler';

  @override
  String get privacy_channelBody =>
      'Krypterade med kanalens nyckel: den som har nyckeln läser alla meddelanden. Nycklar till offentliga kanaler och hashtagkanaler känner alla till, så behandla dem som offentliga.';

  @override
  String get privacy_advertTitle => 'Annonser och positioner';

  @override
  String get privacy_advertBody =>
      'Radions namn och publika nyckel, och dess position om du delar den, sänds okrypterat till alla inom räckhåll.';

  @override
  String get privacy_phoneHeading => 'På den här telefonen';

  @override
  String get privacy_phoneBody =>
      'Meddelanden, kontakter, vägar, spårloggar, vägpunkter, batterihistorik och inställningar stannar i appens privata lagring, skyddade bara av telefonens egen säkerhet. Allt du exporterar kan läsas av den som har filen.';

  @override
  String get privacy_netHeading => 'Över internet';

  @override
  String get privacy_netIntro =>
      'Bara när du använder funktionen som behöver det. Varje förfrågan visar tjänsten din IP-adress och vad som begärdes.';

  @override
  String get privacy_netMaps =>
      'Kartor: rutor från OpenStreetMap, eller Stadia Maps om du väljer det, för området du tittar på.';

  @override
  String get privacy_netTerrain =>
      'Terräng: höjddata från Open-Meteo för täckning och siktlinje.';

  @override
  String get privacy_netModels =>
      'Nedladdningar: översättnings- och bildmodeller från Hugging Face.';

  @override
  String get privacy_netImages =>
      'Bilder: GIF-sökning hos Giphy och bilder från pyx.li-länkar i meddelanden.';

  @override
  String get privacy_netLists =>
      'Listor: regionala förval och kanalkatalogen från appens release-arkiv på GitHub.';

  @override
  String get privacy_netMqtt =>
      'MQTT: bara de mäklare du lägger till. Om du slår på uppladdning publiceras paket som radion hör där. Lösenord sparas i telefonens säkra lagring.';

  @override
  String get privacy_netAnalyzer =>
      'Analysator: CoreScope-uppslag (vem som hörde ett paket, repeaternamn) när du använder dem.';

  @override
  String get privacy_notHeading => 'Vad NOTORYX inte gör';

  @override
  String get privacy_notBody =>
      'Inget konto, ingen analys, inga annonser och inga kraschrapporter. Utvecklarna får ingenting om du inte själv skickar det.';

  @override
  String get team_title => 'Lagspårning';

  @override
  String get team_hint =>
      'Delar din position i en privat kanal medan turen pågår, så att laget ser dig på kartan. Stängs av när turen slutar eller efter 12 timmar.';

  @override
  String get team_channel => 'Kanal';

  @override
  String get team_noChannel =>
      'Lägg först till en privat kanal. Spårning postar aldrig i offentliga eller hashtagkanaler.';

  @override
  String get team_every => 'Var';

  @override
  String team_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get team_needTrip => 'Starta turen för att dela din position.';

  @override
  String team_lastShared(String age) {
    return 'Senast delad $age';
  }

  @override
  String get team_waitingGps => 'Väntar på en position från radion';

  @override
  String get checklist_title => 'Checklistor';

  @override
  String get checklist_toolSubtitle =>
      'Återanvändbara listor före tur och vid utplacering, fungerar offline';

  @override
  String get checklist_empty => 'Inga listor. Lägg till med knappen nedan.';

  @override
  String get checklist_add => 'Ny checklista';

  @override
  String get checklist_edit => 'Redigera checklista';

  @override
  String get checklist_name => 'Namn';

  @override
  String get checklist_items => 'Punkter, en per rad';

  @override
  String checklist_itemCount(int count) {
    return 'Punkter: $count';
  }

  @override
  String get checklist_history => 'Avslutade genomgångar';

  @override
  String get checklist_noRuns => 'Inga avslutade genomgångar än.';

  @override
  String get checklist_inProgress => 'Pågår';

  @override
  String checklist_progress(int done, int total) {
    return '$done av $total klara';
  }

  @override
  String checklist_startedAt(String time) {
    return 'Startad $time';
  }

  @override
  String checklist_finishedAt(String time) {
    return 'Klar $time';
  }

  @override
  String get checklist_note => 'Anteckning';

  @override
  String get checklist_finish => 'Avsluta och spara';

  @override
  String get checklist_unfinished =>
      'Alla punkter är inte bockade. Spara ändå?';

  @override
  String get checklist_saveAnyway => 'Spara ändå';

  @override
  String get checklist_export => 'Exportera eller ta bort';

  @override
  String get checklist_exportText => 'Dela som text';

  @override
  String get checklist_exportJson => 'Dela som JSON';

  @override
  String get checklist_exportFailed => 'Kunde inte dela posten.';

  @override
  String get checklist_deleteRun => 'Ta bort posten';

  @override
  String get checklist_deleteRunConfirm =>
      'Ta bort posten? Det går inte att ångra.';

  @override
  String checklist_deleteConfirm(String name) {
    return 'Ta bort $name? Avslutade poster sparas.';
  }

  @override
  String get checklist_preTrip => 'Före turen';

  @override
  String get checklist_preTrip1 => 'Radion laddad och extrabatteri packat';

  @override
  String get checklist_preTrip2 =>
      'Radion parkopplad med telefonen och testmeddelande skickat';

  @override
  String get checklist_preTrip3 => 'Offlinekartor för området sparade';

  @override
  String get checklist_preTrip4 => 'Rutt och hemkomsttid lämnade hos någon';

  @override
  String get checklist_preTrip5 => 'Gruppkanal och lagkontakter kontrollerade';

  @override
  String get checklist_preTrip6 => 'SOS och incheckning provade en gång';

  @override
  String get checklist_deploy => 'Sätta upp en nod';

  @override
  String get checklist_deploy1 => 'Plats och tillstånd bekräftade';

  @override
  String get checklist_deploy2 => 'Antenn monterad och kontakter tätade';

  @override
  String get checklist_deploy3 => 'Ström och solpanel kontrollerade';

  @override
  String get checklist_deploy4 => 'Radioinställningar och region bekräftade';

  @override
  String get checklist_deploy5 => 'Testmeddelande hört via noden';

  @override
  String get checklist_deploy6 => 'Plats, foton och anteckningar sparade';

  @override
  String get waypoints_title => 'Vägpunkter';

  @override
  String get waypoints_toolSubtitle =>
      'Sparade platser och rutter; importera eller exportera GPX';

  @override
  String get waypoints_importFile => 'Importera kartfil (GPX, KML, GeoJSON)';

  @override
  String get waypoints_importPaste => 'Klistra in GPX, KML eller GeoJSON';

  @override
  String get waypoints_export => 'Exportera GPX';

  @override
  String get waypoints_empty =>
      'Inga vägpunkter än. Importera en GPX-fil eller spara en plats som någon delat i en chatt.';

  @override
  String waypoints_waypoints(int count) {
    return 'Vägpunkter ($count)';
  }

  @override
  String waypoints_routes(int count) {
    return 'Rutter ($count)';
  }

  @override
  String waypoints_routeSummary(int points, String km) {
    return '$points punkter · $km km';
  }

  @override
  String get waypoints_delete => 'Ta bort';

  @override
  String get waypoints_copy => 'Kopiera koordinater';

  @override
  String get waypoints_sendToChannel => 'Skicka till en kanal';

  @override
  String get waypoints_pickChannel => 'Skicka till vilken kanal?';

  @override
  String waypoints_sent(String channel) {
    return 'Skickat till $channel';
  }

  @override
  String get waypoints_importFailed =>
      'Det är ingen GPX-, KML- eller GeoJSON-fil som appen kan läsa.';

  @override
  String get waypoints_pasteHint => 'Klistra in GPX-texten här';

  @override
  String get waypoints_import => 'Importera';

  @override
  String waypoints_imported(int waypoints, int routes) {
    return 'La till $waypoints vägpunkter och $routes rutter';
  }

  @override
  String get waypoints_save => 'Spara som vägpunkt';

  @override
  String get waypoints_unnamed => 'Delad plats';

  @override
  String get waypoints_saved => 'Sparad i Vägpunkter';

  @override
  String get waypoints_alreadySaved => 'Redan i Vägpunkter';

  @override
  String get netChange_title => 'Nätverksändringar';

  @override
  String get netChange_toolSubtitle =>
      'Repeatrar som dök upp nära eller tystnade';

  @override
  String netChange_newDirect(String name) {
    return 'Ny repeater hörd direkt: $name';
  }

  @override
  String netChange_newHops(String name, int hops) {
    return 'Ny repeater $hops hopp bort: $name';
  }

  @override
  String netChange_wentQuiet(String name, int hours) {
    return '$name har tystnat: inte hörd på $hours h';
  }

  @override
  String get netChange_empty =>
      'Inga ändringar än. Favoritrepeatrar som tystnar och nya repeatrar i närheten visas här.';

  @override
  String get netChange_quietSetting => 'Favoritrepeater tystnar';

  @override
  String get netChange_quietHint =>
      'Avisera när en favoritrepeater inte hörts så här länge';

  @override
  String get netChange_newSetting => 'Ny repeater i närheten';

  @override
  String get netChange_newHint =>
      'Avisera när en okänd repeater hörs inom ett hopp';

  @override
  String get netChange_clear => 'Rensa';

  @override
  String get netChange_notifTitle => 'Nätverksändring';

  @override
  String get journal_title => 'Noddagbok';

  @override
  String get journal_toolSubtitle =>
      'Varje nod som hörts, med beteende, taggar och anteckningar';

  @override
  String get journal_empty =>
      'Inga noder än. Varje nod som radion hör läggs till här automatiskt.';

  @override
  String get journal_search => 'Sök namn, ID, taggar och anteckningar';

  @override
  String get journal_filterAll => 'Alla';

  @override
  String get journal_bSteadyRelay => 'Alltid-på-relä';

  @override
  String get journal_bRegular => 'Stamgäst';

  @override
  String get journal_bRoamer => 'Vandrare';

  @override
  String get journal_bRarelyHeard => 'Sällan hörd';

  @override
  String get journal_bNewcomer => 'Nykomling';

  @override
  String get journal_bGoneQuiet => 'Tystnat';

  @override
  String journal_confidence(int percent) {
    return '$percent % säker';
  }

  @override
  String journal_eDaysHeard(int heard, int days) {
    return 'Hörd $heard av $days dagar';
  }

  @override
  String journal_eFirstHeard(int hours) {
    return 'Först hörd för $hours h sedan';
  }

  @override
  String journal_eSilent(int days) {
    return 'Inte hörd på $days dagar';
  }

  @override
  String journal_ePlaces(int places, int km) {
    return 'Sedd på $places platser upp till $km km isär';
  }

  @override
  String journal_eSightings(int count) {
    return '$count nya annonser totalt';
  }

  @override
  String get journal_noLabel => 'Inte nog sett än för en etikett.';

  @override
  String journal_firstSeen(String time) {
    return 'Först hörd: $time';
  }

  @override
  String journal_lastSeen(String time) {
    return 'Senast hörd: $time';
  }

  @override
  String journal_hops(int min, int max) {
    return 'Hopp: $min till $max';
  }

  @override
  String get journal_tags => 'Taggar';

  @override
  String get journal_addTag => 'Lägg till tagg';

  @override
  String get journal_tagHint => 't.ex. led, klubb, min';

  @override
  String journal_removeTag(String tag) {
    return 'Ta bort taggen $tag';
  }

  @override
  String get journal_note => 'Anteckning';

  @override
  String get journal_saveNote => 'Spara anteckning';

  @override
  String get journal_forget => 'Glöm den här noden';

  @override
  String journal_forgetConfirm(String name) {
    return 'Ta bort $name ur dagboken med taggar och anteckning? Hörs den igen börjar den om.';
  }

  @override
  String get journal_forgotten => 'Noden togs bort ur dagboken.';

  @override
  String journal_markLabel(String name) {
    return 'Genererat märke för $name';
  }

  @override
  String get trouble_title => 'Felsökning';

  @override
  String get trouble_toolSubtitle =>
      'Steg-för-steg-hjälp när något inte fungerar';

  @override
  String get trouble_pick => 'Vad är fel?';

  @override
  String get trouble_noDelivery => 'Meddelanden levereras inte';

  @override
  String get trouble_noConnect => 'Jag kan inte ansluta till radion';

  @override
  String get trouble_hearNobody => 'Jag hör ingen';

  @override
  String get trouble_startHere => 'Börja här';

  @override
  String get trouble_resultOk => 'OK';

  @override
  String get trouble_resultProblem => 'Problem';

  @override
  String get trouble_resultUnchecked => 'Kan inte kontrolleras';

  @override
  String get trouble_connectedNow =>
      'Du är ansluten nu. Om anslutningen fortsätter att tappas hjälper stegen nedan ändå.';

  @override
  String get trouble_allOk =>
      'Alla kontroller gick bra. Om det ändå inte fungerar är stegen nedan värda en titt.';

  @override
  String get trouble_connected => 'Din radio är ansluten';

  @override
  String get trouble_connectedAdvice =>
      'Anslut din radio först: Inställningar → Anslut en radio.';

  @override
  String get trouble_routes => 'Vägar är kända till dem du skriver till';

  @override
  String get trouble_routesAdvice =>
      'Meddelanden till någon utan känd väg floodas över hela meshen och kommer ofta inte fram. Vänta tills de annonserar sig, eller be dem, och skriv igen.';

  @override
  String get trouble_heardRecently =>
      'De du skriver till har hörts det senaste dygnet';

  @override
  String get trouble_heardRecentlyAdvice =>
      'Den som inte hörts på ett tag kan vara utom räckhåll eller avstängd. Meddelanden kan inte kvitteras förrän de är tillbaka.';

  @override
  String get trouble_neighbours => 'Din radio hör andra noder';

  @override
  String get trouble_neighboursAdvice =>
      'Hörs inget direkt når din radio inte meshen härifrån. Höj antennen, gå högre eller närmare en repeater.';

  @override
  String get trouble_bluetooth => 'Bluetooth är på och appen får använda det';

  @override
  String get trouble_bluetoothAdvice =>
      'Kontrollera att Bluetooth är på och att NOTORYX Core har behörighet för Bluetooth (och på Android Enheter i närheten) i telefonens inställningar.';

  @override
  String get trouble_otherApp =>
      'Ingen annan telefon eller app är ansluten till radion';

  @override
  String get trouble_otherAppAdvice =>
      'En radio pratar med en app i taget. Stäng andra MeshCore-appar eller stäng av Bluetooth på andra parkopplade telefoner.';

  @override
  String get trouble_inRange => 'Radion är på och i närheten';

  @override
  String get trouble_inRangeAdvice =>
      'Kontrollera att radion är laddad, påslagen och inom några meter. En omstart av radion löser ofta en låst anslutning.';

  @override
  String get trouble_otherTransport => 'Prova ett annat sätt att ansluta';

  @override
  String get trouble_otherTransportAdvice =>
      'Om Bluetooth fortsätter att misslyckas, anslut med USB-kabel eller via Wi-Fi (TCP) om radion stöder det.';

  @override
  String get trouble_noise => 'Radion dränks inte i brus';

  @override
  String get trouble_noiseAdvice =>
      'Ett högt brusgolv döljer svaga signaler. Flytta antennen från elektronik, laddare och solcellsregulatorer.';

  @override
  String get trouble_region => 'Din radio använder ditt områdes inställningar';

  @override
  String get trouble_regionAdvice =>
      'Med annan frekvens, bandbredd eller spridningsfaktor än det lokala meshen hör du ingen. Jämför Inställningar → Radio med vad ditt område använder.';

  @override
  String get trouble_antenna => 'Antennen sitter på';

  @override
  String get trouble_antennaAdvice =>
      'Se till att antennen är ordentligt fastskruvad. Sänd aldrig utan antenn; det kan skada radion.';

  @override
  String get mesh_title => 'Meshhälsa';

  @override
  String get mesh_overallGood => 'Meshen ser frisk ut';

  @override
  String get mesh_overallFair => 'Meshen fungerar, med vissa problem';

  @override
  String get mesh_overallPoor => 'Meshen har det svårt';

  @override
  String get mesh_overallUnknown => 'För lite data än';

  @override
  String get mesh_gradeGood => 'Bra';

  @override
  String get mesh_gradeFair => 'Medel';

  @override
  String get mesh_gradePoor => 'Dålig';

  @override
  String get mesh_gradeUnknown => 'Ingen data';

  @override
  String get mesh_noise => 'Brus';

  @override
  String mesh_noiseValue(String dbm) {
    return 'Brusgolv $dbm dBm';
  }

  @override
  String get mesh_signal => 'Senaste signal';

  @override
  String mesh_signalValue(String db) {
    return 'SNR $db dB';
  }

  @override
  String get mesh_busy => 'Kanalanvändning';

  @override
  String mesh_busyValue(int percent) {
    return 'i luften $percent % av de senaste 15 minuterna';
  }

  @override
  String get mesh_neighbours => 'Hörda direkt';

  @override
  String mesh_neighboursValue(int count) {
    return '$count noder senaste timmen';
  }

  @override
  String get mesh_delivery => 'Direktmeddelanden';

  @override
  String mesh_deliveryValue(int delivered, int total) {
    return '$delivered av $total levererade senaste dygnet';
  }

  @override
  String get mesh_tipNoise =>
      'Något i närheten brusar på den här frekvensen. Flytta antennen från elektronik och laddare.';

  @override
  String get mesh_tipSignal =>
      'Senaste paketet var svagt. Höj antennen eller gå högre upp.';

  @override
  String get mesh_tipBusy =>
      'Kanalen är upptagen. Håll meddelanden korta och undvik floods.';

  @override
  String get mesh_tipNeighbours =>
      'Få noder hörs direkt. Höj antennen eller gå närmare en repeater.';

  @override
  String get mesh_tipDelivery =>
      'Många meddelanden kvitteras inte. Öppna ett misslyckat meddelande för att se var det stannade.';

  @override
  String routeHealth_staleTitle(String name) {
    return 'Vägen till $name kan vara inaktuell';
  }

  @override
  String routeHealth_weakTitle(String name) {
    return 'Vägen till $name är opålitlig';
  }

  @override
  String routeHealth_lastWorkedHours(int hours) {
    return 'fungerade senast för $hours h sedan';
  }

  @override
  String routeHealth_lastWorkedDays(int days) {
    return 'fungerade senast för $days dagar sedan';
  }

  @override
  String routeHealth_notHeard(int days) {
    return 'inte hörd på $days dagar';
  }

  @override
  String routeHealth_failures(int failures, int attempts) {
    return '$failures av $attempts försök misslyckades';
  }

  @override
  String routeHealth_longPath(int hops) {
    return '$hops hopp';
  }

  @override
  String get routeHealth_useFlood => 'Hitta en ny väg';

  @override
  String get routeHealth_keep => 'Behåll vägen';

  @override
  String get readiness_sos => 'SOS-mottagare';

  @override
  String get readiness_sosOk => 'SOS har mottagare.';

  @override
  String get readiness_sosBlocked =>
      'SOS har ingen att nå. Lägg till turkontakter som finns bland dina kontakter, eller välj en SOS-kanal.';

  @override
  String get readiness_routes => 'Vägar till turkontakter';

  @override
  String get readiness_routesOk => 'En väg är känd till varje turkontakt.';

  @override
  String readiness_routesMissing(String names) {
    return 'Ingen känd väg till $names. Meddelanden floodas tills en väg lärs in. Skicka ett meddelande till dem innan du går.';
  }

  @override
  String get readiness_notifications => 'Aviseringar';

  @override
  String get readiness_notificationsOk => 'Tillåtna.';

  @override
  String get readiness_notificationsOff =>
      'Aviseringar är avstängda, så du hör inga svar, incheckningar eller larm.';

  @override
  String get readiness_batteryOpt => 'Batterioptimering';

  @override
  String get readiness_batteryOptOk => 'NOTORYX Core är undantaget.';

  @override
  String get readiness_batteryOptOn =>
      'Android kan stoppa appen i bakgrunden. Stäng av det under Inställningar → Appinställningar → Aviseringar.';

  @override
  String get readiness_blockedTitle => 'Turen kan inte starta än';

  @override
  String readiness_warnTitle(int count) {
    return '$count saker att kolla';
  }

  @override
  String get readiness_startAnyway => 'Starta ändå';

  @override
  String get readiness_review => 'Granska';

  @override
  String get readiness_summaryReady => 'Redo att gå';

  @override
  String readiness_summaryWarn(int count) {
    return '$count att kolla';
  }

  @override
  String get readiness_summaryBlocked => 'SOS når ingen';

  @override
  String get coords_maidenhead => 'Maidenhead-lokator';

  @override
  String get reactions_radioTitle => 'Skicka reaktioner via radio';

  @override
  String get reactions_radioHint =>
      'Varje reaktion är ett paket i luften. Automatiskt behåller dem på den här enheten på EU:s 868 MHz-band, där sändningstiden är begränsad.';

  @override
  String get reactions_radioAuto => 'Automatiskt';

  @override
  String get reactions_radioOn => 'På';

  @override
  String get reactions_radioOff => 'Av (den här enheten)';

  @override
  String get batteryWatch_auto => 'Kontrollera automatiskt';

  @override
  String get batteryWatch_autoHint =>
      'Medan en radio är ansluten frågar appen regelbundet den här repeatern om batteriet. Den svarar bara om du är inloggad.';

  @override
  String get batteryWatch_interval => 'Kontrollera var';

  @override
  String batteryWatch_hours(int hours) {
    return '$hours h';
  }

  @override
  String get batteryWatch_budget =>
      'Högst 6 kontroller i timmen för alla repeatrar, minst 2 minuter isär.';

  @override
  String get batteryWatch_add => 'Lägg till repeater';

  @override
  String get batteryWatch_pick => 'Välj en repeater att bevaka';

  @override
  String get batteryWatch_noRepeaters =>
      'Inga repeatrar bland dina kontakter än.';

  @override
  String batteryWatch_noReply(int count) {
    return 'Inget svar på de senaste $count kontrollerna. Öppna repeatern och logga in igen.';
  }

  @override
  String get batteryWatch_checking => 'Kontrollerar…';

  @override
  String get batteryWatch_alertTitle => 'Repeaterbatteri';

  @override
  String batteryWatch_alertLow(String name, int percent, String volts) {
    return '$name ligger på $percent % ($volts V).';
  }

  @override
  String batteryWatch_alertFalling(String name, String days) {
    return 'Batteriet i $name sjunker snabbt: tomt om ungefär $days dagar i den här takten.';
  }

  @override
  String batteryWatch_alertSilent(String name, int count) {
    return '$name har inte svarat på $count batterikontroller.';
  }

  @override
  String get security_title => 'Säkerhet';

  @override
  String get security_toolSubtitle => 'Applås och krypterad meddelandehistorik';

  @override
  String get appLock_title => 'Applås';

  @override
  String get appLock_subtitle =>
      'Frågar efter fingeravtryck, ansikte eller skärmlås när appen öppnas. Varningar fungerar, och SOS finns kvar på låsskärmen.';

  @override
  String get appLock_reason => 'Lås upp NOTORYX Core';

  @override
  String get appLock_unlock => 'Lås upp';

  @override
  String get appLock_locked => 'NOTORYX Core är låst';

  @override
  String get appLock_unavailable =>
      'Enheten har inget skärmlås, eller så kunde det inte bekräftas.';

  @override
  String get dbEncrypt_title => 'Kryptera meddelandehistoriken';

  @override
  String get dbEncrypt_subtitle =>
      'Krypterar meddelandedatabasen på enheten med en nyckel i telefonens säkra lagring. Om nyckeln försvinner går historiken inte att återställa, så behåll en säkerhetskopia.';

  @override
  String get dbEncrypt_on => 'Status: krypterad';

  @override
  String get dbEncrypt_off => 'Status: inte krypterad';

  @override
  String get dbEncrypt_failed => 'Status: gick inte. Historiken är oförändrad.';

  @override
  String get dbEncrypt_restart => 'Börjar gälla nästa gång appen startas.';

  @override
  String get map_showWaypoints => 'Visa sparade vägpunkter och rutter';

  @override
  String get appLock_sosNoTarget =>
      'Lås upp först och välj vem som får din SOS.';

  @override
  String get notification_replyAction => 'Svara';

  @override
  String get notification_replyHint => 'Skriv ett svar';

  @override
  String outbox_waiting(int count) {
    return 'Väntar på radion: $count';
  }

  @override
  String get outbox_cantQueue =>
      'Ingen radio har anslutits än, så det här kan inte sparas till senare.';

  @override
  String get chat_forward => 'Vidarebefordra';

  @override
  String get forward_title => 'Vidarebefordra till';

  @override
  String get schedule_tooltip => 'Håll in för att skicka senare';

  @override
  String schedule_for(String time) {
    return 'Skickas: $time';
  }

  @override
  String get schedule_pastTime => 'Välj en tid i framtiden.';

  @override
  String get report_open => 'Skicka rapport';

  @override
  String get report_title => 'Fältrapport';

  @override
  String get report_salute => 'SALUTE (vad du såg)';

  @override
  String get report_nineLine => '9-Line (medicinsk evakuering)';

  @override
  String get report_send => 'Skicka rapport';

  @override
  String report_parts(int count) {
    return 'Antal meddelanden: $count';
  }

  @override
  String get report_sent => 'Rapporten skickades';

  @override
  String get contacts_addTooltip => 'Lägg till kontakt';

  @override
  String get dbEncrypt_covers =>
      'Omfattar även kontakter, kanalnycklar, vägpunkter, sparade rutter, utkast och väntande meddelanden.';

  @override
  String get auto_title => 'Automatisering';

  @override
  String get auto_add => 'Lägg till regel';

  @override
  String get auto_intro =>
      'Regler körs bara när appen är öppen. Varje regel utlöses när villkoret börjar gälla, högst en gång per 15 minuter. Regler som skickar meddelanden är totalt begränsade till 3 sändningar per 10 minuter och märks som automatiska.';

  @override
  String get auto_trigBattery => 'Radions batteri sjunker under';

  @override
  String get auto_trigTime => 'Varje dag kl.';

  @override
  String get auto_trigEnter => 'Jag går in i ett område';

  @override
  String get auto_trigLeave => 'Jag lämnar ett område';

  @override
  String get auto_trigHeard => 'En nod hörs igen';

  @override
  String get auto_trigQuiet => 'En nod tystnar';

  @override
  String auto_edit(String name) {
    return 'Redigera $name';
  }

  @override
  String get auto_new => 'Ny regel';

  @override
  String get auto_editTitle => 'Redigera regel';

  @override
  String get auto_delete => 'Ta bort regel';

  @override
  String get auto_needName => 'Ge regeln ett namn.';

  @override
  String get auto_needArea => 'Ange områdets latitud och longitud.';

  @override
  String get auto_needNode => 'Välj en nod.';

  @override
  String get auto_needMessage => 'Skriv meddelandet.';

  @override
  String get auto_needTarget => 'Välj vem som ska få meddelandet.';

  @override
  String get auto_name => 'Regelnamn';

  @override
  String get auto_when => 'När';

  @override
  String auto_below(int percent) {
    return 'Under $percent %';
  }

  @override
  String get auto_time => 'Tid';

  @override
  String get auto_latitude => 'Latitud';

  @override
  String get auto_longitude => 'Longitud';

  @override
  String get auto_usePosition => 'Använd radions position';

  @override
  String auto_radius(int meters) {
    return 'Radie: $meters m';
  }

  @override
  String get auto_node => 'Nod';

  @override
  String auto_heardWithin(int minutes) {
    return 'Räknas som hörd inom $minutes minuter';
  }

  @override
  String get auto_notify => 'Meddela mig';

  @override
  String get auto_send => 'Skicka ett meddelande';

  @override
  String get auto_sendTo => 'Skicka till';

  @override
  String get auto_message => 'Meddelande';

  @override
  String get auto_save => 'Spara';

  @override
  String get auto_entry => 'Automatiseringsregler';

  @override
  String get auto_entrySub =>
      'Utlösare för batteri, tid, område, nod och meddelanden; OCH/ELLER';

  @override
  String get auto_trigMessage => 'Ett meddelande kommer';

  @override
  String get auto_actJoin => 'Gå med i hashtaggkanal';

  @override
  String get auto_actSound => 'Spela ett ljud';

  @override
  String get auto_actWebhook => 'Anropa en webhook';

  @override
  String get auto_outDone => 'Klart';

  @override
  String get auto_outNotConnected => 'Radion är inte ansluten';

  @override
  String get auto_outNoTarget => 'Mottagare eller adress saknas';

  @override
  String get auto_outWebOff => 'Webbförfrågningar är av';

  @override
  String get auto_outWebFailed => 'Webbförfrågan misslyckades';

  @override
  String get auto_outNoSlot => 'Ingen ledig kanalplats';

  @override
  String get auto_outFailed => 'Misslyckades';

  @override
  String get auto_anyone => 'Vem som helst';

  @override
  String get auto_webSwitch => 'Tillåt webbförfrågningar (webhooks)';

  @override
  String get auto_webSwitchSub =>
      'Av som standard. Webhook-åtgärder behöver internet och hoppas över medan detta är av. Allt annat fungerar bara via radio.';

  @override
  String get auto_andJoin => ' och ';

  @override
  String get auto_orJoin => ' eller ';

  @override
  String get auto_needsInternet => 'Kräver internet';

  @override
  String get auto_recent => 'Senaste körningar';

  @override
  String get auto_needCondition => 'Lägg till minst ett villkor.';

  @override
  String get auto_needAction => 'Lägg till minst en åtgärd.';

  @override
  String get auto_conditions => 'Villkor';

  @override
  String get auto_actions => 'Åtgärder';

  @override
  String get auto_addCondition => 'Lägg till villkor';

  @override
  String get auto_addAction => 'Lägg till åtgärd';

  @override
  String auto_remove(String item) {
    return 'Ta bort $item';
  }

  @override
  String get auto_combine => 'Kör regeln när';

  @override
  String get auto_combineAny => 'Något (ELLER)';

  @override
  String get auto_combineAll => 'Alla (OCH)';

  @override
  String get auto_combineAnyHint => 'Körs när något av villkoren inträffar.';

  @override
  String get auto_combineAllHint =>
      'Körs när ett villkor inträffar och alla andra gäller just då, som ”kl. 18:00 OCH batteri under 30 %”.';

  @override
  String get auto_editCondition => 'Villkor';

  @override
  String get auto_editAction => 'Åtgärd';

  @override
  String get auto_done => 'Klar';

  @override
  String get auto_contains => 'Meddelandet innehåller (valfritt)';

  @override
  String get auto_from => 'Från';

  @override
  String get auto_do => 'Gör';

  @override
  String get auto_webhookHint =>
      'Kräver internet. Skickar regelnamn, tid, batteri, nod och text som JSON. Fungerar bara när webbförfrågningar är tillåtna.';

  @override
  String get auto_webhookUrl => 'Webhook-adress (https://…)';

  @override
  String get auto_channelName => 'Hashtaggkanal, t.ex. #vandrare';

  @override
  String get auto_needChannel => 'Ange kanalens namn.';

  @override
  String get auto_needUrl => 'Ange en webbadress som börjar med https://';

  @override
  String auto_placeholders(String list) {
    return 'Du kan använda $list';
  }

  @override
  String get teamSetup_title => 'Teaminställning';

  @override
  String get teamSetup_toolSub => 'Dela radioinställningar, kanaler och rutter';

  @override
  String get teamSetup_share => 'Dela';

  @override
  String get teamSetup_receive => 'Ta emot';

  @override
  String get teamSetup_warning =>
      'Innehåller kanalnycklar. Alla med den här filen eller QR-koden och lösenfrasen kan läsa kanalerna. Berätta lösenfrasen personligen eller på annat sätt, aldrig tillsammans med filen.';

  @override
  String get teamSetup_radio => 'Radioinställningar';

  @override
  String get teamSetup_channels => 'Kanaler och deras nycklar';

  @override
  String get teamSetup_notPublic => 'Inte den offentliga kanalen';

  @override
  String get teamSetup_places => 'Vägpunkter och rutter';

  @override
  String get teamSetup_passHint => 'Lösenfras (minst 12 tecken)';

  @override
  String get teamSetup_create => 'Skapa';

  @override
  String get teamSetup_tooBig =>
      'För mycket för en QR-kod. Dela som fil i stället.';

  @override
  String get teamSetup_shareFile => 'Dela som fil';

  @override
  String get teamSetup_scanTitle => 'Skanna teaminställning';

  @override
  String get teamSetup_wrongPass => 'Fel lösenfras eller skadad fil.';

  @override
  String get teamSetup_notFile => 'Det här är ingen giltig teamfil.';

  @override
  String get teamSetup_openFile => 'Öppna en fil';

  @override
  String get teamSetup_scanQr => 'Skanna en QR-kod';

  @override
  String get teamSetup_pass => 'Lösenfras';

  @override
  String get teamSetup_open => 'Öppna';

  @override
  String teamSetup_channelsList(String names) {
    return 'Kanaler: $names';
  }

  @override
  String teamSetup_placesCount(int waypoints, int routes) {
    return 'Vägpunkter: $waypoints, rutter: $routes';
  }

  @override
  String teamSetup_radioDetail(String details) {
    return 'Radioinställningar: $details';
  }

  @override
  String get teamSetup_radioWarn =>
      'Av som standard. Kontrollera att de är lagliga där du är. En annan frekvens tar dig från ditt nuvarande mesh.';

  @override
  String get teamSetup_connectFirst =>
      'Anslut en radio för att lägga till kanaler eller ändra inställningar.';

  @override
  String get teamSetup_apply => 'Verkställ';

  @override
  String teamSetup_done(String summary) {
    return 'Klart: $summary.';
  }

  @override
  String teamSetup_stopped(String summary, String error) {
    return 'Avbröts halvvägs ($summary): $error';
  }

  @override
  String teamSetup_added(int count) {
    return 'Tillagda kanaler: $count';
  }

  @override
  String teamSetup_addedSkipped(int count, int left) {
    return 'Tillagda kanaler: $count. Finns redan eller ingen plats: $left';
  }

  @override
  String get teamSetup_radioChanged => 'radioinställningar ändrade';

  @override
  String get botUi_replyHint =>
      'Korta svar sparar sändningstid. Högst 140 byte inklusive bot-märkning.';

  @override
  String get botUi_shorterReply => 'Ange ett kortare svar som inte är tomt.';

  @override
  String get botUi_addRule => 'Lägg till svarsregel';

  @override
  String get botUi_editRule => 'Redigera svarsregel';

  @override
  String get botUi_trigger => 'Kommando eller nyckelord';

  @override
  String get botUi_reply => 'Svar';

  @override
  String get botUi_matchAnywhere => 'Matcha nyckelordet var som helst';

  @override
  String get botUi_matchHint =>
      'Av betyder exakt matchning utan skiftlägeskänslighet.';

  @override
  String get botUi_from => 'Från';

  @override
  String get botUi_anyContact => 'Valfri tillåten kontakt';

  @override
  String get botUi_prevContact => 'Tidigare vald kontakt';

  @override
  String get botUi_priority =>
      'Aktiverade inbyggda kommandon går först. Regler körs i listordning.';

  @override
  String get botUi_needTrigger =>
      'Ange en utlösare och ett kort svar som inte är tomt.';

  @override
  String get botUi_title => 'NOTORYX Bot-läge';

  @override
  String get botUi_mode => 'Bot-läge';

  @override
  String get botUi_loading => 'Läser in inställningar…';

  @override
  String get botUi_off => 'Av';

  @override
  String get botUi_onDm => 'På — lyssnar på direktmeddelanden';

  @override
  String botUi_onDmChannels(int count) {
    return 'På — lyssnar på direktmeddelanden och kanaler: $count';
  }

  @override
  String get botUi_onWaiting => 'På — väntar på radioanslutning';

  @override
  String get botUi_intro =>
      'Gratis och lokalt. Körs medan NOTORYX Core är öppen och ansluten till radion. Viloläge eller att stänga appen kan stoppa svar. Cachade meddelanden och eftersläpning vid återanslutning ignoreras. Svar använder den vanliga sändningskön.';

  @override
  String get botUi_away => 'Automatiskt frånvarosvar';

  @override
  String get botUi_awayReply => 'Frånvarosvar';

  @override
  String get botUi_info => 'Nod-/gruppinformation';

  @override
  String get botUi_infoReply => 'Informationssvar';

  @override
  String get botUi_checkIn => 'Incheckningssvar';

  @override
  String get botUi_commands => 'Kommandon';

  @override
  String get botUi_allowWhere => 'Tillåt platssvar med !where';

  @override
  String get botUi_whereHint =>
      'Delar radions annonserade koordinater med tillåtna kontakter. De kan vara inaktuella. Av som standard.';

  @override
  String get botUi_custom => 'Egna kommandon och nyckelordsregler';

  @override
  String get botUi_airtime => 'Styrning av sändningstid';

  @override
  String get botUi_cooldown => 'Väntetid per kontakt';

  @override
  String botUi_minutes(int count) {
    return '$count minuter';
  }

  @override
  String get botUi_maxReplies => 'Högsta antal svar per minut (alla kontakter)';

  @override
  String get botUi_allowed => 'Tillåtna kontakter';

  @override
  String get botUi_allowedHint => 'Inget valt betyder alla kända kontakter.';

  @override
  String get botUi_recent => 'Senaste aktivitet (den här sessionen)';

  @override
  String get botUi_noReplies => 'Inga bot-svar ännu.';

  @override
  String get a11y_jumpToBottom => 'Till det senaste meddelandet';

  @override
  String a11y_cluster(int count) {
    return 'Noder här: $count. Zooma in';
  }

  @override
  String get a11y_wardrivePing => 'Pingdetaljer';

  @override
  String get a11y_receivedImage => 'Mottagen bild';

  @override
  String get a11y_imagePreview => 'Förhandsvisning av bild';

  @override
  String get rcli_title => 'Tillåta fjärrkommandorad?';

  @override
  String rcli_warning(String name) {
    return '$name kan då köra alla kommandon på din radio via meshen: ändra namn, radioinställningar och lösenord eller starta om den. Tillåt bara personer du litar på.';
  }

  @override
  String get rcli_allow => 'Tillåt';

  @override
  String get rcli_toggle => 'Tillåt fjärrkommandorad';

  @override
  String get rcli_toggleHint =>
      'Låter den här kontakten köra alla kommandon på din radio, även ändra inställningar. MeshCore v1.18+.';

  @override
  String rcli_toggleBlocked(String command) {
    return 'Låter den här kontakten köra alla kommandon på din radio. Senast blockerat: \"$command\".';
  }

  @override
  String get rcli_menu => 'Kommandorad på deras radio';

  @override
  String rcli_runsOn(String name) {
    return 'Körs på ${name}s radio bara om du har fått tillåtelse till fjärrkommandorad (MeshCore v1.18+). Inget svar betyder blockerat eller att det inte kom fram.';
  }

  @override
  String get bk_title => 'Krypterad säkerhetskopia';

  @override
  String get bk_intro =>
      'Sparar en krypterad kopia av inställningar, kontakter, kanalnycklar, waypoints och utkast, och om du vill även meddelandehistoriken. Offlinekartor, foton och radions firmware ingår inte.';

  @override
  String get bk_keep =>
      'Förvara lösenfrasen separat. En förlorad lösenfras kan inte återställas.';

  @override
  String get bk_pass => 'Lösenfras (12+ tecken)';

  @override
  String get bk_confirm => 'Bekräfta lösenfras';

  @override
  String get bk_working => 'Arbetar…';

  @override
  String get bk_save => 'Spara krypterad säkerhetskopia';

  @override
  String get bk_mismatch =>
      'Använd minst 12 tecken och samma lösenfras två gånger.';

  @override
  String get bk_done =>
      'Säkerhetskopian är klar. Förvara filen och lösenfrasen säkert.';

  @override
  String get bk_failed =>
      'Kunde inte exportera säkerhetskopian. Dina data ändrades inte.';

  @override
  String get bk_restoreTitle => 'Återställ en säkerhetskopia';

  @override
  String get bk_restorePass => 'Säkerhetskopians lösenfras';

  @override
  String get bk_choose => 'Välj säkerhetskopia';

  @override
  String get bk_cantOpen => 'Kunde inte öppna filen.';

  @override
  String get bk_wrongPass =>
      'Fel lösenfras eller ingen giltig säkerhetskopia. Inget ändrades.';

  @override
  String get bk_confirmTitle => 'Återställa den här säkerhetskopian?';

  @override
  String bk_confirmBody(int count) {
    return 'Det här ersätter $count sparade inställningar på enheten, bland annat kontakter, kanalnycklar och waypoints, med dem i säkerhetskopian. Det går inte att ångra.';
  }

  @override
  String get bk_restore => 'Återställ';

  @override
  String bk_restored(int count) {
    return '$count inställningar återställda. Stäng appen helt och öppna den igen.';
  }

  @override
  String get bk_partial =>
      'Återställningen avbröts halvvägs; vissa inställningar kan ha ändrats. Försök igen.';

  @override
  String get bk_history => 'Ta med meddelandehistorik';

  @override
  String get bk_historyHint =>
      'Direkt- och kanalmeddelanden för alla radioenheter. Filen blir större.';

  @override
  String get bk_tooLarge =>
      'Säkerhetskopian är för stor. Stäng av meddelandehistorik och försök igen.';

  @override
  String bk_confirmHistory(int count) {
    return 'Den lägger också till upp till $count meddelanden i historiken. Meddelanden som redan finns på enheten behålls.';
  }

  @override
  String bk_restoredHistory(int count) {
    return '$count meddelanden har lagts till i historiken.';
  }

  @override
  String get sosSetup_noPeople =>
      'Inga personer bland dina kontakter än. De dyker upp när någon delar sin kontakt eller du hör deras annons.';

  @override
  String get sosSetup_channel => 'SOS går även till kanal';

  @override
  String get sosSetup_channelHint => 'Alla i den kanalen ser ditt SOS.';

  @override
  String get sosSetup_none => 'Ingen';

  @override
  String get trail_safety =>
      'Leddata © OpenStreetMaps bidragsgivare. De kan vara ofullständiga eller inaktuella. Rutter kontrolleras inte för säkerhet eller framkomlighet, så använd inte detta som enda navigering.';

  @override
  String get ant_title => 'Antenntäckning';

  @override
  String get ant_placeHint => 'Tryck länge på kartan för att placera antennen.';

  @override
  String get ant_fromRadio =>
      'Antennen vid din radios position. Tryck länge på kartan för att flytta den.';

  @override
  String get ant_placed =>
      'Antennen placerad på kartan. Tryck länge för att flytta den.';

  @override
  String get ant_height => 'Antennhöjd';

  @override
  String get ant_radius => 'Radie';

  @override
  String get ant_checking => 'Kontrollerar terrängen…';

  @override
  String get ant_estimate => 'Uppskatta täckning';

  @override
  String get ant_noTerrain =>
      'Terränghöjder kunde inte laddas. Första gången behövs internet.';

  @override
  String get ant_legendSignal =>
      'Stora gröna punkter: starkt signal. Små orange punkter: gränsfall. En grov uppskattning från terräng och radioinställningar, med 2 dBi-antenner. Träd och byggnader ingår inte, så verklig räckvidd är ofta kortare.';

  @override
  String get ant_legendLos =>
      'Anslut en radio för signaluppskattningar. Gröna punkter har fri sikt till en handradio (1,5 m). En grov uppskattning, ingen garanti.';

  @override
  String ant_losSummary(int percent, String km) {
    return 'Fri sikt till $percent % av punkterna • längst bort $km km';
  }

  @override
  String ant_signalSummary(int strong, int marginal, String km) {
    return 'Uppskattad signal: stark i $strong % av området, gränsfall i $marginal %, användbar upp till $km km.';
  }

  @override
  String rp_title(String name) {
    return 'Mesh-inställningar för $name';
  }

  @override
  String rp_mostNodes(String summary) {
    return 'De flesta noder här använder $summary. Din radio är inställd annorlunda, så du kanske inte hör dem.';
  }

  @override
  String rp_mostNodesCount(int count, String summary) {
    return 'De flesta noder här ($count på MeshCore-kartan) använder $summary. Din radio är inställd annorlunda, så du kanske inte hör dem.';
  }

  @override
  String rp_localMesh(String summary) {
    return 'Det lokala meshet använder $summary. Din radio är inställd annorlunda, så du kanske inte hör det.';
  }

  @override
  String get rp_notNow => 'Inte nu';

  @override
  String get rp_review => 'Granska';

  @override
  String rp_useTitle(String name) {
    return 'Använda inställningarna för $name?';
  }

  @override
  String get rp_already => 'Din radio använder redan dessa inställningar.';

  @override
  String get rp_fromMap =>
      'Rapporterat av nodägare på MeshCore-kartan, inte kontrollerat i luften.';

  @override
  String rp_updated(String date) {
    return 'Uppdaterad $date. Efter bytet hör du bara radioapparater med samma inställningar.';
  }

  @override
  String get rp_powerOnly => 'Sändareffekten ändras inte.';

  @override
  String get rp_powerHash =>
      'Sändareffekten och storleken på väg-hashen ändras inte.';

  @override
  String get rp_apply => 'Tillämpa på radion';

  @override
  String rp_setTo(String name) {
    return 'Radion inställd på $name.';
  }

  @override
  String rp_failed(String error) {
    return 'Kunde inte ändra radion: $error';
  }

  @override
  String get rp_noArea => 'Inget listat område i närheten.';

  @override
  String get rp_noLonger => 'Det valda området är inte längre listat.';

  @override
  String get rp_autoPrefix => 'Auto: ';

  @override
  String get rp_tileTitle => 'Lokala mesh-inställningar';

  @override
  String get rp_automatic => 'Automatiskt';

  @override
  String get rp_autoSub => 'Utifrån radions eller telefonens position';

  @override
  String get rp_mapSuffix => 'MeshCore-kartan';

  @override
  String get rp_savedList =>
      'Använder den sparade listan. Den uppdateras från GitHub när du är online.';

  @override
  String rp_checked(String time) {
    return 'Listan kontrollerad $time. Områden läggs till via pull request.';
  }

  @override
  String get sh_title => 'Dela en kontakt';

  @override
  String get sh_hint =>
      'Skickar namn och publik nyckel som en länk som vem som helst kan trycka på för att lägga till den.';

  @override
  String get sh_you => 'Det här är du.';

  @override
  String get sh_already => 'Finns redan bland dina kontakter.';

  @override
  String get sh_adding => 'Lägger till…';

  @override
  String get sh_add => 'Lägg till kontakt';

  @override
  String sh_added(String name) {
    return '$name tillagd.';
  }

  @override
  String sh_addFailed(String name, String error) {
    return 'Kunde inte lägga till $name: $error';
  }

  @override
  String get tr_needArea =>
      'Ladda först ned ett område som innehåller båda punkterna.';

  @override
  String get tr_startFar => 'Starten ligger mer än 500 m från en känd led.';

  @override
  String get tr_endFar => 'Målet ligger mer än 500 m från en känd led.';

  @override
  String get tr_notJoined => 'Inga kända leder förbinder punkterna.';

  @override
  String get tr_damaged =>
      'Områdets data är skadade. Ta bort det och ladda ned det igen.';

  @override
  String tr_zoomIn(int max, int current) {
    return 'Zooma in: ett område får vara högst $max km², och den här vyn är $current km².';
  }

  @override
  String get tr_downloading => 'Laddar ned leder…';

  @override
  String tr_saved(String size) {
    return 'Sparade $size leddata.';
  }

  @override
  String get tr_tooLarge => 'Zooma in till ett mindre område.';

  @override
  String get tr_full =>
      'Lagringen för leder är full (500 MB). Ta bort ett område först.';

  @override
  String get tr_noTrails => 'Inga leder hittades i den här vyn.';

  @override
  String get tr_failed =>
      'Nedladdningen misslyckades. Kartservern kan vara upptagen; försök igen senare.';

  @override
  String tr_routeName(String distance) {
    return 'Ledrutt $distance';
  }

  @override
  String get tr_savedRoute => 'Sparad bland dina rutter.';

  @override
  String get tr_areas => 'Nedladdade områden';

  @override
  String tr_used(String size) {
    return '$size av 500 MB används';
  }

  @override
  String tr_deleteArea(String name) {
    return 'Ta bort $name';
  }

  @override
  String get tr_title => 'Ruttplanering på leder';

  @override
  String get tr_search => 'Sök platser';

  @override
  String get tr_start => 'Ruttstart';

  @override
  String get tr_end => 'Ruttmål';

  @override
  String tr_route(String distance) {
    return 'Rutt: $distance längs kända leder.';
  }

  @override
  String get tr_tapStart => 'Tryck på kartan för start och sedan för mål.';

  @override
  String get tr_tapEnd => 'Tryck på kartan för målet.';

  @override
  String get tr_download => 'Ladda ned den här vyn';

  @override
  String get tr_save => 'Spara rutt';

  @override
  String get tr_searchLabel => 'Sök nedladdade platser';

  @override
  String get tr_searchHelp =>
      'Toppar, ledstarter, vatten, stugor, orter och dina vägpunkter. Ett val blir nästa ruttpunkt.';

  @override
  String get tr_nothing =>
      'Inget hittades. Sökningen gäller bara nedladdade områden, och områden sparade före platssökningen måste laddas ned igen.';

  @override
  String get tr_toolSub => 'Offline-rutter längs nedladdade leder';

  @override
  String get place_peak => 'Topp';

  @override
  String get place_pass => 'Pass';

  @override
  String get place_spring => 'Källa';

  @override
  String get place_hut => 'Stuga';

  @override
  String get place_campsite => 'Campingplats';

  @override
  String get place_viewpoint => 'Utsiktspunkt';

  @override
  String get place_shelter => 'Vindskydd';

  @override
  String get place_trailhead => 'Ledstart';

  @override
  String get place_town => 'Ort';

  @override
  String get place_locality => 'Plats';

  @override
  String get place_waypoint => 'Sparad vägpunkt';

  @override
  String get sentinel_title => 'Gemenskapsmoderering';

  @override
  String get sentinel_toolSubtitle =>
      'Rapportera spam till NOTORYX-moderatorer och se flaggade noder';

  @override
  String get sentinel_intro =>
      'Rapporter går till NOTORYX-moderatorer som granskar varje rapport för hand. Godkända avstängningar kommer tillbaka som en rådgivande lista: flaggade noder får en etikett och inget blockeras i meshen.';

  @override
  String get sentinel_enable => 'Använd gemenskapsmoderering';

  @override
  String get sentinel_enableSub =>
      'Av som standard. Så länge den är av kontaktar NOTORYX aldrig modereringstjänsten.';

  @override
  String get sentinel_hide => 'Dölj meddelanden från flaggade avsändare';

  @override
  String get sentinel_hideSub =>
      'Endast kanalmeddelanden. Du kan stänga av det när som helst.';

  @override
  String sentinel_synced(String time) {
    return 'Avstängningslistan uppdaterad $time';
  }

  @override
  String get sentinel_neverSynced => 'Avstängningslistan inte hämtad än';

  @override
  String sentinel_flaggedCount(int count) {
    return 'Flaggade noder: $count';
  }

  @override
  String sentinel_queued(int count) {
    return 'Rapporter som väntar på att skickas: $count';
  }

  @override
  String get sentinel_refresh => 'Uppdatera nu';

  @override
  String get sentinel_yourNode => 'Din nod';

  @override
  String get sentinel_yourNodeClear => 'Din nod är inte flaggad.';

  @override
  String sentinel_yourNodeFlagged(String caseRef) {
    return 'Din nod är flaggad (ärende $caseRef). Om det är ett misstag kan du överklaga.';
  }

  @override
  String get sentinel_yourNodeUnknown =>
      'Anslut en radio för att kontrollera din nod.';

  @override
  String get sentinel_appealPending => 'Din överklagan granskas.';

  @override
  String get sentinel_appeal => 'Överklaga';

  @override
  String get sentinel_appealOther => 'Överklaga ett ärende via nummer';

  @override
  String get sentinel_yourReports => 'Dina senaste rapporter';

  @override
  String get sentinel_report => 'Rapportera till moderatorer';

  @override
  String sentinel_reportTitle(String name) {
    return 'Rapportera $name';
  }

  @override
  String get sentinel_reasonSpam => 'Spam eller reklam';

  @override
  String get sentinel_reasonFlooding => 'Översvämmar meshen';

  @override
  String get sentinel_reasonAbuse => 'Trakasserier eller övergrepp';

  @override
  String get sentinel_reasonImpersonation => 'Identitetsstöld';

  @override
  String get sentinel_reasonOther => 'Annat';

  @override
  String get sentinel_note => 'Detaljer (valfritt)';

  @override
  String get sentinel_includeMessage => 'Bifoga det här meddelandet';

  @override
  String get sentinel_sends =>
      'Skickar nodens ID och namn, ditt skäl och, om ikryssat, det här meddelandet. Inte ditt namn, din nyckel eller din plats.';

  @override
  String get sentinel_send => 'Skicka rapport';

  @override
  String sentinel_sent(String caseRef) {
    return 'Rapport skickad ($caseRef)';
  }

  @override
  String get sentinel_queuedOne =>
      'Ingen anslutning. Rapporten skickas senare.';

  @override
  String sentinel_rejected(String message) {
    return 'Rapporten godtogs inte: $message';
  }

  @override
  String get sentinel_offPrompt => 'Slå på gemenskapsmoderering?';

  @override
  String get sentinel_turnOn => 'Slå på';

  @override
  String get sentinel_flagged => 'Flaggad';

  @override
  String sentinel_flaggedHint(String caseRef) {
    return 'Flaggad av NOTORYX-moderatorer (ärende $caseRef). Endast rådgivande.';
  }

  @override
  String get sentinel_caseRef => 'Ärendenummer (SNT-1234)';

  @override
  String get sentinel_statement => 'Varför ska avstängningen hävas?';

  @override
  String get sentinel_contact =>
      'Kontakt (valfritt, syns bara för moderatorer)';

  @override
  String get sentinel_appealSend => 'Skicka överklagan';

  @override
  String get sentinel_appealReceived =>
      'Överklagan skickad. En moderator granskar den.';

  @override
  String get sentinel_appealUnknown => 'Inget MeshCore-ärende har det numret.';

  @override
  String get sentinel_appealNotOpen =>
      'Ärendet har ingen aktiv avstängning, eller så väntar redan en överklagan.';

  @override
  String get sentinel_appealTooMany =>
      'För många överklaganden. Försök igen om en minut.';

  @override
  String get sentinel_failed =>
      'Kunde inte nå modereringstjänsten. Försök igen senare.';

  @override
  String get privacy_netSentinel =>
      'Moderering: bara om du slår på gemenskapsmoderering. Avstängningslistan och rapporter eller överklaganden du skickar går till NOTORYX-moderatorer via sentinel-relay.meshmayhem.org.';

  @override
  String get mapTrust_favoritesOnly => 'Endast favoriter';

  @override
  String get mapTrust_favoritesOnlyHint => 'Dölj noder utan stjärna';

  @override
  String get topology_flows => 'Flöden';

  @override
  String get topology_network => 'Nätverk';

  @override
  String get topology_hint =>
      'Ringarna visar antal hopp från dig i mitten. Tjockare linjer bar fler meddelanden, större prickar vidarebefordrade mer. Tryck på en prick för att se den repeatern.';

  @override
  String topology_semantics(int repeaters, int rings) {
    return 'Nätverksdiagram. $repeaters repeatrar på $rings ringar runt dig.';
  }

  @override
  String get zones_title => 'Zon- och ledlarm';

  @override
  String get zones_toolSubtitle =>
      'Larmar när någon går in i eller lämnar en zon, eller avviker från en led';

  @override
  String get zones_enabled => 'Larm på';

  @override
  String get zones_enabledHint =>
      'Använder positioner från adverts som radion hör, så ett larm är bara så färskt som senaste advert.';

  @override
  String get zones_watch => 'Bevaka';

  @override
  String get zones_scopeFavorites => 'Favoriter';

  @override
  String get zones_scopeEveryone => 'Alla';

  @override
  String get zones_includeSelf => 'Även min radio';

  @override
  String get zones_zones => 'Zoner';

  @override
  String get zones_none =>
      'Inga zoner än. Lägg till en runt lägret, ett ledstart eller en mötesplats.';

  @override
  String get zones_add => 'Lägg till zon';

  @override
  String get zones_edit => 'Redigera zon';

  @override
  String get zones_name => 'Namn';

  @override
  String get zones_defaultName => 'Zon';

  @override
  String get zones_center => 'Mittpunkt';

  @override
  String get zones_centerMyRadio => 'Min radios position';

  @override
  String zones_centerWaypoint(String name) {
    return 'Waypoint: $name';
  }

  @override
  String get zones_noCenter =>
      'Radion har ingen position och det finns inga waypoints. Ange en position eller spara en waypoint först.';

  @override
  String zones_radius(String distance) {
    return 'Radie: $distance';
  }

  @override
  String get zones_alertOn => 'Larma vid';

  @override
  String get zones_onEnter => 'Inträde';

  @override
  String get zones_onLeave => 'Utträde';

  @override
  String get zones_onBoth => 'Båda';

  @override
  String get zones_delete => 'Ta bort zon';

  @override
  String zones_full(int count) {
    return 'Du kan ha upp till $count zoner.';
  }

  @override
  String get zones_trail => 'Led';

  @override
  String get zones_trailNone => 'Ingen led bevakas';

  @override
  String get zones_trailHint =>
      'Välj en waypoint-rutt eller ett inspelat spår. Den som bevakas och kommer längre bort än gränsen ger ett larm.';

  @override
  String zones_offTrailLimit(String distance) {
    return 'Utanför leden efter $distance';
  }

  @override
  String get zones_you => 'Du';

  @override
  String zones_trackName(String date, String km) {
    return 'Spår $date · $km km';
  }

  @override
  String zones_alertEnteredTitle(String zone) {
    return 'In i $zone';
  }

  @override
  String zones_alertEnteredBody(String name, String zone) {
    return '$name är inne i $zone.';
  }

  @override
  String zones_alertLeftTitle(String zone) {
    return 'Lämnade $zone';
  }

  @override
  String zones_alertLeftBody(String name, String zone) {
    return '$name har lämnat $zone.';
  }

  @override
  String get zones_alertOffTrailTitle => 'Utanför leden';

  @override
  String zones_alertOffTrailBody(String name, String distance, String trail) {
    return '$name är $distance från $trail.';
  }
}
