// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'NOTORYX Core';

  @override
  String get nav_contacts => 'Kontakty';

  @override
  String get nav_channels => 'Kanály';

  @override
  String get nav_map => 'Mapa';

  @override
  String get nav_messages => 'Správy';

  @override
  String get nav_nodes => 'Uzly';

  @override
  String get nav_radio => 'Rádio';

  @override
  String get messages_title => 'Správy';

  @override
  String get messages_filterAll => 'Všetky';

  @override
  String get messages_filterDirect => 'Priame';

  @override
  String get messages_filterChannels => 'Kanály';

  @override
  String messages_filterWithUnread(String label, int count) {
    return '$label · $count';
  }

  @override
  String get messages_search => 'Hľadať správy';

  @override
  String get messages_searchHint => 'Hľadať konverzácie';

  @override
  String get messages_closeSearch => 'Zavrieť hľadanie';

  @override
  String get messages_manageChannels => 'Spravovať kanály';

  @override
  String get messages_new => 'Nová';

  @override
  String get messages_newDirect => 'Napísať uzlu';

  @override
  String get messages_newChannel => 'Pridať kanál alebo sa pripojiť';

  @override
  String get messages_empty => 'Zatiaľ žiadne konverzácie';

  @override
  String get messages_emptyHint =>
      'Tu sa zobrazujú správy od uzlov a z kanálov.';

  @override
  String get messages_noMatches => 'Hľadaniu nezodpovedajú žiadne konverzácie';

  @override
  String messages_you(String text) {
    return 'Vy: $text';
  }

  @override
  String get messages_yesterday => 'Včera';

  @override
  String messages_unreadCount(int count) {
    return 'Neprečítané: $count';
  }

  @override
  String radioStatus_connectedVia(String transport) {
    return 'Pripojené cez $transport';
  }

  @override
  String get radioStatus_bluetooth => 'Bluetooth';

  @override
  String get radioStatus_usb => 'USB';

  @override
  String get radioStatus_tcp => 'Wi‑Fi (TCP)';

  @override
  String radioStatus_battery(int percent) {
    return 'Batéria $percent %';
  }

  @override
  String get radioStatus_openRadio => 'Otvoriť podrobnosti rádia';

  @override
  String get radioOverview_battery => 'Batéria';

  @override
  String radioOverview_firmware(String version) {
    return 'Firmvér $version';
  }

  @override
  String get radioOverview_sendAdvert => 'Odoslať ohlásenie';

  @override
  String get radioOverview_stats => 'Štatistiky rádia';

  @override
  String get accessControl_title => 'Riadenie prístupu';

  @override
  String get accessControl_hubSubtitle => 'Kto sa môže prihlásiť bez hesla';

  @override
  String get accessControl_explainRepeater =>
      'Ľudia z tohto zoznamu sa prihlasujú bez hesla. Správcovia môžu meniť nastavenia; Iba čítanie a Čítanie a zápis dostávajú aj úplnú telemetriu.';

  @override
  String get accessControl_explainRoom =>
      'Správcovia z tohto zoznamu sa prihlasujú bez hesla a môžu spravovať miestnosť. Členovia miestnosti sa pripájajú heslom miestnosti.';

  @override
  String get accessControl_roleReadOnly => 'Iba čítanie';

  @override
  String get accessControl_roleReadWrite => 'Čítanie a zápis';

  @override
  String get accessControl_roleAdmin => 'Správca';

  @override
  String get accessControl_you => 'Vy';

  @override
  String get accessControl_unknownNode => 'Neznámy uzol';

  @override
  String get accessControl_add => 'Pridať';

  @override
  String get accessControl_addTitle => 'Pridať do zoznamu prístupu';

  @override
  String get accessControl_pickContact => 'Vyberte kontakt';

  @override
  String get accessControl_noContacts =>
      'Žiadne kontakty na pridanie. Uzly sa tu zobrazia, keď prijmete ich ohlásenie.';

  @override
  String get accessControl_changeRole => 'Zmeniť rolu';

  @override
  String get accessControl_remove => 'Odobrať prístup';

  @override
  String accessControl_removeConfirm(String name) {
    return 'Odstrániť $name zo zoznamu prístupu? Na prihlásenie bude potrebné heslo.';
  }

  @override
  String get accessControl_removeSelfWarning =>
      'Toto ste vy. Ak sa odstránite, na opätovnú správu tohto uzla budete potrebovať heslo správcu.';

  @override
  String get accessControl_unknownKeyNote =>
      'Nie je vo vašich kontaktoch. Zmena roly vyžaduje novší firmvér uzla; odstránenie funguje vždy.';

  @override
  String get accessControl_prefixUnsupported =>
      'Firmvér tohto uzla nedokáže zmeniť rolu niekoho, kto nie je vo vašich kontaktoch. Stále ho môžete odstrániť.';

  @override
  String get accessControl_empty => 'Zoznam prístupu je prázdny';

  @override
  String get accessControl_emptyHint =>
      'Pridajte ľudí, aby sa mohli prihlásiť bez hesla.';

  @override
  String get accessControl_loading => 'Žiadam od uzla zoznam prístupu…';

  @override
  String get accessControl_timeout =>
      'Uzol neodpovedal. Skontrolujte trasu a skúste to znova.';

  @override
  String get accessControl_maybeIncomplete =>
      'Uzol poslal jednu plnú stranu a jeho firmvér nedokáže poslať viac, takže niektoré položky môžu chýbať.';

  @override
  String get accessControl_saved => 'Zoznam prístupu aktualizovaný';

  @override
  String accessControl_failed(String reply) {
    return 'Uzol zmenu odmietol: $reply';
  }

  @override
  String get companionCli_title => 'Príkazový riadok';

  @override
  String get companionCli_tileSubtitle => 'Spúšťajte príkazy na rádiu';

  @override
  String get companionCli_warning =>
      'Príkazy sa spúšťajú na pripojenom rádiu a môžu zmeniť jeho nastavenia alebo ho reštartovať.';

  @override
  String get companionCli_hint => 'Zadajte príkaz, napr. ver';

  @override
  String get companionCli_send => 'Spustiť príkaz';

  @override
  String get companionCli_noReply =>
      'Žiadna odpoveď. Rádio sa možno reštartuje.';

  @override
  String get companionCli_empty =>
      'Skúste jeden z príkazov vyššie alebo zadajte vlastný.';

  @override
  String get wifi_title => 'Wi‑Fi';

  @override
  String get wifi_tileSubtitle => 'Pripojte rádio k sieti Wi‑Fi';

  @override
  String get wifi_unsupported => 'Firmvér tohto rádia nepodporuje Wi‑Fi.';

  @override
  String get wifi_enabled => 'Používať Wi‑Fi';

  @override
  String get wifi_status => 'Stav';

  @override
  String get wifi_connected => 'Pripojené';

  @override
  String wifi_connectedIp(String ip) {
    return 'Pripojené · $ip';
  }

  @override
  String get wifi_disconnected => 'Nepripojené';

  @override
  String get wifi_network => 'Názov siete (SSID)';

  @override
  String get wifi_password => 'Heslo';

  @override
  String get wifi_passwordKeep =>
      'Nechajte prázdne, ak chcete ponechať aktuálne heslo';

  @override
  String get wifi_save => 'Uložiť';

  @override
  String get wifi_forget => 'Zabudnúť sieť';

  @override
  String get wifi_forgetConfirm => 'Odstrániť z rádia uloženú sieť a heslo?';

  @override
  String get wifi_rebootNeeded =>
      'Uložené. Reštartujte rádio, aby sa zmeny Wi‑Fi prejavili.';

  @override
  String get wifi_rebootNow => 'Reštartovať rádio';

  @override
  String get wifi_rebootConfirm =>
      'Reštartovať rádio teraz? Aplikácia sa odpojí a budete sa musieť znova pripojiť.';

  @override
  String get wifi_loadFailed =>
      'Nastavenia Wi‑Fi sa z rádia nepodarilo načítať.';

  @override
  String get wifi_retry => 'Skúsiť znova';

  @override
  String wifi_saveFailed(String reply) {
    return 'Rádio zmenu neprijalo: $reply';
  }

  @override
  String get accessControl_refresh => 'Obnoviť';

  @override
  String get common_cancel => 'Zrušiť';

  @override
  String get common_ok => 'OK\nDobre';

  @override
  String get common_connect => 'Pripojiť';

  @override
  String get common_unknownDevice => 'Neznáme zariadenie';

  @override
  String get common_save => 'Uložiť';

  @override
  String get common_delete => 'Odstrániť';

  @override
  String get common_deleteAll => 'Zmazať všetko';

  @override
  String get common_close => 'Zavrieť';

  @override
  String get common_done => 'Done';

  @override
  String get common_edit => 'Upraviť';

  @override
  String get common_add => 'Pridať';

  @override
  String get common_settings => 'Nastavenia';

  @override
  String get common_disconnect => 'Odpojiť';

  @override
  String get common_connected => 'Pripojené';

  @override
  String get common_disconnected => 'Odpojené';

  @override
  String get common_create => 'Vytvoriť';

  @override
  String get common_continue => 'Pokračovať';

  @override
  String get common_share => 'Zdieľať';

  @override
  String get common_copy => 'Kopírovať';

  @override
  String get common_retry => 'Pokusť znova';

  @override
  String get common_hide => 'Skryť';

  @override
  String get common_remove => 'Odstrániť';

  @override
  String get common_enable => 'Povolit';

  @override
  String get common_disable => 'Zakázať';

  @override
  String get common_undo => 'Zrušiť';

  @override
  String get messageStatus_sent => 'Odoslané';

  @override
  String get messageStatus_delivered => 'Doručené';

  @override
  String get messageStatus_pending => 'Odoslanie';

  @override
  String get messageStatus_failed => 'Neúspešné odeslanie';

  @override
  String get messageStatus_repeated => 'Slyšal som to opakovane';

  @override
  String get urlImage_enable => 'Povoliť obrázky z URL';

  @override
  String get urlImage_possible =>
      'Možný obrázok z URL; povoľte ho v Nastaveniach.';

  @override
  String get common_reboot => 'Restartovať';

  @override
  String get common_loading => 'Načítavanie...';

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
  String get common_autoRefresh => 'Automatické obnovenie';

  @override
  String get common_interval => 'Časový interval';

  @override
  String get scanner_title => 'MeshCore – Verzia pre verejnosť';

  @override
  String get connectionChoiceUsbLabel => 'USB';

  @override
  String get connectionChoiceBluetoothLabel => 'Bluetooth';

  @override
  String get connectionChoiceTcpLabel => 'TCP';

  @override
  String get tcpScreenTitle => 'Spojte sa pomocou protokolu TCP';

  @override
  String get tcpHostLabel => 'IP adresa';

  @override
  String get tcpHostHint => '192.168.40.10';

  @override
  String get tcpPortLabel => 'Prístav';

  @override
  String get tcpPortHint => '5 000';

  @override
  String get tcpStatus_notConnected => 'Zadajte cieľovú adresu a pripojte sa.';

  @override
  String tcpStatus_connectingTo(String endpoint) {
    return 'Pripojenie k $endpoint...';
  }

  @override
  String get tcpErrorHostRequired => 'Je potrebné zadať IP adresu.';

  @override
  String get tcpErrorPortInvalid => 'Číslo portu musí byť medzi 1 a 65535.';

  @override
  String get tcpErrorUnsupported =>
      'Prevoz prostredníctvom protokolu TCP nie je na tejto platforme podporovaný.';

  @override
  String get tcpErrorTimedOut => 'Pripojenie TCP vypršalo.';

  @override
  String tcpConnectionFailed(String error) {
    return 'Neúspešné vytvorenie TCP spojenia: $error';
  }

  @override
  String get usbScreenTitle => 'Pripojte cez USB';

  @override
  String get usbScreenSubtitle =>
      'Vyberte detekovaný sériový zariadenie a pripojte ho priamo k vašej MeshCore uzlu.';

  @override
  String get usbScreenStatus => 'Vyberte USB zariadenie';

  @override
  String get usbScreenNote =>
      'USB sériová komunikácia je aktívna na podporovaných zariadeniach s Androidom a na desktopových platformách.';

  @override
  String get usbScreenEmptyState =>
      'Nenašli sa žiadne USB zariadenia. Pripojte jedno a obnovte.';

  @override
  String get usbErrorPermissionDenied =>
      'Žiadosť o prístup cez USB bola zamietnutá.';

  @override
  String get usbErrorDeviceMissing =>
      'Vybrané USB zariadenie už nie je dostupné.';

  @override
  String get usbErrorInvalidPort => 'Vyberte platné USB zariadenie.';

  @override
  String get usbErrorBusy =>
      'Ďalšia požiadavka na pripojenie cez USB je aktuálne v procese.';

  @override
  String get usbErrorNotConnected => 'Nie je pripojené žiadne USB zariadenie.';

  @override
  String get usbErrorOpenFailed =>
      'Nepodarilo sa otvoriť vybrané USB zariadenie.';

  @override
  String get usbErrorConnectFailed =>
      'Nepodarilo sa sa sa pripojiť k vybranému USB zariadeniu.';

  @override
  String get usbErrorUnsupported =>
      'Podpora USB sériového rozhrania nie je na tejto platforme dostupná.';

  @override
  String get usbErrorAlreadyActive => 'Pripojenie cez USB je už aktivované.';

  @override
  String get usbErrorNoDeviceSelected =>
      'Nebolo vybrané žiadne USB zariadenie.';

  @override
  String get usbErrorPortClosed => 'Pripojenie cez USB nie je aktivované.';

  @override
  String get usbErrorConnectTimedOut =>
      'Pripojenie nebolo úspešné. Uistite sa, že zariadenie má nainštalovaný firmware USB Companion.';

  @override
  String get usbFallbackDeviceName => 'Webový sériový zariadenie';

  @override
  String get usbStatus_notConnected => 'Vyberte USB zariadenie';

  @override
  String get usbStatus_connecting => 'Pripojenie k USB zariadeniu...';

  @override
  String get usbStatus_searching => 'Hľadanie USB zariadení...';

  @override
  String usbConnectionFailed(String error) {
    return 'Neúspešné pripojenie cez USB: $error';
  }

  @override
  String get scanner_scanning => 'Skrívania zariadení...';

  @override
  String get scanner_connecting => 'Pripojujem sa...';

  @override
  String get scanner_disconnecting => 'Odpojuje sa...';

  @override
  String get scanner_notConnected => 'Nezriadené';

  @override
  String scanner_connectedTo(String deviceName) {
    return 'Pripojené k $deviceName';
  }

  @override
  String get scanner_searchingDevices => 'Hľadám zariadenia MeshCore...';

  @override
  String get scanner_tapToScan =>
      'Stlač skenovanie na nájdenie zariadení MeshCore.';

  @override
  String scanner_connectionFailed(String error) {
    return 'Pripojenie zlyhalo: $error';
  }

  @override
  String get scanner_stop => 'Zastavte';

  @override
  String get scanner_scan => 'Skončiť';

  @override
  String get scanner_bluetoothOff => 'Bluetooth je vypnutý';

  @override
  String get scanner_bluetoothOffMessage =>
      'Prosím, zapnite Bluetooth, aby ste mohli skenovať pre zariadenia.';

  @override
  String get scanner_chromeRequired => 'Vyžaduje sa prehliadač Chrome';

  @override
  String get scanner_chromeRequiredMessage =>
      'Táto webová aplikácia vyžaduje Google Chrome alebo prehliadač založený na Chromium pre podporu Bluetooth.';

  @override
  String get scanner_enableBluetooth => 'Povolte Bluetooth';

  @override
  String get scanner_bluetoothWebUnsupported =>
      'Funkcia Bluetooth nie je dostupná v prehliadači. Prepojte sa pomocou USB.';

  @override
  String get device_quickSwitch => 'Rýchle prepínač';

  @override
  String get device_meshcore => 'MeshCore';

  @override
  String get settings_title => 'Nastavenia';

  @override
  String get settings_deviceInfo => 'Informácie o zariadení';

  @override
  String get settings_appSettings => 'Nastavenia aplikácie';

  @override
  String get settings_appSettingsSubtitle =>
      'Upozornenia, správy a nastavenia mapy';

  @override
  String get settings_nodeSettings => 'Nastavenia uzla';

  @override
  String get settings_nodeName => 'Názov uzla';

  @override
  String get settings_nodeNameNotSet => 'Nezriadené';

  @override
  String get settings_nodeNameHint => 'Zadajte názov uzla';

  @override
  String get settings_nodeNameUpdated => 'Meno aktualizované';

  @override
  String get settings_radioSettings => 'Nastavenia rádia';

  @override
  String get settings_radioSettingsSubtitle =>
      'Frekvencia, výkon, rozptylovací faktor';

  @override
  String get settings_radioSettingsUpdated => 'Nastavenia rádia aktualizované';

  @override
  String get settings_regionSettings => 'Regiony';

  @override
  String get settings_regionSettingsSubtitle => 'Zohľať uložené regiony';

  @override
  String get settings_corridorRegion => 'Región koridoru';

  @override
  String get settings_corridorRegionDefault => '#corridor (predvolený)';

  @override
  String get settings_corridorRegionHelp =>
      'Pakety flood koridoru sa označujú týmto regiónom. Opakovače bez firmvéru koridoru ich posielajú ďalej iba vtedy, ak tento región povoľujú. Nechajte prázdne pre predvolenú značku #corridor.';

  @override
  String get settings_corridorRegionHint => 'Názov regiónu';

  @override
  String get settings_corridorRegionUseDefault => 'Použiť predvolený';

  @override
  String get settings_corridorRegionUpdated => 'Región koridoru aktualizovaný';

  @override
  String get settings_corridorRegionFailed =>
      'Región koridoru sa nepodarilo aktualizovať';

  @override
  String get settings_regionManagement_screenTitle => 'Regiónne vedenie';

  @override
  String get settings_regionNameHint => 'Vstuptejte název regionu';

  @override
  String get settings_regionAddRegion => 'Dodajte region';

  @override
  String get settings_regionFetchRegions => 'Odberanie regionov z repeaterov';

  @override
  String get settings_regionFetchRegionsFail => 'Nebylo našli žiadné regiony';

  @override
  String get settings_regionFetchRegionsAlreadyExists =>
      'Tento oblast je už dodán';

  @override
  String get settings_regionName => 'Regionné název';

  @override
  String get settings_regionDeleted => 'Regionu zníteno';

  @override
  String get settings_deleteRegion => 'Vyniknúcia regionu';

  @override
  String settings_deleteRegionConfirm(String region) {
    return 'Odstraniť $region z listy regionov?';
  }

  @override
  String get settings_location => 'Lokalita';

  @override
  String get settings_locationSubtitle => 'GPS súradnice';

  @override
  String get settings_locationUpdated => 'Lokalita aktualizovaná';

  @override
  String get settings_locationBothRequired =>
      'Zadajte obidve zložky zemyslenia a zložky meracieho kruhu.';

  @override
  String get settings_locationInvalid => 'Neplatná šírka alebo dĺžka.';

  @override
  String get settings_locationGPSEnable => 'Aktivovať GPS';

  @override
  String get settings_locationGPSEnableSubtitle =>
      'Povolí automatické aktualizovanie polohy pomocou GPS.';

  @override
  String get settings_locationIntervalSec => 'Interval pre GPS (Sekundy)';

  @override
  String get settings_locationIntervalInvalid =>
      'Interval musí byť aspoň 60 sekúnd a menej ako 86400 sekúnd.';

  @override
  String get settings_latitude => 'Súradnica';

  @override
  String get settings_longitude => 'Dĺžka';

  @override
  String get settings_contactSettings => 'Nastavenia kontaktov';

  @override
  String get settings_contactSettingsSubtitle =>
      'Nastavenia pre pridávanie kontaktov.';

  @override
  String get settings_privacyMode => 'Režim ochrany súkromia';

  @override
  String get settings_privacyModeSubtitle => 'Skryť meno/poloha v reklamách';

  @override
  String get settings_privacyModeToggle =>
      'Prepínač súkromného režimu skryje vaše meno a polohu v reklamách.';

  @override
  String get settings_privacyModeEnabled => 'Ochranný režim je povolený.';

  @override
  String get settings_privacyModeDisabled => 'Ochranný režim je vypnutý';

  @override
  String get settings_privacy => 'Nastavenia súkromia';

  @override
  String get settings_privacySubtitle => 'Ovládni, aké informácie sa zdieľajú.';

  @override
  String get settings_privacySettingsDescription =>
      'Vyberte, ktoré informácie váš zariadenie zdieľa s ostatnými.';

  @override
  String get settings_denyAll => 'Zamietnuť všetko';

  @override
  String get settings_allowByContact => 'Povoliť podľa kontaktových vlajok';

  @override
  String get settings_allowAll => 'Povoliť všetko';

  @override
  String get settings_telemetryBaseMode => 'Základný režim telemetrie';

  @override
  String get settings_telemetryLocationMode => 'Režim umiestnenia telemetrie';

  @override
  String get settings_telemetryEnvironmentMode => 'Režim prostredia telemetrie';

  @override
  String get settings_advertLocation => 'Umiestnenie inzerátu';

  @override
  String get settings_advertLocationSubtitle => 'Zahrnúť polohu do inzerátu';

  @override
  String get settings_autoZeroHopAdvertOnGpsUpdate =>
      'Automatický zero-hop inzerát pri aktualizácii GPS';

  @override
  String get settings_autoZeroHopAdvertOnGpsUpdateSubtitle =>
      'Keď sa GPS poloha zmení, odoslať zero-hop inzerát (vyžaduje polohu v inzeráte).';

  @override
  String get settings_multiAck => 'Viaceré ACK';

  @override
  String get settings_telemetryModeUpdated =>
      'Režim telemetrie bol aktualizovaný';

  @override
  String get settings_actions => 'Možné akcie';

  @override
  String get settings_deleteAllPaths => 'Delete All Paths';

  @override
  String get settings_deleteAllPathsSubtitle =>
      'Clear all path data from contacts.';

  @override
  String get settings_sendAdvertisement => 'Odoslať reklamu';

  @override
  String get settings_sendAdvertisementSubtitle => 'Momentálne priezornejšie.';

  @override
  String get settings_advertisementSent => 'Reklama odeslaná';

  @override
  String get settings_syncTime => 'Čas synchronizácie';

  @override
  String get settings_syncTimeSubtitle =>
      'Nastaviť hodiny zariadenia na čas telefónu';

  @override
  String get settings_timeSynchronized => 'Čas synchronizovaný';

  @override
  String get settings_refreshContacts => 'Načítať Kontakty';

  @override
  String get settings_refreshContactsSubtitle =>
      'Načítať zoznam kontaktov z zariadenia';

  @override
  String get settings_rebootDevice => 'Restartovať zariadenie';

  @override
  String get settings_rebootDeviceSubtitle =>
      'Restartujte zariadenie MeshCore.';

  @override
  String get settings_rebootDeviceConfirm =>
      'Ste si istý, že chcete zariadenie reštartovať? Budete odpojení.';

  @override
  String get settings_debug => 'Ladenie';

  @override
  String get settings_companionDebugLog =>
      'Logovanie pre ladenie (sprievodný log)';

  @override
  String get settings_companionDebugLogSubtitle =>
      'Príkazy, odpovede a surové dáta pre protokoly BLE/TCP/USB';

  @override
  String get settings_appDebugLog => 'Záznam ladenia aplikácie';

  @override
  String get settings_appDebugLogSubtitle => 'Správy z ladenia aplikácie';

  @override
  String get settings_about => 'O nás';

  @override
  String settings_aboutVersion(String version) {
    return 'MeshCore, verzia $version';
  }

  @override
  String get settings_aboutLegalese => 'MeshCore Open Source Projekt 2024';

  @override
  String get settings_aboutDescription =>
      'Otvorený zdrojový Flutter klient pre MeshCore LoRa sieťové zariadenia.';

  @override
  String get settings_aboutOpenMeteoAttribution =>
      'Údaje o nadmorskej výške LOS: Open-Meteo (CC BY 4.0)';

  @override
  String get settings_infoName => 'Meno';

  @override
  String get settings_infoId => 'Identifikátor';

  @override
  String get settings_infoStatus => 'Stav';

  @override
  String get settings_infoBattery => 'Batéria';

  @override
  String get settings_infoPublicKey => 'Verejný kľúč';

  @override
  String get settings_infoContactsCount => 'Počet kontaktov';

  @override
  String get settings_infoChannelCount => 'Počet kanálov';

  @override
  String get settings_infoHardware => 'Hardware';

  @override
  String get settings_infoFirmware => 'Firmware';

  @override
  String get settings_presets => 'Prednastavenia';

  @override
  String get settings_frequency => 'Frekvencia (MHz)';

  @override
  String get settings_frequencyHelper => '300,0 – 2500,0';

  @override
  String get settings_frequencyInvalid => 'Neplatná frekvencia (300-2500 MHz)';

  @override
  String get settings_bandwidth => 'Šírka pásma';

  @override
  String get settings_spreadingFactor => 'Rozptýľovací faktor';

  @override
  String get settings_codingRate => 'Cenový kurz pre programovanie';

  @override
  String get settings_txPower => 'TX Výkon (dBm)';

  @override
  String get settings_txPowerHelper => '0 – 22';

  @override
  String get settings_txPowerInvalid => 'Neplatná hodnota výkonu TX (0-22 dBm)';

  @override
  String get settings_clientRepeat => 'Opätovné použitie bez elektrickej siete';

  @override
  String get settings_clientRepeatSubtitle =>
      'Umožnite, aby toto zariadenie opakovávalo siete pre ostatných.';

  @override
  String get settings_clientRepeatFreqWarning =>
      'Použitie off-grid systému vyžaduje frekvencie 433, 869 alebo 918 MHz.';

  @override
  String settings_error(String message) {
    return 'Chyba: $message';
  }

  @override
  String get appSettings_title => 'Nastavenia aplikácie';

  @override
  String get appSettings_appearance => 'Vzhľad';

  @override
  String get appSettings_theme => 'Téma';

  @override
  String get appSettings_themeSystem => 'Predvolený systém';

  @override
  String get appSettings_themeLight => 'Svetlo';

  @override
  String get appSettings_themeDark => 'Tmavé';

  @override
  String get appSettings_language => 'Jazyk';

  @override
  String get appSettings_languageSystem => 'Predvolený systém';

  @override
  String get appSettings_languageEn => 'Anglicky';

  @override
  String get appSettings_languageFr => 'Francúzština';

  @override
  String get appSettings_languageEs => 'Španielsky';

  @override
  String get appSettings_languageDe => 'Nemecky';

  @override
  String get appSettings_languagePl => 'Poľský';

  @override
  String get appSettings_languageSl => 'Slovenčina';

  @override
  String get appSettings_languagePt => 'Portugalčina';

  @override
  String get appSettings_languageIt => 'Taliančina';

  @override
  String get appSettings_languageZh => 'Čínština';

  @override
  String get appSettings_languageSv => 'Švédska';

  @override
  String get appSettings_languageNl => 'Niderlandsky';

  @override
  String get appSettings_languageSk => 'Slovenčina';

  @override
  String get appSettings_languageBg => 'Българština';

  @override
  String get appSettings_languageRu => 'Ruština';

  @override
  String get appSettings_languageUk => 'Ukrajinská';

  @override
  String get repeater_pathHashModeOption0 => '0 - 1 byt';

  @override
  String get repeater_pathHashModeOption1 => '1 - 2 bity';

  @override
  String get repeater_pathHashModeOption2 => '2 - 3 bity';

  @override
  String get repeater_pathHashModeOption3 => '3 - 4 bity';

  @override
  String get appSettings_enableMessageTracing => 'Povoliť sledovanie správ';

  @override
  String get appSettings_enableMessageTracingSubtitle =>
      'Zobraziť podrobné metadáta o smerovaní a časovaní správ';

  @override
  String get appSettings_notifications => 'Upozornenia';

  @override
  String get appSettings_enableNotifications => 'Povolte Notifikácie';

  @override
  String get appSettings_enableNotificationsSubtitle =>
      'Zísť o upozornenia na správy a inzeráty';

  @override
  String get appSettings_notificationPermissionDenied =>
      'Odmietená povolenie notifikácií';

  @override
  String get appSettings_notificationsEnabled => 'Upozornenia povolené';

  @override
  String get appSettings_notificationsDisabled => 'Upozornenia sú vypnuté';

  @override
  String get appSettings_messageNotifications => 'Správy od upozornení';

  @override
  String get appSettings_messageNotificationsSubtitle =>
      'Zobraziť upozornenie pri prijímaní nových správ';

  @override
  String get appSettings_channelMessageNotifications => 'Notifikácie z kanálov';

  @override
  String get appSettings_channelMessageNotificationsSubtitle =>
      'Zobraziť upozornenie pri prijímaní správ z kanálu';

  @override
  String get appSettings_advertisementNotifications => 'Upozornenia na reklamy';

  @override
  String get appSettings_advertisementNotificationsSubtitle =>
      'Zobraziť upozornenie, keď sa objavia nové uzly.';

  @override
  String get appSettings_messaging => 'Správy';

  @override
  String get appSettings_clearPathOnMaxRetry => 'Vyčisti cestu na Max Retry';

  @override
  String get appSettings_clearPathOnMaxRetrySubtitle =>
      'Resetovať kontaktný priebeh po 5 neúspešných pokusoch o doručenie';

  @override
  String get appSettings_pathsWillBeCleared =>
      'Cesty budú vymazané po 5 neúspešných pokusoch.';

  @override
  String get appSettings_pathsWillNotBeCleared =>
      'Cesty sa automaticky nevymazávajú.';

  @override
  String get appSettings_autoRouteRotation => 'Automatické prechodové trasy';

  @override
  String get appSettings_autoRouteRotationSubtitle =>
      'Striedajte sa medzi najlepšími trasami a režimom povodňovej analýzy.';

  @override
  String get appSettings_autoRouteRotationEnabled =>
      'Automatické otáčanie trasy povolené';

  @override
  String get appSettings_autoRouteRotationDisabled =>
      'Automatické prekladanie trás pozastavené';

  @override
  String get appSettings_maxRouteWeight => 'Maximálna hmotnosť trasy';

  @override
  String get appSettings_maxRouteWeightSubtitle =>
      'Maximálna hmotnosť, ktorú môže trás prenášať vďaka úspešným zásielkam.';

  @override
  String get appSettings_initialRouteWeight => 'Počiatočná váha trasy';

  @override
  String get appSettings_initialRouteWeightSubtitle =>
      'Počiatočná váha pre nové, objavené cesty';

  @override
  String get appSettings_routeWeightSuccessIncrement => 'Zvyšenie váhy úspechu';

  @override
  String get appSettings_routeWeightSuccessIncrementSubtitle =>
      'Hmotnosť pridaná k trase po úspešnej doručení';

  @override
  String get appSettings_routeWeightFailureDecrement =>
      'Sníženie váhy, ktorá sa používa na odhad rizika.';

  @override
  String get appSettings_routeWeightFailureDecrementSubtitle =>
      'Hmotnosť odstránená z cesty po neúspešnej doručenie';

  @override
  String get appSettings_maxMessageRetries =>
      'Maximalný počet pokusov o doručenie správ';

  @override
  String get appSettings_maxMessageRetriesSubtitle =>
      'Počet pokusov o odošleť pred označením správy ako neúspešnej';

  @override
  String get appSettings_battery => 'Batéria';

  @override
  String get appSettings_batteryChemistry => 'Chemická zloženie batérie';

  @override
  String appSettings_batteryChemistryPerDevice(String deviceName) {
    return 'Nastavenie pre $deviceName';
  }

  @override
  String get appSettings_batteryChemistryConnectFirst =>
      'Pripojte sa k zariadeniu na výber';

  @override
  String get appSettings_batteryNmc => '18650 NMC (3,0-4,2V)';

  @override
  String get appSettings_batteryLifepo4 => 'LiFePO4 (2,6–3,65V)';

  @override
  String get appSettings_batteryLipo => 'LiPo (3,0-4,2V)';

  @override
  String get appSettings_batteryLipoHv => 'LiPo HV (3.0-4.35V)';

  @override
  String get appSettings_mapDisplay => 'Zobrazenie mapy';

  @override
  String get appSettings_showRepeaters => 'Zobraziť opakovače';

  @override
  String get appSettings_showRepeatersSubtitle =>
      'Zobraziť opakujúce sa uzly na mape';

  @override
  String get appSettings_showChatNodes => 'Zobraziť uzly chatových správ';

  @override
  String get appSettings_showChatNodesSubtitle =>
      'Zobraziť chatové uzly na mape';

  @override
  String get appSettings_showOtherNodes => 'Zobraziť ďalšie uzly';

  @override
  String get appSettings_showOtherNodesSubtitle =>
      'Zobraziť ostatné typy uzlov na mape';

  @override
  String get appSettings_timeFilter => 'Filtrovacie Časové Obdoby';

  @override
  String get appSettings_timeFilterShowAll => 'Zobraziť všetky uzly';

  @override
  String appSettings_timeFilterShowLast(int hours) {
    return 'Zobraziť uzly z posledných $hours hodín';
  }

  @override
  String get appSettings_mapTimeFilter => 'Filtračný čas mapy';

  @override
  String get appSettings_showNodesDiscoveredWithin =>
      'Zobraziť uzly objavené v:';

  @override
  String get appSettings_allTime => 'Všetky časy';

  @override
  String get appSettings_lastHour => 'Posledná hodina';

  @override
  String get appSettings_last6Hours => 'Posledné 6 hodín';

  @override
  String get appSettings_last24Hours => 'Posledných 24 hodín';

  @override
  String get appSettings_lastWeek => 'Minul týždeň';

  @override
  String get appSettings_rasterTileSource => 'Zdroj rastrových dlaždíc';

  @override
  String get appSettings_stadiaEndpoint => 'Koncový bod Stadia';

  @override
  String get appSettings_stadiaApiKey => 'Kľúč API Stadia';

  @override
  String get appSettings_stadiaApiKeyRequired =>
      'Vyžaduje sa na používanie Stadia Maps';

  @override
  String appSettings_stadiaApiKeyConfigured(String maskedKey) {
    return 'Nakonfigurované: $maskedKey';
  }

  @override
  String get appSettings_stadiaApiKeyDialogDescription =>
      'Zadajte svoj kľúč API pre Stadia Maps. Aplikácia ho používa na požiadavky na rastrové dlaždice.';

  @override
  String get appSettings_offlineMapCache => 'Offline Mapa Pamäť';

  @override
  String get appSettings_unitsTitle => 'Jednotky';

  @override
  String get appSettings_unitsMetric => 'Metrické (m / km / °C)';

  @override
  String get appSettings_unitsImperial => 'Imperiálne (ft / mi / °F)';

  @override
  String get appSettings_noAreaSelected => 'Neoznačila sa žiadna oblasť';

  @override
  String appSettings_areaSelectedZoom(int minZoom, int maxZoom) {
    return 'Vyberená oblasť (zoom $minZoom-$maxZoom)';
  }

  @override
  String get appSettings_debugCard => 'Ladenie';

  @override
  String get appSettings_appDebugLogging => 'Záznamy ladenia aplikácie';

  @override
  String get appSettings_appDebugLoggingSubtitle =>
      'Logovací správy aplikácie pre ladenie';

  @override
  String get appSettings_appDebugLoggingEnabled =>
      'Aplikácia povolila ladenie protokolmi';

  @override
  String get appSettings_appDebugLoggingDisabled =>
      'Zabudované ladenie aplikácie je vypnuté.';

  @override
  String get contacts_title => 'Kontakty';

  @override
  String get contacts_noContacts => 'Zatiaľ žiadne kontakty.';

  @override
  String get contacts_contactsWillAppear =>
      'Kontakty sa zobrazia, keď zariadenia spúšťajú reklamu.';

  @override
  String get contacts_unread => 'Neprečítané';

  @override
  String get contacts_searchContactsNoNumber => 'Hľadať kontakty...';

  @override
  String contacts_searchContacts(int number, String str) {
    return 'Vyhľadávajte kontakty...';
  }

  @override
  String contacts_searchFavorites(int number, String str) {
    return 'Hľadať $number$str obľúbené...';
  }

  @override
  String contacts_searchUsers(int number, String str) {
    return 'Hľadať $number$str používateľov...';
  }

  @override
  String contacts_searchRepeaters(int number, String str) {
    return 'Hľadať $number$str opakovače...';
  }

  @override
  String contacts_searchRoomServers(int number, String str) {
    return 'Hľadaj $number$str serverov miestností...';
  }

  @override
  String get contacts_noUnreadContacts => 'Žiadne neprečítané kontakty';

  @override
  String get contacts_noContactsFound =>
      'Neboli nájdených žiadnych kontaktov ani skupiny.';

  @override
  String get contacts_deleteContact => 'Odstrániť kontakt';

  @override
  String contacts_removeConfirm(String contactName) {
    return 'Odstrániť $contactName z kontaktov?';
  }

  @override
  String get contacts_manageRepeater => 'Spravovať opakované zoznamy';

  @override
  String get contacts_manageRoom => 'Spravovať server miestnosti';

  @override
  String get contacts_roomLogin => 'Prihlásenie do miestnosti';

  @override
  String get contacts_openChat => 'Otvorené Chat';

  @override
  String get contacts_editGroup => 'Upraviť skupinu';

  @override
  String get contacts_deleteGroup => 'Vymažť skupinu';

  @override
  String contacts_deleteGroupConfirm(String groupName) {
    return 'Odstrániť \"$groupName\"?';
  }

  @override
  String get contacts_newGroup => 'Nová skupina';

  @override
  String get contacts_moreOptions => 'Ďalšie možnosti';

  @override
  String get contacts_searchOpen => 'Vyhľadajte kontakty';

  @override
  String get contacts_searchClose => 'Zavrieť vyhľadávanie';

  @override
  String get contacts_groupName => 'Názov skupiny';

  @override
  String get contacts_groupNameRequired => 'Skupina musí mať názov.';

  @override
  String get contacts_groupNameReserved => 'Tento názov skupiny je rezervovaný';

  @override
  String contacts_groupAlreadyExists(String name) {
    return 'Skupina \"$name\" už existuje';
  }

  @override
  String get contacts_filterContacts => 'Filtrovať kontakty...';

  @override
  String get contacts_noContactsMatchFilter =>
      'Žiadne kontakty neodídu vášmu filtru.';

  @override
  String get contacts_noMembers => 'Žiadni členovia';

  @override
  String get contacts_lastSeenNow => 'Posledné zreteľné zobrazenie teraz';

  @override
  String contacts_lastSeenMinsAgo(int minutes) {
    return 'Posledné zobrazenie $minutes min. dozadu';
  }

  @override
  String get contacts_lastSeenHourAgo =>
      'Zobral/Zabral poslednýkrát pred hodinou.';

  @override
  String contacts_lastSeenHoursAgo(int hours) {
    return 'Posledné zobrazenie $hours hodín dozadu';
  }

  @override
  String get contacts_lastSeenDayAgo =>
      'Zobral/Zabral posledný raz pred 1 dňom.';

  @override
  String contacts_lastSeenDaysAgo(int days) {
    return 'Posledné zobrazenie $days dní dozadu';
  }

  @override
  String get contact_info => 'Kontaktné informácie';

  @override
  String get contact_settings => 'Nastavenia kontaktov';

  @override
  String get contact_telemetry => 'Telemetria';

  @override
  String get contact_lastSeen => 'Naposledy videný';

  @override
  String get contact_clearChat => 'Vymazať chat';

  @override
  String get contact_teleBase => 'Báza telemetrie';

  @override
  String get contact_teleBaseSubtitle =>
      'Povoliť zdieľanie úrovne batérie a základnej telemetrie';

  @override
  String get contact_teleLoc => 'Lokácia telemetrie';

  @override
  String get contact_teleLocSubtitle => 'Povoliť zdieľanie údajov o lokalite';

  @override
  String get contact_teleEnv => 'Prostredie telemetrie';

  @override
  String get contact_teleEnvSubtitle =>
      'Povoliť zdieľanie údajov senzorov prostredia';

  @override
  String get channels_title => 'Kanály';

  @override
  String get channels_noChannelsConfigured => 'Neobsiahnuté žiadne kanály';

  @override
  String get channels_addPublicChannel => 'Pridať verejný kanál';

  @override
  String get channels_searchChannels => 'Vyhľadávajte kanály...';

  @override
  String get channels_noChannelsFound => 'Neobsiahlo sa žiadnych kanálov.';

  @override
  String channels_channelIndex(int index) {
    return 'Kanál $index';
  }

  @override
  String get channels_public => 'Veľké verejné';

  @override
  String channels_via(String path) {
    return 'via $path';
  }

  @override
  String get channels_viaMqtt => 'cez MQTT';

  @override
  String get channels_viaMqttSemantics =>
      'Prijaté cez MQTT, vaše rádio to nepočulo';

  @override
  String get channels_private => 'Osobné';

  @override
  String get channels_editChannel => 'Upraviť kanál';

  @override
  String get channels_muteChannel => 'Stlmiť kanál';

  @override
  String get channels_unmuteChannel => 'Zrušiť stlmenie kanála';

  @override
  String get channels_deleteChannel => 'Odstrániť kanál';

  @override
  String channels_deleteChannelConfirm(String name) {
    return 'Odstrániť \"$name\"? To sa nedá zrušiť.';
  }

  @override
  String channels_channelDeleteFailed(String name) {
    return 'Kanál \"$name\" sa nepodarilo odstrániť';
  }

  @override
  String channels_channelDeleted(String name) {
    return 'Kanál \"$name\" bol odstránený';
  }

  @override
  String get channels_addChannel => 'Pridať kanál';

  @override
  String get channels_channelIndexLabel => 'Index kanála';

  @override
  String get channels_channelName => 'Názov kanálu';

  @override
  String get channels_usePublicChannel => 'Použite verejný kanál';

  @override
  String get channels_standardPublicPsk => 'Štandardný verejný PSK';

  @override
  String get channels_pskHex => 'PSK (Šifrovacia kľúčik)';

  @override
  String get channels_generateRandomPsk => 'Generovať náhodný PSK';

  @override
  String get channels_enterChannelName => 'Prosím, zadajte názov kanála.';

  @override
  String get channels_pskMustBe32Hex =>
      'PSK musí mať 32 hexadecimálových znakov.';

  @override
  String channels_channelAdded(String name) {
    return 'Kanál \"$name\" pridaný';
  }

  @override
  String channels_editChannelTitle(int index) {
    return 'Upraviť kanál $index';
  }

  @override
  String get channels_smazCompression => 'Odstránenie kompresie SMAZ';

  @override
  String get channels_cyr2latCompression => 'Odstránenie kompresie Cyr2Lat';

  @override
  String get channels_cyr2latCompressionDscr =>
      'Pri odosielaní nahradí niektoré znaky cyriliky latinskými znakmi.';

  @override
  String get channels_cyr2latSettingsHeading => 'Nastavenia Cyr2Lat';

  @override
  String get channels_cyr2latSettingsSubheading => 'Zoznam nahradení';

  @override
  String get channels_cyr2latSettingsDscr =>
      'Upravte konfiguráciu JSON pre nahradenie znakov';

  @override
  String get channels_cyr2latSettingsDialogHint => 'JSON mapa nahradení';

  @override
  String channels_cyr2latSettingsDialogWrongJSON(Object error) {
    return 'Nesprávny JSON: $error';
  }

  @override
  String channels_channelUpdated(String name) {
    return 'Kanál \"$name\" bol aktualizovaný';
  }

  @override
  String get settings_cyr2latProfileAdd => 'Pridať profil Cyr2Lat';

  @override
  String get settings_cyr2latProfileName => 'Názov profilu';

  @override
  String get settings_cyr2latProfileNameEmpty =>
      'Názov profilu nesmie byť prázdny';

  @override
  String get settings_cyr2latProfileAdded => 'Profil bol úspešne pridaný';

  @override
  String get settings_cyr2latProfileUpdated =>
      'Profil bol úspešne aktualizovaný';

  @override
  String get settings_cyr2latProfileEdit => 'Upraviť profil Cyr2Lat';

  @override
  String get settings_cyr2latProfileDelete => 'Odstrániť profil Cyr2Lat';

  @override
  String get settings_cyr2latProfileDeleted => 'Profil bol úspešne odstránený';

  @override
  String settings_cyr2latProfileDeleteDscr(String name) {
    return 'Naozaj chcete odstrániť profil \"$name\"?';
  }

  @override
  String get channels_publicChannelAdded => 'Veľký kanál pridaný';

  @override
  String get channels_sortBy => 'Triediť podľa';

  @override
  String get channels_sortManual => 'Ručne';

  @override
  String get channels_sortAZ => 'Od A po Z';

  @override
  String get channels_sortLatestMessages => 'Posledné správy';

  @override
  String get channels_sortUnread => 'Nezriadené';

  @override
  String get channels_createPrivateChannel => 'Vytvorte súkromný kanál';

  @override
  String get channels_createPrivateChannelDesc =>
      'Zabezpečené pomocou tajného kľúča.';

  @override
  String get channels_joinPrivateChannel => 'Pripojiť sa k súkromnému kanálu';

  @override
  String get channels_joinPrivateChannelDesc => 'Ručne zadajte tajný kľúč.';

  @override
  String get channels_joinPublicChannel => 'Pripojte sa k verejnému kanálu';

  @override
  String get channels_joinPublicChannelDesc =>
      'Któvek sátó na tutó kanalizovát.';

  @override
  String get channels_joinHashtagChannel => 'Pripojte sa k Hashtag Kanálu';

  @override
  String get channels_joinHashtagChannelDesc =>
      'Ktoekolikoľvek sa môže pridať do hashtag kanálov.';

  @override
  String get channels_scanQrCode => 'Skenujte QR kód';

  @override
  String get channels_scanQrCodeComingSoon => 'Čoskoro';

  @override
  String get channels_enterHashtag => 'Zadajte hashtag';

  @override
  String get channels_hashtagHint => 'napr. #tím';

  @override
  String channels_regionSetTo(String region) {
    return 'Region: $region';
  }

  @override
  String get channels_regionNotSet => 'Region: žiadné';

  @override
  String get channels_regionSelect_Title => 'Vyberte region';

  @override
  String get channels_clearRegion => 'Jasný údajný oblasť';

  @override
  String get chat_noMessages => 'Zatiaľ žiadne správy.';

  @override
  String get chat_sendMessage => 'Odoslať správu';

  @override
  String chat_sendMessageTo(String contactName) {
    return 'Pošli správu $contactName';
  }

  @override
  String get chat_sendMessageToStart => 'Pošlite správu na začiatok';

  @override
  String get chat_originalMessageNotFound => 'Neznámy pôvodný odkaz.';

  @override
  String chat_replyingTo(String name) {
    return 'Odpovedám $name';
  }

  @override
  String chat_replyTo(String name) {
    return 'Odpovedať $name';
  }

  @override
  String get chat_location => 'Lokalita';

  @override
  String get chat_typeMessage => 'Napište správu...';

  @override
  String chat_messageTooLong(int maxBytes) {
    return 'Správa je príliš dlhá (max $maxBytes bytov).';
  }

  @override
  String chat_airtimeEstimate(String seconds) {
    return '≈$seconds s vysielania';
  }

  @override
  String get chat_messageCopied => 'Správa skopírovaná';

  @override
  String get chat_messageDeleted => 'Posolstvo odstránené';

  @override
  String get chat_retryingMessage => 'Pokus o obnovenie';

  @override
  String chat_retryCount(int current, int max) {
    return 'Skúsiť $current/$max';
  }

  @override
  String get chat_selectSendAction => 'Vybrať akciu odoslania';

  @override
  String get chat_sendGif => 'Odoslať GIF';

  @override
  String get chat_limitToArea => 'Obmedziť na oblasť';

  @override
  String get chat_limitToAreaTitle => 'Posielať iba v rámci…';

  @override
  String get chat_limitToAreaHelp =>
      'Opakovače s firmvérom flood koridoru posielajú správu ďalej iba v tejto oblasti. Ostatné opakovače ju zahodia, pokiaľ nepovoľujú váš región koridoru.';

  @override
  String chat_limitToAreaRadius(int km) {
    return '$km km od vás';
  }

  @override
  String chat_limitToAreaActive(int km) {
    return 'Iba do $km km od vás';
  }

  @override
  String get chat_limitToAreaOff => 'Bez obmedzenia';

  @override
  String get chat_limitToAreaNeedsPosition =>
      'Nastavte polohu rádia, aby ste mohli obmedziť správy na oblasť.';

  @override
  String get chat_sendImageLora => 'Odoslať obrázok cez MeshCore';

  @override
  String get chat_imagePickFailed => 'Nesmiela jsem otvoriť tento obrázok';

  @override
  String get chat_receivedGif => 'Odeslaný GIF';

  @override
  String get chat_reply => 'Odpovedať';

  @override
  String get chat_addReaction => 'Pridať Reakciu';

  @override
  String get chat_me => 'Mne';

  @override
  String get reaction_report => 'Reakcie emoji';

  @override
  String get emojiCategorySmileys => 'Emoji';

  @override
  String get emojiCategoryGestures => 'Gestá';

  @override
  String get emojiCategoryHearts => 'Srdcia';

  @override
  String get emojiCategoryObjects => 'Objekty';

  @override
  String get gifPicker_title => 'Vyberte GIF';

  @override
  String get gifPicker_searchHint => 'Vyhľadávajte GIFy...';

  @override
  String get gifPicker_poweredBy => 'Napájané spoločnosťou GIPHY';

  @override
  String get gifPicker_noGifsFound => 'Neboli nájdené žiadne GIFy.';

  @override
  String get gifPicker_failedLoad => 'Nepodarilo sa načítať GIFy';

  @override
  String get gifPicker_failedSearch => 'Nepodarilo sa vyhľadať GIFy';

  @override
  String get gifPicker_noInternet => 'Žiadna internetová konektivita';

  @override
  String get debugLog_appTitle => 'Záznam ladenia aplikácie';

  @override
  String get debugLog_bleTitle => 'Log BLE Debug';

  @override
  String get debugLog_copyLog => 'Kopírovať záznam';

  @override
  String get debugLog_clearLog => 'Vymažať záznam';

  @override
  String get debugLog_copied => 'Záznam ladenia skopírovaný';

  @override
  String get debugLog_bleCopied => 'Kopírovaný záznam z BLE.';

  @override
  String get debugLog_noEntries =>
      'Zatiaľ neboli zaznamenané žiadne debug logy.';

  @override
  String get debugLog_enableInSettings =>
      'Povolte ladicové logy v nastaveniach';

  @override
  String get debugLog_frames => 'Rámce';

  @override
  String get debugLog_rawLogRx => 'Čistý log – RX';

  @override
  String get debugLog_noBleActivity => 'Zatiaľ žiadna aktivita BLE.';

  @override
  String debugFrame_length(int count) {
    return 'Dĺžka rámca: $count bajtov';
  }

  @override
  String debugFrame_command(String value) {
    return 'Prikáž: 0x$value';
  }

  @override
  String get debugFrame_textMessageHeader => 'Textová zvesť:';

  @override
  String debugFrame_destinationPubKey(String pubKey) {
    return '- Cieľový PubKey: $pubKey';
  }

  @override
  String debugFrame_timestamp(int timestamp) {
    return '- Časové označenie: $timestamp';
  }

  @override
  String debugFrame_flags(String value) {
    return '- Žiadne vlajky: 0x$value';
  }

  @override
  String debugFrame_textType(int type, String label) {
    return '- Typ textu: $type ($label)';
  }

  @override
  String get debugFrame_textTypeCli => 'CLI (Command Line Interface)';

  @override
  String get debugFrame_textTypePlain => 'Jednoduché';

  @override
  String debugFrame_text(String text) {
    return '- Text: \"$text\"';
  }

  @override
  String get debugFrame_hexDump => 'Hexová analýza:';

  @override
  String chat_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'skoky',
      one: 'skok',
    );
    return '$count $_temp0';
  }

  @override
  String get chat_removePath => 'Odstrániť cestu';

  @override
  String get chat_noPathHistoryYet =>
      'Zatiaľ žiadna história trás.\nPošlite správu a objavte trasy.';

  @override
  String get chat_pathCleared =>
      'Cesta vyčistená. Nasledujúce prepočetné získa trasu znova.';

  @override
  String get chat_fullPath => 'Celá cesta';

  @override
  String get routing_title => 'Navigácia';

  @override
  String get routing_modeAuto => 'Auto';

  @override
  String get routing_modeFlood => 'Povodňová vlna';

  @override
  String get routing_modeManual => 'Ručná príručka';

  @override
  String get routing_modeAutoHint =>
      'Automaticky vyberá najznámejší trasa, a ak žiadna nie je známa, použije náhodnú trasu.';

  @override
  String get routing_modeFloodHint =>
      'Prenos prostredníctvom všetkých opakovačov. Najspoľahlivejší spôsob, ale vyžaduje viac času vysielania.';

  @override
  String get routing_modeManualHint =>
      'Vždy dodáva presne podľa zadaného trasy.';

  @override
  String get routing_currentRoute => 'Aktuálna trasa';

  @override
  String get routing_directNoHops => 'Priamo – bez prechodných trás';

  @override
  String get routing_noPathYet =>
      'Zatiaľ neexistuje žiadna cesta. Nasledujúce správy budú pokračovať, kým sa nenájde trasa.';

  @override
  String get routing_floodBroadcast =>
      'Prenos prostredníctvom každého opakovača';

  @override
  String get routing_editPath => 'Upraviť trasu';

  @override
  String get routing_forgetPath => 'Zabudnite na trasu';

  @override
  String get routing_knownPaths => 'Známe cesty';

  @override
  String get routing_knownPathsHint =>
      'Kliknite na cestu, aby ste sa k nej presunuli.';

  @override
  String get routing_inUse => 'V prevádzke';

  @override
  String get routing_qualityStrong => 'Silný prvý krok';

  @override
  String get routing_qualityGood => 'Úspešný prvý krok';

  @override
  String get routing_qualityFair => 'Prvá, spravodlivá fáza';

  @override
  String get routing_qualityWorked => 'Dosiahnutý úspech';

  @override
  String get routing_qualityFlood =>
      'Zistil som to z informácií, ktoré som získal v dôsledku povodňovej situácie.';

  @override
  String get routing_qualityUntested => 'Neotestované';

  @override
  String routing_lastWorked(String when) {
    return 'worked $when';
  }

  @override
  String get routing_neverWorked => 'nikedy nebolo potvrdené';

  @override
  String routing_deliveryCounts(int successes, int failures) {
    return '$successes delivered, $failures failed';
  }

  @override
  String get routing_floodDelivery => 'Doručenie v prípade povodní';

  @override
  String get pathEditor_title => 'Vytvorenie cesty';

  @override
  String pathEditor_hopCounter(int count) {
    return '$count z 64 chmelových zŕš';
  }

  @override
  String get pathEditor_noHops =>
      'Zatiaľ žiadne chmel. Kliknite na opakované, aby ste ich pridali postupne, alebo uložte bez chmelu, aby ste ho mohli poslať priamo.';

  @override
  String get pathEditor_addHops => 'Pridávajte chmel podľa zadaného poriadku.';

  @override
  String get pathEditor_searchRepeaters => 'Hľadať opakované';

  @override
  String get pathEditor_advancedHex => 'Pokročilé: pôvodná hexová cesta';

  @override
  String get pathEditor_hexLabel => 'Prefiksy pre hexadecimálne čísla';

  @override
  String get pathEditor_hexHelper =>
      'Dve hexové čísla na každý krok, oddelené čiarkami';

  @override
  String pathEditor_invalidTokens(String tokens) {
    return 'Neplatné: $tokens';
  }

  @override
  String get pathEditor_tooManyHops => 'Maximálne 64 krokov';

  @override
  String get pathEditor_usePath => 'Použite túto cestu';

  @override
  String get pathEditor_removeHop => 'Odstráňte chmel';

  @override
  String get pathEditor_unknownHop =>
      'Neznáme zariadenie na opakované vysielanie';

  @override
  String get chat_pathSavedLocally =>
      'Uložené lokálne. Spojte sa na synchronizáciu.';

  @override
  String get chat_pathDeviceConfirmed => 'Zariadenie potvrdené.';

  @override
  String get chat_pathDeviceNotConfirmed =>
      'Zariadenie zatiaľ nebolo potvrdené.';

  @override
  String get chat_type => 'Napište';

  @override
  String get chat_path => 'Cesta';

  @override
  String get chat_publicKey => 'Verejný kľúč';

  @override
  String get chat_compressOutgoingMessages => 'Komprimovať odoslané správy';

  @override
  String get chat_floodForced => 'Povodňová (nutená)';

  @override
  String get chat_directForced => 'Priame (donútené)';

  @override
  String chat_hopsForced(int count) {
    return '$count skokov (nutené)';
  }

  @override
  String get chat_floodAuto => 'Povod (automaticky)';

  @override
  String get chat_direct => 'Priamo';

  @override
  String get chat_poiShared => 'Zdieľané body záujmu';

  @override
  String chat_unread(int count) {
    return 'Nezriadené: $count';
  }

  @override
  String get chat_markAsUnread => 'Označenie ako neprečítané';

  @override
  String get chat_newMessages => 'Nové správy';

  @override
  String get chat_openLink => 'Otvoriť odkaz?';

  @override
  String get chat_openLinkConfirmation =>
      'Chcete otvoriť tento odkaz v prehliadači?';

  @override
  String get chat_open => 'Otvoriť';

  @override
  String chat_couldNotOpenLink(String url) {
    return 'Nepodarilo sa otvoriť odkaz: $url';
  }

  @override
  String get chat_invalidLink => 'Neplatný formát odkazu';

  @override
  String get map_title => 'Mapa uzlov';

  @override
  String get map_searchHint => 'Vyhľadajte podľa názvu alebo ID uzla';

  @override
  String get map_activity => 'Aktivita';

  @override
  String get map_online => 'Online';

  @override
  String get map_recent => 'Nedávne';

  @override
  String get map_stale => 'Neaktuálne';

  @override
  String get map_visible => 'Viditeľný';

  @override
  String get map_hidden => 'Skrytý';

  @override
  String get map_centerOnNode => 'Nacentrovať na uzol';

  @override
  String get map_details => 'Podrobnosti';

  @override
  String get map_noGps => 'Bez GPS';

  @override
  String get map_noResults => 'Nenašli sa žiadne zodpovedajúce uzly.';

  @override
  String get map_lineOfSight => 'Úroveň výhľadu';

  @override
  String get map_losScreenTitle => 'Úroveň výhľadu';

  @override
  String get map_noNodesWithLocation => 'Žiadne uzly s údajmi o polohe';

  @override
  String get map_nodesNeedGps =>
      'Uholníky musia zdieľať svoje GPS súradnice, aby sa zobrazili na mape.';

  @override
  String map_nodesCount(int count) {
    return 'Uzly: $count';
  }

  @override
  String map_pinsCount(int count) {
    return 'Krúžky: $count';
  }

  @override
  String get map_chat => 'Rozhovor';

  @override
  String get map_repeater => 'Opakovanie';

  @override
  String get map_room => 'Izba';

  @override
  String get map_sensor => 'Senzor';

  @override
  String get map_pinDm => 'Zabudka (DM)';

  @override
  String get map_pinPrivate => 'Zabudka (Osobná)';

  @override
  String get map_pinPublic => 'Zablokovať (verejne)';

  @override
  String get map_lastSeen => 'Posledné zreteľné zobrazenie';

  @override
  String get map_disconnectConfirm =>
      'Ste si istý/á, že chcete odpojiť od tohto zariadenia?';

  @override
  String get map_from => 'Od';

  @override
  String get map_source => 'Zdroj';

  @override
  String get map_flags => 'Zástavy';

  @override
  String get map_type => 'Type';

  @override
  String get map_path => 'Path';

  @override
  String get map_location => 'Location';

  @override
  String get map_estLocation => 'Est. Location';

  @override
  String get map_publicKey => 'Public Key';

  @override
  String get map_publicKeyPrefixHint => 'e.g. ab12';

  @override
  String get map_shareMarkerHere => 'Zdieľte značku tu';

  @override
  String get map_setAsMyLocation => 'Nastavte ako moju polohu';

  @override
  String get floodCorridor_title => 'Flood koridor';

  @override
  String get floodCorridor_previewToHere => 'Náhľad flood koridoru sem';

  @override
  String get floodCorridor_requesting => 'Žiadam rádio o koridor…';

  @override
  String get floodCorridor_unsupported =>
      'Firmvér vášho rádia nepodporuje flood koridory.';

  @override
  String get floodCorridor_noProposal =>
      'Rádio nedokázalo navrhnúť koridor. Uistite sa, že má nastavenú polohu.';

  @override
  String floodCorridor_circleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kruhov',
      few: '$count kruhy',
      one: '1 kruh',
    );
    return '$_temp0';
  }

  @override
  String floodCorridor_repeatersInside(int inside, int total) {
    return '$inside z $total známych opakovačov vnútri';
  }

  @override
  String get floodCorridor_straightLine =>
      'Priamka: po ceste nie sú žiadne známe opakovače';

  @override
  String get floodCorridor_followsRepeaters => 'Sleduje vaše známe opakovače';

  @override
  String get floodCorridor_horizonLimited =>
      'Známe opakovače nedosiahnu cieľ; zvyšok je priamka';

  @override
  String get floodCorridor_thinStretch =>
      'Časť koridoru má málo známych opakovačov';

  @override
  String get floodCorridor_moreCoverage =>
      'Vyžadovať väčšie pokrytie opakovačmi';

  @override
  String get floodCorridor_previewNote =>
      'Iba náhľad. Opakovače bez firmvéru koridoru koridory neuplatňujú.';

  @override
  String get map_pinLabel => 'Označka upozornenia';

  @override
  String get map_label => 'Značka';

  @override
  String get map_pointOfInterest => 'Bod záujmu';

  @override
  String get map_sendToContact => 'Pošleť na kontakt';

  @override
  String get map_sendToChannel => 'Poslať do kanálu';

  @override
  String get map_noChannelsAvailable => 'Неexistujú žiadne kanály.';

  @override
  String get map_publicLocationShare => 'Zdieľiť verejnú lokalitu';

  @override
  String map_publicLocationShareConfirm(String channelLabel) {
    return 'Čoskoro budete zdieľať polohu v $channelLabel. Tento kanál je verejný a môže ho vidieť každý s PSK.';
  }

  @override
  String get map_connectToShareMarkers =>
      'Pripojte sa k zariadeniu na zdieľanie značiek';

  @override
  String get map_filterNodes => 'Filtrovať uzly';

  @override
  String get map_nodeTypes => 'Typy uzlov';

  @override
  String get map_chatNodes => 'Chatové uzly';

  @override
  String get map_repeaters => 'Opakovadlá';

  @override
  String get map_otherNodes => 'Ostatné uzly';

  @override
  String get map_showOverlaps => 'Prekrývanie opakovača kľúča';

  @override
  String get map_keyPrefix => 'Päťciferné predpona';

  @override
  String get map_filterByKeyPrefix => 'Filtrovať podľa predponového kľúča';

  @override
  String get map_publicKeyPrefix => 'Prefix verejného kľúča';

  @override
  String get map_markers => 'Označkovače';

  @override
  String get map_showSharedMarkers => 'Zobraziť zdieľané značky';

  @override
  String get map_showGuessedLocations =>
      'Zobraziť umiestnenia odhadnutých uzlov';

  @override
  String get map_showDiscoveryContacts => 'Zobraziť kontakty objavov';

  @override
  String get map_guessedLocation => 'Odhadnutá lokalita';

  @override
  String get map_lastSeenTime => 'Posledný čas sledovania';

  @override
  String get map_sharedPin => 'Zdieľaný PIN';

  @override
  String get map_sharedAt => 'Zdieľané';

  @override
  String get map_joinRoom => 'Pripojiť miestnosť';

  @override
  String get map_manageRepeater => 'Spravovať Opakovanie';

  @override
  String get map_tapToAdd => 'Kliknite na uzly, aby ste ich pridali k ceste.';

  @override
  String get map_runTrace => 'Spustiť trasovaním cesty';

  @override
  String get map_runTraceWithReturnPath => 'Vráťte sa späť po tej istej ceste.';

  @override
  String get map_removeLast => 'Odstrániť posledný';

  @override
  String get map_pathTraceCancelled => 'Zrušenie stopáže cesty bolo zrušené.';

  @override
  String get mapCache_title => 'Offline Mapa Pamäť';

  @override
  String get mapCache_selectAreaFirst => 'Vyberte si oblasť na predprerúčenie.';

  @override
  String get mapCache_noTilesToDownload =>
      'Žiadne dlaždice na stiahnutie pre toto zóna';

  @override
  String get mapCache_downloadTilesTitle => 'Stiahnuť dlaždice';

  @override
  String mapCache_downloadTilesPrompt(int count) {
    return 'Stiahnuť $count dlaždíc na offline použitie?';
  }

  @override
  String get mapCache_downloadAction => 'Stiahnuť';

  @override
  String mapCache_cachedTiles(int count) {
    return 'Zabudené $count dlaždíc';
  }

  @override
  String mapCache_cachedTilesWithFailed(int downloaded, int failed) {
    return 'Uložené $downloaded dlaždice ($failed neúspešné)';
  }

  @override
  String get mapCache_clearOfflineCacheTitle => 'Vymazať offline uloženie';

  @override
  String get mapCache_clearOfflineCachePrompt =>
      'Odstrániť všetky uložené mapové dlaždice?';

  @override
  String get mapCache_offlineCacheCleared => 'Offline polia vymazaná';

  @override
  String get mapCache_noAreaSelected => 'Neoznačila sa žiadna oblasť';

  @override
  String get mapCache_cacheArea => 'Obdĺžková oblasť';

  @override
  String get mapCache_useCurrentView => 'Použite aktuálny zobrazenie';

  @override
  String get mapCache_zoomRange => 'Rozsah zväčšenia';

  @override
  String mapCache_estimatedTiles(int count) {
    return 'Odhadnuté dlaždice: $count';
  }

  @override
  String mapCache_downloadedTiles(int completed, int total) {
    return 'Stiahnuté $completed / $total';
  }

  @override
  String get mapCache_downloadTilesButton => 'Stiahnuť dlaždice';

  @override
  String get mapCache_clearCacheButton => 'Vyprázdniť Vädsť';

  @override
  String mapCache_failedDownloads(int count) {
    return 'Neúspešné stiahnutia: $count';
  }

  @override
  String get mapCache_cachedTilesLabel => 'Cached tiles';

  @override
  String get mapCache_cachedTileSummaryLabel => 'Cached tile summary';

  @override
  String mapCache_bulkDownloadDisabledForSource(String source) {
    return 'Offline bulk downloads are disabled for $source.';
  }

  @override
  String mapCache_bulkDownloadDisabledInConfig(String source) {
    return 'Offline bulk downloads are disabled for $source in this app configuration.';
  }

  @override
  String mapCache_summarySource(String source) {
    return 'Source: $source';
  }

  @override
  String mapCache_summaryCachedTilesForSource(int count) {
    return 'Cached tiles for source: $count';
  }

  @override
  String mapCache_summaryCachedInSelection(int count) {
    return 'Cached in selected area/zoom: $count';
  }

  @override
  String mapCache_summaryApproxCacheSize(String size) {
    return 'Approx cache size: $size';
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
  String get time_justNow => 'Príbeh';

  @override
  String time_minutesAgo(int minutes) {
    return '$minutes min dozadu';
  }

  @override
  String time_hoursAgo(int hours) {
    return '$hours h dozadu';
  }

  @override
  String time_daysAgo(int days) {
    return '$days dní dozadu';
  }

  @override
  String get time_hour => 'hodina';

  @override
  String get time_hours => 'hodiny';

  @override
  String get time_day => 'deň';

  @override
  String get time_days => 'dni';

  @override
  String get time_week => 'týždeň';

  @override
  String get time_weeks => 'týždne';

  @override
  String get time_month => 'mesiac';

  @override
  String get time_months => 'mesiace';

  @override
  String get time_minutes => 'minúty';

  @override
  String get time_allTime => 'Všetko Časom';

  @override
  String get dialog_disconnect => 'Odpojiť';

  @override
  String get dialog_disconnectConfirm =>
      'Ste si istý/á, že chcete odpojiť od tohto zariadenia?';

  @override
  String get login_repeaterLogin => 'Opätovné prihlásenie';

  @override
  String get login_roomLogin => 'Prihlásenie do miestnosti';

  @override
  String get login_password => 'Heslo';

  @override
  String get login_enterPassword => 'Zadajte heslo';

  @override
  String get login_savePassword => 'Uložiť heslo';

  @override
  String get login_savePasswordSubtitle =>
      'Heslo bude bezpečne uložené na tomto zariadení.';

  @override
  String get login_repeaterDescription =>
      'Zadajte heslo opakovača, aby ste získali prístup k nastaveniam a stavu.';

  @override
  String get login_roomDescription =>
      'Zadajte heslo do miestnosti na prístup k nastaveniam a stavu.';

  @override
  String get login_routing => 'Rútiace';

  @override
  String get login_routingMode => 'Režim trasy';

  @override
  String get login_autoUseSavedPath => 'Použiť uloženú cestu';

  @override
  String get login_forceFloodMode =>
      'Zavrieť režim núdzového povodňového režimu';

  @override
  String get login_managePaths => 'Spravovať Cesty';

  @override
  String get login_login => 'Prihlásiť';

  @override
  String login_attempt(int current, int max) {
    return 'Skúšaj $current/$max';
  }

  @override
  String login_failed(String error) {
    return 'Prihlásenie zlyhalo: $error';
  }

  @override
  String get login_failedMessage =>
      'Prihlásenie zlyhalo. Heslo je nesprávne alebo je opakovač nedostupný.';

  @override
  String get common_reload => 'Načítať';

  @override
  String get common_clear => 'Zmazať';

  @override
  String get path_currentPathLabel => 'Aktuálny priebeh';

  @override
  String get path_noRepeatersFound =>
      'Nenašli sa žiadne opakovače ani serverové miestnosti.';

  @override
  String get repeater_management => 'Správa opakérov';

  @override
  String get room_management => 'Správa servera miestnosti';

  @override
  String get repeater_guest => 'Informácie o opakovači';

  @override
  String get room_guest => 'Informácie o serveri';

  @override
  String get repeater_managementTools => 'Nástroje na správu';

  @override
  String get repeater_guestTools => 'Nástroje pre hostí';

  @override
  String get repeater_status => 'Stav';

  @override
  String get repeater_statusSubtitle =>
      'Zobraziť stav, štatistiky a susedov repeatera';

  @override
  String get repeater_telemetry => 'Telemetria';

  @override
  String get repeater_telemetrySubtitle =>
      'Zobraziť telemetriu senzorov a systémových štatistík';

  @override
  String get repeater_cli => 'CLI (Command Line Interface)';

  @override
  String get repeater_cliSubtitle => 'Pošlite príkazy opakovaču';

  @override
  String get repeater_neighbors => 'Súsezný';

  @override
  String get repeater_neighborsSubtitle => 'Zobraziť susedné body bez skokov.';

  @override
  String get repeater_settings => 'Nastavenia';

  @override
  String get repeater_settingsSubtitle => 'Konfigurujte parametre opakovača';

  @override
  String get repeater_clockSyncAfterLogin =>
      'Synchronizácia hodiniek po prihlávení';

  @override
  String get repeater_clockSyncAfterLoginSubtitle =>
      'Automaticky posielajte notifikáciu \"synchronizácia času\" po úspešnom prihládení.';

  @override
  String get repeater_statusTitle => 'Status opakého zboru';

  @override
  String get repeater_routingMode => 'Režim trasy';

  @override
  String get repeater_refresh => 'Obnoviť';

  @override
  String get repeater_statusRequestTimeout => 'Požiadavka stavu zlyhala.';

  @override
  String repeater_errorLoadingStatus(String error) {
    return 'Chyba pri načítaní stavu: $error';
  }

  @override
  String get repeater_systemInformation => 'Informácie o systéme';

  @override
  String get repeater_battery => 'Batéria';

  @override
  String get repeater_clockAtLogin => 'Čas (při přihlášení)';

  @override
  String get repeater_uptime => 'Dostupnosť';

  @override
  String get repeater_queueLength => 'Dĺžka fronty';

  @override
  String get repeater_debugFlags => 'Kontrolné značky';

  @override
  String get repeater_radioStatistics => 'Rádio Štatistiky';

  @override
  String get repeater_lastRssi => 'Posledná RSSI';

  @override
  String get repeater_lastSnr => 'Posledný SNR';

  @override
  String get repeater_noiseFloor => 'Hladina šumu';

  @override
  String get repeater_txAirtime => 'TX Airtime';

  @override
  String get repeater_rxAirtime => 'RX Airtime';

  @override
  String get repeater_chanUtil => 'Využitie kanálu';

  @override
  String get repeater_packetStatistics => 'Statistiky balíka';

  @override
  String get repeater_sent => 'Odoslané';

  @override
  String get repeater_received => 'Prišlo';

  @override
  String get repeater_duplicates => 'Duplikáty';

  @override
  String repeater_daysHoursMinsSecs(
    int days,
    int hours,
    int minutes,
    int seconds,
  ) {
    return '$days dní ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String repeater_packetTxTotal(int total, String flood, String direct) {
    return 'Celkem: $total, Povodňový režim: $flood, Priamy: $direct';
  }

  @override
  String repeater_packetRxTotal(int total, String flood, String direct) {
    return 'Celkem: $total, Povodňový režim: $flood, Priamy: $direct';
  }

  @override
  String repeater_duplicatesFloodDirect(String flood, String direct) {
    return 'Pond: $flood, Priamy: $direct';
  }

  @override
  String repeater_duplicatesTotal(int total) {
    return 'Celkem: $total';
  }

  @override
  String get repeater_settingsTitle => 'Nastavenia Opakovača';

  @override
  String get repeater_basicSettings => 'Základné nastavenia';

  @override
  String get repeater_repeaterName => 'Opakovacia názov';

  @override
  String get repeater_repeaterNameHelper => 'Zobrazenie názvu tohto opakovača';

  @override
  String get repeater_adminPassword => 'Heslo administrátora';

  @override
  String get repeater_adminPasswordHelper => 'Celý prístupový heslo';

  @override
  String get repeater_guestPassword => 'Heslo hosťa';

  @override
  String get repeater_guestPasswordHelper => 'Prístupový heslo iba na čítanie';

  @override
  String get repeater_radioSettings => 'Nastavenia rádia';

  @override
  String get repeater_frequencyMhz => 'Frekvencia (MHz)';

  @override
  String get repeater_frequencyHelper => '300–2500 MHz';

  @override
  String get repeater_txPower => 'TX Power';

  @override
  String get repeater_txPowerHelper => '1-30 dBm';

  @override
  String get repeater_bandwidth => 'Šírka pásma';

  @override
  String get repeater_spreadingFactor => 'Šírenie faktoru';

  @override
  String get repeater_codingRate => 'Rýchlosť kódovania';

  @override
  String get repeater_locationSettings => 'Nastavenia polohy';

  @override
  String get repeater_latitude => 'Súradnica';

  @override
  String get repeater_latitudeHelper => 'Desatinné zložky (napr. 37.7749)';

  @override
  String get repeater_longitude => 'Dĺžka';

  @override
  String get repeater_longitudeHelper => 'Desatinné zložky (napr. -122.4194)';

  @override
  String get repeater_features => 'Funkcie';

  @override
  String get repeater_packetForwarding => 'Riadenie prienikov';

  @override
  String get repeater_packetForwardingSubtitle =>
      'Povolte opakovač na smerovanie paketov.';

  @override
  String get repeater_guestAccess => 'Prístup pre hostí';

  @override
  String get repeater_guestAccessSubtitle =>
      'Umožniť prístup hosta iba na čítanie.';

  @override
  String get repeater_privacyMode => 'Režim ochrany súkromia';

  @override
  String get repeater_privacyModeSubtitle => 'Skryť meno/poloha v reklamách';

  @override
  String get repeater_advertisementSettings => 'Nastavenia reklamy';

  @override
  String get repeater_localAdvertInterval => 'Lokálna reklamná časová obdoba';

  @override
  String repeater_localAdvertIntervalMinutes(int minutes) {
    return '$minutes minút';
  }

  @override
  String get repeater_floodAdvertInterval =>
      'Interval reklamnej povodňovej reklamy';

  @override
  String repeater_floodAdvertIntervalHours(int hours) {
    return '$hours hodín';
  }

  @override
  String get repeater_encryptedAdvertInterval => 'Šifrovaný reklamný interval';

  @override
  String get repeater_dangerZone => 'Nebezpečná zóna';

  @override
  String get repeater_rebootRepeater => 'Restart Repetér';

  @override
  String get repeater_rebootRepeaterSubtitle => 'Resetovať vysielací prístroj';

  @override
  String get repeater_rebootRepeaterConfirm =>
      'Ste si istý, že chcete tento opakovač restartovať?';

  @override
  String get repeater_regenerateIdentityKey => 'Generovať kľúč identity';

  @override
  String get repeater_regenerateIdentityKeySubtitle =>
      'Generovať nový pár verejných/privátnych kľúčov';

  @override
  String get repeater_regenerateIdentityKeyConfirm =>
      'Toto vytvorí nový identitu pre opakovač. Pokračovať?';

  @override
  String get repeater_eraseFileSystem => 'Vymažať Systémový Reťazec';

  @override
  String get repeater_eraseFileSystemSubtitle =>
      'Formátovať systém opakujúcich sa súborov';

  @override
  String get repeater_eraseFileSystemConfirm =>
      'VAROVANIE: Toto zmaže všetky dáta na opakovači. To sa nedá zrušiť!';

  @override
  String get repeater_eraseSerialOnly =>
      'Odstránenie je dostupné len cez sériové rozhranie.';

  @override
  String repeater_commandSent(String command) {
    return 'Poforovaný príkaz: $command';
  }

  @override
  String repeater_errorSendingCommand(String error) {
    return 'Chyba pri odeslaní príkazu: $error';
  }

  @override
  String get repeater_confirm => 'Potvrdiť';

  @override
  String get repeater_settingsSaved => 'Nastavenia boli uložené úspešne.';

  @override
  String get repeater_rxGain => 'Zvýšený zisk RX';

  @override
  String get repeater_rxGainHelper =>
      'Vyššia citlivosť, vyšší príkon (platí len pre modely SX1262/SX1268)';

  @override
  String get repeater_refreshRxGain => 'Obnovte zvýšený zisk z RX';

  @override
  String get repeater_multiAcks => 'Víťazné potvrdenia (víťazné ACK)';

  @override
  String get repeater_multiAcksSubtitle =>
      'Potvrďte správy prostredníctvom viacerých trás pre lepšiu doručenie.';

  @override
  String get repeater_refreshMultiAcks =>
      'Opätovne potvrďte viacero ACK signálov';

  @override
  String get repeater_networkHealth => 'Zdravie siete';

  @override
  String get repeater_loopDetect => 'Detekcia slučiek';

  @override
  String get repeater_loopDetectHelper =>
      'Vytvorte balíčky, ktoré vizuálne pripomínajú slučky v síti.';

  @override
  String get repeater_loopDetectOff => 'Vypnuté';

  @override
  String get repeater_loopDetectMinimal => 'Minimálny';

  @override
  String get repeater_loopDetectModerate => 'Stredný, mierny';

  @override
  String get repeater_loopDetectStrict => 'Prísne';

  @override
  String get repeater_dutyCycle => 'Cyklus činnosti';

  @override
  String get repeater_dutyCycleHelper =>
      'Maximálna percentáľ dostupného času vysielania';

  @override
  String repeater_dutyCyclePercent(int percent) {
    return '$percent%';
  }

  @override
  String get repeater_ownerInfo => 'Informácie o poskytovateľovi';

  @override
  String get repeater_ownerInfoHelper =>
      'Veľké dátové informácie pre tento vysielací zdroj';

  @override
  String get repeater_refreshOwnerInfo => 'Zísť informácie o operátore';

  @override
  String get repeater_floodMax => 'Maximálny počet skokov pri povodni';

  @override
  String get repeater_floodMaxHelper =>
      'Maximálny počet paketov, ktoré môžu preletieť cez jeden hop (0-64)';

  @override
  String get repeater_advancedSettings => 'Pokročilé';

  @override
  String get repeater_advancedSettingsSubtitle =>
      'Ovládacie knopy pre skúsených operátorov';

  @override
  String get repeater_pathHashMode => 'Režim hashovania cesty';

  @override
  String get repeater_pathHashModeHelper =>
      'Bajty použité na zakódovanie ID tohto opakovača v tagoch flood trasy/detekcie slučky. 0=1 bajt (256 ID, až 64 skokov), 1=2 bajty (65 000 ID, až 32 skokov), 2=3 bajty (16 miliónov ID, až 21 skokov). Firmvér pred v1.14 vždy používal 1-bajtové trasy; v1.14 a novšie možno nakonfigurovať na 2- alebo 3-bajtové trasy.';

  @override
  String get repeater_keySettings => 'Zmena identititačných klíčov';

  @override
  String get repeater_keySettingsSubtitle =>
      'Zmena prehľadného/osobného klíčového zbraň';

  @override
  String get repeater_prvKey => 'Prívatná klíč';

  @override
  String get repeater_prvKeyHelper =>
      'Nová prívna klíčová číslo pre repeater, 128-znáčlový šestnáctorýč.';

  @override
  String get repeater_generatePrvKey => 'Vytvorenie príma kľúčového paru';

  @override
  String get repeater_stopGeneratingPrvKey =>
      'Prerušenie hľadania klíčového paru';

  @override
  String get repeater_pubKey => 'Public key';

  @override
  String get repeater_pubKeyHelper =>
      'Táto je veľká klíč, ktorý sa vztahuje s generovaným manéčným klíčom. Nemožné je to ustanovit priateľne.';

  @override
  String get repeater_pubKeyPrefix => 'Požadovaný prefiks';

  @override
  String repeater_pubKeyPrefixHelper(int tries) {
    return 'Zahľadnite sa veľkú publicenu klíču, ktorá začíná tými šestícih štiastkami. Očekivané potrebné pokusy: $tries.';
  }

  @override
  String get repeater_txDelay => 'Zpoždanie v Flood, TX';

  @override
  String get repeater_txDelayHelper =>
      'Nastavenie pre opakované vysielanie pre dopravu počas povodní, ako násobok času, ktorý paket využije (0-2, výchoce hodnota 0,5). Vyššia hodnota znamená menej kolízii, ale pomalšie doručovanie.';

  @override
  String get repeater_directTxDelay => 'Priame oneskorenie TX';

  @override
  String get repeater_directTxDelayHelper =>
      'Nastavenie pre retransmisiu pre priame (nie pre plnú sieť), ako násobok času prenosu paketov (0-2, výchoce 0,3).';

  @override
  String get repeater_intThresh => 'Hranica, pri ktorej dochádza k rušeniu';

  @override
  String get repeater_intThreshHelper =>
      'Hranica je nastavená tak, aby odfiltrovala šum nad touto úrovňou. Hodnota 0 znamená, že sa nebude nič odfiltrovať – nastavte ju len v prípade, že zaznamenáte chyby pri prijímaní signálu v šumnej frekvencii.';

  @override
  String get repeater_agcResetInterval => 'Interval reštartu AGC';

  @override
  String get repeater_agcResetIntervalHelper =>
      'Ako často by ste mali reštartovať automatické ovládanie zosilnenia, aby ste sa vrátili do normálneho stavu, ak je zosilnenie zablokované? Nastavenie „4.0“ vypne pravidelné reštarty.';

  @override
  String get repeater_actionsTitle => 'Opatrenia';

  @override
  String get repeater_sendAdvert => 'Odoslať inzerát o povodňovej situácii';

  @override
  String get repeater_sendAdvertSubtitle =>
      'Zverejnite reklamu na povodňu prostredníctvom siete.';

  @override
  String get repeater_sendAdvertZeroHop => 'Odoslať reklamu bez prenosu';

  @override
  String get repeater_sendAdvertZeroHopSubtitle =>
      'Zverejnite reklamnú správu, ktorá sa prenáša len raz (bez prenosov).';

  @override
  String get repeater_clockSync => 'Synchronizujte hodiny teraz';

  @override
  String get repeater_clockSyncSubtitle =>
      'Nastavte čas na vašom telefóne, aby odpovedal na volania z vysielacieho zariadenia.';

  @override
  String repeater_actionSucceeded(String action) {
    return '$action succeeded';
  }

  @override
  String repeater_actionFailed(String action, String error) {
    return '$action failed: $error';
  }

  @override
  String get repeater_settingsSavedRebootNeeded =>
      'Nastavenia uložené – reštartujte vysielací prístroj, aby sa nastavenia aplikovali.';

  @override
  String repeater_settingsPartialFailure(String failures) {
    return 'Niektoré nastavenia neúspešné: $failures';
  }

  @override
  String repeater_errorSavingSettings(String error) {
    return 'Chyba pri ukladaní nastavení: $error';
  }

  @override
  String get repeater_refreshBasicSettings => 'Obnoviť základné nastavenia';

  @override
  String get repeater_refreshRadioSettings => 'Obnoviť Nastavenia Rádií';

  @override
  String get repeater_refreshTxPower => 'Obnoviť TX napájanie';

  @override
  String get repeater_refreshPacketForwarding => 'Obnoviť smerovanie paketov';

  @override
  String get repeater_refreshGuestAccess => 'Obnoviť prístup hosťa';

  @override
  String get repeater_refreshPrivacyMode => 'Obnoviť Ochranný režim';

  @override
  String repeater_refreshed(String label) {
    return '$label sa znova načítalo';
  }

  @override
  String repeater_errorRefreshing(String label) {
    return 'Chyba pri obnovení $label';
  }

  @override
  String get repeater_cliTitle => 'Opakovacia CLI';

  @override
  String get repeater_debugNextCommand => 'Oprava Nasledujúceho Príkaz';

  @override
  String get repeater_commandHelp => 'Pomoc';

  @override
  String get repeater_clearHistory => 'Vymazať históriu';

  @override
  String get repeater_noCommandsSent =>
      'Zatiaľ neboli odeslané žiadne príkazy.';

  @override
  String get repeater_typeCommandOrUseQuick =>
      'Zadajte príkaz nižšie alebo použite rýchle príkazy';

  @override
  String get repeater_enterCommandHint => 'Zadajte príkaz...';

  @override
  String get repeater_previousCommand => 'Predchádzajúci príkaz';

  @override
  String get repeater_nextCommand => 'Nasledujúci príkaz';

  @override
  String get repeater_enterCommandFirst => 'Zadajte najprv príkaz';

  @override
  String get repeater_cliCommandFrameTitle => 'Rámok Príkaz CLI';

  @override
  String repeater_cliCommandError(String error) {
    return 'Chyba: $error';
  }

  @override
  String get repeater_cliQuickGetName => 'Zísť meno';

  @override
  String get repeater_cliQuickGetRadio => 'Zísť po rádiu';

  @override
  String get repeater_cliQuickGetTx => 'Zísť TX';

  @override
  String get repeater_cliQuickNeighbors => 'Súsezný';

  @override
  String get repeater_cliQuickVersion => 'Verzia';

  @override
  String get repeater_cliQuickAdvertise => 'Reklama';

  @override
  String get repeater_cliQuickClock => 'Hodiny';

  @override
  String get repeater_cliQuickClockSync => 'Synchronizácia hodin';

  @override
  String get repeater_cliQuickDiscovery => 'Objaviť susedov';

  @override
  String get repeater_cliHelpAdvert => 'Odosiela reklamnú balíček.';

  @override
  String get repeater_cliHelpReboot =>
      'Resetuje zariadenie. (pozor, môže dôjsť k \'Timeoutu\', čo je normálne)';

  @override
  String get repeater_cliHelpClock =>
      'Zobrazuje aktuálny čas podľa hodiniek zariadenia.';

  @override
  String get repeater_cliHelpPassword =>
      'Nastaví nový administrátorský prístupový údaj pre zariadenie.';

  @override
  String get repeater_cliHelpVersion =>
      'Zobrazuje verziu zariadenia a dátum zostavenia firmvéru.';

  @override
  String get repeater_cliHelpClearStats =>
      'Resetuje rôzne štatistické počítadlá na nulu.';

  @override
  String get repeater_cliHelpSetAf => 'Nastavuje časový faktor.';

  @override
  String get repeater_cliHelpSetTx =>
      'Nastavenie vysielacej sily LoRa v dBm. (potrebuje sa reštart na aplikáciu)';

  @override
  String get repeater_cliHelpSetRepeat =>
      'Umožňuje alebo vypína zopakovaný príspevok pre tento uzol.';

  @override
  String get repeater_cliHelpSetAllowReadOnly =>
      '(Server miestnosti) Ak je \'zapnuté\', potom bude povolený prístup s prázdnym heslom, ale nebude možné posielať správu do miestnosti. (iba čítať).';

  @override
  String get repeater_cliHelpSetFloodMax =>
      'Nastavuje maximálny počet skokov pre vstupný povelový paket (ak je >= max, paket nie je preposlaný)';

  @override
  String get repeater_cliHelpSetIntThresh =>
      'Nastavuje hranicu ruživeho ladenia (v dB). Predvolené je 14. Nastavením na 0 sa vypne detekcia ruživeho ladenia kanálu.';

  @override
  String get repeater_cliHelpSetAgcResetInterval =>
      'Nastavuje interval na reštartovanie Auto Gain Controlleru. Nastavenie na 0 vypne funkciu.';

  @override
  String get repeater_cliHelpSetMultiAcks =>
      'Povolí alebo pozastaví funkciiu \"dvojité potvrdenia\".';

  @override
  String get repeater_cliHelpSetAdvertInterval =>
      'Nastavuje interval časovača v minútach na odošle miestny (bezprostredný) reklamný paket. Nastavenie na 0 vypne funkciu.';

  @override
  String get repeater_cliHelpSetFloodAdvertInterval =>
      'Nastavuje interval časovača v hodinách na odeslanie reklamnej vlne. Nastavenie na 0 vypne.';

  @override
  String get repeater_cliHelpSetGuestPassword =>
      'Nastavuje/aktualizuje heslo hosťa. (pre opakované pripojenia môžu hosťovské prihlásenia posielať požadanie \"Get Stats\")';

  @override
  String get repeater_cliHelpSetName => 'Nastaví názov reklamy.';

  @override
  String get repeater_cliHelpSetLat =>
      'Nastaví geografickú šírku reklamnej mapy. (desatinné stupne)';

  @override
  String get repeater_cliHelpSetLon =>
      'Nastavuje longitudinu reklamnej mapy. (desatinné stupne)';

  @override
  String get repeater_cliHelpSetRadio =>
      'Nastavuje úplne nové parametre rádia a uloží ich do preferencií. Požaduje príkaz \"reboot\" na aplikáciu.';

  @override
  String get repeater_cliHelpSetRxDelay =>
      'Nastavenia (experimentálne) základné (musi byť > 1 pre účel) na aplikáciu mierneho onesenia prijatých paketov, na základe signálu/skóre. Nastavenie na 0 vypne.';

  @override
  String get repeater_cliHelpSetTxDelay =>
      'Nastavuje faktor násobený časom na vzduchu pre paket v režime povodňovej vlny a s náhodným systémom slotov, aby sa oneskorene jeho prenosovanie (s cieľom znížiť pravdepodobnosť kolízii).';

  @override
  String get repeater_cliHelpSetDirectTxDelay =>
      'Podobne ako txdelay, ale pre aplikáciu náhodného oneskorenia pri preposlaní paketov v režime priameho prenosu.';

  @override
  String get repeater_cliHelpSetBridgeEnabled => 'Aktivovať/Zatvárať most.';

  @override
  String get repeater_cliHelpSetBridgeDelay =>
      'Nastaviť odklad pred retransmisiou paketov.';

  @override
  String get repeater_cliHelpSetBridgeSource =>
      'Zvolte, či bude most retransmitovať prijaté alebo vysielané balíčky.';

  @override
  String get repeater_cliHelpSetBridgeBaud =>
      'Nastavte sériový link baudrate pre rs232 mosty.';

  @override
  String get repeater_cliHelpSetBridgeSecret =>
      'Nastaviť tajomstvo mosta pre eshnow mosty.';

  @override
  String get repeater_cliHelpSetAdcMultiplier =>
      'Nastavuje vlastný faktor na úpravu nahlásenej batériovej napätia (podporované len na vybraných doskách).';

  @override
  String get repeater_cliHelpTempRadio =>
      'Nastaví dočasné rádiové parametre pre zadaný počet minút, po skončení sa vráti k pôvodným rádiovým parametrom. (nepočuva sa do preferencií).';

  @override
  String get repeater_cliHelpSetPerm =>
      'Zmení ACL. Odstráni zodpovedný záznam (podľa prefixa pubkey), ak je \"permissions\" rovné 0. Pridá nový záznam, ak je pubkey-hex plnej dĺžky a momentálne sa nenachádza v ACL. Aktualizuje záznam podľa zodpovedajúceho prefixa pubkey. Bitové oprávnenia sa líšia podľa funkčnej roly, ale nízke 2 bity sú: 0 (Hostiteľ), 1 (Čítanie len), 2 (Čítanie a zápis), 3 (Správca).';

  @override
  String get repeater_cliHelpGetBridgeType =>
      'Zísť typ mosta: žiadny, rs232, espnow';

  @override
  String get repeater_cliHelpLogStart =>
      'Začína protokolovanie balíkov do systému súborov.';

  @override
  String get repeater_cliHelpLogStop =>
      'Zastaví protokolovanie paketov do systémového súboru.';

  @override
  String get repeater_cliHelpLogErase =>
      'Odstráni záznamy z balíkov z systému súborov.';

  @override
  String get repeater_cliHelpNeighbors =>
      'Zobrazuje zoznam iných repeaterových uzlov zasielaných cez zero-hop reklamy. Každý riadok je id-prefix-hex:timestamp:snr-times-4';

  @override
  String get repeater_cliHelpNeighborRemove =>
      'Odstráni prvú zhodujúcu položku (podľa prefixu pubkey (hex)) z zoznamu susedov.';

  @override
  String get repeater_cliHelpRegion =>
      '(len sériál) Zobrazuje všetky definované regióny a aktuálne povolenia pre povodňové situácie.';

  @override
  String get repeater_cliHelpRegionLoad =>
      'Poznámka: toto je špeciálna multi-príkázová inštancia. Každé nasledujúce príkaza je názov oblasti (zapustený s medzerami na indikáciu hierarchického pomeru, s minimálne jednou medzerou). Ukončené odeslaním prázdnej platnej linky/príkazu.';

  @override
  String get repeater_cliHelpRegionGet =>
      'Hľadá región s daným príponou názvu (alebo \"\\\" pre globálny rozsah). Odpovedá \"-> región-název (rodič-název) \'F\'\"';

  @override
  String get repeater_cliHelpRegionPut =>
      'Pridá alebo aktualizuje definíciu regiónu s daným menom.';

  @override
  String get repeater_cliHelpRegionRemove =>
      'Odstráni definíciu oblasti s daným názvom. (musí zodpovedať presne a nemala by mať podoblasti)';

  @override
  String get repeater_cliHelpRegionAllowf =>
      'Nastavuje povolenie \'P\'lávu pre zadanú oblasť. (\'\' pre globálny/dedičský rozsah)';

  @override
  String get repeater_cliHelpRegionDenyf =>
      'Odstráni povolenie \'F\'lood\' pre zadanú oblasť. (UPOZORNENIE: v tejto fáze nie je odporúčané ho používať na globálnom/dedskom rozsahu!!).';

  @override
  String get repeater_cliHelpRegionHome =>
      'Odpovedá s aktuálnou \'domovskou\' oblasťou. (Poznámka aplikovaná zatiaľ nikde, vyhradené na budúce)';

  @override
  String get repeater_cliHelpRegionHomeSet => 'Nastaví \'domovskú\' oblasť.';

  @override
  String get repeater_cliHelpRegionSave =>
      'Uloží zoznam/mapu regiónov do úložiska.';

  @override
  String get repeater_cliHelpGps =>
      'Zobrazuje stav GPS. Ak je GPS vypnutý, odpovedá len \"off\", ak je zapnutý, odpovedá s \"on\", stavom, fixom a počtom satelitov.';

  @override
  String get repeater_cliHelpGpsOnOff => 'Prepínač stavu GPS napájania.';

  @override
  String get repeater_cliHelpGpsSync =>
      'Synchronizuje čas uzla s GPS hodinami.';

  @override
  String get repeater_cliHelpGpsSetLoc =>
      'Nastaví polohu uzla na GPS súradnice a uloží preferencie.';

  @override
  String get repeater_cliHelpGpsAdvert =>
      'Poskytuje konfiguráciu reklamy pre uzol:\n- žiadna: nezahrňte polohu do reklám\n- zdieľať: zdieľajte GPS polohu (z SensorManager)\n- nastavenia: zobrazujte polohu uloženú v nastaveniach';

  @override
  String get repeater_cliHelpGpsAdvertSet =>
      'Nastavuje konfiguráciu reklamy na zadané miesto.';

  @override
  String get repeater_commandsListTitle => 'Zoznam príkazov';

  @override
  String get repeater_commandsListNote =>
      'Poznámka: pre rôzne príkazy \"set ...\" existuje aj príkaz \"get ...\".';

  @override
  String get repeater_general => 'Obecné';

  @override
  String get repeater_settingsCategory => 'Nastavenia';

  @override
  String get repeater_bridge => 'Most';

  @override
  String get repeater_logging => 'Záznamy';

  @override
  String get repeater_neighborsRepeaterOnly => 'Súseznýci (iba opakovač)';

  @override
  String get repeater_regionManagementRepeaterOnly =>
      'Správa regiónov (iba opakovač)';

  @override
  String get repeater_regionNote =>
      'Regionové príkazy boli zavádzané na správu regionálnych definícií a oprávnení.';

  @override
  String get repeater_gpsManagement => 'Správa GPS';

  @override
  String get repeater_gpsNote =>
      'GPS príkaz bol zavádzaný na riadenie lokalitných tém.';

  @override
  String get repeater_getCategory => 'Zísť hodnoty';

  @override
  String get repeater_powerMgmt => 'Správa energie';

  @override
  String get repeater_sensors => 'Senzory';

  @override
  String get repeater_cliHelpPowerOff =>
      'Vypína zariadenie. (neočakáva sa žiadna odpoveď)';

  @override
  String get repeater_cliHelpClkReboot =>
      'Resetuje hodiny na známu epochu a reštartuje zariadenie.';

  @override
  String get repeater_cliHelpAdvertZeroHop =>
      'Rozosiela reklamu, ktorá sa prenáša len medzi susednými zariadeniami (bez prenosu cez iné siete).';

  @override
  String get repeater_cliHelpStartOta =>
      'Spustí aktualizáciu firmvéru prostredníctvom diaľkového prenosu na podporovaných doskách.';

  @override
  String get repeater_cliHelpTime =>
      'Nastavuje časovník zariadenia na zadané sekundy od Unix epochy. Časovník sa nedá otáčať dozadu.';

  @override
  String get repeater_cliHelpBoard =>
      'Zobrazuje informácie o výrobcom dosky / identifikátor hardvéru.';

  @override
  String get repeater_cliHelpDiscoverNeighbors =>
      'Odosiela požiadavku na nájdenie susedných uzlov. (Len pre opakovače)';

  @override
  String get repeater_cliHelpPowersaving =>
      'Ukazuje, či je režim úspory energie zapnutý alebo vypnutý.';

  @override
  String get repeater_cliHelpPowersavingOnOff =>
      'Umožňuje alebo vypína režim úspory energie (ak je podporovaný).';

  @override
  String get repeater_cliHelpErase =>
      '(Používa sa len pre sériové zariadenia) Formátuje systém súborov zariadenia. Vymaže všetky nastavenia a kontakty.';

  @override
  String get repeater_cliHelpSetDutyCycle =>
      'Nastavuje maximálnu povolenú frekvenciu prenosu ako percento (1-100). Internálne upravuje faktor času prenosu.';

  @override
  String get repeater_cliHelpSetPrvKey =>
      '(Používa sa len v sériovej verzii) Nahradí privátny kľúč, ktorý identifikuje zariadenie. Po aplikácii je potrebné zariadenie reštartovať. Generuje nový verejný kľúč.';

  @override
  String get repeater_cliHelpSetRadioRxGain =>
      '(iba pre SX126x) Zapína zvýšený zisk prijímania pre zlepšenie citlivosti pri vyššom príkonu.';

  @override
  String get repeater_cliHelpSetOwnerInfo =>
      'Definuje reťazec s informáciami o kontaktnom osobě, ktorý je zahrnutý v reklamách. Používajte \'|\' pre nové riadky.';

  @override
  String get repeater_cliHelpSetPathHashMode =>
      'Nastavuje režim hashovania cesty. 0 = starý režim, 1 = štandardný režim, 2 = striktný režim. Ovplyvňuje, ako sa prekladajú trasy.';

  @override
  String get repeater_cliHelpSetLoopDetect =>
      'Nastavuje citlivosť detekcie slučky routovania: vypnutá, minimálna, stredná alebo prísna.';

  @override
  String get repeater_cliHelpSetFreq =>
      '(Používa sa len v sériovej verzii) Rýchlo nastavuje len frekvenciu. Je potrebné reštartovať. Pre úplné nastavenie rádia preferujte funkciu \"nastavenie rádia\".';

  @override
  String get repeater_cliHelpSetBridgeChannel =>
      '(Používa sa len pre ESPNow most) Nastavuje WiFi kanál (1-14), ktorý používa most.';

  @override
  String get repeater_cliHelpGetName => 'Zobrazuje zadané meno uzla.';

  @override
  String get repeater_cliHelpGetRole =>
      'Ukazuje funkciu firmvéru (opakovač, server pre miestnosť atď.).';

  @override
  String get repeater_cliHelpGetPublicKey =>
      'Zobrazuje verejný kľúč zariadenia.';

  @override
  String get repeater_cliHelpGetPrvKey =>
      '(Používa sa len v sériových aplikáciách) Zobrazuje súkromný kľúč zariadenia. Zotriďte ho ako tajný údaj.';

  @override
  String get repeater_cliHelpGetRepeat =>
      'Ukazuje, či je funkcia preposielania paketov (funkcia opakéra) zapnutá alebo vypnutá.';

  @override
  String get repeater_cliHelpGetTx =>
      'Zobrazuje aktuálnu výkonovú hodnotu TX v dBm.';

  @override
  String get repeater_cliHelpGetFreq =>
      'Zobrazuje nakonfigurovanú frekvenciu v MHz.';

  @override
  String get repeater_cliHelpGetRadio =>
      'Zobrazuje všetky parametre rádiového signálu: frekvencia, šírka pásma, faktor rozširovania, rýchlosť kódovania.';

  @override
  String get repeater_cliHelpGetRadioRxGain =>
      '(iba pre SX126x) Zobrazuje stav zosilnenia prijímača RX.';

  @override
  String get repeater_cliHelpGetAf =>
      'Zobrazuje aktuálny koeficient času vysielania.';

  @override
  String get repeater_cliHelpGetDutyCycle =>
      'Zobrazuje aktuálnu povolenú frekvenciu ako percentáž.';

  @override
  String get repeater_cliHelpGetIntThresh =>
      'Zobrazuje hranicu pre prechodové signály v dB.';

  @override
  String get repeater_cliHelpGetAgcResetInterval =>
      'Zobrazuje interval reštartovania AGC v sekundách.';

  @override
  String get repeater_cliHelpGetMultiAcks =>
      'Ukazuje, či je režim dvojité potvrdenie zapnutý (1) alebo vypnutý (0).';

  @override
  String get repeater_cliHelpGetAllowReadOnly =>
      'Ukazuje, či je povolená len čítacia funkcia pre hostí.';

  @override
  String get repeater_cliHelpGetAdvertInterval =>
      'Zobrazuje čas trvania miestnej reklamnej pauzy v minútach.';

  @override
  String get repeater_cliHelpGetFloodAdvertInterval =>
      'Zobrazuje časový interval reklamy počas záplavy v hodinách.';

  @override
  String get repeater_cliHelpGetGuestPassword =>
      'Zobrazuje nastavené heslo pre hosta.';

  @override
  String get repeater_cliHelpGetLat => 'Zobrazuje nastavenú šírku.';

  @override
  String get repeater_cliHelpGetLon => 'Zobrazuje nastavenú dĺžku.';

  @override
  String get repeater_cliHelpGetRxDelay =>
      'Zobrazuje základnú hodnotu rxdelay.';

  @override
  String get repeater_cliHelpGetTxDelay =>
      'Ukazuje faktor zpoždenia pre režim povodňovej komunikácie.';

  @override
  String get repeater_cliHelpGetDirectTxDelay =>
      'Zobrazuje faktor zloženia pri priamej modulácii.';

  @override
  String get repeater_cliHelpGetFloodMax =>
      'Zobrazuje maximálny počet opakovaní povodňového stavu.';

  @override
  String get repeater_cliHelpGetOwnerInfo =>
      'Zobrazuje reťazec s kontaktnými údajmi vlastníka.';

  @override
  String get repeater_cliHelpGetPathHashMode =>
      'Zobrazuje režim hashovania cesty (0/1/2).';

  @override
  String get repeater_cliHelpGetLoopDetect =>
      'Ukazuje citlivosť na detekciu slučiek.';

  @override
  String get repeater_cliHelpGetAcl =>
      '(Používa sa len v sériovej konfigurácii) Zobrazuje prístupové pravidlá na opakovači.';

  @override
  String get repeater_cliHelpGetBridgeEnabled =>
      'Ukazuje, či je most povolený.';

  @override
  String get repeater_cliHelpGetBridgeDelay =>
      'Zobrazuje čas strávený prechodom mosta v milisekundách.';

  @override
  String get repeater_cliHelpGetBridgeSource =>
      'Ukazuje, či most prijíma alebo vysiela RX alebo TX balíky.';

  @override
  String get repeater_cliHelpGetBridgeBaud =>
      '(iba pre rozhranie RS232) Zobrazuje rýchlosť prenosu dát na rozhraní RS232.';

  @override
  String get repeater_cliHelpGetBridgeChannel =>
      '(Používa sa len pre ESPNow) Zobrazuje WiFi kanál mosta.';

  @override
  String get repeater_cliHelpGetBridgeSecret =>
      '(Používa sa len pre ESPNow most) Zobrazuje spoločný tajný kľúč mosta.';

  @override
  String get repeater_cliHelpGetBootloaderVer =>
      '(iba pre NRF52) Zobrazuje verziu bootloaderu.';

  @override
  String get repeater_cliHelpGetAdcMultiplier =>
      'Zobrazuje násobič ADC (škálovanie napätia batérie).';

  @override
  String get repeater_cliHelpGetPwrMgtSupport =>
      'Označuje, či riadiace orgány majú podporu pre správu energie.';

  @override
  String get repeater_cliHelpGetPwrMgtSource =>
      'Ukazuje aktuálny zdroj napájania: externý alebo batéria.';

  @override
  String get repeater_cliHelpGetPwrMgtBootReason =>
      'Zobrazuje najaktuálnejšie dôvody pre reštart a vypnutie.';

  @override
  String get repeater_cliHelpGetPwrMgtBootMv =>
      'Zobrazuje napätie batérie pri spustení systému v milivoltov (mV).';

  @override
  String get repeater_cliHelpSensorGet =>
      'Číta hodnotu nastavenia pre špecifický senzor pomocou klávesového vstupu.';

  @override
  String get repeater_cliHelpSensorSet =>
      'Vytvára vlastné nastavenie pre senzor.';

  @override
  String get repeater_cliHelpSensorList =>
      'Zobrazuje všetky nastavenia pre špecifické senzory, zoradené podľa voliteľného indexu začiatku.';

  @override
  String get repeater_cliHelpRegionDefault =>
      'Zobrazuje aktuálnu rozsiahku, ktorá je nastavená ako výchozí.';

  @override
  String get repeater_cliHelpRegionDefaultSet =>
      'Nastavuje výchoce rozsiahku regiónu. Použite \"<null>\", aby ju vymazal.';

  @override
  String get repeater_cliHelpRegionListAllowed =>
      'Zoznam oblastí, ktoré umožňujú premávku počas povodní.';

  @override
  String get repeater_cliHelpRegionListDenied =>
      'Zoznam oblastí, ktoré zakazujú premávku v dôsledku povodní.';

  @override
  String get repeater_cliHelpStatsPackets =>
      '(Len pre sériové záznamy) Zobrazuje štatistiky na úrovni paketov.';

  @override
  String get repeater_cliHelpStatsRadio =>
      '(Len pre sériu) Zobrazuje údaje o rádiových staniciach.';

  @override
  String get repeater_cliHelpStatsCore =>
      '(Len pre sériové modely) Zobrazuje základné štatistiky firmvéru.';

  @override
  String get telemetry_receivedData => 'Obdolené Telemetrické dáta';

  @override
  String get telemetry_requestTimeout => 'Požiadavka telemetrie zlyhala.';

  @override
  String telemetry_errorLoading(String error) {
    return 'Chyba pri načítaní telemetrie: $error';
  }

  @override
  String get telemetry_noData => 'Nejsú dostupné žiadne údaje z telemetrie.';

  @override
  String telemetry_channelTitle(int channel) {
    return 'Kanál $channel';
  }

  @override
  String get telemetry_batteryLabel => 'Batéria';

  @override
  String get telemetry_voltageLabel => 'Napätie';

  @override
  String get telemetry_mcuTemperatureLabel => 'MCU teplota';

  @override
  String get telemetry_temperatureLabel => 'Teplota';

  @override
  String get telemetry_currentLabel => 'Aktuálne';

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
  String get telemetry_digitalInputLabel => 'Digitálny vstup';

  @override
  String get telemetry_digitalOutputLabel => 'Digitálny výstup';

  @override
  String get telemetry_analogInputLabel => 'Analógový vstup';

  @override
  String get telemetry_analogOutputLabel => 'Analógový výstup';

  @override
  String get telemetry_genericLabel => 'Všeobecný senzor';

  @override
  String get telemetry_luminosityLabel => 'Osvetlenie';

  @override
  String get telemetry_presenceLabel => 'Prítomnosť';

  @override
  String get telemetry_humidityLabel => 'Vlhkosť';

  @override
  String get telemetry_accelerometerLabel => 'Akcelerometer';

  @override
  String get telemetry_pressureLabel => 'Tlak';

  @override
  String get telemetry_altitudeLabel => 'Nadmorská výška';

  @override
  String get telemetry_frequencyLabel => 'Frekvencia';

  @override
  String get telemetry_percentageLabel => 'Percento';

  @override
  String get telemetry_concentrationLabel => 'Koncentrácia';

  @override
  String get telemetry_powerLabel => 'Výkon';

  @override
  String get telemetry_distanceLabel => 'Vzdialenosť';

  @override
  String get telemetry_energyLabel => 'Energia';

  @override
  String get telemetry_directionLabel => 'Smer';

  @override
  String get telemetry_timeLabel => 'Čas';

  @override
  String get telemetry_gyrometerLabel => 'Gyrometer';

  @override
  String get telemetry_colourLabel => 'Farba';

  @override
  String get telemetry_gpsLabel => 'GPS';

  @override
  String get telemetry_switchLabel => 'Prepínač';

  @override
  String get telemetry_polylineLabel => 'Lomená čiara';

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
  String get telemetry_autoFetchQuantity => 'Počet požiadaviek';

  @override
  String get telemetry_error => 'Nepodarilo sa získať údaje';

  @override
  String get neighbors_receivedData => 'Obdielo dáta suseda';

  @override
  String get neighbors_requestTimedOut => 'Súďia žiadajú o časové ukončenie.';

  @override
  String neighbors_errorLoading(String error) {
    return 'Chyba pri načítaní susedov: $error';
  }

  @override
  String get neighbors_repeatersNeighbors => 'Opakovadlá Súsezná';

  @override
  String get neighbors_noData =>
      'Nie je dostupná žiadna informácia o susedoch.';

  @override
  String neighbors_unknownContact(String pubkey) {
    return 'Neznáma $pubkey';
  }

  @override
  String neighbors_heardAgo(String time) {
    return 'Počuli sme to: $time dozadu';
  }

  @override
  String get channelPath_title => 'Cesta balíka';

  @override
  String get channelPath_viewMap => 'Zobraziť mapu';

  @override
  String get channelPath_otherObservedPaths => 'Ostatné pozorovacie cesty';

  @override
  String get channelPath_repeaterHops => 'Skoky opakovača';

  @override
  String get channelPath_noHopDetails =>
      'Podrobnosti o balíčku zatiaľ nie sú dostupné.';

  @override
  String get channelPath_sourceLabel => 'Zdroj';

  @override
  String get channelPath_sourceMqtt => 'MQTT';

  @override
  String get channelPath_viaMqttNoRfPath =>
      'Táto správa prišla cez MQTT. Vaše rádio ju nepočulo, takže neexistuje rádiová trasa z vášho rádia.';

  @override
  String get channelPath_messageDetails => 'Podrobnosti o zprávach';

  @override
  String get channelPath_senderLabel => 'Posielateľ';

  @override
  String get channelPath_timeLabel => 'Čas';

  @override
  String get channelPath_repeatsLabel => 'Opakovanie';

  @override
  String channelPath_pathLabel(int index) {
    return 'Cesta $index';
  }

  @override
  String get channelPath_observedLabel => 'Pozorované';

  @override
  String channelPath_observedPathTitle(int index, String hops) {
    return 'Sledovaný postup $index • $hops';
  }

  @override
  String get channelPath_noLocationData => 'Žiadne údaje o polohe';

  @override
  String channelPath_timeWithDate(int day, int month, String time) {
    return '$day/$month $time';
  }

  @override
  String channelPath_timeOnly(String time) {
    return '$time';
  }

  @override
  String get channelPath_unknownPath => 'Neznáme';

  @override
  String get channelPath_floodPath => 'Povodňová';

  @override
  String get channelPath_directPath => 'Priamo';

  @override
  String channelPath_observedZeroOf(int total) {
    return '0 z $total skokov';
  }

  @override
  String channelPath_observedSomeOf(int observed, int total) {
    return '$observed z $total skokov';
  }

  @override
  String get channelPath_mapTitle => 'Mapa Trasy';

  @override
  String get channelPath_noRepeaterLocations =>
      'Pre túto cestu nie je dostupných žiadne polohy opakovačov.';

  @override
  String channelPath_primaryPath(int index) {
    return 'Cesta $index (Hlavná)';
  }

  @override
  String get channelPath_pathLabelTitle => 'Cesta';

  @override
  String get channelPath_observedPathHeader => 'Sledovaná cesta';

  @override
  String channelPath_selectedPathLabel(String label, String prefixes) {
    return '$label • $prefixes';
  }

  @override
  String get channelPath_noHopDetailsAvailable =>
      'Pre toto balíček nie sú dostupné údaje o skokoch.';

  @override
  String get channelPath_unknownRepeater => 'Neznáme opakovače';

  @override
  String get community_title => 'Komunita';

  @override
  String get community_create => 'Vytvoriť komunitu';

  @override
  String get community_createDesc =>
      'Vytvorte novú komunitu a zdieľajte cez QR kód.';

  @override
  String get community_join => 'Pripojiť';

  @override
  String get community_joinTitle => 'Pripojiť sa k spoločenstvu';

  @override
  String community_joinConfirmation(String name) {
    return 'Chceš sa pridať do komunity \"$name\"?';
  }

  @override
  String get community_scanQr => 'Skontrolujte komunitný QR kód';

  @override
  String get community_scanInstructions =>
      'Zamerte kameru na komunitný QR kód.';

  @override
  String get community_showQr => 'Zobraziť QR kód';

  @override
  String get community_publicChannel => 'Komunita verejná';

  @override
  String get community_hashtagChannel => 'Komunitný Hashtag';

  @override
  String get community_name => 'Komunita';

  @override
  String get community_enterName => 'Zadajte názov komunity';

  @override
  String community_created(String name) {
    return 'Komunita \"$name\" vytvorená';
  }

  @override
  String community_joined(String name) {
    return 'Pripojená komunita \"$name\"';
  }

  @override
  String get community_qrTitle => 'Zdieľť komunitu';

  @override
  String community_qrInstructions(String name) {
    return 'Skenejte tento QR kód, aby ste sa pripojili k $name.';
  }

  @override
  String get community_hashtagPrivacyHint =>
      'Hashtagové kanály komunity sú prístupné len členom komunity';

  @override
  String get community_invalidQrCode => 'Neplatná QR kód komunity.';

  @override
  String get community_alreadyMember => 'Už ste členom.';

  @override
  String community_alreadyMemberMessage(String name) {
    return 'Vy ste už členom \"$name\".';
  }

  @override
  String get community_addPublicChannel => 'Pridať verejný komunikačný kanál';

  @override
  String get community_addPublicChannelHint =>
      'Automaticky prida verejný kanál pre túto komunitu.';

  @override
  String get community_noCommunities =>
      'Zatiaľ ste sa nepripojili k žiadnej komunite';

  @override
  String get community_scanOrCreate =>
      'Skene QR kód alebo vytvor komunitu na začiatok.';

  @override
  String get community_manageCommunities => 'Spravovať komunity';

  @override
  String get community_delete => 'Nechajte komunitu';

  @override
  String community_deleteConfirm(String name) {
    return 'Opustiť \"$name\"?';
  }

  @override
  String community_deleteChannelsWarning(int count) {
    return 'Tým sa tiež vymaže $count kanál/kanálov a ich správy.';
  }

  @override
  String community_deleted(String name) {
    return 'Opustená komunita \"$name\"';
  }

  @override
  String get community_regenerateSecret => 'Zobraziť nový tajný kód';

  @override
  String community_regenerateSecretConfirm(String name) {
    return 'Znovu vygenerovať tajný kľúč pre \"$name\"? Všetci členovia budú musieť skanovať nový QR kód, aby mohli nadviazať komunikáciu.';
  }

  @override
  String get community_regenerate => 'Znovu vygenerovať';

  @override
  String community_secretRegenerated(String name) {
    return 'Záznam pre \"$name\" bol regenerovaný tajne';
  }

  @override
  String get community_updateSecret => 'Aktualizovať tajné heslo';

  @override
  String community_secretUpdated(String name) {
    return 'Zmena tajnej slova pre \"$name\"';
  }

  @override
  String community_scanToUpdateSecret(String name) {
    return 'Skáňte nový QR kód na aktualizáciu tajného hesla pre \"$name\"';
  }

  @override
  String get community_addHashtagChannel => 'Pridať komunitný hashtag';

  @override
  String get community_addHashtagChannelDesc =>
      'Pridajte hashtagový kanál pre túto komunitu.';

  @override
  String get community_selectCommunity => 'Vyberte komunitu';

  @override
  String get community_regularHashtag => 'Zvyčajný hashtag';

  @override
  String get community_regularHashtagDesc =>
      'Veľký hashtag (ktočokoľvek sa môže pridať)';

  @override
  String get community_communityHashtag => 'Komunitný Hashtag';

  @override
  String get community_communityHashtagDesc => 'Špecifické pre členov komunity';

  @override
  String community_forCommunity(String name) {
    return 'Pre $name';
  }

  @override
  String get listFilter_tooltip => 'Filtrovať a triediť';

  @override
  String get listFilter_sortBy => 'Triediť podľa';

  @override
  String get listFilter_latestMessages => 'Posledné správy';

  @override
  String get listFilter_heardRecently => 'Nedávno počuli.';

  @override
  String get listFilter_az => 'Od A po Z';

  @override
  String get listFilter_filters => 'Filtre';

  @override
  String get listFilter_all => 'Všetko';

  @override
  String get listFilter_favorites => 'Obľúbené';

  @override
  String get listFilter_addToFavorites => 'Pridaj do obľúbených';

  @override
  String get listFilter_removeFromFavorites => 'Odstrániť z označení';

  @override
  String get listFilter_users => 'Používatelia';

  @override
  String get listFilter_repeaters => 'Opakovadlá';

  @override
  String get listFilter_roomServers => 'Servéry miestnosti';

  @override
  String get listFilter_unreadOnly => 'Nezaregistrované len';

  @override
  String get listFilter_newGroup => 'Nová skupina';

  @override
  String get traceCard_title => 'Karta trasovania';

  @override
  String get traceCard_open => 'Zdieľať kartu trasovania';

  @override
  String traceCard_from(String name) {
    return 'Od $name';
  }

  @override
  String traceCard_to(String name) {
    return 'Pre $name';
  }

  @override
  String traceCard_sentAt(String time) {
    return 'Odoslané $time';
  }

  @override
  String traceCard_roundTrip(String seconds) {
    return 'Tam a späť $seconds s';
  }

  @override
  String traceCard_hops(int count) {
    return 'Skoky: $count';
  }

  @override
  String get traceCard_backToYou => 'Späť k tebe';

  @override
  String traceCard_distance(String distance) {
    return 'Trasa $distance';
  }

  @override
  String traceCard_weakest(String snr) {
    return 'Najslabšie spojenie $snr';
  }

  @override
  String get traceCard_noMap =>
      'Pre túto trasu nie sú známe polohy, preto nie je mapa.';

  @override
  String get traceCard_guessed => 'odhadovaná poloha';

  @override
  String get traceCard_mapLabel => 'Mapa cesty tam a späť';

  @override
  String get traceCard_shareImage => 'Zdieľať obrázok';

  @override
  String get traceCard_shareText => 'Zdieľať text';

  @override
  String get traceCard_shareFailed => 'Kartu trasovania sa nepodarilo zdieľať.';

  @override
  String get traceCard_snrUnknown => 'bez SNR';

  @override
  String get pathTrace_you => 'Vy';

  @override
  String get pathTrace_failed => 'Sledovanie cesty zlyhalo.';

  @override
  String get pathTrace_notAvailable => 'Path trace nie je k dispozícii.';

  @override
  String get pathTrace_refreshTooltip => 'Obnoviť Path Trace.';

  @override
  String get pathTrace_someHopsNoLocation =>
      'Jedna alebo viac chmeľov chýba lokalita!';

  @override
  String get pathTrace_clearTooltip => 'Zmazať cestu';

  @override
  String get losSelectStartEnd => 'Vyberte počiatočný a koncový uzol pre LOS.';

  @override
  String losRunFailed(String error) {
    return 'Kontrola priamej viditeľnosti zlyhala: $error';
  }

  @override
  String get losClearAllPoints => 'Vymazať všetky body';

  @override
  String get losRunToViewElevationProfile =>
      'Ak chcete zobraziť výškový profil, spustite LOS';

  @override
  String get losMenuTitle => 'Menu LOS';

  @override
  String get losMenuSubtitle =>
      'Klepnutím na uzly alebo dlhým stlačením mapy získate vlastné body';

  @override
  String get losShowDisplayNodes => 'Zobraziť uzly zobrazenia';

  @override
  String get losCustomPoints => 'Vlastné body';

  @override
  String losCustomPointLabel(int index) {
    return 'Vlastné $index';
  }

  @override
  String get losPointA => 'Bod A';

  @override
  String get losPointB => 'Bod B';

  @override
  String losAntennaA(String value, String unit) {
    return 'Anténa A: $value $unit';
  }

  @override
  String losAntennaB(String value, String unit) {
    return 'Anténa B: $value $unit';
  }

  @override
  String get losRun => 'Spustite LOS';

  @override
  String get losNoElevationData => 'Žiadne údaje o nadmorskej výške';

  @override
  String losProfileClear(
    String distance,
    String distanceUnit,
    String clearance,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, vymazať LOS, min. vôľa $clearance $heightUnit';
  }

  @override
  String losProfileBlocked(
    String distance,
    String distanceUnit,
    String obstruction,
    String heightUnit,
  ) {
    return '$distance $distanceUnit, blokovaný $obstruction $heightUnit';
  }

  @override
  String get losStatusChecking => 'LOS: kontrolujem...';

  @override
  String get losStatusNoData => 'LOS: žiadne údaje';

  @override
  String losStatusSummary(int clear, int total, int blocked, int unknown) {
    return 'LOS: $clear/$total vymazané, $blocked blokované, $unknown neznáme';
  }

  @override
  String get losErrorElevationUnavailable =>
      'Údaje o nadmorskej výške nie sú k dispozícii pre jednu alebo viacero vzoriek.';

  @override
  String get losErrorInvalidInput =>
      'Neplatné body/údaje o nadmorskej výške pre výpočet LOS.';

  @override
  String get losRenameCustomPoint => 'Premenovať vlastný bod';

  @override
  String get losPointName => 'Názov bodu';

  @override
  String get losShowPanelTooltip => 'Zobraziť panel LOS';

  @override
  String get losHidePanelTooltip => 'Skryť panel LOS';

  @override
  String get losElevationAttribution =>
      'Údaje o nadmorskej výške: Open-Meteo (CC BY 4.0)';

  @override
  String get losLegendRadioHorizon => 'Rádiový horizont';

  @override
  String get losLegendLosBeam => 'Priama viditeľnosť';

  @override
  String get losLegendTerrain => 'Terén';

  @override
  String get losBlockedSpotsTitle => 'Zablokované miesta';

  @override
  String get losBlockedSpotsHint =>
      'Kliknite na zablokované miesto, aby ste ho zvýraznili na mape.';

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
  String get losSelectedObstructionTitle => 'Vybraná prekážka';

  @override
  String losSelectedObstructionDetails(
    String obstruction,
    String heightUnit,
    String distanceFromA,
    String distanceUnit,
    String distanceFromB,
  ) {
    return 'Blocked by $obstruction $heightUnit, $distanceFromA from A and $distanceFromB from B ($distanceUnit).';
  }

  @override
  String get losFrequencyLabel => 'Frekvencia';

  @override
  String get losFrequencyInfoTooltip => 'Zobraziť podrobnosti výpočtu';

  @override
  String get losFrequencyDialogTitle => 'Výpočet rádiového horizontu';

  @override
  String losFrequencyDialogDescription(
    double baselineK,
    double baselineFreq,
    double frequencyMHz,
    double kFactor,
  ) {
    return 'Počnúc od k=$baselineK pri $baselineFreq MHz výpočet upraví k-faktor pre aktuálne pásmo $frequencyMHz MHz, ktorý definuje zakrivený strop rádiového horizontu.';
  }

  @override
  String get contacts_pathTrace => 'Sledovanie lúčov';

  @override
  String get contacts_ping => 'Pingovať';

  @override
  String get contacts_repeaterPathTrace => 'Sledovanie cesty k opakovaču';

  @override
  String get contacts_repeaterPing => 'Pingovať opakovač';

  @override
  String get contacts_roomPathTrace => 'Sledovanie cesty k serveru miestnosti';

  @override
  String get contacts_roomPing => 'Ping server miestnosti';

  @override
  String get contacts_chatTraceRoute => 'Sledovať trasu lúča';

  @override
  String contacts_pathTraceTo(String name) {
    return 'Sledovať trasu k $name';
  }

  @override
  String get contacts_clipboardEmpty => 'Schránka je prázdna.';

  @override
  String get contacts_pasteNotContact =>
      'Toto nie je kontakt MeshCore. Skopírujte odkaz alebo oznam meshcore:// a skúste to znova.';

  @override
  String get contacts_invalidAdvertFormat => 'Neplatné kontaktné údaje';

  @override
  String get contacts_contactImported => 'Kontakt bol importovaný.';

  @override
  String get contacts_contactImportFailed =>
      'Kontakt sa nepodarilo importovať.';

  @override
  String get contacts_zeroHopAdvert => 'Inzerát Zero Hop';

  @override
  String get contacts_floodAdvert => 'Inzerát povodní';

  @override
  String get contacts_copyAdvertToClipboard => 'Kopírovať reklamu do schránky';

  @override
  String get contacts_addContactFromClipboard => 'Pridať kontakt z schránky';

  @override
  String get contacts_ShareContact => 'Kopírovať kontakt do schránky';

  @override
  String get contacts_ShareContactZeroHop => 'Zdieľať kontakt cez inzerát';

  @override
  String get contacts_zeroHopContactAdvertSent => 'Poslal kontakt cez inzerát.';

  @override
  String get contacts_zeroHopContactAdvertFailed =>
      'Zlyhalo odoslanie kontaktu.';

  @override
  String get contacts_contactAdvertCopied =>
      'Inzerát bol skopírovaný do schránky.';

  @override
  String get contacts_contactAdvertCopyFailed =>
      'Kopírovanie inzerátu do schránky zlyhalo.';

  @override
  String get notification_activityTitle => 'Aktivita MeshCore';

  @override
  String notification_messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'správ',
      few: 'správy',
      one: 'správa',
    );
    return '$count $_temp0';
  }

  @override
  String notification_channelMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'správ kanálu',
      few: 'správy kanálu',
      one: 'správa kanálu',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nových uzlov',
      few: 'nové uzly',
      one: 'nový uzol',
    );
    return '$count $_temp0';
  }

  @override
  String notification_newTypeDiscovered(String contactType) {
    return 'Nový $contactType objavený';
  }

  @override
  String get notification_receivedNewMessage => 'Prijatá nová správa';

  @override
  String get settings_gpxExportRepeaters =>
      'Exportovať repeater / server miestnosti do GPX';

  @override
  String get settings_gpxExportRepeatersSubtitle =>
      'Exportuje repeater / roomserver s lokalitou do súboru GPX.';

  @override
  String get settings_gpxExportContacts => 'Export sprievodcov do GPX';

  @override
  String get settings_gpxExportContactsSubtitle =>
      'Exportuje sprievodcov s umiestnením do súboru GPX.';

  @override
  String get settings_gpxExportAll => 'Exportovať všetky kontakty do GPX';

  @override
  String get settings_gpxExportAllSubtitle =>
      'Exportuje všetky kontakty s lokalitou do súboru GPX.';

  @override
  String get settings_gpxExportSuccess => 'Úspešne exportovaný súbor GPX.';

  @override
  String get settings_gpxExportNoContacts => 'Žiadne kontakty na export.';

  @override
  String get settings_gpxExportNotAvailable =>
      'Nie je podporované na vašom zariadení/operáciomnom systéme';

  @override
  String get settings_gpxExportError => 'Vyskytol sa chyba počas exportu.';

  @override
  String get settings_gpxExportRepeatersRoom =>
      'Umiestnenia opakovačov a serverov miestností';

  @override
  String get settings_gpxExportChat => 'Lokácie sprievodcov';

  @override
  String get settings_gpxExportAllContacts => 'Všetky kontaktné lokality';

  @override
  String get settings_gpxExportShareText =>
      'Mapové údaje exportované z NOTORYX Core';

  @override
  String get settings_gpxExportShareSubject =>
      'NOTORYX Core export dát GPX mapových údajov';

  @override
  String get snrIndicator_nearByRepeaters => 'Miestne opakovače';

  @override
  String get snrIndicator_lastSeen => 'Naposledy videný';

  @override
  String get contactsSettings_title => 'Nastavenia kontaktov';

  @override
  String get contactsSettings_autoAddTitle => 'Automatické zisťovanie';

  @override
  String get contactsSettings_otherTitle =>
      'Ďalšie nastavenia súvisiace s kontaktami';

  @override
  String get contactsSettings_autoAddUsersTitle =>
      'Automaticky pridávať užívateľov';

  @override
  String get contactsSettings_autoAddUsersSubtitle =>
      'Povoliť spoločníkovi automaticky pridávať objavených užívateľov.';

  @override
  String get contactsSettings_autoAddRepeatersTitle =>
      'Automaticky pridávať opakovače';

  @override
  String get contactsSettings_autoAddRepeatersSubtitle =>
      'Povoliť spoločníkovi automaticky pridávať objavené repeater.';

  @override
  String get contactsSettings_autoAddRoomServersTitle =>
      'Automaticky pridávať server miestnosti';

  @override
  String get contactsSettings_autoAddRoomServersSubtitle =>
      'Povoliť spoločníkovi automaticky pridať objavené serverové miestnosti.';

  @override
  String get contactsSettings_autoAddSensorsTitle =>
      'Automaticky pridávať senzory';

  @override
  String get contactsSettings_autoAddSensorsSubtitle =>
      'Povoliť spoločníkovi automaticky pridávať objavené senzory.';

  @override
  String get contactsSettings_overwriteOldestTitle => 'Prepísať najstaršie';

  @override
  String get contactsSettings_overwriteOldestSubtitle =>
      'Keď je zoznam kontaktov plný, bude nahradený najstarší neoznačený kontakt.';

  @override
  String get discoveredContacts_Title => 'Objavené kontakty';

  @override
  String get discoveredContacts_noMatching => 'Žiadne zhodné kontakty';

  @override
  String get discoveredContacts_searchHint => 'Vyhľadať objavené kontakty';

  @override
  String get discoveredContacts_contactAdded => 'Kontakt bol pridaný';

  @override
  String get discoveredContacts_addContact => 'Pridať kontakt';

  @override
  String get discoveredContacts_copyContact => 'Kopírovať kontakt do schránky';

  @override
  String get discoveredContacts_deleteContact => 'Zmazať kontakt';

  @override
  String get discoveredContacts_deleteContactAll =>
      'Zmazať všetky objavené kontakty';

  @override
  String get discoveredContacts_deleteContactAllContent =>
      'Ste si istí, že chcete zmazať všetky objavené kontakty?';

  @override
  String get chat_sendCooldown => 'Prosím, počkajte chvíľu, než zašlete znova.';

  @override
  String get appSettings_jumpToOldestUnread => 'Presk oceň';

  @override
  String get appSettings_jumpToOldestUnreadSubtitle =>
      'Pri otvorení chatu s neprečítanými správami, prejdite do prvého neprečítaného, namiesto poslednej.';

  @override
  String get appSettings_languageHu => 'Maďarský';

  @override
  String get appSettings_languageJa => 'Japonský';

  @override
  String get appSettings_languageKo => 'Kórejský';

  @override
  String get radioStats_tooltip => 'Statistiky rádiových a sieťových kanálov';

  @override
  String get radioStats_screenTitle => 'Štatistiky rádiových vysielaní';

  @override
  String get radioStats_notConnected =>
      'Pripojte sa k zariadeniu, aby ste mohli sledovať štatistiky rádiového vysielania.';

  @override
  String get radioStats_firmwareTooOld =>
      'Statistické údaje z rádia vyžadujú sprievodný softvér verzie v8 alebo novšej.';

  @override
  String get radioStats_waiting => 'Čakám na údaje…';

  @override
  String radioStats_noiseFloor(int noiseDbm) {
    return 'Úroveň hluku: $noiseDbm dBm';
  }

  @override
  String radioStats_lastRssi(int rssiDbm) {
    return 'Posledný údaj RSSI: $rssiDbm dBm';
  }

  @override
  String radioStats_lastSnr(String snr) {
    return 'Posledná hodnota SNR: $snr dB';
  }

  @override
  String radioStats_txAir(int seconds) {
    return 'Čas vysielania na TX (celkový): $seconds s';
  }

  @override
  String radioStats_rxAir(int seconds) {
    return 'Čas RX (celkový): $seconds s';
  }

  @override
  String get radioStats_chartCaption =>
      'Úroveň šumu (dBm) pre posledné vzorky.';

  @override
  String radioStats_stripNoise(int noiseDbm) {
    return 'Úroveň hluku: $noiseDbm dBm';
  }

  @override
  String get radioStats_stripWaiting => 'Získavanie údajov o rádiu…';

  @override
  String get radioStats_settingsTile => 'Štatistiky rádiových vysielaní';

  @override
  String get radioStats_settingsSubtitle =>
      'Úroveň hluku, RSSI, SNR a časové rozloženie';

  @override
  String get translation_title => 'Preklad';

  @override
  String get imageMessages_enableTitle => 'Zabezpečte zobrazi';

  @override
  String get imageMessages_enableSubtitle =>
      'Odeslanie obrazov pre mšťanie. Potrebujete jednorazové stáhnutie modelu obrazov.';

  @override
  String get imageMessages_modelSectionTitle => 'Model v kínajme';

  @override
  String get imageMessages_downloadModel => 'Stáhnie';

  @override
  String get imageMessages_cancelDownload => 'Zastavenie';

  @override
  String get imageMessages_removeModel => 'Vyhniť model';

  @override
  String get imageMessages_modelReady => 'Čiačný';

  @override
  String get imageMessages_modelNotPublished =>
      'Nesprávne vypisáné — tento prechovka nie môže jej stáhnuť.';

  @override
  String get imageMessages_downloadFailed =>
      'Model s obrázkom nemôžno sťažovať.';

  @override
  String get imageMessages_autoProcessTitle => 'Automaticky prepojiť slučaje.';

  @override
  String get imageMessages_autoProcessSubtitle =>
      'Rekonstruujte každý obraz tak, ako pridá. Používajete okolo 2 GB pamäti pre drugú hodinu; odložte rekonstrukciu tým kliknutím.';

  @override
  String get translation_enableTitle => 'Aktivovať preklad';

  @override
  String get translation_enableSubtitle =>
      'Prekladajte prichádzajúce správy a umožnite ich preklad pred odoslaním.';

  @override
  String get translation_composerTitle => 'Preložte pred odeslaním';

  @override
  String get translation_composerSubtitle =>
      'Riadi výchoce stav ikony pre preklad, ktorú používa program.';

  @override
  String get translation_autoIncomingTitle => 'Automaticky prekladať správy';

  @override
  String get translation_autoIncomingSubtitle =>
      'Automaticky prekladá správy pre upozornenia aj pre čet alebo kanál.';

  @override
  String get translation_translateMessage => 'Preložiť správu';

  @override
  String get translation_targetLanguage => 'Cieľový jazyk';

  @override
  String get translation_useAppLanguage => 'Použite jazyk aplikácie';

  @override
  String get translation_downloadedModelLabel => 'Stiahnutý model';

  @override
  String get translation_presetModelLabel =>
      'Prednastavený model od Hugging Face';

  @override
  String get translation_manualUrlLabel =>
      'Odkaz na manuál (v elektronickej forme)';

  @override
  String get translation_downloadModel => 'Stiahnuť model';

  @override
  String get translation_downloading => 'Stiahnutie...';

  @override
  String get translation_working => 'Práca...';

  @override
  String get translation_stop => 'Zastavte';

  @override
  String get translation_mergingChunks =>
      'Sliečenie stiahnutých častí do konečného súboru...';

  @override
  String get translation_downloadedModels => 'Stiahnuté modely';

  @override
  String get translation_deleteModel => 'Odstrániť model';

  @override
  String get translation_modelDownloaded => 'Model pre preklad bol stiahnutý.';

  @override
  String get translation_downloadStopped => 'Stiahnutie bolo prerušené.';

  @override
  String translation_downloadFailed(String error) {
    return 'Neúspešné stiahnutie: $error';
  }

  @override
  String get translation_enterUrlFirst =>
      'Najprv zadajte URL pre konkrétny model.';

  @override
  String get scanner_linuxPairingShowPin => 'Zobraziť PIN';

  @override
  String get scanner_linuxPairingHidePin => 'Skryť PIN';

  @override
  String get scanner_linuxPairingPinTitle => 'PIN pre párovanie cez Bluetooth';

  @override
  String scanner_linuxPairingPinPrompt(String deviceName) {
    return 'Zadajte PIN pre $deviceName (ak neexistuje, nechajte prázdne).';
  }

  @override
  String get translation_messageTranslation => 'Preklad textu';

  @override
  String get translation_translateBeforeSending => 'Preložte pred odeslaním';

  @override
  String get translation_composerEnabledHint =>
      'Správy budú preložené, než budú odoslané.';

  @override
  String get translation_composerDisabledHint =>
      'Posielajte správy v pôvodnej písanom jazyku.';

  @override
  String translation_translateTo(String language) {
    return 'Preložte do $language';
  }

  @override
  String get translation_translationOptions => 'Možnosti prekladania';

  @override
  String get translation_systemLanguage => 'Jazyk systému';

  @override
  String get background_serviceTitle => 'MeshCore running';

  @override
  String get background_serviceText => 'Keeping BLE connected';

  @override
  String appSettings_translationModelDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String appSettings_translationModelDeleteFailed(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String channels_channelUpdateFailed(String error) {
    return 'Failed to update channel: $error';
  }

  @override
  String get contact_typeChat => 'Chat';

  @override
  String get contact_typeRepeater => 'Repeater';

  @override
  String get contact_typeRoom => 'Room';

  @override
  String get contact_typeSensor => 'Sensor';

  @override
  String get contact_typeUnknown => 'Unknown';

  @override
  String get map_zoomIn => 'Zväčšiť';

  @override
  String get map_zoomOut => 'Zmenť zamer zblízka';

  @override
  String get map_centerMap => 'Mapa centra';

  @override
  String get chrome_bluetoothRequiresChromium =>
      'Web Bluetooth vyžaduje prehliadač Chromium.';

  @override
  String channels_communityShortId(String id) {
    return 'ID: $id...';
  }

  @override
  String get pathTrace_legendGpsConfirmed => 'GPS potvrdilo';

  @override
  String get pathTrace_legendInferred => 'Odvodená poloha';

  @override
  String get pathMap_viewSingle => 'Jednotlivý';

  @override
  String get pathMap_viewCombined => 'Spojené';

  @override
  String get pathMap_play => 'Prehrať';

  @override
  String get pathMap_pause => 'Pozastaviť';

  @override
  String get pathMap_replay => 'Prehrať znova';

  @override
  String get pathMap_stepBack => 'Predchádzajúci skok';

  @override
  String get pathMap_stepForward => 'Nasledujúci skok';

  @override
  String get pathMap_animationOn => 'Zobraziť animáciu paketu';

  @override
  String get pathMap_animationOff => 'Skryť animáciu paketu';

  @override
  String pathMap_hopOf(int current, int total) {
    return 'Skok $current z $total';
  }

  @override
  String pathMap_observedPaths(int count) {
    return 'Pozorované cesty: $count';
  }

  @override
  String get pathMap_primary => 'Primárna';

  @override
  String pathMap_alternate(int index) {
    return 'Alternatívny $index';
  }

  @override
  String pathMap_hopCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skokov',
      few: '$count skoky',
      one: '1 skok',
    );
    return '$_temp0';
  }

  @override
  String pathMap_gpsCount(int confirmed, int total) {
    return '$confirmed/$total GPS';
  }

  @override
  String get pathMap_legendShared => 'Spoločný segment';

  @override
  String get pathMap_legendEstimated => 'Odhadovaný segment';

  @override
  String pathMap_sharedNodeCount(int count) {
    return 'Používané $count cestami';
  }

  @override
  String pathMap_partialAnimation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skokov nemá polohu — zobrazená trasa je neúplná',
      few: '$count skoky nemajú polohu — zobrazená trasa je neúplná',
      one: '1 skok nemá polohu — zobrazená trasa je neúplná',
    );
    return '$_temp0';
  }

  @override
  String get pathMap_showAllPaths => 'Zobraziť všetky';

  @override
  String get pathMap_hidePath => 'Skryť cestu';

  @override
  String get pathMap_showPath => 'Zobraziť trasu';

  @override
  String get pathMap_collapsePanel => 'Zatvoriť panel';

  @override
  String get pathMap_expandPanel => 'Rozbaliť panel';

  @override
  String get pathMap_noLocation => 'Bez polohy';

  @override
  String get pathMap_followPacket => 'Uzamknúť pohľad na paket';

  @override
  String get pathMap_unfollowPacket => 'Odomknúť pohľad od paketu';

  @override
  String get imageSend_title => 'Vyslat obraz';

  @override
  String get imageSend_cropNote =>
      'Zmeneno na 512 × 512 · vzorýst nie byl zachovan';

  @override
  String get imageSend_originalSize =>
      'Výborný text:\n\n\"Language is the road map of a culture. It tells us where to go as a society and helps us understand the world around us. Learning a new language opens up new perspectives and opportunities, allowing us to connect with people from different backgrounds and build bridges between cultures.\"\n\nSlovenská preklada:\n\n\"Jazyk je cesta pre zručnosti a odráža kultúru. Dá nám uvedomi, dokádať, kúdy sa pohladneme a pomáha našej společnosti poradiť sa v rôznych okolnosti a porozumieť o svetu kolem nás. Nauka nového jazyka otviera nové perspektívy a možnosti, čo pohybuje našu schopnosť sa spoluprávať s ľudmi z rôznych okolnosti a budovať mosty medzi kultúry.\"';

  @override
  String get imageSend_onAirSize => 'V prúce';

  @override
  String get imageSend_quality => 'Kvalita';

  @override
  String get imageSend_qualityStandard => 'Stándard';

  @override
  String get imageSend_qualityHigh => 'Vysoká';

  @override
  String get imageSend_packetsLabel => 'Pakety';

  @override
  String get imageSend_airtimeLabel => 'Čas na anteni';

  @override
  String get imageSend_sizeLabel => 'Základ';

  @override
  String imageSend_packetsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'paketov',
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
  String get imageSend_radioUnknownTitle => 'Nastavenia radio nezná';

  @override
  String get imageSend_radioUnknownBody =>
      'Zkonečte s určým prijemcem, aby sa mohlo výpočet času, ktorý je v prúbežu.';

  @override
  String get imageSend_longSendTitle => 'Dlouhá transmisia';

  @override
  String imageSend_longSendBody(String duration) {
    return 'Tento dôvod udrží kanál priamo na $duration.';
  }

  @override
  String get imageSend_floodNote =>
      'Povodný routing: každý repeater v rozsahu zrňa každý paket, takže kanál zostá zajetší dlouше, než tu.';

  @override
  String get imageSend_parityTitle => 'Poučný paket pre očudenie';

  @override
  String get imageSend_paritySubtitle =>
      'Jedný dodatný paket. Skúsené súhlasy nie sa uznávaú, takže to umožňuje prechovávaču opraviť obraz, pokiaľ sa jedný paket niebyl ztrácený.';

  @override
  String get imageSend_send => 'Odeslať';

  @override
  String get imageSend_cancel => 'Zastavenie';

  @override
  String get imageSend_encodeFailed => 'Tento obráz nie byla byla schována.';

  @override
  String get imageSend_codecDownloading =>
      'Model prehľadovania prebeža stále stále stále prechádza.';

  @override
  String get imageSend_codecUnavailable =>
      'Zobrazenie nie je dostupný na tomto zariadení.';

  @override
  String get imageSend_codecDisabled =>
      'Zobrazy s prešteľkami sú v nastavení vypnené.';

  @override
  String get imageSend_deviceUnsupported =>
      'Tento radiok nie môže odeslať obrazové pakety. Podeďte správne určité zařízení s oprogramovaním spolupráce 13 alebo novším.';

  @override
  String get imageSend_directMessagesUnsupported =>
      'Obrazy sa prechádzajú jako skupinové údaje, preto sa ich môžu odeslať len na kanál — nie v príbeh sa.';

  @override
  String get imageSend_tooLarge =>
      'Tento obraz byl skodyrovany do viac paketov, ako umožňuje si sítka format.';

  @override
  String imageSend_sentConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'paketov',
      one: 'paket',
    );
    return 'Obrázok odoslaný ako $count $_temp0.';
  }

  @override
  String imageSend_sendFailed(String error) {
    return 'Obraz nemôžlo odeslať: $error';
  }

  @override
  String imageSend_sendingProgress(int sent, int total) {
    return 'Vysyťanie obrazu — pakét $sent z $total';
  }

  @override
  String receivedImage_senderPrefix(String prefix) {
    return 'Vęzlo $prefix';
  }

  @override
  String receivedImage_incoming(int received, int total) {
    return 'Otrzymané $received z $total pakotí';
  }

  @override
  String get receivedImage_queued => 'Čekanie na dekódovanie';

  @override
  String get receivedImage_tapToDecode => 'Kliknite, aby dekódovať';

  @override
  String get receivedImage_decoding => 'Rekonstrukcia… o čoľve 1 s';

  @override
  String receivedImage_incomplete(int received, int total) {
    return 'Obraz nieješťajný — $received z $total paciek príšlo';
  }

  @override
  String get receivedImage_corrupt => 'Obraz nemôžu byť prepojený';

  @override
  String get receivedImage_decoderMissing =>
      'Otrzymaná slúba — dekódovanie slúby je vypadejce';

  @override
  String get receivedImage_evicted => 'Obraz nemá uložený';

  @override
  String get receivedImage_retry => 'Zkôr to opítajte';

  @override
  String get receivedImage_decodeAgain => 'Zdeľte sa znovu';

  @override
  String get receivedImage_openSettings => 'Založte';

  @override
  String get receivedImage_tapToProcess => 'Ukliknite, aby sa príjomili';

  @override
  String receivedImage_awaiting(int bytes, int packets) {
    String _temp0 = intl.Intl.pluralLogic(
      packets,
      locale: localeName,
      other: 'paketov',
      one: 'paket',
    );
    return '$bytes bajtov · $packets $_temp0';
  }

  @override
  String imageSend_secondsValue(String seconds) {
    return '$seconds s';
  }

  @override
  String imageSend_minutesSecondsValue(String minutes, String seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get bastion_tagline => 'Komunikácia bez infraštruktúry.';

  @override
  String get bastion_nodes => 'Uzly';

  @override
  String get bastion_repeaters => 'Opakovače';

  @override
  String get bastion_active1h => 'Aktívne 1 h';

  @override
  String get bastion_mapCoverage => 'Mapa + pokrytie';

  @override
  String get bastion_routeIntelligence => 'Analýza trás';

  @override
  String get bastion_repeaterTools => 'Nástroje opakovača';

  @override
  String get bastion_fieldStats => 'Terénne štatistiky';

  @override
  String get bastion_fieldOps => 'Túra + terénne operácie';

  @override
  String get bastion_coverageCapture => 'Záznam pokrytia';

  @override
  String get bastion_mapAttribution =>
      'Mapové údaje © prispievatelia OpenStreetMap; dlaždice od zvoleného poskytovateľa';

  @override
  String bastion_observationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozorovaní',
      many: '$count pozorovania',
      few: '$count pozorovania',
      one: '1 pozorovanie',
    );
    return '$_temp0';
  }

  @override
  String bastion_uniqueNodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jedinečných uzlov',
      many: '$count jedinečného uzla',
      few: '$count jedinečné uzly',
      one: '1 jedinečný uzol',
    );
    return '$_temp0';
  }

  @override
  String bastion_hopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skokov',
      many: '$count skoku',
      few: '$count skoky',
      one: '1 skok',
    );
    return '$_temp0';
  }

  @override
  String bastion_minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minút',
      many: '$count minúty',
      few: '$count minúty',
      one: '1 minúta',
    );
    return '$_temp0';
  }

  @override
  String get sos_holdHint =>
      'Podržte 2 sekundy. Každých 5 minút posiela vašu polohu kontaktom túry, kým niekto neodpovie.';

  @override
  String sos_holdHintChannel(String channel) {
    return 'Podržte 2 sekundy. Každých 5 minút posiela vašu polohu kontaktom túry a do $channel, kým niekto neodpovie.';
  }

  @override
  String sos_notSent(String error) {
    return 'SOS nebolo odoslané: $error';
  }

  @override
  String sos_acknowledged(String name) {
    return 'Potvrdil(a) $name. Opakovanie zastavené.';
  }

  @override
  String get sos_waitingForRadio => 'Čaká sa, kým rádio odošle…';

  @override
  String sos_repeatsFinished(int sends, int max) {
    return 'Odoslané $sends z $max-krát. Opakovanie skončilo; zatiaľ bez odpovede.';
  }

  @override
  String sos_nextAt(int sends, int max, String time) {
    return 'Odoslané $sends z $max-krát. Ďalšie o $time.';
  }

  @override
  String get sos_active => 'SOS AKTÍVNE';

  @override
  String get sos_stop => 'ZASTAVIŤ';

  @override
  String get sos_imSafe => 'SOM V BEZPEČÍ';

  @override
  String get sos_holdSemantics => 'SOS. Podržte na odoslanie.';

  @override
  String get sos_keepHolding => 'DRŽTE ĎALEJ…';

  @override
  String get sos_holdForSos => 'PODRŽTE PRE SOS';

  @override
  String get sos_blockStorage =>
      'Najprv odstráňte chybu ukladania terénneho denníka.';

  @override
  String get sos_blockNotConnected =>
      'Pripojte svoje rádio MeshCore na odoslanie SOS.';

  @override
  String get sos_blockNoTarget =>
      'Vyberte kontakty túry alebo kanál SOS v časti Naplánovať túru.';

  @override
  String get checkIn_labelOk => 'Som v poriadku';

  @override
  String get checkIn_labelAtCamp => 'V tábore';

  @override
  String get checkIn_labelDelayed => 'Meškám';

  @override
  String get checkIn_labelHeadingBack => 'Vraciam sa';

  @override
  String get checkIn_blockLoading => 'Načítava sa túra…';

  @override
  String get checkIn_blockStorage =>
      'Pred odoslaním odstráňte chybu ukladania terénneho denníka.';

  @override
  String get checkIn_blockBusy => 'Odosiela sa hlásenie. Počkajte.';

  @override
  String get checkIn_blockNoContacts =>
      'Vyberte kontakty túry v časti Naplánovať túru.';

  @override
  String get checkIn_blockRosterIncomplete =>
      'Niektoré kontakty túry nie sú dostupné. Skontrolujte zoznam.';

  @override
  String get checkIn_blockNotConnected =>
      'Pripojte svoje rádio MeshCore na nahlásenie sa.';

  @override
  String get checkIn_blockNotActive => 'Spustite túru, aby ste zapli hlásenia.';

  @override
  String get checkIn_notSent => 'Neodoslané';

  @override
  String checkIn_deliveredToOne(String name) {
    return 'Doručené: $name';
  }

  @override
  String checkIn_deliveredToAll(int count) {
    return 'Doručené všetkým kontaktom ($count)';
  }

  @override
  String checkIn_deliveredSome(String delivered, String total) {
    return 'Doručené $delivered z $total';
  }

  @override
  String checkIn_notDeliveredTo(String names) {
    return 'Nedoručené: $names';
  }

  @override
  String get checkIn_waitingForRest => 'Čaká sa na ostatných';

  @override
  String get checkIn_aContact => 'kontakt';

  @override
  String get checkIn_statusPending => 'Čaká';

  @override
  String get checkIn_statusSent => 'Odoslané';

  @override
  String get checkIn_statusDelivered => 'Doručené';

  @override
  String get checkIn_statusFailed => 'Zlyhalo';

  @override
  String get checkIn_explainPending =>
      'Lokálne vo fronte. Nepotvrdzuje to rádiový prenos ani príjem.';

  @override
  String get checkIn_explainSent =>
      'Rádio prijalo odoslanie. Nebolo zaznamenané žiadne potvrdenie doručenia.';

  @override
  String get checkIn_explainDelivered =>
      'Aplikácia zaznamenala potvrdenie doručenia. Nedokazuje to, že si ho osoba prečítala.';

  @override
  String get checkIn_explainFailed =>
      'Žiadne potvrdené doručenie. Skontrolujte rádiové spojenie, dostupnosť príjemcu a históriu opakovaní.';

  @override
  String get checkIn_explainUnknown =>
      'Stav doručenia nie je dostupný. Nepredpokladajte, že správa dorazila.';

  @override
  String get tripBrief_heading => 'NOTORYX • Prehľad túry MeshCore';

  @override
  String tripBrief_trip(String name) {
    return 'Túra: $name';
  }

  @override
  String tripBrief_status(String status) {
    return 'Stav: $status';
  }

  @override
  String get tripBrief_active => 'Aktívna';

  @override
  String get tripBrief_stopped => 'Zastavená';

  @override
  String tripBrief_contacts(String names) {
    return 'Kontakty: $names';
  }

  @override
  String get tripBrief_noneSelected => 'Žiadne vybrané';

  @override
  String get tripBrief_unavailableContact =>
      'Nedostupný kontakt (skontrolujte zoznam)';

  @override
  String tripBrief_overdueAfter(int minutes) {
    return 'Aktivita mešká po: $minutes min (tento telefón upozorní, keď kontakt stíchne)';
  }

  @override
  String tripBrief_reminder(String value) {
    return 'Pripomienka hlásenia: $value';
  }

  @override
  String tripBrief_reminderEvery(int minutes) {
    return 'každých $minutes min bez hlásenia';
  }

  @override
  String tripBrief_choices(String choices) {
    return 'Možnosti hlásenia: $choices';
  }

  @override
  String tripBrief_position(String value) {
    return 'Poloha rádia v hláseniach: $value';
  }

  @override
  String get tripBrief_includedMayBeStale => 'Zahrnutá; môže byť zastaraná';

  @override
  String tripBrief_battery(String value) {
    return 'Batéria rádia v hláseniach: $value';
  }

  @override
  String get tripBrief_included => 'Zahrnutá';

  @override
  String get tripBrief_off => 'Vyp.';

  @override
  String get tripBrief_review =>
      'Pred odoslaním hlásenia skontrolujte príjemcov a správu.';

  @override
  String get tripBrief_noProof =>
      'Vo fronte alebo odoslané nedokazuje doručenie. Potvrdenie nedokazuje, že bolo prečítané.';

  @override
  String get tripBrief_overdueMeaning =>
      'Meškanie znamená žiadnu nedávnu aktivitu kontaktu; nie je to potvrdená núdzová situácia.';

  @override
  String get tripBrief_automations =>
      'Terénne automatizácie fungujú iba vtedy, keď je aplikácia aktívna. Dohodnite si samostatný plán pre prípad straty kontaktu.';

  @override
  String get tripBrief_sharesOnly =>
      'Tento prehľad iba zdieľa informácie; neodosiela rádiovú správu ani nespúšťa túru.';

  @override
  String get fieldOps_title => 'Terénne operácie NOTORYX Core';

  @override
  String get fieldOps_tabTrip => 'Túra';

  @override
  String get fieldOps_tabReady => 'Pripravenosť';

  @override
  String get fieldOps_tabLog => 'Denník';

  @override
  String get fieldOps_tabAuto => 'Auto';

  @override
  String get fieldOps_tabCoverage => 'Pokrytie';

  @override
  String get fieldOps_tabConnection => 'Spojenie';

  @override
  String get fieldOps_diagnostics => 'Diagnostika';

  @override
  String get fieldOps_storageLoadError =>
      'Terénne údaje sa nepodarilo načítať. Uložené údaje zostali zachované; automatizácie zostávajú vypnuté.';

  @override
  String get fieldOps_storageSaveError =>
      'Terénne údaje sa nepodarilo uložiť. Automatizácie zastavené; existujúce uložené údaje zostávajú zachované.';

  @override
  String get fieldOps_regionHint =>
      'Vyberte oblasť a úrovne priblíženia v časti Offline mapy.';

  @override
  String fieldOps_regionLabel(String source, String minZoom, String maxZoom) {
    return '$source • priblíženie $minZoom–$maxZoom';
  }

  @override
  String fieldOps_mapVerifyFailed(String error) {
    return 'Oblasť mapy sa nepodarilo overiť: $error';
  }

  @override
  String fieldOps_tripActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Túra aktívna • $count kontaktov',
      many: 'Túra aktívna • $count kontaktu',
      few: 'Túra aktívna • $count kontakty',
      one: 'Túra aktívna • 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_tripStopped =>
      'Túra je zastavená. Spustite ju, keď budete pripravení.';

  @override
  String fieldOps_reminderAt(String time) {
    return 'Pripomienka hlásenia o $time';
  }

  @override
  String fieldOps_quietTooLong(String names) {
    return 'Príliš dlho ticho: $names';
  }

  @override
  String get fieldOps_planTrip => 'Naplánovať túru';

  @override
  String get fieldOps_endTrip => 'Ukončiť túru';

  @override
  String get fieldOps_startTrip => 'Spustiť túru';

  @override
  String get fieldOps_tripBrief => 'Prehľad túry';

  @override
  String get fieldOps_connectRadio => 'Pripojiť rádio';

  @override
  String get fieldOps_previewedCheckIns => 'Hlásenia s náhľadom';

  @override
  String get fieldOps_previewedCheckInsHint =>
      'Vyberte stav, skontrolujte skutočných príjemcov a správu a potom odošlite. Vo fronte neznamená doručené.';

  @override
  String get fieldOps_tripRoster => 'Zoznam túry';

  @override
  String get fieldOps_rosterEmpty =>
      'Vyberte až šesť známych kontaktov četu v časti Naplánovať túru.';

  @override
  String get fieldOps_rosterCaveat =>
      '„Naposledy počutý“ je dôkaz minulej aktivity. Nepotvrdzuje súčasnú dostupnosť. Označenia meškania znamenajú žiadnu nedávnu aktivitu kontaktu, nie potvrdenú núdzovú situáciu.';

  @override
  String get fieldOps_offlineMaps => 'Offline mapy';

  @override
  String get fieldOps_checkingTiles => 'Kontrolujú sa uložené dlaždice…';

  @override
  String fieldOps_cachedTiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dlaždíc vo vyrovnávacej pamäti.',
      many: '$count dlaždice vo vyrovnávacej pamäti.',
      few: '$count dlaždice vo vyrovnávacej pamäti.',
      one: '1 dlaždica vo vyrovnávacej pamäti.',
    );
    return '$_temp0 Nezaručuje to, že je pokrytá celá trasa.';
  }

  @override
  String get fieldOps_downloadAreas =>
      'Stiahnuť / skontrolovať offline oblasti';

  @override
  String fieldOps_lastCheckIn(String time) {
    return 'Posledné hlásenie, $time';
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
      other: 'Znova odoslať $count nedoručeným',
      many: 'Znova odoslať $count nedoručeným',
      few: 'Znova odoslať $count nedoručeným',
      one: 'Znova odoslať 1 nedoručenému',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_memberUnavailable => 'Vybraný kontakt nie je dostupný';

  @override
  String get fieldOps_memberUnavailableHint =>
      'Pred odoslaním skontrolujte túto túru.';

  @override
  String fieldOps_lastActivity(int minutes) {
    return 'Posledná aktivita pred $minutes min';
  }

  @override
  String fieldOps_lastActivityOverdue(int minutes) {
    return 'Posledná aktivita pred $minutes min • mešká';
  }

  @override
  String get fieldOps_noCheckInRecorded =>
      'V tomto denníku nie je zaznamenané žiadne hlásenie.';

  @override
  String get fieldOps_tripMap => 'Mapa túry';

  @override
  String get fieldOps_tripMapEmpty =>
      'Žiadny vybraný kontakt zatiaľ nevysielal súradnice.';

  @override
  String get fieldOps_lastPositions => 'Naposledy vysielané polohy';

  @override
  String get fieldOps_positionsCaveat =>
      'Polohy môžu byť zastarané. Táto mapa nesleduje GPS telefónu a nedokazuje, že členovia sú teraz tu.';

  @override
  String get fieldOps_briefPreviewTitle => 'Náhľad prehľadu túry';

  @override
  String get fieldOps_briefPreviewHint =>
      'Obsahuje názvy túry a kontaktov. Pred zdieľaním skontrolujte. Súradnice, kľúče a história správ sú vynechané.';

  @override
  String get fieldOps_shareBrief => 'Zdieľať prehľad';

  @override
  String get fieldOps_briefSubject => 'Prehľad túry NOTORYX Core';

  @override
  String get fieldOps_tripName => 'Názov túry';

  @override
  String get fieldOps_defaultTripName => 'Moja túra';

  @override
  String get fieldOps_includePosition => 'Pridať vysielanú polohu rádia';

  @override
  String get fieldOps_includePositionHint =>
      'Môže byť zastaraná; zdieľanie je predvolene vypnuté.';

  @override
  String get fieldOps_includeBattery => 'Pridať batériu rádia';

  @override
  String get fieldOps_overdueLabel => 'Upozorniť ma, keď kontakt mlčí';

  @override
  String get fieldOps_reminderLabel => 'Pripomínať mi hlásenie';

  @override
  String get fieldOps_reminderHelper =>
      'Upozornenie v telefóne, aj keď je NOTORYX Core zatvorený.';

  @override
  String get fieldOps_reminderOff => 'Vyp.';

  @override
  String fieldOps_reminderAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Po $count minútach bez hlásenia',
      many: 'Po $count minúty bez hlásenia',
      few: 'Po $count minútach bez hlásenia',
      one: 'Po 1 minúte bez hlásenia',
    );
    return '$_temp0';
  }

  @override
  String get fieldOps_sosChannelLabel => 'SOS ide aj do kanála';

  @override
  String get fieldOps_sosChannelNone => 'Žiadny';

  @override
  String get fieldOps_selectContacts =>
      'Vyberte až šesť známych kontaktov četu';

  @override
  String get fieldOps_sendCheckInTitle => 'Odoslať hlásenie?';

  @override
  String fieldOps_recipients(String names) {
    return 'Komu: $names';
  }

  @override
  String get fieldOps_sendCheckInHint =>
      'Používa bežné priame správy. Doručenie sa bude sledovať v terénnom denníku.';

  @override
  String get fieldOps_send => 'Odoslať';

  @override
  String get sosRelay_title => 'Preposielanie SOS';

  @override
  String get sosRelay_enable =>
      'Preposielať SOS, ktoré nepreposlal žiadny opakovač';

  @override
  String get sosRelay_needsFirmware =>
      'Vyžaduje firmvér rádia v1.16 alebo novší';

  @override
  String get sosRelay_noneYet => 'Zatiaľ nebolo preposlané žiadne SOS';

  @override
  String sosRelay_relayedCount(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Preposlaných $count SOS paketov, naposledy o $time',
      few: 'Preposlané $count SOS pakety, naposledy o $time',
      one: 'Preposlaný 1 SOS paket, naposledy o $time',
    );
    return '$_temp0';
  }

  @override
  String get sosRelay_explainer =>
      'Keď rádio počuje SOS priamo od odosielateľa a žiadny opakovač ho do približne 15 sekúnd nepreposlal, NOTORYX ho pošle ešte raz, nezmenené, aby sa dostalo k opakovaču, ktorý počujete vy, ale odosielateľ nie. Preposielajú sa len SOS vo vašich kanáloch. Spotrebúva batériu a čas vysielania, preto je predvolene vypnuté.';

  @override
  String get fieldOps_beforeYouLeave => 'Pred odchodom';

  @override
  String get fieldOps_radioConnected => 'Rádio pripojené';

  @override
  String get fieldOps_connectHint =>
      'Pripojte sa cez Bluetooth, USB alebo TCP.';

  @override
  String get fieldOps_radioBattery => 'Batéria rádia';

  @override
  String get fieldOps_batteryUnknown => 'Neznáma; skontrolujte rádio.';

  @override
  String fieldOps_batteryDetail(String percent) {
    return '$percent % • nabite na plánovanú túru.';
  }

  @override
  String get fieldOps_tripContacts => 'Kontakty túry';

  @override
  String fieldOps_tripContactsDetail(String available, String selected) {
    return 'Dostupné $available/$selected. Skontrolujte, či majú kompatibilné rádiá a kanály.';
  }

  @override
  String get fieldOps_offlineArea => 'Vybraná offline oblasť mapy';

  @override
  String get fieldOps_checkingFiles => 'Kontrolujú sa miestne súbory…';

  @override
  String fieldOps_regionStatus(
    String available,
    String expected,
    String missing,
  ) {
    return 'Dostupné súbory dlaždíc: $available/$expected; chýba $missing. Je to snímka; pred odchodom otvorte oblasť offline.';
  }

  @override
  String get fieldOps_locationChoice => 'Zdieľanie polohy';

  @override
  String get fieldOps_locationOptedIn =>
      'Zapnuté: súradnice vysielané rádiom môžu byť zastarané.';

  @override
  String get fieldOps_locationOff =>
      'Zdieľanie je vypnuté. Vaše hlásenia neobsahujú súradnice.';

  @override
  String get fieldOps_automationAvailability => 'Dostupnosť automatizácie';

  @override
  String get fieldOps_automationAvailabilityDetail =>
      'Funguje iba vtedy, keď je aplikácia aktívna. Spánok, zatvorenie alebo strata rádia môžu zabrániť plánovaným akciám.';

  @override
  String get fieldOps_readinessCaveat =>
      'Kontroly pripravenosti sú orientačné; nedokazujú dosah rádia ani nezaručujú doručenie správ.';

  @override
  String get fieldOps_radio => 'Rádio';

  @override
  String get fieldOps_refreshChecks => 'Obnoviť kontroly';

  @override
  String get fieldOps_searchLog => 'Hľadať v terénnom denníku';

  @override
  String get fieldOps_kindAll => 'Všetko';

  @override
  String get fieldOps_kindCheckIn => 'Hlásenie';

  @override
  String get fieldOps_kindReceived => 'Prijaté';

  @override
  String get fieldOps_kindNote => 'Poznámka';

  @override
  String get fieldOps_kindDeadZone => 'Mŕtva zóna';

  @override
  String get fieldOps_kindRadio => 'Rádio';

  @override
  String get fieldOps_kindAutomation => 'Automatizácia';

  @override
  String get fieldOps_kindMissed => 'Zmeškané';

  @override
  String get fieldOps_kindSos => 'SOS';

  @override
  String get fieldOps_kindTrip => 'Túra';

  @override
  String get fieldOps_kindOverdue => 'Mešká';

  @override
  String get fieldOps_addNote => 'Pridať poznámku';

  @override
  String get fieldOps_exportJson => 'Exportovať JSON';

  @override
  String get fieldOps_deleteLog => 'Odstrániť denník';

  @override
  String get fieldOps_logSubject => 'Terénny denník NOTORYX Core';

  @override
  String get fieldOps_logCaveat =>
      'Uložené lokálne, najviac 1 000 záznamov. Exporty môžu obsahovať kľúče kontaktov, správy a polohy; pred zdieľaním skontrolujte.';

  @override
  String get fieldOps_noEntries => 'Žiadne zodpovedajúce záznamy.';

  @override
  String get fieldOps_tripUnspecified => 'Túra neuvedená';

  @override
  String fieldOps_entryStatus(String status, String explanation) {
    return '$status: $explanation';
  }

  @override
  String fieldOps_entryPosition(String latitude, String longitude) {
    return 'Zaznamenaná vysielaná poloha rádia $latitude, $longitude (môže byť zastaraná)';
  }

  @override
  String get fieldOps_noteTitle => 'Terénne pozorovanie';

  @override
  String get fieldOps_noteLabel => 'Čo ste pozorovali?';

  @override
  String get fieldOps_deadZone => 'Nahlásená mŕtva zóna';

  @override
  String get fieldOps_deadZoneHint =>
      'Vaše pozorovanie, nie overená predpoveď pokrytia.';

  @override
  String get fieldOps_savePosition => 'Uložiť vysielanú polohu rádia';

  @override
  String fieldOps_positionDetail(String latitude, String longitude) {
    return '$latitude, $longitude • môže byť zastaraná; nie GPS telefónu';
  }

  @override
  String get fieldOps_noPosition => 'Žiadne použiteľné vysielané súradnice';

  @override
  String get fieldOps_deleteLogTitle => 'Odstrániť terénny denník?';

  @override
  String get fieldOps_deleteLogBody =>
      'Odstráni všetky uložené záznamy v tomto telefóne. Nastavenia túry zostanú zachované.';

  @override
  String get fieldOps_localAutomations => 'Miestne automatizácie';

  @override
  String get fieldOps_enableForTrip => 'Zapnúť pre túto túru';

  @override
  String get fieldOps_automationsCaveat =>
      'Po každom reštarte aplikácie sú vypnuté. Pravidlá fungujú iba vtedy, keď je aplikácia aktívna. Zmeškané plánované akcie sa zobrazia v terénnom denníku a nikdy sa nedobiehajú naraz. Automatické hlásenia sú obmedzené na jednu dávku za 10 minút.';

  @override
  String get fieldOps_openBotMode => 'Otvoriť režim bota NOTORYX';

  @override
  String get fieldOps_ruleEnabled => 'Pravidlo zapnuté';

  @override
  String get fieldOps_dryRun => 'Skúšobný beh';

  @override
  String get fieldOps_dryRunHint =>
      'Zaznamenať akciu bez odoslania alebo upozornenia.';

  @override
  String get fieldOps_then => 'Potom';

  @override
  String get fieldOps_actionLog => 'Zapísať do terénneho denníka';

  @override
  String get fieldOps_actionNotify => 'Zobraziť miestne upozornenie';

  @override
  String get fieldOps_actionCheckIn => 'Poslať „I\'m OK“ kontaktom túry';

  @override
  String get fieldOps_batteryThreshold => 'Batéria na úrovni alebo pod';

  @override
  String fieldOps_nextDue(String time) {
    return 'Ďalšie: $time';
  }

  @override
  String get fieldOps_nextDueNone => 'Ďalšie: nenaplánované';

  @override
  String get fieldOps_previewInLog => 'Náhľad v denníku';

  @override
  String get fieldOps_allowNotifications => 'Povoliť upozornenia';

  @override
  String get fieldOps_triggerReconnect => 'KEĎ sa rádio znova pripojí';

  @override
  String get fieldOps_triggerDisconnect => 'KEĎ sa rádio odpojí';

  @override
  String get fieldOps_triggerLowBattery => 'KEĎ batéria rádia prekročí prah';

  @override
  String get fieldOps_triggerNewNode => 'KEĎ pribudne nový uzol';

  @override
  String get fieldOps_triggerRepeater => 'KEĎ pribudne nový opakovač';

  @override
  String get fieldOps_triggerScheduled => 'KEĎ je na rade plánované hlásenie';

  @override
  String get fieldOps_explainConnection => 'Vysvetliť moje spojenie';

  @override
  String fieldOps_connectionState(String state, String transport) {
    return 'Stav: $state • $transport';
  }

  @override
  String get fieldOps_connectedCaveat =>
      'Telefón má spojenie s rádiom. Samo osebe to nezaisťuje trasu k vašim príjemcom.';

  @override
  String get fieldOps_disconnectedHint =>
      'Žiadne aktívne rádiové spojenie. Skontrolujte povolenia Bluetooth, napájanie a dosah rádia; USB/TCP sú dostupné v časti Pripojiť rádio.';

  @override
  String fieldOps_awaitingConfirmation(int count) {
    return 'Hlásenia túry čakajúce na potvrdenie: $count';
  }

  @override
  String get fieldOps_staleCaveat =>
      'Časy posledného videnia a vysielané polohy uzlov môžu byť zastarané. Analýza trás zobrazuje trasy naučené z pozorovaných pokusov; nevymýšľa cesty.';

  @override
  String get fieldOps_routeIntelligence => 'Analýza trás';

  @override
  String get fieldOps_coverageIntelligence => 'Analýza pokrytia';

  @override
  String get fieldOps_coverageIntelligenceHint =>
      'Porovnajte zaznamenané pozorovania z dvoch terénnych relácií. Body označujú vysielané polohy rádia zapisovateľa, kde boli počuť uzly. Neznamenajú súvislé pokrytie. Snímky RSSI/SNR nie sú merania pre jednotlivé uzly.';

  @override
  String get fieldOps_captureSession => 'Zaznamenať reláciu';

  @override
  String get fieldOps_refreshHistory => 'Obnoviť históriu';

  @override
  String get fieldOps_noCoverageSessions =>
      'Zatiaľ žiadne uložené relácie pokrytia.';

  @override
  String get fieldOps_sessionA => 'Relácia A • tyrkysová';

  @override
  String get fieldOps_sessionB => 'Relácia B • jantárová';

  @override
  String fieldOps_uniqueCompare(String a, String b) {
    return 'A: jedinečné uzly $a • B: jedinečné uzly $b';
  }

  @override
  String fieldOps_overlap(String shared, String onlyA, String onlyB) {
    return 'Spoločné: $shared • Iba A: $onlyA • Iba B: $onlyB';
  }

  @override
  String get fieldOps_compareCaveat =>
      'Ak uzol nepočuť počas jednej relácie, nepotvrdzuje to mŕtvu zónu. Podmienky a dĺžka pozorovania sa líšia.';

  @override
  String get fieldOps_heardTooltip =>
      'Pozorovanie počutého uzla; nie je dôkazom úspešného spojenia';

  @override
  String get fieldOps_noteTooltip =>
      'Miestna poznámka pri súradniciach vysielaných rádiom; môže byť zastaraná.';

  @override
  String get bastionHome_aboutTooltip => 'O aplikácii NOTORYX Core';

  @override
  String get bastionHome_getStarted => 'Začíname';

  @override
  String get bastionHome_getStartedHint =>
      'Pripojte rádio a overte svoju prvú správu';

  @override
  String get bastionHome_planYourTrip => 'Naplánujte si túru';

  @override
  String get bastionHome_tripActive => 'Túra aktívna';

  @override
  String get bastionHome_tripStopped => 'Túra zastavená';

  @override
  String bastionHome_tripSummary(String state, String contacts, String unread) {
    return '$state • kontakty: $contacts • neprečítané: $unread';
  }

  @override
  String get bastionHome_checkInOk => 'Hlásenie: som v poriadku';

  @override
  String get bastionHome_checkInHint =>
      'Pred odoslaním skontrolujte kontakty a správu. Potvrdenia sledujte v terénnom denníku.';

  @override
  String bastionHome_lastCheckIn(String summary) {
    return 'Posledné hlásenie: $summary';
  }

  @override
  String get bastionHome_connectRadio => 'Pripojiť rádio';

  @override
  String get bastionHome_connectRadioHint =>
      'Pripojenia MeshCore cez Bluetooth, USB a TCP';

  @override
  String get bastionHome_liveDiagnostics => 'Živá diagnostika';

  @override
  String get bastionHome_liveDiagnosticsHint =>
      'Stav rádia, signál, zariadenie a nástroje rámcov';

  @override
  String get bastionHome_meshDiscovery => 'Objavovanie siete';

  @override
  String get bastionHome_meshDiscoveryHint =>
      'Nájdite uzly a preskúmajte sieť okolo seba';

  @override
  String get bastionHome_fieldOpsHint =>
      'Prehľad túry, pripravenosť, terénny denník, automatizácie a porovnanie pokrytia';

  @override
  String get bastionHome_fieldTools => 'Terénne nástroje NOTORYX';

  @override
  String get bastionHome_statusActive => 'AKTÍVNE';

  @override
  String get bastionHome_consoleOnline => 'Terénna konzola online';

  @override
  String get bastionHome_consoleReady => 'Terénna konzola pripravená';

  @override
  String get bastionHome_consoleHint =>
      'Pripojte rádio, aby sa zapol živý prehľad.';

  @override
  String bastionHome_battery(String value) {
    return 'Bat $value';
  }

  @override
  String get bastionTools_title => 'Terénne nástroje';

  @override
  String get bastionTools_backup => 'Šifrovaná záloha';

  @override
  String get bastionTools_backupHint =>
      'Uložte nastavenia, kontakty a kľúče, voliteľne s históriou četu';

  @override
  String get bastionTools_fieldOpsHint =>
      'Hlásenia, pripravenosť, terénny denník, automatizácie a porovnania';

  @override
  String get bastionTools_mapHint =>
      'Živá mapa, relácie záznamu, nástroje offline máp a regióny';

  @override
  String get bastionTools_pathAnalysis => 'Analýza ciest';

  @override
  String get bastionTools_pathHint => 'Trasy, objavovanie a analýza ciest';

  @override
  String get bastionTools_repeaterHint =>
      'Stav, prihlásenie, telemetria, susedia a správa';

  @override
  String get bastionTools_statsHint =>
      'Živé počty v sieti a aktivita kontaktov';

  @override
  String get bastionTools_diagnostics => 'Diagnostika';

  @override
  String get bastionTools_diagnosticsHint =>
      'Stav rádia, informácie o zariadení, surové rámce a export';

  @override
  String get bastionTools_about => 'O aplikácii + poďakovania';

  @override
  String get bastionTools_aboutHint =>
      'Verzia NOTORYX Core, vyhlásenie o nezávislosti a licencie open source';

  @override
  String get bastionAbout_title => 'O aplikácii + Poďakovania';

  @override
  String get bastionAbout_intro =>
      'Nezávislá komunitná sprievodná aplikácia pre siete MeshCore. NOTORYX Core nie je oficiálna aplikácia MeshCore a zahrnutie komunitných zdrojov neznamená partnerstvo ani podporu.';

  @override
  String get bastionAbout_version => 'Verzia';

  @override
  String get bastionAbout_openSource => 'Základ open source';

  @override
  String get bastionAbout_openSourceBody =>
      'NOTORYX Core je postavený na otvorenom kóde MeshCore Open pod licenciou MIT a upravuje ho. Práca na postupe pokrytia uvádza aj, kde je to vhodné, aplikáciu MeshMapper Flutter App s licenciou MIT.';

  @override
  String get bastionAbout_community => 'Komunita na prvom mieste';

  @override
  String get bastionAbout_communityBody =>
      'Zdroje tretích tvorcov zostávajú majetkom ich príslušných tvorcov. Nevyplýva z toho vlastníctvo ani partnerstvo.';

  @override
  String get bastionAbout_legalese =>
      'NOTORYX Core • Nezávislý sprievodca MeshCore';

  @override
  String get bastionAbout_licenses => 'Licencie open source';

  @override
  String get bastionSetup_title => 'Začíname s NOTORYX Core';

  @override
  String get bastionSetup_intro =>
      'Pripojte sa, vyberte kontakt a potom overte správu. K tomuto sprievodcovi sa môžete kedykoľvek vrátiť z prehľadu.';

  @override
  String get bastionSetup_step1 => '1. Pripojte svoje rádio MeshCore';

  @override
  String bastionSetup_connectedTo(String device, String transport) {
    return 'Pripojené k $device cez $transport.';
  }

  @override
  String get bastionSetup_noRadio => 'Zatiaľ nie je pripojené žiadne rádio.';

  @override
  String get bastionSetup_step1Power =>
      'Zapnite sprievodné rádio MeshCore. Otvorte Pripojiť rádio a vyberte Bluetooth, USB alebo TCP. Povoľte oprávnenia požadované pre zvolené pripojenie.';

  @override
  String get bastionSetup_step1Bluetooth =>
      'Ak je vyhľadávanie Bluetooth prázdne, skontrolujte, či je Bluetooth zapnutý a či má NOTORYX Core oprávnenie Zariadenia v okolí v nastaveniach aplikácií Androidu. Postupujte podľa ďalších žiadostí o oprávnenia, ktoré zobrazí skener.';

  @override
  String get bastionSetup_connectionDiagnostics => 'Diagnostika pripojenia';

  @override
  String get bastionSetup_step2 => '2. Vyberte kontakt četu';

  @override
  String get bastionSetup_step2Body =>
      'Požiadajte partnera v okolí s kompatibilnými nastaveniami rádia MeshCore, aby oznámil svoj uzol. Nižšie vyberte známy kontakt četu; opakovače sa spravujú samostatne.';

  @override
  String get bastionSetup_noContacts =>
      'Nie sú dostupné žiadne kontakty četu. Pripojte rádio a otvorte Objavovanie siete.';

  @override
  String get bastionSetup_testRecipient => 'Testovací príjemca';

  @override
  String get bastionSetup_meshDiscovery => 'Objavovanie siete';

  @override
  String get bastionSetup_step3 => '3. Odošlite a overte správu';

  @override
  String get bastionSetup_step3Body =>
      'Otvorte čet, napíšte krátku testovaciu správu, skontrolujte príjemcu a ťuknite na Odoslať. Vráťte sa sem a uvidíte najnovšiu odchádzajúcu správu zaznamenanú od otvorenia sprievodcu.';

  @override
  String get bastionSetup_openTestChat => 'Otvoriť testovací čet';

  @override
  String get bastionSetup_connectFirst =>
      'Pripojte rádio, aby ste otvorili testovací čet.';

  @override
  String get bastionSetup_chooseRecipient => 'Najprv vyberte príjemcu.';

  @override
  String get bastionSetup_noTestMessage =>
      'V tejto relácii sprievodcu nebola zaznamenaná žiadna odchádzajúca testovacia správa.';

  @override
  String bastionSetup_latestMessage(String status, String time) {
    return 'Najnovšia správa: $status • $time';
  }

  @override
  String get bastionSetup_confirmReceipt =>
      'Požiadajte partnera, aby potvrdil prijatie alebo odpovedal. Zaznamenané potvrdenie nedokazuje, že správu prečítal. Ak správa zlyhá, znova skontrolujte pripojenie a príjemcu.';

  @override
  String get bastionSetup_step4 => '4. Pripravte sa do terénu';

  @override
  String get bastionSetup_step4Body =>
      'Naplánujte kontakty túry a skontrolujte stiahnuté oblasti máp. Režim bota a terénne automatizácie sú na začiatku vypnuté; terénne automatizácie fungujú iba vtedy, keď je aplikácia aktívna.';

  @override
  String get bastionSetup_tripTools => 'Nástroje túry a pripravenosti';

  @override
  String get bastionDiag_title => 'Diagnostika';

  @override
  String get bastionDiag_export => 'Exportovať diagnostiku';

  @override
  String get bastionDiag_channels => 'Kanály';

  @override
  String get bastionDiag_radio => 'Rádio';

  @override
  String get bastionDiag_frequency => 'Frekvencia';

  @override
  String get bastionDiag_bandwidth => 'Šírka pásma';

  @override
  String get bastionDiag_spreadingFactor => 'Rozptylový faktor';

  @override
  String get bastionDiag_codingRate => 'Kódovací pomer';

  @override
  String get bastionDiag_txPower => 'Vysielací výkon';

  @override
  String get bastionDiag_noiseFloor => 'Úroveň šumu';

  @override
  String get bastionDiag_device => 'Zariadenie';

  @override
  String get bastionDiag_name => 'Názov';

  @override
  String get bastionDiag_manufacturer => 'Výrobca';

  @override
  String get bastionDiag_firmware => 'Firmvér';

  @override
  String get bastionDiag_battery => 'Batéria';

  @override
  String get bastionDiag_transport => 'Pripojenie';

  @override
  String get bastionDiag_deepTools => 'Pokročilé nástroje';

  @override
  String get bastionDiag_liveStats => 'Živé štatistiky rádia';

  @override
  String get bastionDiag_liveStatsHint => 'Šum, RSSI, SNR a čas vysielania';

  @override
  String get bastionDiag_frameDebug => 'Ladenie rámcov / BLE';

  @override
  String get bastionDiag_frameDebugHint =>
      'Preskúmajte dekódované a surové prijaté rámce';

  @override
  String get bastionDiag_appLog => 'Ladiaci denník aplikácie';

  @override
  String get bastionDiag_appLogHint =>
      'Prezrite si diagnostické udalosti aplikácie';

  @override
  String get bastionDiag_online => 'Rádio online';

  @override
  String get bastionDiag_offline => 'Rádio offline';

  @override
  String get bastionDiag_offlineHint =>
      'Pripojte sprievodcu MeshCore, aby sa naplnila živá diagnostika.';

  @override
  String get coverage_title => 'Záznam pokrytia';

  @override
  String get coverage_leaveBlocked =>
      'Pred odchodom reláciu zastavte a uložte.';

  @override
  String get coverage_savedSessions => 'Uložené relácie';

  @override
  String get coverage_caveat =>
      'RSSI/SNR sú snímky rádia a môžu patriť inému paketu. Polohy sú súradnice vysielané rádiom, nie GPS telefónu ani dôkaz pokrytia. Azúrová: zapisovateľ; jantárová: vysielaný uzol. Interpolácia sa nevykonáva.';

  @override
  String get coverage_captureActive => 'Záznam aktívny';

  @override
  String get coverage_fieldSession => 'Terénna relácia pokrytia';

  @override
  String get coverage_connectedBody =>
      'NOTORYX Core počas tejto relácie zaznamenáva novo počuté uzly vrátane údajov o trase, metadát uzla/polohy a najbližšej dostupnej snímky RSSI/SNR rádia.';

  @override
  String get coverage_disconnectedBody =>
      'Pred spustením pripojte rádio. Záznam pokrytia zaznamenáva živé pozorovania siete z pripojeného sprievodného rádia.';

  @override
  String get coverage_observations => 'Pozorovania';

  @override
  String get coverage_uniqueNodes => 'Jedinečné uzly';

  @override
  String get coverage_elapsed => 'Uplynulo';

  @override
  String get coverage_radioConnected => 'Rádio pripojené';

  @override
  String get coverage_noRadio => 'Žiadne rádio';

  @override
  String get coverage_gpsReady => 'GPS rádia pripravené';

  @override
  String get coverage_noGps => 'Žiadne GPS rádia';

  @override
  String get coverage_stopSave => 'Zastaviť + uložiť reláciu';

  @override
  String get coverage_start => 'Spustiť reláciu pokrytia';

  @override
  String get coverage_exportJson => 'Exportovať JSON';

  @override
  String get coverage_exportCsv => 'Exportovať CSV';

  @override
  String get coverage_liveObservations => 'Živé pozorovania';

  @override
  String get coverage_waiting => 'Čaká sa na aktivitu siete';

  @override
  String get coverage_waitingBody =>
      'Spustite reláciu a novo počuté aktívne uzly sa zobrazia tu. Hodnoty RSSI/SNR sú snímky rádia a nie vždy sa dajú jednoznačne priradiť konkrétnemu paketu.';

  @override
  String get coverage_signalNa => 'signál n/a';

  @override
  String get coverage_snrNa => 'SNR n/a';

  @override
  String get coverage_gpsUnavailable => 'GPS rádia nedostupné';

  @override
  String coverage_pathLine(String path, String location) {
    return 'Cesta: $path  •  $location';
  }

  @override
  String get coverage_pathFlood => 'flood';

  @override
  String get coverage_pathDirect => 'priama';

  @override
  String get coverage_shareSubject => 'Relácia pokrytia NOTORYX Core';

  @override
  String get coverage_shareText => 'Export záznamu pokrytia NOTORYX Core';

  @override
  String get coverage_historyTitle => 'Uložené relácie pokrytia';

  @override
  String coverage_loadFailed(String error) {
    return 'Relácie sa nepodarilo načítať: $error';
  }

  @override
  String get coverage_deleteTitle => 'Odstrániť uloženú reláciu?';

  @override
  String coverage_deleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pozorovaní sa odstráni z tohto zariadenia.',
      many: '$count pozorovania sa odstráni z tohto zariadenia.',
      few: '$count pozorovania sa odstránia z tohto zariadenia.',
      one: '1 pozorovanie sa odstráni z tohto zariadenia.',
    );
    return '$_temp0';
  }

  @override
  String coverage_deleteFailed(String error) {
    return 'Reláciu sa nepodarilo odstrániť: $error';
  }

  @override
  String get coverage_retention =>
      'Uchováva sa 20 najnovších dokončených relácií. Zdieľajte relácie, ktoré si chcete ponechať. Prerušené záznamy možno znova otvoriť nižšie.';

  @override
  String get coverage_noSessions =>
      'Zatiaľ žiadne uložené relácie. Zastavte záznam, aby sa uložil.';

  @override
  String get coverage_interrupted => 'Prerušený záznam';

  @override
  String get coverage_saved => 'Uložené';

  @override
  String get coverage_deleteTooltip => 'Odstrániť reláciu';

  @override
  String coverage_exportFailed(String error) {
    return 'Export zlyhal: $error';
  }

  @override
  String get coverage_sessionTitle => 'Relácia pokrytia';

  @override
  String get coverage_shareJson => 'Zdieľať JSON';

  @override
  String get coverage_shareCsv => 'Zdieľať CSV';

  @override
  String coverage_snapshotDetail(String rssi, String snr, String age) {
    return '$rssi dBm • SNR $snr dB • vek snímky $age ms';
  }

  @override
  String get coverage_unknown => 'neznámy';

  @override
  String coverage_pathValue(String path) {
    return 'cesta $path';
  }

  @override
  String get coverage_recorder => 'Zapisovateľ';

  @override
  String get coverage_noCoordinates =>
      'V tejto relácii nie sú použiteľné súradnice. Pozorovania zostávajú dostupné nižšie.';

  @override
  String get coverage_osmAttribution =>
      '© prispievatelia OpenStreetMap • online podkladová mapa';

  @override
  String get fieldStats_title => 'Terénna analýza';

  @override
  String get fieldStats_chatNodes => 'Uzly četu';

  @override
  String get fieldStats_rooms => 'Miestnosti';

  @override
  String get fieldStats_sensors => 'Senzory';

  @override
  String get fieldStats_direct => 'Priame';

  @override
  String get mapHub_title => 'Terénna mapa NOTORYX';

  @override
  String get mapHub_intro =>
      'Živé mapy, offline oblasti, regionálne profily a terénne relácie pokrytia NOTORYX Core.';

  @override
  String get mapHub_captureHint =>
      'Spustiť a zastaviť terénnu reláciu pokrytia';

  @override
  String get mapHub_badgeNew => 'NOVÉ';

  @override
  String get mapHub_liveMap => 'Živá mapa siete';

  @override
  String get mapHub_liveMapHint =>
      'Uzly, opakovače, polohy, trasy a nástroje mapy';

  @override
  String get mapHub_badgeLive => 'NAŽIVO';

  @override
  String get mapHub_offlinePacks => 'Balíky offline máp';

  @override
  String get mapHub_offlinePacksHint =>
      'Uložte dlaždice máp pre túry a oblasti bez signálu';

  @override
  String get mapHub_badgeOffline => 'OFFLINE';

  @override
  String get mapHub_regions => 'Profily regiónov';

  @override
  String get mapHub_regionsHint =>
      'Spravujte a sťahujte regionálne definície siete';

  @override
  String get mapHub_badgeRegions => 'REGIÓNY';

  @override
  String get routes_title => 'Analýza trás';

  @override
  String get routes_headline => 'Pozrite sa, ako sa prevádzka pohybuje sieťou.';

  @override
  String get routes_body =>
      'NOTORYX Core zoraďuje uložené trasy podľa histórie ciest, ktorú sa už naučil zo skutočných pokusov o správy a objavovanie.';

  @override
  String get routes_routes => 'Trasy';

  @override
  String get routes_success => 'Úspechy';

  @override
  String get routes_failed => 'Zlyhania';

  @override
  String get routes_routeMap => 'Mapa trás';

  @override
  String get routes_routeMapHint => 'Preskúmajte uzly a cesty';

  @override
  String get routes_discover => 'Objaviť';

  @override
  String get routes_discoverHint => 'Nájdite nové trasy';

  @override
  String get routes_learned => 'Naučené trasy';

  @override
  String get routes_none => 'Zatiaľ žiadna história trás';

  @override
  String get routes_noneBody =>
      'Používajte sieť ako zvyčajne alebo spustite objavovanie. NOTORYX Core tu zobrazí naučené trasy, keď bude k dispozícii história ciest.';

  @override
  String get routes_direct => 'PRIAMA';

  @override
  String routes_routeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trás',
      many: '$count trasy',
      few: '$count trasy',
      one: '1 trasa',
    );
    return '$_temp0';
  }

  @override
  String routes_best(String path) {
    return 'NAJLEPŠIA  $path';
  }

  @override
  String routes_bestDetail(
    String hops,
    String weight,
    String success,
    String fail,
  ) {
    return '$hops  •  váha $weight  •  úspechy: $success / zlyhania: $fail';
  }

  @override
  String routes_fastest(String ms) {
    return 'Najrýchlejšia známa: $ms ms';
  }

  @override
  String routes_flood(String success, String fail) {
    return 'Flood: úspechy: $success / zlyhania: $fail';
  }

  @override
  String get repeaterTools_unnamed => 'Nepomenovaný opakovač';

  @override
  String get repeaterTools_empty =>
      'Zatiaľ neboli objavené žiadne opakovače. Pripojte rádio a najprv preskúmajte sieť.';

  @override
  String get rptTest_title => 'Test blízkych opakovačov';

  @override
  String get rptTest_subtitle =>
      'Jedno ťuknutie: ktoré opakovače vás počujú priamo';

  @override
  String get rptTest_start => 'Testovať teraz';

  @override
  String get rptTest_listening => 'Čakám na odpovede…';

  @override
  String rptTest_wait(int seconds) {
    return 'Ďalší test o $seconds s';
  }

  @override
  String rptTest_found(int count) {
    return 'Opakovače, ktoré odpovedali: $count';
  }

  @override
  String get rptTest_none =>
      'Žiadny opakovač v priamom dosahu neodpovedal. Skúste z vyššieho miesta alebo znova o minútu. Opakovače so starším firmvérom na tento test neodpovedajú.';

  @override
  String get rptTest_strong => 'Silný';

  @override
  String get rptTest_usable => 'Použiteľný';

  @override
  String get rptTest_weak => 'Slabý';

  @override
  String rptTest_unknown(String prefix) {
    return 'Opakovač $prefix';
  }

  @override
  String rptTest_line(String there, String here, String rssi) {
    return 'Počul vás pri $there dB · vy ho pri $here dB, $rssi dBm';
  }

  @override
  String rptTest_rowLabel(
    String name,
    String quality,
    String there,
    String here,
    String rssi,
  ) {
    return '$name, $quality. Počul vás pri $there decibeloch. Vy ho pri $here decibeloch, $rssi dBm.';
  }

  @override
  String get rptTest_notConnected => 'Pripojte rádio, aby ste spustili test.';

  @override
  String get rptTest_explainer =>
      'Odošle jednu požiadavku na objavenie bez skokov, takže odpovedajú len opakovače, ktoré počujú vaše rádio priamo. Prvé číslo ukazuje, ako dobre vás opakovač počul, druhé, ako dobre ste ho počuli vy. Medzi testami je 30 sekúnd, lebo opakovače obmedzujú počet odpovedí.';

  @override
  String get notification_fieldAlertTitle => 'Terénne upozornenie NOTORYX';

  @override
  String get notification_checkInReminderTitle =>
      'Pripomienka hlásenia NOTORYX Core';

  @override
  String notification_checkInReminderBody(int minutes, String trip) {
    return 'Už $minutes min bez hlásenia na túre $trip. Otvorte NOTORYX Core a nahláste sa.';
  }

  @override
  String notification_overdueBody(String name, int minutes) {
    return '$name sa neozval(a) $minutes min. Nie je to potvrdená núdzová situácia.';
  }

  @override
  String get notification_aTripContact => 'Kontakt túry';

  @override
  String notification_checkInNotDelivered(String name) {
    return 'Hlásenie nebolo doručené: $name. Môžete ho znova odoslať na karte Túra.';
  }

  @override
  String notification_sosAcknowledged(String name) {
    return 'SOS potvrdil(a) $name';
  }

  @override
  String get settings_batterySaver => 'Šetrič batérie';

  @override
  String get settings_batterySaverOn =>
      'Zapnuté: batéria rádia každých 10 min, GPS každých 5 min, štatistiky najviac raz za minútu, kontroly túry každé 1–2 min. Správy, upozornenia a SOS sa nemenia.';

  @override
  String get settings_batterySaverOff =>
      'Kontrolovať rádio a túru menej často a šetriť batériu telefónu aj rádia. Správy, upozornenia a SOS sa nemenia.';

  @override
  String get settings_readAloud => 'Čítať nové správy nahlas';

  @override
  String get settings_readAloudHelper =>
      'Kým je NOTORYX Core otvorený. Stlmené kanály zostávajú ticho. Každú správu možno prečítať aj z jej ponuky.';

  @override
  String get settings_readAloudOff => 'Vyp.';

  @override
  String get settings_readAloudDirect => 'Priame správy';

  @override
  String get settings_readAloudAll => 'Priame správy a správy kanálov';

  @override
  String get chat_readAloud => 'Prečítať nahlas';

  @override
  String get messageSearch_title => 'Hľadať v správach';

  @override
  String get messageSearch_intro =>
      'Hľadajte vo všetkých priamych správach a správach kanálov uložených v tomto telefóne.';

  @override
  String messageSearch_noResults(String query) {
    return 'Žiadna správa neobsahuje „$query“.';
  }

  @override
  String messageSearch_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výsledkov',
      many: '$count výsledku',
      few: '$count výsledky',
      one: '1 výsledok',
    );
    return '$_temp0';
  }

  @override
  String messageSearch_capped(int count) {
    return 'Zobrazuje sa najnovších $count výsledkov';
  }

  @override
  String get shortcuts_checkIn => 'Nahlásiť sa';

  @override
  String get shortcuts_trip => 'Túra';

  @override
  String get shortcuts_chats => 'Čety';

  @override
  String get shortcuts_map => 'Mapa';

  @override
  String get sensor_liveUpdates => 'Živé aktualizácie';

  @override
  String get sensor_intro =>
      'Nech senzor sám posiela hodnoty, keď sa zmenia, namiesto opakovaného pýtania. Vyžaduje prihlásenie s prístupom na čítanie.';

  @override
  String get sensor_watch => 'Sledovať zmeny';

  @override
  String get sensor_loadFirst =>
      'Najprv načítajte telemetriu, aby ste mohli vybrať hodnoty.';

  @override
  String sensor_watching(String readings, String time) {
    return 'Sleduje sa: $readings do $time.';
  }

  @override
  String sensor_watchingRegion(String readings, String time, String region) {
    return 'Sleduje sa: $readings do $time • región $region.';
  }

  @override
  String get sensor_noChanges => 'Zatiaľ neboli nahlásené žiadne zmeny.';

  @override
  String sensor_lastUpdate(String time, int count) {
    return 'Posledná aktualizácia $time • prijaté: $count';
  }

  @override
  String get sensor_stop => 'Zastaviť živé aktualizácie';

  @override
  String sensor_stopUnconfirmed(String error) {
    return 'Zastavené tu; senzor nepotvrdil a prestane, keď uplynie čas. $error';
  }

  @override
  String get sensor_dialogBody =>
      'Senzor kontroluje približne raz za minútu a pošle aktualizáciu, keď sa vybraná hodnota zmení viac než jej prah.';

  @override
  String sensor_readingTitle(String label, String channel) {
    return '$label (kanál $channel)';
  }

  @override
  String sensor_readingValue(String label, String channel, String value) {
    return '$label (kanál $channel): $value';
  }

  @override
  String sensor_watchItem(String label, String channel, String delta) {
    return '$label (kanál $channel) ±$delta';
  }

  @override
  String sensor_updateOn(String delta) {
    return 'Aktualizovať pri zmene o $delta';
  }

  @override
  String get sensor_changeThreshold => 'Zmeniť prah';

  @override
  String sensor_capacity(int max, String used) {
    return 'Senzor môže sledovať najviac $max bajtov hodnôt (použité: $used).';
  }

  @override
  String get sensor_for => 'Na';

  @override
  String sensor_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hodín',
      many: '$count hodiny',
      few: '$count hodiny',
      one: '1 hodinu',
    );
    return '$_temp0';
  }

  @override
  String get sensor_start => 'Spustiť';

  @override
  String sensor_thresholdTitle(String label) {
    return 'Prah: $label';
  }

  @override
  String get sensor_typeTemperature => 'Teplota';

  @override
  String get sensor_typeHumidity => 'Vlhkosť';

  @override
  String get sensor_typePressure => 'Tlak';

  @override
  String get sensor_typeVoltage => 'Napätie';

  @override
  String get sensor_typeCurrent => 'Prúd';

  @override
  String get sensor_typeLight => 'Svetlo';

  @override
  String get sensor_typeConcentration => 'Koncentrácia';

  @override
  String get sensor_typePercentage => 'Percento';

  @override
  String get sensor_typeAnalogInput => 'Analógový vstup';

  @override
  String get sensor_typeAltitude => 'Nadmorská výška';

  @override
  String get setupWizard_title => 'Pripojte rádio';

  @override
  String get setupWizard_choose => '1. Vyberte pripojenie';

  @override
  String get setupWizard_prepare => '2. Pripravte rádio';

  @override
  String get setupWizard_intro =>
      'Vyberte, ako sa tento telefón alebo počítač pripojí k rádiu. Rádio prenáša správy cez sieť mesh.';

  @override
  String get setupWizard_bluetooth =>
      'Bezdrôtové pripojenie ku kompatibilnému rádiu v blízkosti.';

  @override
  String get setupWizard_noBluetooth =>
      'Bluetooth nie je v tomto prehliadači dostupný. Použite natívnu aplikáciu alebo podporované USB pripojenie.';

  @override
  String get setupWizard_usb => 'Káblové pripojenie dátovým USB káblom.';

  @override
  String get setupWizard_noUsb =>
      'USB sériové rozhranie tu nie je dostupné. Použite podporovanú aplikáciu pre počítač alebo Android, prípadne Chrome s Web Serial.';

  @override
  String get setupWizard_bluetoothSteps =>
      'Zapnite rádio a majte ho blízko. Zapnite Bluetooth a povoľte aplikácii jeho použitie. Zavrite ostatné aplikácie pripojené k rádiu, otvorte zoznam zariadení a vyhľadajte.';

  @override
  String get setupWizard_usbSteps =>
      'Pripojte zapnuté rádio dátovým USB káblom; kábel iba na nabíjanie nebude fungovať. Zavrite ostatné sériové aplikácie. Otvorte zoznam USB zariadení, vyberte rádio a povoľte prístup, ak sa zobrazí výzva.';

  @override
  String get setupWizard_firmwareTitle =>
      'Pred zmenou firmvéru skontrolujte kompatibilitu';

  @override
  String get setupWizard_firmware =>
      'Rádio potrebuje firmvér MeshCore companion, ktorý podporuje zvolené pripojenie. Podpora sa líši podľa dosky a zostavy firmvéru; samotný USB konektor ešte neznamená podporu USB sériového rozhrania. Pozrite si pokyny pre svoju dosku a nainštalovanú zostavu. Firmvér opakovača alebo servera miestnosti nie je companion. Neúspešné pripojenie samo osebe neznamená, že treba firmvér nahrať znova.';

  @override
  String get setupWizard_settings =>
      'Tento sprievodca nenahráva firmvér ani nemení nastavenia rádia. Po pripojení použite Nastavenia pre región, frekvenciu a pokročilé možnosti. Pred zmenou nastavení sa dohodnite s miestnou sieťou mesh.';

  @override
  String get setupWizard_openBluetooth => 'Otvoriť zariadenia Bluetooth';

  @override
  String get setupWizard_openUsb => 'Otvoriť zariadenia USB';

  @override
  String get setupWizard_change => 'Zmeniť typ pripojenia';

  @override
  String get setupWizard_later => 'Nastaviť neskôr';

  @override
  String get setupWizard_bluetoothError =>
      'K rádiu sa nepodarilo pripojiť. Majte ho zapnuté a blízko, skontrolujte povolenia Bluetooth a zavrite ostatné pripojené aplikácie. Potom hľadajte znova.';

  @override
  String get setupWizard_scanError =>
      'Rádiá sa nepodarilo vyhľadať. Zapnite Bluetooth a v systémových nastaveniach povoľte prístup k Bluetooth alebo zariadeniam v okolí, potom hľadajte znova.';

  @override
  String get setupWizard_usbError =>
      'Cez USB sa nepodarilo pripojiť. Skontrolujte dátový kábel a vybrané zariadenie, povoľte prístup k USB a zavrite ostatné sériové aplikácie. Znova pripojte kábel a skúste to znova.';

  @override
  String get connections_title => 'Pripojenia';

  @override
  String get connections_radioTitle => 'Pripojenie rádia';

  @override
  String get connections_bluetoothOffNotice =>
      'Bluetooth je vypnutý. Zapnite ho, aby ste sa mohli znova pripojiť; aplikácia to skúsi znova, keď bude opäť zapnutý.';

  @override
  String get connections_transport => 'Spôsob pripojenia';

  @override
  String connections_lastError(String error) {
    return 'Posledná chyba: $error';
  }

  @override
  String get connections_disconnectRadio => 'Odpojiť rádio';

  @override
  String connections_reconnectTo(String name) {
    return 'Znova pripojiť k $name';
  }

  @override
  String get connections_forgetRadio => 'Zabudnúť rádio';

  @override
  String get connections_connectAnother => 'Pripojiť iné rádio';

  @override
  String get connections_usbSerial => 'USB sériové';

  @override
  String get connections_tcpIp => 'TCP/IP';

  @override
  String get connections_device => 'Zariadenie';

  @override
  String get connections_publicKey => 'Verejný kľúč';

  @override
  String get connections_firmware => 'Firmvér';

  @override
  String connections_firmwareProtocol(String code) {
    return 'protokol v$code';
  }

  @override
  String get connections_battery => 'Batéria';

  @override
  String get connections_lastRx => 'Posledný príjem';

  @override
  String get connections_reconnectFailed =>
      'K rádiu sa nepodarilo znova pripojiť';

  @override
  String get connections_statusBluetoothOff => 'Bluetooth je vypnutý';

  @override
  String get connections_statusConnected => 'Pripojené';

  @override
  String get connections_statusConnecting => 'Pripája sa…';

  @override
  String get connections_statusDisconnecting => 'Odpája sa…';

  @override
  String get connections_statusScanning => 'Hľadajú sa rádiá…';

  @override
  String get connections_statusReconnectingSoon => 'Čoskoro sa znova pripojí…';

  @override
  String get connections_statusNotConnected => 'Nepripojené';

  @override
  String get mqtt_cardTitle => 'Pripojenie MQTT';

  @override
  String get mqtt_statusNotConfigured => 'Nenastavené';

  @override
  String get mqtt_statusDisconnected => 'Odpojené';

  @override
  String get mqtt_statusConnecting => 'Pripája sa';

  @override
  String get mqtt_statusConnected => 'Pripojené';

  @override
  String get mqtt_statusReconnecting => 'Znova sa pripája';

  @override
  String get mqtt_statusError => 'Chyba pripojenia';

  @override
  String mqtt_broker(String host, int port, String transport) {
    return 'Broker: $host:$port ($transport)';
  }

  @override
  String get mqtt_tokenSignIn => 'Prihlasuje sa tokenom podpísaným rádiom';

  @override
  String mqtt_tokenSignInAs(String username) {
    return 'Prihlasuje sa tokenom podpísaným rádiom ako $username…';
  }

  @override
  String get mqtt_connectRadioToSignIn =>
      'Pripojte rádio, aby ste sa prihlásili';

  @override
  String mqtt_tokenRenewsAt(String time) {
    return 'Token sa obnoví o $time';
  }

  @override
  String mqtt_signedInAs(String username) {
    return 'Prihlásené ako $username';
  }

  @override
  String mqtt_listeningOn(String topic) {
    return 'Počúva na $topic';
  }

  @override
  String mqtt_packetCounts(int accepted, int duplicate, int invalid) {
    return 'Pakety: nové $accepted, duplicitné $duplicate, neplatné $invalid';
  }

  @override
  String mqtt_retryCount(int attempt, int max) {
    return 'Pokus $attempt z $max';
  }

  @override
  String get mqtt_sharingWaitsForRadio => 'Zdieľanie čaká na pripojenie rádia';

  @override
  String mqtt_sharingOn(String topic) {
    return 'Zdieľa na $topic';
  }

  @override
  String mqtt_willShareOn(String topic) {
    return 'Bude zdieľať na $topic';
  }

  @override
  String mqtt_onlineStatusOn(String topic) {
    return 'Stav online na $topic';
  }

  @override
  String mqtt_sharedCounts(int shared, int held) {
    return 'Zdieľané $shared, zadržané $held';
  }

  @override
  String get mqtt_addBrokerHint =>
      'Pridajte broker na prepojenie prevádzky MeshCore cez internet. Pripojenie rádia funguje nezávisle.';

  @override
  String get mqtt_disconnect => 'Odpojiť MQTT';

  @override
  String get mqtt_connect => 'Pripojiť MQTT';

  @override
  String get mqtt_packetFeed => 'Prúd paketov';

  @override
  String get mqtt_setUpBroker => 'Nastaviť broker';

  @override
  String get mqtt_brokerSettings => 'Nastavenia brokera';

  @override
  String get mqtt_settingsTitle => 'Nastavenia brokera MQTT';

  @override
  String get mqtt_presetLabel => 'Začať zo šablóny';

  @override
  String get mqtt_presetCustom => 'Vlastný broker';

  @override
  String get mqtt_presetLocal => 'Miestny broker (zadajte adresu)';

  @override
  String get mqtt_presetLetsMeshUs => 'Analyzátor LetsMesh (USA, komunita)';

  @override
  String get mqtt_presetLetsMeshEu => 'Analyzátor LetsMesh (EÚ, komunita)';

  @override
  String get mqtt_presetLetsMeshNote =>
      'LetsMesh je komunitou prevádzkovaný analyzátor paketov MeshCore; nie je súčasťou NOTORYX a NOTORYX ho neschvaľuje. Zdieľanie vyžaduje pripojené rádio a zostáva vypnuté, kým ho nezapnete.';

  @override
  String get mqtt_hostname => 'Názov hostiteľa brokera';

  @override
  String get mqtt_port => 'Port';

  @override
  String get mqtt_useTls => 'Použiť TLS';

  @override
  String get mqtt_allowCleartext =>
      'Povoliť nešifrované pripojenie k miestnemu brokeru';

  @override
  String get mqtt_allowCleartextHint =>
      'Iba localhost, .local a súkromní hostitelia 10.x / 192.168.x.';

  @override
  String get mqtt_useWebSocket => 'Použiť WebSocket';

  @override
  String get mqtt_webSocketPath => 'Cesta WebSocket';

  @override
  String get mqtt_topicPrefix => 'Predpona témy';

  @override
  String get mqtt_region => 'Región (voliteľné)';

  @override
  String get mqtt_regionHelp =>
      'Kód regiónu pozorovateľa, napr. PHL. Nechajte prázdne pre všetky.';

  @override
  String get mqtt_deliverChannel =>
      'Pridávať správy z kanálov prijaté cez MQTT';

  @override
  String get mqtt_deliverChannelHint =>
      'Správy vo vašich kanáloch, ktoré počuli pozorovatelia, sa zobrazia v chatoch. Neposielajú sa cez vaše rádio.';

  @override
  String get mqtt_sharingTitle => 'Zdieľanie ako pozorovateľ';

  @override
  String get mqtt_share => 'Zdieľať pakety, ktoré počuje moje rádio';

  @override
  String get mqtt_shareHint =>
      'Zverejňuje ohlásenia a prevádzku kanálov, ktoré rádio prijíma, s jeho verejným kľúčom, silou signálu a regiónom. Správy v kanáloch zostávajú šifrované. Vyžaduje región.';

  @override
  String get mqtt_shareDirect => 'Zahrnúť prevádzku priamych správ';

  @override
  String get mqtt_shareDirectHint =>
      'Požiadavky, odpovede a priame správy. Obsah zostáva šifrovaný, ale ukazuje, ktoré uzly spolu komunikujú.';

  @override
  String get mqtt_shareOwn => 'Zahrnúť moje vlastné správy a ohlásenia';

  @override
  String get mqtt_signInTitle => 'Prihlásenie';

  @override
  String get mqtt_authPassword => 'Používateľské meno a heslo';

  @override
  String get mqtt_authToken => 'Token podpísaný rádiom';

  @override
  String get mqtt_tokenExplain =>
      'Rádio podpíše vlastným kľúčom prihlasovací token platný hodinu a aplikácia ho obnoví pred vypršaním. Kľúč nikdy neopustí rádio. Používateľské meno je v1_ a verejný kľúč vášho rádia.';

  @override
  String get mqtt_radioReady => 'Rádio pripojené: pripravené na prihlásenie.';

  @override
  String get mqtt_radioNeeded =>
      'Pripojte rádio, aby ste sa prihlásili. MQTT naň čaká.';

  @override
  String get mqtt_username => 'Používateľské meno (voliteľné)';

  @override
  String get mqtt_password => 'Heslo';

  @override
  String get mqtt_keepPassword =>
      'Nechajte prázdne, ak chcete ponechať uložené heslo.';

  @override
  String get mqtt_credentialsWeb =>
      'V prehliadači sa prihlasovacie údaje uchovávajú len do zatvorenia stránky.';

  @override
  String get mqtt_credentialsKeychain =>
      'Prihlasovacie údaje sa ukladajú do systémovej kľúčenky, nikdy do nastavení aplikácie ani do záznamov.';

  @override
  String get mqtt_saveSettings => 'Uložiť nastavenia';

  @override
  String get mqtt_feedTitle => 'Prúd paketov MQTT';

  @override
  String get mqtt_feedConnect =>
      'Pripojte sa k brokeru, aby ste videli pakety od pozorovateľov.';

  @override
  String mqtt_feedWaiting(String topic) {
    return 'Čaká sa na pakety na $topic';
  }

  @override
  String get mqtt_feedUnknownObserver => 'Neznámy pozorovateľ';

  @override
  String mqtt_feedHeardBy(String observer) {
    return 'Počul $observer';
  }

  @override
  String mqtt_feedHopsBytes(int hops, int bytes) {
    return 'Skoky: $hops · bajty: $bytes';
  }

  @override
  String get mqtt_packetRequest => 'Požiadavka';

  @override
  String get mqtt_packetResponse => 'Odpoveď';

  @override
  String get mqtt_packetDirectMessage => 'Priama správa';

  @override
  String get mqtt_packetAck => 'Potvrdenie';

  @override
  String get mqtt_packetAdvert => 'Ohlásenie';

  @override
  String get mqtt_packetChannelMessage => 'Správa kanála';

  @override
  String get mqtt_packetChannelData => 'Dáta kanála';

  @override
  String get mqtt_packetAnonymousRequest => 'Anonymná požiadavka';

  @override
  String get mqtt_packetPath => 'Trasa';

  @override
  String get mqtt_packetTrace => 'Sledovanie';

  @override
  String get mqtt_packetMultipart => 'Viacdielny';

  @override
  String get mqtt_packetControl => 'Riadenie';

  @override
  String mqtt_packetType(int type) {
    return 'Typ $type';
  }

  @override
  String get mqtt_routeTransportFlood => 'Flood s transportom';

  @override
  String get mqtt_routeFlood => 'Flood';

  @override
  String get mqtt_routeDirect => 'Priama';

  @override
  String get mqtt_routeTransportDirect => 'Priama s transportom';

  @override
  String get mqtt_noticeInvalidHost =>
      'Zadajte názov hostiteľa alebo adresu IPv4 bez schémy a portu.';

  @override
  String get mqtt_noticeInvalidPort => 'Port musí byť od 1 do 65535.';

  @override
  String get mqtt_noticeInvalidWebSocketPath =>
      'Cesta WebSocket musí začínať znakom / a nesmie obsahovať dopyt ani fragment.';

  @override
  String get mqtt_noticeInvalidTopicPrefix =>
      'Predpona témy musí byť neprázdna cesta MQTT bez zástupných znakov.';

  @override
  String get mqtt_noticeInvalidRegion =>
      'Región musí mať 2 až 8 písmen alebo číslic, napr. PHL.';

  @override
  String get mqtt_noticeTlsRequired =>
      'TLS je povinné, pokiaľ nie je výslovne povolený nezabezpečený prístup k miestnemu brokeru.';

  @override
  String get mqtt_noticeCleartextLocalOnly =>
      'Nešifrované MQTT je povolené iba pre výslovne schválených miestnych hostiteľov.';

  @override
  String get mqtt_noticeRegionNeededToShare =>
      'Nastavte región, aby ste mohli zdieľať pakety ako pozorovateľ.';

  @override
  String mqtt_noticePasswordNeeded(String username) {
    return 'Zadajte heslo pre $username.';
  }

  @override
  String get mqtt_noticeNoNetwork =>
      'Žiadne pripojenie k sieti. MQTT sa znova pripojí, keď sa obnoví.';

  @override
  String get mqtt_noticeSubscriptionRefused => 'Broker odmietol odber paketov.';

  @override
  String get mqtt_noticeBadCredentials =>
      'Broker odmietol používateľské meno alebo heslo.';

  @override
  String get mqtt_noticeNotAuthorized =>
      'Tento účet nemá na brokeri oprávnenie.';

  @override
  String get mqtt_noticeConnectionRefused => 'Broker odmietol pripojenie.';

  @override
  String get mqtt_noticeUnreachable => 'Broker je nedostupný.';

  @override
  String get mqtt_noticeTlsFailed =>
      'Zabezpečené (TLS) pripojenie sa nepodarilo nadviazať.';

  @override
  String get mqtt_noticeWebSocketOnly =>
      'Táto platforma podporuje MQTT iba cez WebSocket.';

  @override
  String get mqtt_noticeRadioNotConnected =>
      'Pripojte rádio, aby ste sa prihlásili jeho kľúčom.';

  @override
  String get mqtt_noticeSigningUnsupported =>
      'Firmvér tohto rádia nepodporuje podpisovanie jeho kľúčom.';

  @override
  String get mqtt_noticeSigningTimeout =>
      'Rádio neodpovedalo na žiadosť o podpis. Jeho firmvér možno podpisovanie nepodporuje.';

  @override
  String get mqtt_noticeSigningTooLong =>
      'Dáta sú príliš dlhé na to, aby ich rádio podpísalo.';

  @override
  String get mqtt_noticeSigningRejected => 'Rádio odmietlo podpísať dáta.';

  @override
  String get scanner_signalStrong => 'Silný';

  @override
  String get scanner_signalGood => 'Dobrý';

  @override
  String get scanner_signalFair => 'Priemerný';

  @override
  String get scanner_signalWeak => 'Slabý';

  @override
  String get scanner_nearbyRadios => 'Rádiá v blízkosti';

  @override
  String get scanner_lastRadio => 'Posledné rádio';

  @override
  String get scanner_reconnect => 'Znova pripojiť';

  @override
  String get scanner_tcpHint => 'Rádio s firmvérom Wi‑Fi vo vašej sieti.';

  @override
  String get scanner_otherWays => 'Iné spôsoby pripojenia';

  @override
  String scanner_radiosFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rádií v blízkosti',
      few: '$count rádiá v blízkosti',
      one: '1 rádio v blízkosti',
    );
    return '$_temp0';
  }

  @override
  String get scanner_searchingTitle => 'Hľadajú sa rádiá…';

  @override
  String get scanner_findTitle => 'Nájdite svoje rádio';

  @override
  String get scanner_heroHint =>
      'Zapnite rádio a majte ho do pár metrov. Potrebuje firmvér MeshCore companion.';

  @override
  String get scanner_tipsTitle => 'Nevidíte svoje rádio?';

  @override
  String get scanner_tipPower => 'Skontrolujte, či je zapnuté a aktívne.';

  @override
  String get scanner_tipFirmware =>
      'Potrebuje firmvér MeshCore companion. Opakovače a izbové servery sa tu nezobrazujú.';

  @override
  String get scanner_tipOtherDevice =>
      'Rádio sa pripája naraz len k jednému zariadeniu. Odpojte ho od iných telefónov či počítačov.';

  @override
  String get connections_internetBridge => 'Internetový most';

  @override
  String get connections_noRadio => 'Žiadne rádio';

  @override
  String get connections_radioSettings => 'Nastavenia rádia';

  @override
  String get connections_viewDashboard => 'Zobraziť prehľad pripojení';

  @override
  String get channelDirectory_title => 'Adresár kanálov';

  @override
  String get channelDirectory_subtitle =>
      'Nájdite verejné hashtagové kanály vo svojom okolí';

  @override
  String get channelDirectory_search => 'Hľadať kanály alebo miesta';

  @override
  String get channelDirectory_nearYou => 'Vo vašom okolí';

  @override
  String get channelDirectory_all => 'Všetky kanály';

  @override
  String get channelDirectory_catAll => 'Všetky';

  @override
  String get channelDirectory_catEmergency => 'Núdzové';

  @override
  String get channelDirectory_catLocal => 'Miestne';

  @override
  String get channelDirectory_catGeneral => 'Všeobecné';

  @override
  String get channelDirectory_catInterest => 'Záujmy';

  @override
  String get channelDirectory_catTest => 'Testovacie';

  @override
  String get channelDirectory_join => 'Pripojiť sa';

  @override
  String get channelDirectory_joined => 'Pripojené';

  @override
  String get channelDirectory_noMatches => 'Hľadaniu nezodpovedá žiadny kanál.';

  @override
  String get channelDirectory_connectFirst =>
      'Pripojte rádio, aby ste sa mohli pripájať ku kanálom.';

  @override
  String get channelDirectory_slotsFull =>
      'Všetky sloty kanálov v rádiu sú obsadené. Najprv odstráňte kanál.';

  @override
  String get channelDirectory_joinFailed =>
      'Kanál sa nepodarilo pridať. Skúste to znova.';

  @override
  String get channelDirectory_addHint =>
      'Chýba kanál? Ktokoľvek ho môže navrhnúť úpravou zdieľaného zoznamu na GitHube.';

  @override
  String get prefixTool_title => 'ID opakovačov';

  @override
  String get prefixTool_subtitle =>
      'Kto používa ID, ktoré ID sa zhodujú a voľné ID pre nový opakovač';

  @override
  String get prefixTool_width => 'Veľkosť ID cesty';

  @override
  String prefixTool_widthBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String get prefixTool_includeCompanions => 'Zahrnúť companiony a senzory';

  @override
  String prefixTool_summary(int nodes, int used, int shared) {
    return 'Známe uzly: $nodes · použité ID: $used · zdieľané: $shared';
  }

  @override
  String prefixTool_freeOfSpace(int free, int space) {
    return 'Voľné ID: $free z $space';
  }

  @override
  String get prefixTool_lookupHint => 'Vyhľadať ID, napr. 3D';

  @override
  String prefixTool_lookupFree(String id) {
    return 'Žiadny známy uzol nepoužíva $id.';
  }

  @override
  String prefixTool_lookupUsed(int count, String id) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$id používa $count uzlov',
      few: '$id používajú $count uzly',
      one: '$id používa 1 uzol',
    );
    return '$_temp0';
  }

  @override
  String get prefixTool_shared => 'Zdieľané ID';

  @override
  String get prefixTool_sharedHint =>
      'Cesty cez tieto ID vyzerajú rovnako, pokiaľ sieť nepoužíva dlhšie ID.';

  @override
  String get prefixTool_noShared => 'Medzi známymi uzlami nie sú zdieľané ID.';

  @override
  String get prefixTool_free => 'Voľné ID';

  @override
  String get prefixTool_shuffle => 'Ďalšie návrhy';

  @override
  String get prefixTool_makeKey => 'Vytvoriť kľúč';

  @override
  String get prefixTool_onlyKnown =>
      'Len podľa uzlov, ktoré rádio počulo. Voľné ID tu môže patriť opakovaču, ktorý ste nepočuli.';

  @override
  String prefixTool_inUseWarning(String id, String name) {
    return '$id už používa $name.';
  }

  @override
  String get prefixTool_pickFree => 'Vybrať voľné ID';

  @override
  String keyGen_title(String id) {
    return 'Kľúč pre ID $id';
  }

  @override
  String keyGen_searching(int tries) {
    return 'Hľadá sa… vyskúšané kľúče: $tries';
  }

  @override
  String get keyGen_publicKey => 'Verejný kľúč';

  @override
  String get keyGen_privateKey => 'Súkromný kľúč';

  @override
  String get keyGen_copy => 'Kopírovať';

  @override
  String get keyGen_copied => 'Skopírované';

  @override
  String get keyGen_secretWarning =>
      'Súkromný kľúč držte v tajnosti. Kto ho má, môže sa vydávať za tento uzol.';

  @override
  String get keyGen_howToUse =>
      'Pre opakovač: otvorte jeho nastavenia, vložte ho ako súkromný kľúč a uložte. Rádiá companion potrebujú firmvér, ktorý povoľuje import kľúča.';

  @override
  String get keyGen_tryAgain => 'Vytvoriť ďalší';

  @override
  String get regionSetup_title => 'Nastavenie regiónov';

  @override
  String get regionSetup_hubSubtitle =>
      'Zaradiť tento opakovač do stromu regiónov vašej oblasti';

  @override
  String get regionSetup_intro =>
      'Regióny držia správu v oblasti namiesto zaplavenia celej siete. Opakovač preposiela správy regiónu, len ak má tento región, preto mu dajte jeho región a všetky nad ním.';

  @override
  String get regionSetup_where => 'Kde je opakovač?';

  @override
  String get regionSetup_tree => 'Strom regiónov';

  @override
  String get regionSetup_custom => 'Vlastné';

  @override
  String get regionSetup_region => 'Najmiestnejší región';

  @override
  String get regionSetup_customLabel => 'Regióny, od najširšieho';

  @override
  String regionSetup_invalidName(String name) {
    return '„$name“ nie je platný názov regiónu. Použite malé písmená, číslice a pomlčky, najviac 29 znakov.';
  }

  @override
  String regionSetup_tooMany(int max) {
    return 'Opakovač môže mať najviac $max regiónov.';
  }

  @override
  String get regionSetup_options => 'Možnosti';

  @override
  String get regionSetup_setDefault => 'Najmiestnejší región ako predvolený';

  @override
  String get regionSetup_setDefaultBody =>
      'Vlastné oznámenia opakovača zostanú v tomto regióne.';

  @override
  String get regionSetup_legacy => 'Firmvér 1.14';

  @override
  String get regionSetup_legacyBody =>
      'Pridá region allowf za každý región. Od 1.15 netreba.';

  @override
  String get regionSetup_denyUnscoped => 'Nepreposielať správy bez regiónu';

  @override
  String get regionSetup_denyUnscopedBody =>
      'Zapnite až vtedy, keď celá oblasť používa regióny, inak správy zo starších aplikácií neprejdú.';

  @override
  String get regionSetup_commands => 'Príkazy';

  @override
  String get regionSetup_copyAll => 'Kopírovať všetko';

  @override
  String get regionSetup_copied => 'Skopírované';

  @override
  String get regionSetup_pickFirst => 'Vyberte región, aby ste videli príkazy.';

  @override
  String regionSetup_sendTo(String name) {
    return 'Odoslať do $name';
  }

  @override
  String get regionSetup_howToSend =>
      'Na odoslanie sa prihláste do opakovača a otvorte Nastavenie regiónov z jeho ponuky, alebo ich vložte do jeho príkazového riadka.';

  @override
  String get regionSetup_noReply => 'Bez odpovede. Zastavené tu.';

  @override
  String get regionSetup_addToMine => 'Pridať tieto regióny do môjho zoznamu';

  @override
  String regionSetup_addedToMine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Do zoznamu pridaných $count regiónov',
      few: 'Do zoznamu pridané $count regióny',
      one: 'Do zoznamu pridaný 1 región',
    );
    return '$_temp0';
  }

  @override
  String get trackLog_title => 'Záznam trasy';

  @override
  String get trackLog_subtitle => 'Zaznamenajte stopu z GPS rádia';

  @override
  String get trackLog_recording => 'Nahráva sa';

  @override
  String get trackLog_notRecording => 'Nenahráva sa';

  @override
  String get trackLog_noGps =>
      'Rádio nehlási polohu GPS. Záznam trasy potrebuje rádio so zapnutým GPS.';

  @override
  String get trackLog_start => 'Spustiť záznam';

  @override
  String get trackLog_stop => 'Zastaviť záznam';

  @override
  String get trackLog_howItWorks =>
      'Používa polohu, ktorú rádio hlási približne raz za minútu, kým je NOTORYX Core otvorený. Bod sa pridá po presune o 25 m alebo každých 15 minút na mieste.';

  @override
  String get trackLog_snap => 'Zaokrúhľovať polohy na približne 100 m';

  @override
  String get trackLog_snapBody => 'Kvôli súkromiu pri zdieľaní trasy.';

  @override
  String get trackLog_saved => 'Uložené trasy';

  @override
  String get trackLog_none => 'Zatiaľ žiadne trasy.';

  @override
  String get trackLog_export => 'Exportovať ako GPX';

  @override
  String get trackLog_exportFailed => 'Trasu sa nepodarilo exportovať.';

  @override
  String get trackLog_deleteTitle => 'Odstrániť túto trasu?';

  @override
  String get trackLog_deleteBody =>
      'Odstráni sa z tohto zariadenia. Exportované súbory GPX zostanú.';

  @override
  String trackLog_stats(String km, String duration, int points) {
    return '$km km · $duration · body: $points';
  }

  @override
  String trackLog_gpxName(String when) {
    return 'Trasa NOTORYX $when';
  }

  @override
  String get routes_nearbyTitle => 'Najlepšie opakovače v okolí';

  @override
  String get routes_nearbyEmptyTitle => 'Zatiaľ nepočuť žiadne opakovače';

  @override
  String get routes_nearbyEmpty =>
      'Opakovače, ktoré rádio počuje priamo, sa tu zobrazia od najsilnejšieho, keď prijíma prevádzku. Zoznam pokrýva poslednú hodinu.';

  @override
  String get routes_unknownRepeater => 'Neznámy opakovač';

  @override
  String routes_nearbyDetail(int count, String ago) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'počutý $count-krát',
      few: 'počutý $count-krát',
      one: 'počutý raz',
    );
    return '$_temp0 · $ago';
  }

  @override
  String routes_minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'pred $minutes min',
      one: 'pred 1 min',
      zero: 'práve teraz',
    );
    return '$_temp0';
  }

  @override
  String routes_via(String names) {
    return 'cez $names';
  }

  @override
  String get nav_home => 'Domov';

  @override
  String get nav_chats => 'Čety';

  @override
  String get nav_tools => 'Nástroje';

  @override
  String get nav_settings => 'Nastavenia';

  @override
  String get nav_more => 'Viac';

  @override
  String get tools_groupApp => 'Aplikácia a nastavenia';

  @override
  String get tools_groupField => 'V teréne';

  @override
  String get tools_groupMaps => 'Mapy a pokrytie';

  @override
  String get tools_groupRouting => 'Trasy a opakovače';

  @override
  String get tools_pathGraph => 'Graf ciest';

  @override
  String get tools_pathGraphHint =>
      'Ako sa k vám dostávajú správy: každá počutá cesta s najvyťaženejšími opakovačmi';

  @override
  String get tools_antenna => 'Pokrytie antény';

  @override
  String get tools_antennaHint => 'Odhadnite, kam dosiahne anténa nad terénom';

  @override
  String routes_repeaterWithId(String id) {
    return 'Opakovač $id';
  }

  @override
  String get signedCov_section => 'Podpísané správy';

  @override
  String get signedCov_share => 'Zdieľať podpísanú správu';

  @override
  String get signedCov_shareHint =>
      'Každý šesťuholník je podpísaný kľúčom pokrytia tohto telefónu, takže upravené či vymyslené sa dajú odhaliť. Nič neopustí telefón, kým to nezdieľaš.';

  @override
  String get signedCov_check => 'Overiť správu';

  @override
  String get signedCov_checkHint =>
      'Vlož podpísanú správu a uvidíš, ktoré pozorovania sú pravé';

  @override
  String get signedCov_paste => 'Podpísaná správa (JSON)';

  @override
  String get signedCov_verify => 'Overiť';

  @override
  String signedCov_yourKey(String fingerprint) {
    return 'Tvoj kľúč pokrytia: $fingerprint';
  }

  @override
  String signedCov_result(int accepted, int rejected) {
    return 'Overené pozorovania: $accepted, zamietnuté: $rejected';
  }

  @override
  String signedCov_signer(String fingerprint) {
    return 'Podpísané kľúčom $fingerprint';
  }

  @override
  String get signedCov_unreadable => 'Toto nie je podpísaná správa o pokrytí.';

  @override
  String signedCov_rBadSignature(int count) {
    return '$count bez podpisu alebo s chybným podpisom';
  }

  @override
  String signedCov_rMalformed(int count) {
    return '$count poškodených';
  }

  @override
  String signedCov_rImpossible(int count) {
    return '$count s nemožnými hodnotami signálu';
  }

  @override
  String signedCov_rFuture(int count) {
    return '$count s dátumom v budúcnosti';
  }

  @override
  String get signedCov_empty => 'Zatiaľ nie sú vzorky pokrytia na zdieľanie.';

  @override
  String get signedCov_shareFailed => 'Správu sa nepodarilo zdieľať.';

  @override
  String get coverageHex_title => 'Šesťuholníky pokrytia';

  @override
  String get coverageHex_toolSubtitle =>
      'Mapujte, kde rádio počuje sieť, a zdieľajte to';

  @override
  String get coverageHex_mapCoverage => 'Mapovať pokrytie';

  @override
  String get coverageHex_statusOff =>
      'Vypnuté. Zapnite počas jazdy alebo chôdze a zmapujte, kde rádio počuje sieť.';

  @override
  String get coverageHex_waitingGps => 'Čaká sa na GPS…';

  @override
  String coverageHex_gpsTooRough(String meters) {
    return 'Presnosť GPS $meters m: príliš hrubá, nezaznamenáva sa.';
  }

  @override
  String coverageHex_recording(String meters) {
    return 'Zaznamenáva sa. Presnosť GPS $meters m.';
  }

  @override
  String get coverageHex_hexagons => 'Šesťuholníky';

  @override
  String get coverageHex_samples => 'Vzorky';

  @override
  String get coverageHex_privacyNote =>
      'Používa GPS telefónu, kým je tento prepínač zapnutý. Zdieľajú sa iba ID šesťuholníkov (asi 0,9 km), nikdy presná poloha.';

  @override
  String get coverageHex_uploadSection => 'Nahrávanie do máp pokrytia';

  @override
  String get coverageHex_wifiOnly => 'Nahrávať iba cez Wi-Fi';

  @override
  String get coverageHex_wifiOnlyHint =>
      'Vzorky čakajú v telefóne (až 7 dní) na Wi-Fi.';

  @override
  String coverageHex_waiting(String count) {
    return 'čaká: $count';
  }

  @override
  String get coverageHex_addMap => 'Pridať mapu pokrytia';

  @override
  String get coverageHex_addMapHint =>
      'Akýkoľvek HTTPS koncový bod, ktorý prijíma pokrytie.';

  @override
  String get coverageHex_uploadNow => 'Nahrať teraz';

  @override
  String get coverageHex_mapDialogTitle => 'Mapa pokrytia';

  @override
  String get coverageHex_nameMissing => 'Pomenujte ju.';

  @override
  String get coverageHex_url => 'URL na nahrávanie';

  @override
  String get coverageHex_urlInvalid => 'Musí to byť URL https://.';

  @override
  String get coverageHex_apiKey => 'Kľúč API (voliteľný)';

  @override
  String get coverageHex_apiKeyHint => 'Odosiela sa ako X-API-Key.';

  @override
  String get coverageHex_format => 'Formát';

  @override
  String get coverageHex_formatHex => 'ID šesťuholníkov (NOTORYX)';

  @override
  String get coverageHex_formatMeshMapper => 'Kompatibilné s MeshMapper';

  @override
  String get coverageHex_privacy => 'Súkromie';

  @override
  String get coverageHex_privacyLive => 'Naživo';

  @override
  String get coverageHex_privacyDelayed => 'Oneskorené o 3 h';

  @override
  String get coverageHex_privacyAnonymous => 'Anonymne, 24 h';

  @override
  String get coverageHex_privacyLiveHint => 'Odošle sa asi do 15 minút.';

  @override
  String get coverageHex_privacyDelayedHint =>
      'Zadržané 3 hodiny, aby mapa neukázala, kde ste teraz.';

  @override
  String get coverageHex_privacyAnonymousHint =>
      'Zadržané 24 hodín, iba s dátumom a bez podpisu, aby sa nahrávky nedali prepojiť.';

  @override
  String get coverageHex_uploadsOn => 'Nahrávanie zapnuté';

  @override
  String coverageHex_sent(String count, String time) {
    return 'Odoslané bunky: $count o $time.';
  }

  @override
  String coverageHex_httpError(String code) {
    return 'Mapa odpovedala $code; skúsi sa znova.';
  }

  @override
  String get coverageHex_unreachable => 'Mapa je nedostupná; skúsi sa znova.';

  @override
  String get coverageHex_noPermission => 'Povolenie na polohu nebolo udelené.';

  @override
  String get coverageHex_noGps => 'GPS nie je k dispozícii.';

  @override
  String get coverageHex_loadFailed =>
      'Uložené pokrytie sa nedá prečítať; začína sa odznova.';

  @override
  String get mqttExtra_wifiOnly => 'Pripájať iba cez Wi-Fi';

  @override
  String mqttExtra_backlog(String count) {
    return 'Paketov čaká na nahranie: $count (uchovávajú sa až 72 hodín).';
  }

  @override
  String get mqttExtra_add => 'Pridať ďalší broker';

  @override
  String get mqttExtra_addBody =>
      'Zdieľa to, čo rádio počuje, s ďalším MQTT brokerom popri hlavnom. Iba nahráva, nikdy nevracia pakety do aplikácie.';

  @override
  String get mqttExtra_separateKey => 'Použiť samostatný kľúč';

  @override
  String get mqttExtra_separateKeyHint =>
      'Prihlasuje sa kľúčom vytvoreným v tomto telefóne namiesto kľúča rádia, takže broker nespojí nahrávky s vaším rádiom.';

  @override
  String mqttExtra_removeTitle(String name) {
    return 'Odstrániť $name?';
  }

  @override
  String get mqttExtra_removeBody =>
      'Odpojí a zabudne nastavenia, heslo, kľúč a čakajúce pakety.';

  @override
  String mqttExtra_ownKey(String key) {
    return 'Prihlasuje sa vlastným kľúčom: $key…';
  }

  @override
  String get botWx_title => 'Uverejňovať výstrahy počasia v kanáli';

  @override
  String get botWx_body =>
      'Každých 10 minút kontroluje americkú National Weather Service na vážne a extrémne výstrahy pre GPS polohu rádia (zaokrúhlenú na asi 1 km) a každú novú uverejní raz. Potrebuje internet v telefóne.';

  @override
  String get botWx_channel => 'Uverejniť v kanáli';

  @override
  String get botWx_moderate => 'Zahrnúť mierne výstrahy';

  @override
  String get botWx_moderateHint => 'Upozornenia aj výstrahy. Viac správ.';

  @override
  String botWx_lastChecked(String time) {
    return 'Naposledy skontrolované $time.';
  }

  @override
  String get botWx_noPosition => 'Rádio ešte nenahlásilo GPS polohu.';

  @override
  String get botWx_noChannel => 'Vyberte kanál pre výstrahy.';

  @override
  String get botWx_channelGone => 'Vybraný kanál už neexistuje.';

  @override
  String botWx_httpError(String code) {
    return 'Meteorologická služba odpovedala $code.';
  }

  @override
  String get botWx_unreachable => 'Meteorologická služba je nedostupná.';

  @override
  String get botCmd_sun => 'Východ a západ slnka na GPS polohe rádia.';

  @override
  String get botCmd_moon => 'Fáza Mesiaca a osvetlenie.';

  @override
  String get botCmd_weather =>
      'Aktuálne počasie pri rádiu (Open-Meteo). Posiela polohu zaokrúhlenú na asi 1 km.';

  @override
  String get botCmd_dice => 'Hádže kockami: !dice, !dice 20 alebo !dice 2d6.';

  @override
  String get botCmd_trace => 'Vypíše opakovače, cez ktoré prišla správa.';

  @override
  String get ping_title => 'Ping opakovača';

  @override
  String get ping_toolSubtitle =>
      'Čas tam a späť a signál oboma smermi k blízkemu opakovaču';

  @override
  String get ping_noRepeaters => 'Zatiaľ žiadne známe opakovače';

  @override
  String get ping_choose => 'Vyberte opakovač';

  @override
  String get ping_avgMs => 'ms tam a späť';

  @override
  String get ping_snrThere => 'SNR tam';

  @override
  String get ping_snrBack => 'SNR späť';

  @override
  String get ping_loss => 'Stratené';

  @override
  String ping_running(int done, int total) {
    return 'Ping $done z $total…';
  }

  @override
  String ping_start(int count) {
    return 'Ping $count-krát';
  }

  @override
  String get ping_results => 'Sondy';

  @override
  String get ping_noReply => 'Bez odpovede';

  @override
  String ping_resultLine(String ms, String snr) {
    return '$ms ms · SNR tam $snr';
  }

  @override
  String get ping_explainer =>
      'Každá sonda je sledovanie cesty s jedným skokom: opakovač zaznamená, ako dobre vás počul, a pošle to späť. Funguje s opakovačmi, ktoré rádio počuje priamo.';

  @override
  String get hunt_title => 'Hľadanie anténou';

  @override
  String get hunt_toolSubtitle =>
      'Veľký merač signálu, ktorý kliká rýchlejšie pri silnejšom signáli';

  @override
  String get hunt_noSignal => 'Zatiaľ bez signálu';

  @override
  String get hunt_noReply => 'Bez odpovede — posuňte alebo otočte anténu';

  @override
  String get hunt_heardHere => 'dB počuté tu';

  @override
  String get hunt_best => 'Najlepší';

  @override
  String get hunt_sound => 'Klikanie pri silnejúcom signáli';

  @override
  String get hunt_soundHint =>
      'S vibráciou pri každom kliknutí, aby ste mohli mieriť bez pozerania.';

  @override
  String get hunt_stop => 'Zastaviť';

  @override
  String get hunt_start => 'Začať hľadanie';

  @override
  String get hunt_explainer =>
      'Sonduje opakovač približne raz za sekundu. Nasmerujte smerovú anténu alebo choďte: číslo ukazuje, ako dobre ho rádio počuje.';

  @override
  String get settings_refreshRate => 'Frekvencia obnovy';

  @override
  String get settings_refreshFast => 'Rýchlo';

  @override
  String get settings_refreshNormal => 'Normálne';

  @override
  String get settings_refreshSlow => 'Pomaly';

  @override
  String get settings_refreshFastHint =>
      'Batéria každú minútu, GPS každých 30 s. Čerstvejšie údaje, väčšia spotreba.';

  @override
  String get settings_refreshNormalHint =>
      'Batéria každé 2 minúty, GPS každú minútu.';

  @override
  String get settings_refreshSlowHint =>
      'Batéria každých 6 minút, GPS každé 3. Šetrí batériu.';

  @override
  String get settings_refreshSaverOn =>
      'Šetrič batérie je zapnutý a určuje tempo (batéria každých 10 minút).';

  @override
  String get reach_check => 'Skontrolovať dosah u pozorovateľov';

  @override
  String get reach_title => 'Dosah u pozorovateľov';

  @override
  String get reach_noHash =>
      'Túto správu ešte nemožno vyhľadať: žiadny opakovač ju nevrátil do rádia, takže ID paketu nie je známe.';

  @override
  String get reach_unreachable =>
      'Analyzátor je nedostupný. Skontrolujte internet alebo adresu analyzátora v nastaveniach.';

  @override
  String get reach_none =>
      'Zatiaľ ju nepočul žiadny pozorovateľ. Pozorovatelia nahrávajú chvíľu po príjme, skúste to o minútu.';

  @override
  String get reach_observers => 'pozorovatelia';

  @override
  String get reach_maxHops => 'max. skokov';

  @override
  String get reach_bestSnr => 'najlepší SNR';

  @override
  String reach_hops(int count) {
    return '$count skokov ďaleko';
  }

  @override
  String get reach_explainer =>
      'Z online analyzátora: pozorovatelia, ktorí tento paket počuli a nahrali.';

  @override
  String get reach_checkAgain => 'Znova';

  @override
  String get analyzer_title => 'Online analyzátor';

  @override
  String get analyzer_url => 'Adresa analyzátora';

  @override
  String get analyzer_urlHint =>
      'Analyzátor CoreScope (https://). Použite ten pre váš región.';

  @override
  String get analyzer_reset => 'Predvolené';

  @override
  String get analyzer_hint =>
      'Slúži na kontrolu, ktorí pozorovatelia počuli vaše správy. Odošle sa iba ID paketu.';

  @override
  String get analyzer_hopLookup => 'Mená neznámych opakovačov online';

  @override
  String get analyzer_hopLookupHint =>
      'Keď ID opakovača nie je v kontaktoch, meno sa zistí z analyzátora. Odosielajú sa iba krátke ID. Meno s „?“ znamená, že ID zdieľa viac opakovačov.';

  @override
  String discovered_tray(int count) {
    return 'Kanály počuté v okolí: $count';
  }

  @override
  String get discovered_title => 'Počuté v okolí, nepripojené';

  @override
  String discovered_heard(int count, String time) {
    return 'Počuté $count× · naposledy $time';
  }

  @override
  String get discovered_ignore => 'Ignorovať';

  @override
  String get discovered_ignoreAll => 'Ignorovať všetky';

  @override
  String get discovered_joinAll => 'Pripojiť všetky';

  @override
  String get discovered_explainer =>
      'Ide o verejné kanály z adresára, v ktorých rádio počulo prevádzku. Každý bol potvrdený dešifrovaním správy jeho kľúčom. Ignorované zostávajú skryté.';

  @override
  String get mqtt_presetMeshRank => 'MeshRank (komunita)';

  @override
  String get mqtt_presetMeshRankNote =>
      'MeshRank je komunitný rebríček sietí MeshCore, nie je súčasťou NOTORYX a nie je ním odporúčaný. Bez prihlásenia: pakety sa zdieľajú pod kľúčom a kódom regiónu rádia, až po zapnutí zdieľania.';

  @override
  String get pathFilter_title => 'Filter šírky cesty';

  @override
  String get pathFilter_firmwareNote =>
      'Vyžaduje firmvér opakovača s pravidlami preposielania (mikecarper/MeshCore). Oficiálny firmvér MeshCore tieto príkazy odmietne.';

  @override
  String get pathFilter_width => 'Šírka cesty';

  @override
  String get pathFilter_anyWidth => 'Akákoľvek šírka';

  @override
  String pathFilter_bytes(int n) {
    return 'Cesty s $n bajtmi';
  }

  @override
  String get pathFilter_twoOrMore => '2 alebo 3 bajty (2+)';

  @override
  String get pathFilter_path => 'Platí pre';

  @override
  String get pathFilter_radio => 'Rádiové záplavy';

  @override
  String get pathFilter_bridge => 'Most';

  @override
  String get pathFilter_cross => 'Prechod';

  @override
  String get pathFilter_bridgeCross => 'Most a prechod';

  @override
  String get pathFilter_limit => 'Obmedziť namiesto zahodenia';

  @override
  String get pathFilter_limitOn => 'Preposiela do nastaveného počtu za minútu.';

  @override
  String get pathFilter_drop => 'Zhodné záplavy sa zahadzujú.';

  @override
  String get pathFilter_perMinute => 'Za minútu';

  @override
  String get pathFilter_rateInvalid => 'Zadajte 1 až 65534.';

  @override
  String get pathFilter_reviewNote =>
      'Iba vyplní príkazový riadok. Skontrolujte ho a stlačte Odoslať. Najprv použite „get fr“ na zobrazenie pravidiel.';

  @override
  String get pathFilter_useCommand => 'Použiť príkaz';

  @override
  String get settings_linkPreviews => 'Náhľady odkazov';

  @override
  String get settings_linkPreviewsHint =>
      'Zobrazí názov odkazu v správe. Predvolene vypnuté: načítanie stránky prezradí webu vašu IP adresu.';

  @override
  String get guide_title => 'Terénna príručka';

  @override
  String get guide_subtitle => 'Základy, batérie v chlade, solár a antény';

  @override
  String get guide_secMesh => 'Pripojenie k sieti';

  @override
  String get guide_mesh1 =>
      'Telefón komunikuje s rádiom cez Bluetooth, USB alebo Wi-Fi; rádio so sieťou cez LoRa. Správy fungujú aj bez signálu.';

  @override
  String get guide_mesh2 =>
      'Opakovače posúvajú správy ďalej; každé preposlanie je skok. Menej skokov je rýchlejšie a spoľahlivejšie.';

  @override
  String get guide_mesh3 =>
      'Píšte krátko a nezahlcujte rušné kanály: každá správa využíva spoločný vysielací čas.';

  @override
  String get guide_secCold => 'Batérie v chlade';

  @override
  String get guide_cold1 =>
      'Nenabíjajte lítiové batérie pod bodom mrazu (0 °C): trvalo ich to poškodí.';

  @override
  String get guide_cold2 =>
      'Noste rádio pod bundou. Chlad znižuje kapacitu, ktorá sa po zahriatí vráti.';

  @override
  String get guide_cold3 =>
      'Pre pevné stanovištia v chladnom podnebí je LiFePO4 lepšia ako lítium-iónová; vyhrievaná alebo izolovaná skrinka pomôže obom.';

  @override
  String get guide_secSolar => 'Solár pre opakovače';

  @override
  String get guide_solar1 =>
      'Opakovač spotrebuje veľmi málo, ale panel a batériu dimenzujte na najtmavší zimný týždeň, nie na letný deň.';

  @override
  String get guide_solar2 =>
      'Otočte panel k rovníku a v zime ho strmo nakloňte; chráňte ho pred snehom a tieňom.';

  @override
  String get guide_secAntenna => 'Antény a umiestnenie';

  @override
  String get guide_ant1 =>
      'Výška je dôležitejšia ako výkon: rádio o pár metrov vyššie dosiahne oveľa ďalej ako na stole.';

  @override
  String get guide_ant2 =>
      'Anténu majte zvislo a ďalej od kovu a použite takú pre vaše pásmo (napr. 868 MHz v Európe).';

  @override
  String get guide_secMore => 'Viac informácií';

  @override
  String get guide_moreMeshcore => 'Oficiálny projekt MeshCore';

  @override
  String get guide_moreCascadia =>
      'Komunitné návody: začíname, wardriving, regióny, solár';

  @override
  String get post_signed => 'Podpísané';

  @override
  String get post_unverified => 'Neoverené';

  @override
  String post_signedKnown(String name) {
    return 'Podpísal $name, jeden z vašich kontaktov.';
  }

  @override
  String get post_signedUnknownKey =>
      'Podpísané, ale nie žiadnym z vašich kontaktov. Pridajte odosielateľa do kontaktov a uvidíte, kto to je.';

  @override
  String get post_unverifiedHint =>
      'S príspevkom prišiel podpis, ktorý nesedí. Mohol sa cestou zmeniť alebo nie je od toho, kto tvrdí.';

  @override
  String get settings_signPosts =>
      'Podpisovať všetky moje príspevky v kanáloch';

  @override
  String get settings_signPostsHint =>
      'SOS v kanáli je vždy podpísané. Toto podpíše každý príspevok, aby ostatní používatelia NOTORYX videli, že ste to naozaj vy. Každý podpis je jeden paket navyše vo vysielaní.';

  @override
  String get tools_search => 'Hľadať nástroje a nastavenia';

  @override
  String get tools_noMatches => 'Vyhľadávaniu nezodpovedajú žiadne nástroje.';

  @override
  String get tools_bot => 'Režim bota';

  @override
  String get tools_botHint =>
      'Automatické odpovede, !príkazy a výstrahy počasia v kanáloch';

  @override
  String get botChannels_title => 'Kanály';

  @override
  String get botChannels_hint =>
      'Bot odpovedá na !príkazy aj v zapnutých kanáloch, v tom istom kanáli. Odpovede o neprítomnosti tam nikdy neposiela.';

  @override
  String get botChannels_none => 'Na tomto rádiu zatiaľ nie sú kanály.';

  @override
  String get advert_zeroHopHint =>
      'Iba rádiá, ktoré vás počujú priamo. Opakovače ho nepreposielajú.';

  @override
  String get advert_floodHint =>
      'Opakovače ho šíria celou sieťou. Zaberie viac vysielacieho času.';

  @override
  String get radioPresets_custom => 'Vlastné';

  @override
  String get radioPresets_search => 'Hľadať predvoľby';

  @override
  String get radioPresets_suggested => 'Odporúčané pre váš región';

  @override
  String get radioPresets_community => 'Predvoľby komunity';

  @override
  String get radioPresets_hint =>
      'Toto sú predvoľby odporúčané komunitou MeshCore. Vyberte tú, ktorú používa miestna sieť. Nastaví frekvenciu, šírku pásma, SF a CR; vysielací výkon zostáva.';

  @override
  String get mySensors_title => 'Senzory';

  @override
  String get mySensors_refresh => 'Načítať senzory';

  @override
  String get mySensors_reading => 'Čítajú sa senzory rádia…';

  @override
  String get mySensors_failed =>
      'Rádio neodpovedalo. Ťuknite na obnoviť a skúste znova.';

  @override
  String get mySensors_none => 'Žiadne údaje zo senzorov rádia.';

  @override
  String get activeChannels_title => 'Aktívne online';

  @override
  String activeChannels_messages(int count) {
    return 'Správy: $count';
  }

  @override
  String activeChannels_source(String host) {
    return 'Kanály, ktoré sa používajú, podľa pozorovateľov $host. V nastaveniach zmeňte analyzátor pre svoju oblasť.';
  }

  @override
  String get fieldOps_checkInChannelLabel => 'Hlásenia idú aj do kanála';

  @override
  String get fieldOps_checkInChannelHint =>
      'Podpísané kľúčom rádia, aby ostatní v kanáli videli, že ste to naozaj vy. Kontakty výletu ho stále dostanú priamo.';

  @override
  String get channels_regionUnknown => 'Regionálne';

  @override
  String channels_regionSemantics(String region) {
    return 'Odoslané do regiónu $region';
  }

  @override
  String get channels_regionUnknownSemantics =>
      'Odoslané do regiónu, ktorý aplikácia nepozná';

  @override
  String get timeline_title => 'Časová os';

  @override
  String get timeline_toolSubtitle =>
      'Správy, nové uzly, zmeny signálu a miesta v jednom prehľade';

  @override
  String get timeline_refresh => 'Znova načítať';

  @override
  String get timeline_search => 'Hľadať na časovej osi';

  @override
  String get timeline_kindMessages => 'Správy';

  @override
  String get timeline_kindNodes => 'Nové uzly';

  @override
  String get timeline_kindSignal => 'Signál';

  @override
  String get timeline_kindPlaces => 'Miesta';

  @override
  String timeline_messageFrom(String sender, String where) {
    return '$sender v $where';
  }

  @override
  String timeline_nodeJoined(String name) {
    return 'Prvýkrát počuť: $name';
  }

  @override
  String timeline_signalUp(String name, String from, String to) {
    return '$name: signál stúpol z $from na $to dB';
  }

  @override
  String timeline_signalDown(String name, String from, String to) {
    return '$name: signál klesol z $from na $to dB';
  }

  @override
  String timeline_placeSaved(String name) {
    return 'Miesto uložené: $name';
  }

  @override
  String timeline_placeShared(String sender, String where) {
    return '$sender zdieľal miesto v $where';
  }

  @override
  String get timeline_empty =>
      'Zatiaľ nič. Tu sa zobrazia správy, novo počuté uzly, zmeny signálu a miesta.';

  @override
  String get wardrive_title => 'Wardrive';

  @override
  String get wardrive_hint =>
      'Pingujte z miesta, kde ste, a mapujte, ktoré opakovače vás počujú';

  @override
  String get wardrive_start => 'Štart';

  @override
  String get wardrive_stop => 'Stop';

  @override
  String get wardrive_pings => 'pingy';

  @override
  String get wardrive_heard => 'počuté';

  @override
  String get wardrive_pinging => 'Pingujem…';

  @override
  String get wardrive_waitPosition =>
      'Čaká sa na GPS polohu z telefónu alebo rádia.';

  @override
  String get wardrive_waitRadio => 'Pripojte rádio na pingovanie.';

  @override
  String get wardrive_history => 'História';

  @override
  String get wardrive_noSessions => 'Zatiaľ žiadne jazdy.';

  @override
  String wardrive_sessionSummary(int pings, int heard) {
    return 'Pingy: $pings · počuté: $heard';
  }

  @override
  String get wardrive_delete => 'Odstrániť';

  @override
  String get wardrive_recentre => 'Späť na moju polohu';

  @override
  String get wardrive_youAreHere => 'Ste tu';

  @override
  String get wardrive_backToLive => 'Späť na aktuálnu';

  @override
  String get wardrive_noReplies => 'Tento ping nepočul žiadny opakovač.';

  @override
  String wardrive_replyDetail(String there, String here) {
    return 'Počul vás pri $there dB · vy ho pri $here dB';
  }

  @override
  String get wardrive_explainer =>
      'Každý ping je žiadosť o objavenie bez preposielania: odpovedajú len opakovače v priamom dosahu a nič sa nepublikuje do kanála. Poloha pochádza z GPS telefónu, inak z rádia.';

  @override
  String get mapTelemetry_policy =>
      'Uložené hodnoty sa po 1 hodine stlmia a po 24 hodinách zmiznú. Obnovenie odošle jednu požiadavku; uzol musí povoliť telemetriu a senzory môžu vyžadovať prihlásenie. Mapa nikdy nežiada aktualizácie automaticky.';

  @override
  String get autoConnect_title => 'Automaticky sa pripojiť k môjmu rádiu';

  @override
  String get autoConnect_hint =>
      'Po otvorení aplikácie sa znova pripojí k poslednému rádiu bez ťuknutia. Ak ešte nie je v dosahu, skúsi to niekoľkokrát.';

  @override
  String get networks_title => 'Siete';

  @override
  String get networks_hint => 'Vyhľadávanie sietí v okolí a ich záznam';

  @override
  String get networks_yourNetwork => 'Vaša sieť';

  @override
  String get networks_scanTitle => 'Hľadať siete';

  @override
  String get networks_scanExplainer =>
      'Rádio počuje len siete s presne rovnakými nastaveniami, preto ho vyhľadávanie postupne prepne na každú, počúva a potom ho vráti späť. Počas vyhľadávania ste mimo svojej siete.';

  @override
  String get networks_listenFor => 'Počúvať na každej';

  @override
  String networks_choose(int count) {
    return 'Siete na vyhľadanie: $count';
  }

  @override
  String get networks_suggested => 'Navrhované';

  @override
  String get networks_start => 'Spustiť vyhľadávanie';

  @override
  String get networks_cancel => 'Zastaviť vyhľadávanie';

  @override
  String networks_listening(String name, int step, int steps) {
    return 'Počúvam $name ($step z $steps)';
  }

  @override
  String get networks_blockNoRadio => 'Pripojte rádio na vyhľadávanie.';

  @override
  String get networks_blockSettings => 'Čaká sa na nastavenia rádia.';

  @override
  String get networks_blockSos =>
      'Nie počas SOS: vyhľadávanie vás odpojí od siete.';

  @override
  String get networks_blockTrip =>
      'Nie počas výletu: vyhľadávanie vás odpojí od siete.';

  @override
  String get networks_nearby => 'Siete v okolí';

  @override
  String get networks_nothingYet =>
      'Zatiaľ nebola počutá žiadna sieť. Spustite vyhľadávanie.';

  @override
  String networks_heardSummary(int nodes, int packets, String snr) {
    return 'Uzly $nodes · pakety $packets · SNR $snr dB';
  }

  @override
  String networks_lastHeard(String time) {
    return 'Naposledy počutá $time';
  }

  @override
  String networks_timesHeard(int count) {
    return 'Koľkokrát počutá: $count';
  }

  @override
  String get networks_saved => 'Uložené siete';

  @override
  String get networks_noSaved => 'Zatiaľ žiadne uložené siete.';

  @override
  String get networks_add => 'Pridať sieť';

  @override
  String get networks_join => 'Pripojiť sa';

  @override
  String networks_joinConfirm(String name) {
    return 'Prepnúť rádio na $name? Opustíte aktuálnu sieť. Vysielací výkon zostane rovnaký.';
  }

  @override
  String networks_joined(String name) {
    return 'Rádio je teraz na $name.';
  }

  @override
  String get networks_log => 'Záznam sietí';

  @override
  String get networks_logEmpty => 'Zatiaľ nič zaznamenané.';

  @override
  String get networks_showMap => 'Mapa';

  @override
  String get networks_exportCsv => 'Exportovať CSV';

  @override
  String get networks_exportGpx => 'Exportovať GPX';

  @override
  String get networks_clearLog => 'Vymazať záznam';

  @override
  String get networks_clearLogConfirm => 'Odstrániť všetky zaznamenané siete?';

  @override
  String get networks_name => 'Názov';

  @override
  String get networks_invalid =>
      'Skontrolujte nastavenia: sú mimo rozsahu, ktorý prijímajú rádiá MeshCore.';

  @override
  String get networks_nodesHeard => 'Počuté uzly';

  @override
  String get chat_resendNeedsRadio =>
      'Neodoslané: pripojte rádio a skúste to znova. Správa zostáva uložená.';

  @override
  String get quick_title => 'Rýchle správy';

  @override
  String get quick_ok => 'OK';

  @override
  String get quick_onMyWay => 'Som na ceste';

  @override
  String get quick_atCamp => 'V tábore';

  @override
  String get quick_runningLate => 'Meškám';

  @override
  String get quick_needHelp => 'Potrebujem pomoc';

  @override
  String get quick_copyThat => 'Rozumiem';

  @override
  String get quick_empty =>
      'Žiadne rýchle správy. Ťuknite na Upraviť a pridajte jednu.';

  @override
  String get quick_add => 'Nová rýchla správa';

  @override
  String get quick_reset => 'Obnoviť predvolené';

  @override
  String get chat_stopRetrying => 'Zastaviť opakovanie';

  @override
  String chat_addFirstBanner(String name) {
    return '$name môže čítať vaše priame správy a odpovedať na ne až po pridaní vás medzi kontakty. Ak to neurobil, pošlite svoj oznam alebo zdieľajte kontakt.';
  }

  @override
  String get map_goToMyPosition => 'Prejsť na moju polohu';

  @override
  String get map_positionUnavailable =>
      'Vaša poloha nie je dostupná. Zapnite polohu alebo nastavte polohu rádia.';

  @override
  String get contact_forgetAdvert => 'Zabudnúť posledný oznam';

  @override
  String get contact_forgetAdvertHint =>
      'Ak sa oznamy tohto uzla po resetovaní jeho hodín prestali aktualizovať, Zabudnúť posledný oznam prepustí ďalší.';

  @override
  String get contact_forgetAdvertDone =>
      'Hotovo. Ďalší oznam tohto uzla bude prijatý.';

  @override
  String get networks_modeQuick => 'Rýchle';

  @override
  String get networks_modeThorough => 'Dôkladné';

  @override
  String get networks_modeQuickHint =>
      'V každej sieti pošle jeden krátky ping bez preposielania a niekoľko sekúnd počúva. Nájde siete s opakovačom v dosahu.';

  @override
  String get networks_modeThoroughHint =>
      'Iba počúva, dlhšie v každej sieti. Nič neposiela a nájde aj siete bez opakovača v dosahu, ak niekto vysiela.';

  @override
  String networks_estimate(String time) {
    return 'asi $time';
  }

  @override
  String discoveredContacts_selected(int count) {
    return 'Vybrané: $count';
  }

  @override
  String get discoveredContacts_selectAll => 'Vybrať všetko';

  @override
  String get discoveredContacts_addSelected => 'Pridať vybrané';

  @override
  String discoveredContacts_addAllShown(int count) {
    return 'Pridať všetky zobrazené ($count)';
  }

  @override
  String discoveredContacts_addManyTitle(int count) {
    return 'Pridať kontakty ($count)?';
  }

  @override
  String discoveredContacts_roomLeft(int room) {
    return 'Rádio má miesto ešte pre $room kontaktov.';
  }

  @override
  String discoveredContacts_roomLimit(int room, int count) {
    return 'Rádio má miesto ešte pre $room kontaktov, preto sa pridá len prvých $room z $count.';
  }

  @override
  String discoveredContacts_adding(int done, int total) {
    return 'Pridáva sa $done z $total…';
  }

  @override
  String discoveredContacts_addedMany(int count) {
    return 'Pridané kontakty: $count';
  }

  @override
  String discoveredContacts_addedSome(int added, int failed) {
    return 'Pridané kontakty: $added. Nepridané: $failed.';
  }

  @override
  String get discoveredContacts_radioFull =>
      'Zoznam kontaktov rádia je plný. Najprv odstráňte niektoré kontakty.';

  @override
  String get fieldIntel_radioNow => 'Rádio teraz';

  @override
  String get fieldIntel_noRadio => 'Pripojte rádio pre živé údaje.';

  @override
  String get fieldIntel_noise => 'šum dBm';

  @override
  String get fieldIntel_lastSnr => 'posledný SNR';

  @override
  String get fieldIntel_lastRssi => 'posledný RSSI';

  @override
  String get fieldIntel_battery => 'batéria V';

  @override
  String fieldIntel_airtime(String sent, String received) {
    return 'Čas vysielania od štartu rádia: odoslané $sent, prijaté $received';
  }

  @override
  String get fieldIntel_whoAround => 'Kto je nablízku';

  @override
  String get fieldIntel_m15 => '15 min';

  @override
  String get fieldIntel_h1 => '1 hod.';

  @override
  String get fieldIntel_h24 => '24 hod.';

  @override
  String get fieldIntel_older => 'Staršie';

  @override
  String get fieldIntel_lastHour => 'Posledná hodina';

  @override
  String get fieldIntel_chartHint =>
      'Kedy bol každý uzol naposledy počutý, po hodinách za posledný deň. Ťuknite na stĺpec a uvidíte kto.';

  @override
  String get fieldIntel_mix => 'Typy uzlov';

  @override
  String get fieldIntel_reach => 'Dosah';

  @override
  String get fieldIntel_hops1 => '1 skok';

  @override
  String get fieldIntel_hops2 => '2 skoky';

  @override
  String get fieldIntel_hops3 => '3+ skoky';

  @override
  String get fieldIntel_noRoute => 'Zatiaľ bez trasy';

  @override
  String get fieldIntel_distance => 'Najbližšie a najvzdialenejšie';

  @override
  String get fieldIntel_noneLocated => 'Žiadny z kontaktov nemá polohu.';

  @override
  String get fieldIntel_noPosition =>
      'Rádio zatiaľ nemá polohu, preto sa vzdialenosti nedajú vypočítať.';

  @override
  String get fieldIntel_bestRepeaters => 'Najlepšie priamo počuté opakovače';

  @override
  String get fieldIntel_noneDirect =>
      'Za posledných 30 minút nebol priamo počutý žiadny opakovač.';

  @override
  String get fieldIntel_attention => 'Vyžaduje pozornosť';

  @override
  String get fieldIntel_allGood => 'Nič nevyžaduje pozornosť.';

  @override
  String fieldIntel_lowBattery(String volts) {
    return 'Slabá batéria: $volts V';
  }

  @override
  String fieldIntel_quietFavorite(String ago) {
    return 'Obľúbený nepočutý od $ago';
  }

  @override
  String get fieldIntel_moreTools => 'Ďalšie nástroje';

  @override
  String fieldIntel_nodeCount(int count) {
    return 'Uzly: $count';
  }

  @override
  String get fieldIntel_none => 'Žiadne uzly.';

  @override
  String fieldIntel_lastHeard(String ago) {
    return 'Naposledy počutý $ago';
  }

  @override
  String get fieldIntel_showOnMap => 'Zobraziť na mape';

  @override
  String get fieldIntel_openChat => 'Otvoriť chat';

  @override
  String get repeaterTools_login => 'Prihlásiť sa';

  @override
  String get repeaterTools_heardDirect => 'Počutý priamo';

  @override
  String get repeaterTools_filterAll => 'Všetky';

  @override
  String get repeaterTools_filterLowBattery => 'Slabá batéria';

  @override
  String get repeaterTools_hint =>
      'Ťuknite na opakovač pre podrobnosti a odtiaľ sa prihláste pre stav, susedov, telemetriu a príkazový riadok.';

  @override
  String get repeaterTools_noneMatch => 'Žiadne opakovače.';

  @override
  String get repeaterTools_toolsTitle => 'Nástroje';

  @override
  String get repeaterTools_regionSetupHint =>
      'Vyhľadajte strom regiónov pre svoju oblasť a skopírujte jeho príkazy';

  @override
  String get routes_failingOnly => 'Iba neúspešné trasy';

  @override
  String get routes_contactDetails => 'Údaje kontaktu';

  @override
  String get links_contactTitle => 'Pridať kontakt?';

  @override
  String get links_importAdvert => 'Pridať tento kontakt do rádia?';

  @override
  String get links_connectFirst =>
      'Najprv pripojte rádio a potom odkaz otvorte znova.';

  @override
  String get links_added => 'Kontakt pridaný';

  @override
  String get links_notContact => 'Tento odkaz nie je kontakt MeshCore.';

  @override
  String get radioBuzzer_title => 'Bzučiak rádia';

  @override
  String get radioBuzzer_hint =>
      'Rádio pípne pri nových správach. Zobrazuje sa len pri rádiách s bzučiakom.';

  @override
  String get radioBuzzer_failed => 'Rádio zmenu neprijalo. Skúste to znova.';

  @override
  String get appSettings_floodAttempts => 'Pokusy zaplavením';

  @override
  String get appSettings_floodAttemptsSubtitle =>
      'Ďalšie pokusy poslané zaplavením po zlyhaní priamych, ak sa trasa zmenila. Každý zaberie viac vysielacieho času. 0 ich vypne.';

  @override
  String get pathGraph_you => 'Vy';

  @override
  String pathGraph_relayed(int count) {
    return 'Preposlal $count správ';
  }

  @override
  String get pathGraph_ambiguousNote =>
      'Toto krátke ID zodpovedá viacerým opakovačom, takže sa nedá priradiť jednému.';

  @override
  String get pathGraph_comesFrom => 'Prichádza z';

  @override
  String get pathGraph_goesTo => 'Ide do';

  @override
  String get pathGraph_repeaterDetails => 'Údaje opakovača';

  @override
  String get pathGraph_days7 => '7 dní';

  @override
  String get pathGraph_empty =>
      'V tomto období zatiaľ nie sú trasy správ z kanálov. Trasy sa zbierajú z prijatých správ z kanálov, keď je sledovanie zapnuté.';

  @override
  String pathGraph_summary(int paths, int repeaters) {
    return 'Počuté trasy: $paths · opakovače: $repeaters';
  }

  @override
  String get pathGraph_hashOnly =>
      'Každý skok je zobrazený hash predponou alebo menom, ak opakovač poznáte.';

  @override
  String pathGraph_matched(int count) {
    return '$count krátkych (1-bajtových) skokov priradených ku konkrétnemu opakovaču podľa dlhších trás.';
  }

  @override
  String pathGraph_matchedAmbiguous(int matched, int ambiguous) {
    return '$matched krátkych (1-bajtových) skokov priradených ku konkrétnemu opakovaču podľa dlhších trás · $ambiguous stále nejednoznačných (označené ?).';
  }

  @override
  String get pathGraph_chartHint =>
      'Vľavo: vzdialenejšie opakovače. Vpravo: vy. Hrúbka pásu je počet správ cez tento skok. Ťuknite na políčko a uvidíte opakovač.';

  @override
  String get pathGraph_busiest => 'Najvyťaženejšie opakovače';

  @override
  String pathGraph_chartSemantics(String name, int count) {
    return 'Graf trás. Najvyťaženejší opakovač $name, preposlal $count správ.';
  }

  @override
  String diag_copied(String label) {
    return 'Skopírované: $label';
  }

  @override
  String get diag_noChannels => 'V tomto rádiu nie sú kanály.';

  @override
  String get diag_tapToCopy =>
      'Ťuknite na hodnotu a skopírujete ju. Potiahnutím nadol obnovíte.';

  @override
  String get diag_storage => 'Úložisko';

  @override
  String diag_storageValue(int used, int total) {
    return '$used z $total KB';
  }

  @override
  String get rxLog_title => 'Denník RX';

  @override
  String get rxLog_hint => 'Každý paket, ktorý vaše rádio počuje, naživo';

  @override
  String get rxLog_empty =>
      'Zatiaľ žiadne pakety. Pakety, ktoré rádio počuje, sa tu zobrazia hneď, ako prídu.';

  @override
  String get rxLog_note =>
      'Uchováva sa iba v pamäti, posledných 2 000 paketov. Nič sa neukladá ani neodosiela.';

  @override
  String get rxLog_pause => 'Pozastaviť';

  @override
  String get rxLog_resume => 'Pokračovať';

  @override
  String get rxLog_export => 'Exportovať CSV';

  @override
  String get rxLog_clearConfirm => 'Vymazať denník RX?';

  @override
  String rxLog_count(int shown, int total) {
    return '$shown zobrazených · $total počutých';
  }

  @override
  String get rxLog_paused => 'Pozastavené: nové pakety sa nezaznamenávajú';

  @override
  String get rxLog_kindAll => 'Všetky';

  @override
  String get rxLog_kindAdvert => 'Ohlásenia';

  @override
  String get rxLog_kindChannel => 'Kanál';

  @override
  String get rxLog_kindDirect => 'Priame';

  @override
  String get rxLog_kindAck => 'ACK';

  @override
  String get rxLog_kindPath => 'Cesty';

  @override
  String get rxLog_kindTrace => 'Trasovania';

  @override
  String get rxLog_kindControl => 'Riadenie';

  @override
  String get rxLog_kindOther => 'Iné';

  @override
  String get rxLog_routeFlood => 'Záplava';

  @override
  String get rxLog_routeDirect => 'Priama trasa';

  @override
  String get rxLog_heardDirectly => 'Počuté priamo';

  @override
  String rxLog_hops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skokov',
      many: '$count skoku',
      few: '$count skoky',
      one: '1 skok',
    );
    return '$_temp0';
  }

  @override
  String rxLog_bytes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bajtov',
      many: '$count bajtu',
      few: '$count bajty',
      one: '1 bajt',
    );
    return '$_temp0';
  }

  @override
  String get rxLog_own => 'Vaše rádio';

  @override
  String rxLog_signal(String snr, int rssi) {
    return 'SNR $snr · $rssi dBm';
  }

  @override
  String get rxLog_signalTitle => 'Signál';

  @override
  String get rxLog_route => 'Trasa';

  @override
  String get rxLog_path => 'Cesta';

  @override
  String get rxLog_payloadType => 'Typ obsahu';

  @override
  String get rxLog_hash => 'Hash paketu';

  @override
  String get rxLog_raw => 'Surový paket';

  @override
  String get rxLog_copyHex => 'Kopírovať hex';

  @override
  String get deliv_title => 'Podrobnosti doručenia';

  @override
  String get deliv_note => 'Zistené z údajov uložených s touto správou.';

  @override
  String get deliv_queued => 'V poradí';

  @override
  String get deliv_sent => 'Odoslané rádiom';

  @override
  String get deliv_notSent => 'Rádio neprijalo';

  @override
  String get deliv_attempts => 'Pokusy';

  @override
  String deliv_attemptsValue(int made, int total) {
    return '$made z $total';
  }

  @override
  String deliv_plan(int direct, int flood) {
    return 'Plán: $direct priamo, potom $flood záplavou';
  }

  @override
  String get deliv_lastRoute => 'Posledná trasa';

  @override
  String get deliv_routeFlood => 'Záplava cez všetky opakovače';

  @override
  String get deliv_routeNeighbor => 'Priamo, bez opakovačov';

  @override
  String deliv_routeVia(String path) {
    return 'Priamo cez $path';
  }

  @override
  String get deliv_confirmed => 'Prijatie potvrdené';

  @override
  String deliv_tripTime(String seconds) {
    return 'Spiatočný čas $seconds s';
  }

  @override
  String get deliv_waiting => 'Čaká sa na potvrdenie';

  @override
  String get deliv_noConfirm => 'Bez potvrdenia';

  @override
  String deliv_lastHeard(String name) {
    return '$name naposledy počuť';
  }

  @override
  String deliv_hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'pred $hours hodinami',
      one: 'pred 1 hodinou',
    );
    return '$_temp0';
  }

  @override
  String deliv_vDelivered(String name) {
    return 'Doručené. $name to potvrdil.';
  }

  @override
  String deliv_vDeliveredFlood(String name) {
    return 'Doručené záplavou po zlyhaní priamych pokusov. Uložená trasa k $name môže byť zastaraná.';
  }

  @override
  String deliv_vPending(int attempt, int total) {
    return 'Stále sa skúša: pokus $attempt z $total.';
  }

  @override
  String get deliv_vNotSent =>
      'Rádio túto správu nikdy neprijalo. Skontrolujte pripojenie a skúste znova.';

  @override
  String deliv_vQuiet(String name, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hodín',
      few: '$hours hodiny',
      one: '1 hodinu',
    );
    return 'Bez potvrdenia. $name nebolo počuť $_temp0, môže byť mimo dosahu alebo vypnutý.';
  }

  @override
  String get deliv_vNoFlood =>
      'Bez potvrdenia cez uloženú trasu a pokusy záplavou sú vypnuté. Zapnite ich v Nastavenia → Nastavenia aplikácie → Správy alebo skúste znova.';

  @override
  String get deliv_vNoAck =>
      'Žiadne potvrdenie z žiadnej trasy. Môže byť mimo dosahu alebo sa potvrdenie nedostalo späť k vám.';

  @override
  String get favReturn_setting => 'Obľúbené opäť v dosahu';

  @override
  String get favReturn_settingHint =>
      'Upozorniť, keď je obľúbený kontakt po období ticha opäť počuť';

  @override
  String get favReturn_off => 'Vyp.';

  @override
  String favReturn_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Po $count hodinách',
      one: 'Po 1 hodine',
    );
    return '$_temp0';
  }

  @override
  String get favReturn_title => 'Opäť v dosahu';

  @override
  String favReturn_body(String name, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hodinách',
      one: '1 hodine',
    );
    return '$name je opäť počuť po $_temp0 ticha';
  }

  @override
  String get batteryOpt_title => 'Optimalizácia batérie';

  @override
  String get batteryOpt_off =>
      'Pre NOTORYX Core vypnutá, takže upozornenia fungujú aj na pozadí.';

  @override
  String get batteryOpt_on =>
      'Zapnutá. Android môže aplikáciu na pozadí zastaviť, takže upozornenia na SOS, prihlásenia a správy môžu meškať alebo sa stratiť.';

  @override
  String get batteryOpt_fix => 'Vypnúť';

  @override
  String block_sender(String name) {
    return 'Blokovať $name';
  }

  @override
  String get block_confirmBody =>
      'Jeho správy v kanáloch sa v tomto zariadení skryjú a nikdy vás neupozornia. Stále vidí vaše správy. Odblokovať ho môžete v Nastaveniach.';

  @override
  String get block_action => 'Blokovať';

  @override
  String block_done(String name) {
    return '$name zablokovaný';
  }

  @override
  String get mention_suggestions => 'Návrhy mien';

  @override
  String get block_listTitle => 'Zablokovaní odosielatelia';

  @override
  String get block_listHint =>
      'Správy od týchto mien sa v kanáloch skrývajú a nikdy vás neupozornia.';

  @override
  String get block_listEmpty => 'Nikto nie je zablokovaný.';

  @override
  String get block_unblock => 'Odblokovať';

  @override
  String block_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zablokovaných',
      few: '$count zablokovaní',
      one: '1 zablokovaný',
      zero: 'Nikto nie je zablokovaný',
    );
    return '$_temp0';
  }

  @override
  String contactTable_nearlyFull(int percent) {
    return 'Zoznam kontaktov rádia je plný na $percent %';
  }

  @override
  String get contactTable_full => 'Zoznam kontaktov rádia je plný';

  @override
  String contactTable_count(int used, int max) {
    return '$used z $max kontaktov';
  }

  @override
  String get contactTable_overwriteHint =>
      'Keď je plný, rádio nahradí kontakt počutý najdávnejšie. Obľúbené zostanú.';

  @override
  String get contactTable_stopHint =>
      'Keď je plný, rádio prestane pridávať novo počuté kontakty.';

  @override
  String get contactTable_freeUp => 'Uvoľniť miesto';

  @override
  String get contactTable_sheetBody =>
      'Najprv najdávnejšie počuté. Obľúbené nie sú uvedené.';

  @override
  String contactTable_lastHeard(String when) {
    return 'Naposledy počutý $when';
  }

  @override
  String contactTable_remove(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstrániť $count kontaktov',
      few: 'Odstrániť $count kontakty',
      one: 'Odstrániť 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get contactTable_confirmBody =>
      'Odstránia sa z rádia a ich správy v tomto zariadení sa vymažú. Nedá sa to vrátiť späť.';

  @override
  String contactTable_removed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstránených $count kontaktov',
      few: 'Odstránené $count kontakty',
      one: 'Odstránený 1 kontakt',
    );
    return '$_temp0';
  }

  @override
  String get contactTable_noneToSuggest =>
      'Všetky kontakty sú obľúbené, preto nie je čo navrhnúť.';

  @override
  String get adminWait_waiting => 'Čaká sa na odpoveď';

  @override
  String adminWait_retrying(int attempt, int total) {
    return 'Zatiaľ bez odpovede. Nový pokus ($attempt z $total)';
  }

  @override
  String adminWait_direct(int hops) {
    String _temp0 = intl.Intl.pluralLogic(
      hops,
      locale: localeName,
      other: 'Priamo, $hops skokov',
      few: 'Priamo, $hops skoky',
      one: 'Priamo, 1 skok',
      zero: 'Priamo',
    );
    return '$_temp0';
  }

  @override
  String adminWait_upTo(int seconds) {
    return 'až $seconds s';
  }

  @override
  String get theme_descBlaze => 'Antracit a bridlica so signálnou oranžovou';

  @override
  String get theme_descNeonAnarchy =>
      'Toxická zelená a elektrická fialová na čiernej';

  @override
  String get theme_descTactical => 'Olivová, oceľovo šedá a zemité tóny';

  @override
  String get theme_descPinkOverload => 'Sýto ružová, žuvačková a levanduľová';

  @override
  String get theme_descBareBeauty => 'Teplý nude, staroružová, kakao a šalvia';

  @override
  String get theme_descOkabeIto =>
      'Bezpečné pre farboslepých, vysoká čitateľnosť';

  @override
  String get theme_descNightOps =>
      'Tlmené červené na takmer čiernej pre slabé svetlo';

  @override
  String get theme_descSeasonal => 'Mení sa s ročnými obdobiami a sviatkami';

  @override
  String get theme_selected => 'Vybrané';

  @override
  String get seasonal_season => 'Ročné obdobie';

  @override
  String seasonal_auto(String season) {
    return 'Automaticky (teraz $season)';
  }

  @override
  String get seasonal_autoHint =>
      'Podľa dátumu zariadenia, s ročnými obdobiami severnej pologule';

  @override
  String get season_spring => 'Jar';

  @override
  String get season_summer => 'Leto';

  @override
  String get season_autumn => 'Jeseň';

  @override
  String get season_winter => 'Zima';

  @override
  String get season_halloween => 'Halloween';

  @override
  String get season_christmas => 'Vianoce';

  @override
  String get season_valentine => 'Valentín';

  @override
  String get seasonal_holidays => 'Sviatočné farby';

  @override
  String get seasonal_holidaysHint =>
      'Halloween, Vianoce a Valentín v ich termínoch';

  @override
  String get coords_setting => 'Formát súradníc';

  @override
  String get coords_decimal => 'Desatinné stupne';

  @override
  String get coords_dms => 'Stupne, minúty, sekundy';

  @override
  String get coords_utm => 'UTM';

  @override
  String get coords_mgrs => 'MGRS';

  @override
  String get coords_copyTitle => 'Kopírovať polohu';

  @override
  String coords_copied(String format) {
    return 'Skopírované ako $format';
  }

  @override
  String pathHash_badge(int width) {
    return 'Trasa používa $width-bajtové hashe cesty';
  }

  @override
  String pathHash_mismatch(int width) {
    return 'Vaše rádio používa $width bajty';
  }

  @override
  String get lite_qrPasteHint =>
      'Táto verzia nemá skener s kamerou. Vložte namiesto toho text z QR kódu.';

  @override
  String get lite_qrPasteLabel => 'Text QR kódu';

  @override
  String get theme_darkMode => 'Iná téma v tmavom režime';

  @override
  String get theme_darkModeHint =>
      'Používať inú tému, kým je zariadenie v tmavom režime';

  @override
  String get theme_darkModeTheme => 'Téma tmavého režimu';

  @override
  String get batteryWatch_title => 'Sledovanie batérií';

  @override
  String get batteryWatch_toolSubtitle =>
      'Batérie opakovačov za posledných 30 dní';

  @override
  String get batteryWatch_empty =>
      'Zatiaľ žiadne hodnoty batérií opakovačov. Otvorte Stav alebo Telemetriu opakovača a jeho hodnoty sa tu uchovajú 30 dní.';

  @override
  String get batteryWatch_note =>
      'Hodnoty pochádzajú z odpovedí Stav a Telemetria, o ktoré požiadate. Nič navyše sa nevysiela.';

  @override
  String get batteryWatch_statusLow => 'Slabá batéria';

  @override
  String get batteryWatch_statusFalling => 'Rýchlo klesá';

  @override
  String get batteryWatch_statusQuiet => 'Žiadna nedávna hodnota';

  @override
  String get batteryWatch_statusOk => 'V poriadku';

  @override
  String get batteryWatch_statusUnknown => 'Zatiaľ málo hodnôt';

  @override
  String batteryWatch_emptyIn(String days) {
    return 'Pri tomto tempe vybitá asi o $days dní';
  }

  @override
  String batteryWatch_trend(String volts) {
    return '$volts V za deň za posledný týždeň';
  }

  @override
  String batteryWatch_lastReading(String age) {
    return 'Posledná hodnota: $age';
  }

  @override
  String batteryWatch_readings(int count) {
    return 'Hodnoty za 30 dní: $count';
  }

  @override
  String get batteryWatch_history => 'História batérie';

  @override
  String batteryWatch_chartLabel(int count, String low, String high) {
    return 'Graf batérie: $count hodnôt, medzi $low V a $high V';
  }

  @override
  String get batteryWatch_clear => 'Vymazať históriu';

  @override
  String get batteryWatch_unknownRepeater => 'Neznámy opakovač';

  @override
  String get batteryWatch_cleared => 'História vymazaná';

  @override
  String get a11y_clear => 'Vymazať';

  @override
  String get a11y_showOnMap => 'Zobraziť na mape';

  @override
  String get a11y_showHide => 'Zobraziť alebo skryť';

  @override
  String get a11y_flash => 'Blesk';

  @override
  String get a11y_switchCamera => 'Prepnúť kameru';

  @override
  String get a11y_pauseGif => 'Prehrať alebo pozastaviť GIF';

  @override
  String get a11y_chooseGif => 'Vybrať tento GIF';

  @override
  String get privacy_title => 'Súkromie';

  @override
  String get privacy_toolSubtitle => 'Čo vidí sieť, tento telefón a internet';

  @override
  String get privacy_meshHeading => 'V sieti';

  @override
  String get privacy_dmTitle => 'Priame správy';

  @override
  String get privacy_dmBody =>
      'Šifrované medzi vaším rádiom a rádiom príjemcu. Opakovače ich posúvajú ďalej, ale prečítať ich nevedia. Krátke ID odosielateľa a príjemcu a trasa sú nešifrované.';

  @override
  String get privacy_channelTitle => 'Kanály';

  @override
  String get privacy_channelBody =>
      'Šifrované kľúčom kanála: kto má kľúč, prečíta každú správu. Kľúče verejných a hashtagových kanálov pozná každý, preto ich berte ako verejné.';

  @override
  String get privacy_advertTitle => 'Ohlásenia a polohy';

  @override
  String get privacy_advertBody =>
      'Názov a verejný kľúč rádia a jeho poloha, ak ju zdieľate, sa vysielajú nešifrovane všetkým v dosahu.';

  @override
  String get privacy_phoneHeading => 'Na tomto telefóne';

  @override
  String get privacy_phoneBody =>
      'Správy, kontakty, trasy, záznamy, body, história batérií a nastavenia zostávajú v súkromnom úložisku aplikácie, chránené len zabezpečením telefónu. Čo exportujete, prečíta každý, kto má súbor.';

  @override
  String get privacy_netHeading => 'Cez internet';

  @override
  String get privacy_netIntro =>
      'Len keď použijete funkciu, ktorá to potrebuje. Každá požiadavka ukáže službe vašu IP adresu a čo sa žiadalo.';

  @override
  String get privacy_netMaps =>
      'Mapy: dlaždice z OpenStreetMap alebo, ak ho zvolíte, Stadia Maps pre zobrazenú oblasť.';

  @override
  String get privacy_netTerrain =>
      'Terén: nadmorské výšky z Open-Meteo pre pokrytie a priamu viditeľnosť.';

  @override
  String get privacy_netModels =>
      'Sťahovanie: modely na preklad a obrázky z Hugging Face.';

  @override
  String get privacy_netImages =>
      'Obrázky: hľadanie GIF v Giphy a obrázky z odkazov pyx.li v správach.';

  @override
  String get privacy_netLists =>
      'Zoznamy: regionálne predvoľby a adresár kanálov z GitHub repozitára vydaní aplikácie.';

  @override
  String get privacy_netMqtt =>
      'MQTT: len brokery, ktoré pridáte. Ak zapnete nahrávanie, pakety, ktoré rádio počuje, sa tam zverejnia. Heslá sú v zabezpečenom úložisku telefónu.';

  @override
  String get privacy_netAnalyzer =>
      'Analyzátor: dotazy CoreScope (kto počul paket, názvy opakovačov), keď ich použijete.';

  @override
  String get privacy_notHeading => 'Čo NOTORYX nerobí';

  @override
  String get privacy_notBody =>
      'Žiadny účet, analytika, reklamy ani hlásenia o pádoch. Vývojári nedostanú nič, pokiaľ to sami nepošlete.';

  @override
  String get team_title => 'Sledovanie tímu';

  @override
  String get team_hint =>
      'Kým je výlet aktívny, zdieľa vašu polohu v súkromnom kanáli, aby vás tím videl na mape. Vypne sa na konci výletu alebo po 12 hodinách.';

  @override
  String get team_channel => 'Kanál';

  @override
  String get team_noChannel =>
      'Najprv pridajte súkromný kanál. Sledovanie nikdy neposiela do verejných ani hashtagových kanálov.';

  @override
  String get team_every => 'Každých';

  @override
  String team_minutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get team_needTrip => 'Začnite výlet, aby ste zdieľali polohu.';

  @override
  String team_lastShared(String age) {
    return 'Naposledy zdieľané $age';
  }

  @override
  String get team_waitingGps => 'Čaká sa na polohu z rádia';

  @override
  String get checklist_title => 'Kontrolné zoznamy';

  @override
  String get checklist_toolSubtitle =>
      'Opakovane použiteľné zoznamy pred túrou a na nasadenie, fungujú offline';

  @override
  String get checklist_empty => 'Žiadne zoznamy. Pridaj tlačidlom nižšie.';

  @override
  String get checklist_add => 'Nový zoznam';

  @override
  String get checklist_edit => 'Upraviť zoznam';

  @override
  String get checklist_name => 'Názov';

  @override
  String get checklist_items => 'Položky, jedna na riadok';

  @override
  String checklist_itemCount(int count) {
    return 'Položky: $count';
  }

  @override
  String get checklist_history => 'Dokončené kontroly';

  @override
  String get checklist_noRuns => 'Zatiaľ žiadne dokončené kontroly.';

  @override
  String get checklist_inProgress => 'Prebieha';

  @override
  String checklist_progress(int done, int total) {
    return 'Hotovo $done z $total';
  }

  @override
  String checklist_startedAt(String time) {
    return 'Začaté $time';
  }

  @override
  String checklist_finishedAt(String time) {
    return 'Dokončené $time';
  }

  @override
  String get checklist_note => 'Poznámka';

  @override
  String get checklist_finish => 'Dokončiť a uložiť';

  @override
  String get checklist_unfinished =>
      'Niektoré položky nie sú odškrtnuté. Uložiť aj tak?';

  @override
  String get checklist_saveAnyway => 'Uložiť aj tak';

  @override
  String get checklist_export => 'Exportovať alebo odstrániť';

  @override
  String get checklist_exportText => 'Zdieľať ako text';

  @override
  String get checklist_exportJson => 'Zdieľať ako JSON';

  @override
  String get checklist_exportFailed => 'Záznam sa nepodarilo zdieľať.';

  @override
  String get checklist_deleteRun => 'Odstrániť záznam';

  @override
  String get checklist_deleteRunConfirm =>
      'Odstrániť tento záznam? Nedá sa to vrátiť.';

  @override
  String checklist_deleteConfirm(String name) {
    return 'Odstrániť $name? Dokončené záznamy zostanú.';
  }

  @override
  String get checklist_preTrip => 'Pred túrou';

  @override
  String get checklist_preTrip1 => 'Rádio nabité, náhradná batéria zbalená';

  @override
  String get checklist_preTrip2 =>
      'Rádio spárované s telefónom, testovacia správa odoslaná';

  @override
  String get checklist_preTrip3 => 'Offline mapy oblasti uložené';

  @override
  String get checklist_preTrip4 => 'Trasa a čas návratu nechané niekomu doma';

  @override
  String get checklist_preTrip5 =>
      'Skupinový kanál a kontakty tímu skontrolované';

  @override
  String get checklist_preTrip6 => 'SOS a prihlásenie raz vyskúšané';

  @override
  String get checklist_deploy => 'Inštalácia uzla';

  @override
  String get checklist_deploy1 => 'Miesto a povolenie potvrdené';

  @override
  String get checklist_deploy2 => 'Anténa namontovaná, konektory utesnené';

  @override
  String get checklist_deploy3 => 'Napájanie a solár skontrolované';

  @override
  String get checklist_deploy4 => 'Nastavenia rádia a región potvrdené';

  @override
  String get checklist_deploy5 => 'Testovacia správa prešla cez uzol';

  @override
  String get checklist_deploy6 => 'Poloha, fotky a poznámky zaznamenané';

  @override
  String get waypoints_title => 'Body trasy';

  @override
  String get waypoints_toolSubtitle =>
      'Uložené miesta a trasy; import a export GPX';

  @override
  String get waypoints_importFile => 'Importovať súbor GPX';

  @override
  String get waypoints_importPaste => 'Vložiť GPX';

  @override
  String get waypoints_export => 'Exportovať GPX';

  @override
  String get waypoints_empty =>
      'Zatiaľ žiadne body. Importujte súbor GPX alebo uložte miesto zdieľané v chate.';

  @override
  String waypoints_waypoints(int count) {
    return 'Body ($count)';
  }

  @override
  String waypoints_routes(int count) {
    return 'Trasy ($count)';
  }

  @override
  String waypoints_routeSummary(int points, String km) {
    return '$points bodov · $km km';
  }

  @override
  String get waypoints_delete => 'Odstrániť';

  @override
  String get waypoints_copy => 'Kopírovať súradnice';

  @override
  String get waypoints_sendToChannel => 'Poslať do kanála';

  @override
  String get waypoints_pickChannel => 'Do ktorého kanála poslať?';

  @override
  String waypoints_sent(String channel) {
    return 'Odoslané do $channel';
  }

  @override
  String get waypoints_importFailed =>
      'Toto nie je súbor GPX, ktorý aplikácia vie prečítať.';

  @override
  String get waypoints_pasteHint => 'Sem vložte text GPX';

  @override
  String get waypoints_import => 'Importovať';

  @override
  String waypoints_imported(int waypoints, int routes) {
    return 'Pridané body: $waypoints, trasy: $routes';
  }

  @override
  String get waypoints_save => 'Uložiť ako bod';

  @override
  String get waypoints_unnamed => 'Zdieľané miesto';

  @override
  String get waypoints_saved => 'Uložené v Bodoch trasy';

  @override
  String get waypoints_alreadySaved => 'Už je v Bodoch trasy';

  @override
  String get netChange_title => 'Zmeny v sieti';

  @override
  String get netChange_toolSubtitle =>
      'Opakovače, ktoré sa objavili nablízku alebo stíchli';

  @override
  String netChange_newDirect(String name) {
    return 'Nový opakovač počutý priamo: $name';
  }

  @override
  String netChange_newHops(String name, int hops) {
    return 'Nový opakovač $hops skok ďaleko: $name';
  }

  @override
  String netChange_wentQuiet(String name, int hours) {
    return '$name stíchol: nepočuť $hours h';
  }

  @override
  String get netChange_empty =>
      'Zatiaľ žiadne zmeny. Tu sa zobrazia obľúbené opakovače, ktoré stíchnu, a nové opakovače nablízku.';

  @override
  String get netChange_quietSetting => 'Obľúbený opakovač stíchne';

  @override
  String get netChange_quietHint =>
      'Upozorniť, keď obľúbený opakovač nepočuť tak dlho';

  @override
  String get netChange_newSetting => 'Nový opakovač nablízku';

  @override
  String get netChange_newHint =>
      'Upozorniť, keď je neznámy opakovač počuť do jedného skoku';

  @override
  String get netChange_clear => 'Vymazať';

  @override
  String get netChange_notifTitle => 'Zmena v sieti';

  @override
  String get journal_title => 'Denník uzlov';

  @override
  String get journal_toolSubtitle =>
      'Každý počutý uzol so štítkami správania, značkami a poznámkami';

  @override
  String get journal_empty =>
      'Zatiaľ žiadne uzly. Každý uzol, ktorý rádio začuje, sa sem pridá automaticky.';

  @override
  String get journal_search => 'Hľadať mená, ID, značky a poznámky';

  @override
  String get journal_filterAll => 'Všetky';

  @override
  String get journal_bSteadyRelay => 'Stále zapnutý prenos';

  @override
  String get journal_bRegular => 'Pravidelný';

  @override
  String get journal_bRoamer => 'Tulák';

  @override
  String get journal_bRarelyHeard => 'Zriedka počuť';

  @override
  String get journal_bNewcomer => 'Nováčik';

  @override
  String get journal_bGoneQuiet => 'Utíchol';

  @override
  String journal_confidence(int percent) {
    return 'Istota $percent %';
  }

  @override
  String journal_eDaysHeard(int heard, int days) {
    return 'Počuť $heard z $days dní';
  }

  @override
  String journal_eFirstHeard(int hours) {
    return 'Prvýkrát počuť pred $hours h';
  }

  @override
  String journal_eSilent(int days) {
    return 'Nepočuť $days dní';
  }

  @override
  String journal_ePlaces(int places, int km) {
    return 'Videný na $places miestach vzdialených až $km km';
  }

  @override
  String journal_eSightings(int count) {
    return 'Spolu $count nových oznámení';
  }

  @override
  String get journal_noLabel => 'Zatiaľ málo údajov na štítok.';

  @override
  String journal_firstSeen(String time) {
    return 'Prvýkrát: $time';
  }

  @override
  String journal_lastSeen(String time) {
    return 'Naposledy: $time';
  }

  @override
  String journal_hops(int min, int max) {
    return 'Skoky: $min až $max';
  }

  @override
  String get journal_tags => 'Značky';

  @override
  String get journal_addTag => 'Pridať značku';

  @override
  String get journal_tagHint => 'napr. chodník, klub, môj';

  @override
  String journal_removeTag(String tag) {
    return 'Odstrániť značku $tag';
  }

  @override
  String get journal_note => 'Poznámka';

  @override
  String get journal_saveNote => 'Uložiť poznámku';

  @override
  String get journal_forget => 'Zabudnúť tento uzol';

  @override
  String journal_forgetConfirm(String name) {
    return 'Odstrániť $name z denníka aj so značkami a poznámkou? Ak ho znova začuješ, začne sa odznova.';
  }

  @override
  String get journal_forgotten => 'Uzol odstránený z denníka.';

  @override
  String journal_markLabel(String name) {
    return 'Vygenerovaná značka pre $name';
  }

  @override
  String get trouble_title => 'Riešenie problémov';

  @override
  String get trouble_toolSubtitle =>
      'Pomoc krok za krokom, keď niečo nefunguje';

  @override
  String get trouble_pick => 'Čo je zle?';

  @override
  String get trouble_noDelivery => 'Správy sa nedoručujú';

  @override
  String get trouble_noConnect => 'Neviem sa pripojiť k rádiu';

  @override
  String get trouble_hearNobody => 'Nikoho nepočujem';

  @override
  String get trouble_startHere => 'Začnite tu';

  @override
  String get trouble_resultOk => 'OK';

  @override
  String get trouble_resultProblem => 'Problém';

  @override
  String get trouble_resultUnchecked => 'Nedá sa overiť';

  @override
  String get trouble_connectedNow =>
      'Teraz ste pripojení. Ak spojenie stále padá, kroky nižšie aj tak pomôžu.';

  @override
  String get trouble_allOk =>
      'Všetky kontroly prešli. Ak to stále nefunguje, pozrite si kroky nižšie.';

  @override
  String get trouble_connected => 'Vaše rádio je pripojené';

  @override
  String get trouble_connectedAdvice =>
      'Najprv pripojte rádio: Nastavenia → Pripojiť rádio.';

  @override
  String get trouble_routes => 'K ľuďom, ktorým píšete, sú známe trasy';

  @override
  String get trouble_routesAdvice =>
      'Správy niekomu bez známej trasy zaplavia celú sieť a často nedorazia. Počkajte, kým sa ohlási, alebo ho o to požiadajte, a napíšte znova.';

  @override
  String get trouble_heardRecently =>
      'Ľudí, ktorým píšete, bolo počuť za posledný deň';

  @override
  String get trouble_heardRecentlyAdvice =>
      'Kto nebol dlho počuť, môže byť mimo dosahu alebo vypnutý. Jeho správy sa nepotvrdia, kým sa nevráti.';

  @override
  String get trouble_neighbours => 'Vaše rádio počuje iné uzly';

  @override
  String get trouble_neighboursAdvice =>
      'Ak nič nepočuť priamo, rádio odtiaľto nedosiahne sieť. Zdvihnite anténu, choďte vyššie alebo bližšie k opakovaču.';

  @override
  String get trouble_bluetooth =>
      'Bluetooth je zapnutý a aplikácia ho smie používať';

  @override
  String get trouble_bluetoothAdvice =>
      'Skontrolujte, či je Bluetooth zapnutý a či má NOTORYX Core v nastaveniach telefónu povolenie Bluetooth (a v Androide Zariadenia v okolí).';

  @override
  String get trouble_otherApp =>
      'Žiadny iný telefón ani aplikácia nie je pripojená k rádiu';

  @override
  String get trouble_otherAppAdvice =>
      'Rádio komunikuje naraz len s jednou aplikáciou. Zatvorte iné aplikácie MeshCore alebo vypnite Bluetooth na iných spárovaných telefónoch.';

  @override
  String get trouble_inRange => 'Rádio je zapnuté a nablízku';

  @override
  String get trouble_inRangeAdvice =>
      'Skontrolujte, či je rádio nabité, zapnuté a pár metrov od vás. Reštart rádia často vyrieši zaseknuté spojenie.';

  @override
  String get trouble_otherTransport => 'Skúste iný spôsob pripojenia';

  @override
  String get trouble_otherTransportAdvice =>
      'Ak Bluetooth stále zlyháva, pripojte sa USB káblom alebo cez Wi-Fi (TCP), ak to rádio podporuje.';

  @override
  String get trouble_noise => 'Rádio sa neutápa v šume';

  @override
  String get trouble_noiseAdvice =>
      'Vysoká úroveň šumu skrýva slabé signály. Dajte anténu ďalej od elektroniky, nabíjačiek a solárnych regulátorov.';

  @override
  String get trouble_region => 'Rádio používa nastavenia vašej oblasti';

  @override
  String get trouble_regionAdvice =>
      'S inou frekvenciou, šírkou pásma alebo rozprestieracím faktorom než miestna sieť nikoho nepočujete. Porovnajte Nastavenia → Rádio s tým, čo používa vaša oblasť.';

  @override
  String get trouble_antenna => 'Anténa je nasadená';

  @override
  String get trouble_antennaAdvice =>
      'Uistite sa, že anténa je pevne priskrutkovaná. Nikdy nevysielajte bez nej; môže to poškodiť rádio.';

  @override
  String get mesh_title => 'Stav siete';

  @override
  String get mesh_overallGood => 'Sieť vyzerá v poriadku';

  @override
  String get mesh_overallFair => 'Sieť funguje, ale s problémami';

  @override
  String get mesh_overallPoor => 'Sieť má problémy';

  @override
  String get mesh_overallUnknown => 'Zatiaľ málo údajov';

  @override
  String get mesh_gradeGood => 'Dobrý';

  @override
  String get mesh_gradeFair => 'Priemerný';

  @override
  String get mesh_gradePoor => 'Slabý';

  @override
  String get mesh_gradeUnknown => 'Bez údajov';

  @override
  String get mesh_noise => 'Šum';

  @override
  String mesh_noiseValue(String dbm) {
    return 'Úroveň šumu $dbm dBm';
  }

  @override
  String get mesh_signal => 'Posledný signál';

  @override
  String mesh_signalValue(String db) {
    return 'SNR $db dB';
  }

  @override
  String get mesh_busy => 'Využitie kanála';

  @override
  String mesh_busyValue(int percent) {
    return 'vo vysielaní $percent % z posledných 15 minút';
  }

  @override
  String get mesh_neighbours => 'Počuté priamo';

  @override
  String mesh_neighboursValue(int count) {
    return '$count uzlov za poslednú hodinu';
  }

  @override
  String get mesh_delivery => 'Priame správy';

  @override
  String mesh_deliveryValue(int delivered, int total) {
    return 'doručené $delivered z $total za posledný deň';
  }

  @override
  String get mesh_tipNoise =>
      'Niečo v blízkosti šumí na tejto frekvencii. Dajte anténu ďalej od elektroniky a nabíjačiek.';

  @override
  String get mesh_tipSignal =>
      'Posledný paket bol slabý. Zdvihnite anténu alebo choďte vyššie.';

  @override
  String get mesh_tipBusy =>
      'Kanál je vyťažený. Píšte stručne a vyhnite sa zaplavovaniu.';

  @override
  String get mesh_tipNeighbours =>
      'Priamo počuť málo uzlov. Zdvihnite anténu alebo sa priblížte k opakovaču.';

  @override
  String get mesh_tipDelivery =>
      'Mnoho správ nie je potvrdených. Otvorte neúspešnú správu a pozrite, kde sa zastavila.';

  @override
  String routeHealth_staleTitle(String name) {
    return 'Trasa k $name môže byť zastaraná';
  }

  @override
  String routeHealth_weakTitle(String name) {
    return 'Trasa k $name je nespoľahlivá';
  }

  @override
  String routeHealth_lastWorkedHours(int hours) {
    return 'naposledy fungovala pred $hours h';
  }

  @override
  String routeHealth_lastWorkedDays(int days) {
    return 'naposledy fungovala pred $days dňami';
  }

  @override
  String routeHealth_notHeard(int days) {
    return 'nepočuť $days dní';
  }

  @override
  String routeHealth_failures(int failures, int attempts) {
    return '$failures z $attempts pokusov zlyhalo';
  }

  @override
  String routeHealth_longPath(int hops) {
    return '$hops skokov';
  }

  @override
  String get routeHealth_useFlood => 'Nájsť novú trasu';

  @override
  String get routeHealth_keep => 'Ponechať trasu';

  @override
  String get readiness_sos => 'Príjemcovia SOS';

  @override
  String get readiness_sosOk => 'SOS má príjemcov.';

  @override
  String get readiness_sosBlocked =>
      'SOS nemá komu poslať. Pridajte účastníkov výletu zo svojich kontaktov alebo nastavte SOS kanál.';

  @override
  String get readiness_routes => 'Trasy k účastníkom';

  @override
  String get readiness_routesOk => 'Ku každému účastníkovi je známa trasa.';

  @override
  String readiness_routesMissing(String names) {
    return 'K $names nie je známa trasa. Správy sa budú šíriť zaplavením, kým sa trasa nenaučí. Pošlite im správu pred odchodom.';
  }

  @override
  String get readiness_notifications => 'Upozornenia';

  @override
  String get readiness_notificationsOk => 'Povolené.';

  @override
  String get readiness_notificationsOff =>
      'Upozornenia sú vypnuté, takže nebudete počuť odpovede, hlásenia ani výstrahy.';

  @override
  String get readiness_batteryOpt => 'Optimalizácia batérie';

  @override
  String get readiness_batteryOptOk => 'NOTORYX Core je vyňatý.';

  @override
  String get readiness_batteryOptOn =>
      'Android môže aplikáciu na pozadí zastaviť. Vypnite to v Nastavenia → Nastavenia aplikácie → Upozornenia.';

  @override
  String get readiness_blockedTitle => 'Výlet sa ešte nedá začať';

  @override
  String readiness_warnTitle(int count) {
    return '$count vecí na kontrolu';
  }

  @override
  String get readiness_startAnyway => 'Začať aj tak';

  @override
  String get readiness_review => 'Skontrolovať';

  @override
  String get readiness_summaryReady => 'Pripravené na cestu';

  @override
  String readiness_summaryWarn(int count) {
    return '$count na kontrolu';
  }

  @override
  String get readiness_summaryBlocked => 'SOS sa k nikomu nedostane';

  @override
  String get coords_maidenhead => 'Lokátor Maidenhead';

  @override
  String get reactions_radioTitle => 'Posielať reakcie rádiom';

  @override
  String get reactions_radioHint =>
      'Každá reakcia je paket vo vzduchu. Automaticky ich v pásme EÚ 868 MHz, kde je vysielací čas obmedzený, necháva len na tomto zariadení.';

  @override
  String get reactions_radioAuto => 'Automaticky';

  @override
  String get reactions_radioOn => 'Zap.';

  @override
  String get reactions_radioOff => 'Vyp. (toto zariadenie)';

  @override
  String get batteryWatch_auto => 'Kontrolovať automaticky';

  @override
  String get batteryWatch_autoHint =>
      'Kým je pripojené rádio, aplikácia sa pravidelne pýta opakovača na batériu. Odpovie len vtedy, ak ste prihlásení.';

  @override
  String get batteryWatch_interval => 'Kontrolovať každých';

  @override
  String batteryWatch_hours(int hours) {
    return '$hours h';
  }

  @override
  String get batteryWatch_budget =>
      'Najviac 6 kontrol za hodinu pre všetky opakovače, aspoň 2 minúty od seba.';

  @override
  String get batteryWatch_add => 'Pridať opakovač';

  @override
  String get batteryWatch_pick => 'Vyberte opakovač na sledovanie';

  @override
  String get batteryWatch_noRepeaters =>
      'V kontaktoch zatiaľ nie sú opakovače.';

  @override
  String batteryWatch_noReply(int count) {
    return 'Žiadna odpoveď na posledných $count kontrol. Otvorte opakovač a prihláste sa znova.';
  }

  @override
  String get batteryWatch_checking => 'Kontroluje sa…';

  @override
  String get batteryWatch_alertTitle => 'Batéria opakovača';

  @override
  String batteryWatch_alertLow(String name, int percent, String volts) {
    return '$name je na $percent % ($volts V).';
  }

  @override
  String batteryWatch_alertFalling(String name, String days) {
    return 'Batéria $name rýchlo klesá: pri tomto tempe vybitá asi o $days dní.';
  }

  @override
  String batteryWatch_alertSilent(String name, int count) {
    return '$name neodpovedal na $count kontrol batérie.';
  }

  @override
  String get security_title => 'Zabezpečenie';

  @override
  String get security_toolSubtitle =>
      'Zámok aplikácie a šifrovaná história správ';

  @override
  String get appLock_title => 'Zámok aplikácie';

  @override
  String get appLock_subtitle =>
      'Pri otvorení vyžaduje odtlačok, tvár alebo zámok obrazovky. Upozornenia fungujú ďalej a SOS zostáva na uzamknutej obrazovke.';

  @override
  String get appLock_reason => 'Odomknúť NOTORYX Core';

  @override
  String get appLock_unlock => 'Odomknúť';

  @override
  String get appLock_locked => 'NOTORYX Core je zamknutý';

  @override
  String get appLock_unavailable =>
      'Toto zariadenie nemá zámok obrazovky alebo sa ho nepodarilo overiť.';

  @override
  String get dbEncrypt_title => 'Šifrovať históriu správ';

  @override
  String get dbEncrypt_subtitle =>
      'Šifruje databázu správ v tomto zariadení kľúčom v zabezpečenom úložisku telefónu. Pri strate kľúča históriu nemožno obnoviť, preto si uchovajte zálohu.';

  @override
  String get dbEncrypt_on => 'Stav: šifrované';

  @override
  String get dbEncrypt_off => 'Stav: nešifrované';

  @override
  String get dbEncrypt_failed => 'Stav: nepodarilo sa. História je nezmenená.';

  @override
  String get dbEncrypt_restart => 'Prejaví sa pri ďalšom spustení aplikácie.';

  @override
  String get map_showWaypoints => 'Zobraziť uložené body a trasy';

  @override
  String get appLock_sosNoTarget =>
      'Najprv odomknite a vyberte, kto dostane vaše SOS.';

  @override
  String get notification_replyAction => 'Odpovedať';

  @override
  String get notification_replyHint => 'Napíšte odpoveď';

  @override
  String outbox_waiting(int count) {
    return 'Čaká na rádio: $count';
  }

  @override
  String get outbox_cantQueue =>
      'Zatiaľ nebolo pripojené žiadne rádio, preto to nemožno uložiť na neskôr.';

  @override
  String get chat_forward => 'Preposlať';

  @override
  String get forward_title => 'Preposlať do';

  @override
  String get schedule_tooltip => 'Podržaním odošlete neskôr';

  @override
  String schedule_for(String time) {
    return 'Odoslanie: $time';
  }

  @override
  String get schedule_pastTime => 'Vyberte čas v budúcnosti.';

  @override
  String get report_open => 'Odoslať hlásenie';

  @override
  String get report_title => 'Terénne hlásenie';

  @override
  String get report_salute => 'SALUTE (čo ste videli)';

  @override
  String get report_nineLine => '9-Line (lekárska evakuácia)';

  @override
  String get report_send => 'Odoslať hlásenie';

  @override
  String report_parts(int count) {
    return 'Počet správ: $count';
  }

  @override
  String get report_sent => 'Hlásenie odoslané';

  @override
  String get contacts_addTooltip => 'Pridať kontakt';

  @override
  String get dbEncrypt_covers =>
      'Zahŕňa aj kontakty, kľúče kanálov, body trasy, uložené trasy, koncepty a čakajúce správy.';

  @override
  String get auto_title => 'Automatizácia';

  @override
  String get auto_add => 'Pridať pravidlo';

  @override
  String get auto_intro =>
      'Pravidlá fungujú len pri otvorenej aplikácii. Každé sa spustí, keď sa jeho podmienka začne plniť, najviac raz za 15 minút. Pravidlá odosielajúce správy sú spolu obmedzené na 3 odoslania za 10 minút a sú označené ako automatické.';

  @override
  String get auto_trigBattery => 'Batéria rádia klesne pod';

  @override
  String get auto_trigTime => 'Každý deň o';

  @override
  String get auto_trigEnter => 'Vstúpim do oblasti';

  @override
  String get auto_trigLeave => 'Opustím oblasť';

  @override
  String get auto_trigHeard => 'Uzol je znova počuť';

  @override
  String get auto_trigQuiet => 'Uzol stíchne';

  @override
  String auto_edit(String name) {
    return 'Upraviť $name';
  }

  @override
  String get auto_new => 'Nové pravidlo';

  @override
  String get auto_editTitle => 'Upraviť pravidlo';

  @override
  String get auto_delete => 'Odstrániť pravidlo';

  @override
  String get auto_needName => 'Pomenujte pravidlo.';

  @override
  String get auto_needArea => 'Zadajte zemepisnú šírku a dĺžku oblasti.';

  @override
  String get auto_needNode => 'Vyberte uzol.';

  @override
  String get auto_needMessage => 'Napíšte správu.';

  @override
  String get auto_needTarget => 'Vyberte príjemcu.';

  @override
  String get auto_name => 'Názov pravidla';

  @override
  String get auto_when => 'Kedy';

  @override
  String auto_below(int percent) {
    return 'Pod $percent %';
  }

  @override
  String get auto_time => 'Čas';

  @override
  String get auto_latitude => 'Šírka';

  @override
  String get auto_longitude => 'Dĺžka';

  @override
  String get auto_usePosition => 'Použiť polohu rádia';

  @override
  String auto_radius(int meters) {
    return 'Polomer: $meters m';
  }

  @override
  String get auto_node => 'Uzol';

  @override
  String auto_heardWithin(int minutes) {
    return 'Považuje sa za počutý do $minutes minút';
  }

  @override
  String get auto_notify => 'Upozorniť ma';

  @override
  String get auto_send => 'Odoslať správu';

  @override
  String get auto_sendTo => 'Odoslať komu';

  @override
  String get auto_message => 'Správa';

  @override
  String get auto_save => 'Uložiť';

  @override
  String get auto_entry => 'Pravidlá automatizácie';

  @override
  String get auto_entrySub => 'Spúšťače batérie, času, oblasti a uzla';

  @override
  String get teamSetup_title => 'Nastavenie tímu';

  @override
  String get teamSetup_toolSub => 'Zdieľať nastavenia rádia, kanály a trasy';

  @override
  String get teamSetup_share => 'Zdieľať';

  @override
  String get teamSetup_receive => 'Prijať';

  @override
  String get teamSetup_warning =>
      'Obsahuje kľúče kanálov. Ktokoľvek s týmto súborom alebo QR kódom a heslom môže čítať tieto kanály. Heslo oznámte osobne alebo inak, nikdy spolu so súborom.';

  @override
  String get teamSetup_radio => 'Nastavenia rádia';

  @override
  String get teamSetup_channels => 'Kanály a ich kľúče';

  @override
  String get teamSetup_notPublic => 'Bez verejného kanála';

  @override
  String get teamSetup_places => 'Body a trasy';

  @override
  String get teamSetup_passHint => 'Heslo (aspoň 12 znakov)';

  @override
  String get teamSetup_create => 'Vytvoriť';

  @override
  String get teamSetup_tooBig => 'Príliš veľa pre QR kód. Zdieľajte ako súbor.';

  @override
  String get teamSetup_shareFile => 'Zdieľať ako súbor';

  @override
  String get teamSetup_scanTitle => 'Skenovať nastavenie tímu';

  @override
  String get teamSetup_wrongPass => 'Nesprávne heslo alebo poškodený súbor.';

  @override
  String get teamSetup_notFile => 'Toto nie je platný tímový súbor.';

  @override
  String get teamSetup_openFile => 'Otvoriť súbor';

  @override
  String get teamSetup_scanQr => 'Skenovať QR kód';

  @override
  String get teamSetup_pass => 'Heslo';

  @override
  String get teamSetup_open => 'Otvoriť';

  @override
  String teamSetup_channelsList(String names) {
    return 'Kanály: $names';
  }

  @override
  String teamSetup_placesCount(int waypoints, int routes) {
    return 'Body: $waypoints, trasy: $routes';
  }

  @override
  String teamSetup_radioDetail(String details) {
    return 'Nastavenia rádia: $details';
  }

  @override
  String get teamSetup_radioWarn =>
      'Predvolene vypnuté. Overte, či sú u vás legálne. Iná frekvencia vás odpojí od súčasnej siete.';

  @override
  String get teamSetup_connectFirst =>
      'Pripojte rádio na pridanie kanálov alebo zmenu nastavení.';

  @override
  String get teamSetup_apply => 'Použiť';

  @override
  String teamSetup_done(String summary) {
    return 'Hotovo: $summary.';
  }

  @override
  String teamSetup_stopped(String summary, String error) {
    return 'Zastavené v polovici ($summary): $error';
  }

  @override
  String teamSetup_added(int count) {
    return 'Pridané kanály: $count';
  }

  @override
  String teamSetup_addedSkipped(int count, int left) {
    return 'Pridané kanály: $count. Už existujú alebo chýba miesto: $left';
  }

  @override
  String get teamSetup_radioChanged => 'nastavenia rádia zmenené';

  @override
  String get botUi_replyHint =>
      'Krátke odpovede šetria čas vysielania. Najviac 140 bajtov vrátane označenia bota.';

  @override
  String get botUi_shorterReply => 'Zadajte kratšiu, neprázdnu odpoveď.';

  @override
  String get botUi_addRule => 'Pridať pravidlo odpovede';

  @override
  String get botUi_editRule => 'Upraviť pravidlo odpovede';

  @override
  String get botUi_trigger => 'Príkaz alebo kľúčové slovo';

  @override
  String get botUi_reply => 'Odpoveď';

  @override
  String get botUi_matchAnywhere => 'Hľadať slovo kdekoľvek';

  @override
  String get botUi_matchHint =>
      'Vypnuté znamená presnú zhodu bez ohľadu na veľkosť písmen.';

  @override
  String get botUi_from => 'Od';

  @override
  String get botUi_anyContact => 'Ktorýkoľvek povolený kontakt';

  @override
  String get botUi_prevContact => 'Predtým vybraný kontakt';

  @override
  String get botUi_priority =>
      'Zapnuté vstavané príkazy majú prednosť. Pravidlá idú v poradí zoznamu.';

  @override
  String get botUi_needTrigger => 'Zadajte spúšťač a krátku neprázdnu odpoveď.';

  @override
  String get botUi_title => 'Režim bota NOTORYX';

  @override
  String get botUi_mode => 'Režim bota';

  @override
  String get botUi_loading => 'Načítavajú sa nastavenia…';

  @override
  String get botUi_off => 'Vypnutý';

  @override
  String get botUi_onDm => 'Zapnutý — počúva priame správy';

  @override
  String botUi_onDmChannels(int count) {
    return 'Zapnutý — počúva priame správy a kanály: $count';
  }

  @override
  String get botUi_onWaiting => 'Zapnutý — čaká na pripojenie rádia';

  @override
  String get botUi_intro =>
      'Zadarmo a lokálne. Funguje, kým je NOTORYX Core otvorený a pripojený k rádiu. Spánok telefónu alebo zatvorenie aplikácie môže odpovede zastaviť. Správy z vyrovnávacej pamäte a nahromadené pri pripojení sa ignorujú. Odpovede používajú bežný front odosielania.';

  @override
  String get botUi_away => 'Automatická odpoveď v neprítomnosti';

  @override
  String get botUi_awayReply => 'Odpoveď v neprítomnosti';

  @override
  String get botUi_info => 'Informácie o uzle / skupine';

  @override
  String get botUi_infoReply => 'Informačná odpoveď';

  @override
  String get botUi_checkIn => 'Odpoveď na ohlásenie';

  @override
  String get botUi_commands => 'Príkazy';

  @override
  String get botUi_allowWhere => 'Povoliť odpovede polohy !where';

  @override
  String get botUi_whereHint =>
      'Zdieľa súradnice oznamované rádiom s povolenými kontaktmi. Môžu byť zastarané. Predvolene vypnuté.';

  @override
  String get botUi_custom => 'Vlastné príkazy a pravidlá kľúčových slov';

  @override
  String get botUi_airtime => 'Riadenie času vysielania';

  @override
  String get botUi_cooldown => 'Pauza na kontakt';

  @override
  String botUi_minutes(int count) {
    return '$count minút';
  }

  @override
  String get botUi_maxReplies => 'Maximum odpovedí za minútu (všetky kontakty)';

  @override
  String get botUi_allowed => 'Povolené kontakty';

  @override
  String get botUi_allowedHint => 'Bez výberu znamená všetky známe kontakty.';

  @override
  String get botUi_recent => 'Nedávna aktivita (táto relácia)';

  @override
  String get botUi_noReplies => 'Zatiaľ žiadne odpovede bota.';

  @override
  String get a11y_jumpToBottom => 'Prejsť na najnovšiu správu';

  @override
  String a11y_cluster(int count) {
    return 'Uzly tu: $count. Priblížiť';
  }

  @override
  String get a11y_wardrivePing => 'Podrobnosti pingu';

  @override
  String get a11y_receivedImage => 'Prijatý obrázok';

  @override
  String get a11y_imagePreview => 'Náhľad obrázka';

  @override
  String get rcli_title => 'Povoliť vzdialený príkazový riadok?';

  @override
  String rcli_warning(String name) {
    return '$name bude môcť cez sieť spúšťať akýkoľvek príkaz na tvojom rádiu: meniť jeho názov, nastavenia rádia a heslá alebo ho reštartovať. Povoľ to len ľuďom, ktorým dôveruješ.';
  }

  @override
  String get rcli_allow => 'Povoliť';

  @override
  String get rcli_toggle => 'Povoliť vzdialený príkazový riadok';

  @override
  String get rcli_toggleHint =>
      'Umožní tomuto kontaktu spúšťať akýkoľvek príkaz na tvojom rádiu vrátane zmeny nastavení. MeshCore v1.18+.';

  @override
  String rcli_toggleBlocked(String command) {
    return 'Umožní tomuto kontaktu spúšťať akýkoľvek príkaz na tvojom rádiu. Naposledy zablokované: \"$command\".';
  }

  @override
  String get rcli_menu => 'Príkazový riadok na jeho rádiu';

  @override
  String rcli_runsOn(String name) {
    return 'Funguje na rádiu $name len vtedy, ak ti povolil vzdialený príkazový riadok (MeshCore v1.18+). Bez odpovede to bolo zablokované alebo to nedošlo.';
  }

  @override
  String get bk_title => 'Šifrovaná záloha';

  @override
  String get bk_intro =>
      'Uloží šifrovanú kópiu nastavení, kontaktov, kľúčov kanálov, bodov trasy a konceptov a ak chcete, aj históriu správ. Offline mapy, fotky a firmvér rádia nie sú zahrnuté.';

  @override
  String get bk_keep =>
      'Heslo uchovávaj oddelene. Stratené heslo sa nedá obnoviť.';

  @override
  String get bk_pass => 'Heslo (12+ znakov)';

  @override
  String get bk_confirm => 'Potvrdiť heslo';

  @override
  String get bk_working => 'Prebieha…';

  @override
  String get bk_save => 'Uložiť šifrovanú zálohu';

  @override
  String get bk_mismatch => 'Použi aspoň 12 znakov a zhodné heslá.';

  @override
  String get bk_done =>
      'Záloha je pripravená. Súbor a heslo uchovávaj na bezpečnom mieste.';

  @override
  String get bk_failed =>
      'Zálohu sa nepodarilo exportovať. Tvoje údaje sa nezmenili.';

  @override
  String get bk_restoreTitle => 'Obnoviť zálohu';

  @override
  String get bk_restorePass => 'Heslo zálohy';

  @override
  String get bk_choose => 'Vybrať súbor zálohy';

  @override
  String get bk_cantOpen => 'Súbor sa nepodarilo otvoriť.';

  @override
  String get bk_wrongPass =>
      'Nesprávne heslo alebo neplatná záloha. Nič sa nezmenilo.';

  @override
  String get bk_confirmTitle => 'Obnoviť túto zálohu?';

  @override
  String bk_confirmBody(int count) {
    return 'Nahradí $count uložených nastavení v tomto zariadení vrátane kontaktov, kľúčov kanálov a bodov trasy tými zo zálohy. Nedá sa to vrátiť späť.';
  }

  @override
  String get bk_restore => 'Obnoviť';

  @override
  String bk_restored(int count) {
    return 'Obnovené nastavenia: $count. Úplne zatvor aplikáciu a znova ju otvor.';
  }

  @override
  String get bk_partial =>
      'Obnova sa zastavila v polovici; niektoré nastavenia sa mohli zmeniť. Skús to znova.';

  @override
  String get bk_history => 'Zahrnúť históriu správ';

  @override
  String get bk_historyHint =>
      'Priame a kanálové správy pre každé rádio. Súbor bude väčší.';

  @override
  String get bk_tooLarge =>
      'Záloha je príliš veľká. Vypnite históriu správ a skúste to znova.';

  @override
  String bk_confirmHistory(int count) {
    return 'Pridá aj až $count správ do histórie. Správy, ktoré už v zariadení sú, zostanú zachované.';
  }

  @override
  String bk_restoredHistory(int count) {
    return 'Do histórie sa pridalo $count správ.';
  }

  @override
  String get sosSetup_noPeople =>
      'V kontaktoch zatiaľ nikto nie je. Zobrazia sa, keď niekto zdieľa kontakt alebo začuješ jeho ohlásenie.';

  @override
  String get sosSetup_channel => 'SOS ide aj do kanála';

  @override
  String get sosSetup_channelHint => 'Všetci v tom kanáli uvidia tvoje SOS.';

  @override
  String get sosSetup_none => 'Žiadny';

  @override
  String get trail_safety =>
      'Údaje o chodníkoch © prispievatelia OpenStreetMap. Môžu byť neúplné alebo zastarané. Trasy sa nekontrolujú z hľadiska bezpečnosti ani priechodnosti, preto ich nepoužívaj ako jedinú navigáciu.';

  @override
  String get ant_title => 'Pokrytie antény';

  @override
  String get ant_placeHint => 'Podrž mapu na umiestnenie antény.';

  @override
  String get ant_fromRadio =>
      'Anténa na pozícii tvojho rádia. Podrž mapu na jej presunutie.';

  @override
  String get ant_placed => 'Anténa umiestnená na mape. Podrž na presunutie.';

  @override
  String get ant_height => 'Výška antény';

  @override
  String get ant_radius => 'Polomer';

  @override
  String get ant_checking => 'Kontrola terénu…';

  @override
  String get ant_estimate => 'Odhadnúť pokrytie';

  @override
  String get ant_noTerrain =>
      'Výšky terénu sa nepodarilo načítať. Prvýkrát je potrebný internet.';

  @override
  String get ant_legendSignal =>
      'Veľké zelené body: silný signál. Malé oranžové: na hrane. Hrubý odhad z terénu a nastavení rádia pri anténach 2 dBi. Stromy a budovy nie sú zahrnuté, skutočný dosah býva kratší.';

  @override
  String get ant_legendLos =>
      'Pripoj rádio na odhad signálu. Zelené body majú priamu viditeľnosť na ručné rádio (1,5 m). Hrubý odhad, nie záruka.';

  @override
  String ant_losSummary(int percent, String km) {
    return 'Priama viditeľnosť na $percent % bodov • najďalej $km km';
  }

  @override
  String ant_signalSummary(int strong, int marginal, String km) {
    return 'Odhadovaný signál: silný na $strong % oblasti, na hrane na $marginal %, použiteľný do $km km.';
  }

  @override
  String rp_title(String name) {
    return 'Nastavenia siete $name';
  }

  @override
  String rp_mostNodes(String summary) {
    return 'Väčšina uzlov tu používa $summary. Tvoje rádio je nastavené inak, takže ich možno nebudeš počuť.';
  }

  @override
  String rp_mostNodesCount(int count, String summary) {
    return 'Väčšina uzlov tu ($count na mape MeshCore) používa $summary. Tvoje rádio je nastavené inak, takže ich možno nebudeš počuť.';
  }

  @override
  String rp_localMesh(String summary) {
    return 'Miestna sieť používa $summary. Tvoje rádio je nastavené inak, takže ju možno nebudeš počuť.';
  }

  @override
  String get rp_notNow => 'Teraz nie';

  @override
  String get rp_review => 'Skontrolovať';

  @override
  String rp_useTitle(String name) {
    return 'Použiť nastavenia $name?';
  }

  @override
  String get rp_already => 'Tvoje rádio už tieto nastavenia používa.';

  @override
  String get rp_fromMap =>
      'Nahlásené vlastníkmi uzlov na mape MeshCore, neoverené vo vysielaní.';

  @override
  String rp_updated(String date) {
    return 'Aktualizované $date. Po zmene budeš počuť len rádiá s rovnakými nastaveniami.';
  }

  @override
  String get rp_powerOnly => 'Vysielací výkon sa nemení.';

  @override
  String get rp_powerHash => 'Vysielací výkon a veľkosť hash cesty sa nemenia.';

  @override
  String get rp_apply => 'Použiť v rádiu';

  @override
  String rp_setTo(String name) {
    return 'Rádio nastavené na $name.';
  }

  @override
  String rp_failed(String error) {
    return 'Rádio sa nepodarilo zmeniť: $error';
  }

  @override
  String get rp_noArea => 'Nablízku nie je žiadna oblasť zo zoznamu.';

  @override
  String get rp_noLonger => 'Zvolená oblasť už nie je v zozname.';

  @override
  String get rp_autoPrefix => 'Auto: ';

  @override
  String get rp_tileTitle => 'Nastavenia miestnej siete';

  @override
  String get rp_automatic => 'Automaticky';

  @override
  String get rp_autoSub => 'Podľa polohy rádia alebo telefónu';

  @override
  String get rp_mapSuffix => 'mapa MeshCore';

  @override
  String get rp_savedList =>
      'Používa sa uložený zoznam. Online sa aktualizuje z GitHubu.';

  @override
  String rp_checked(String time) {
    return 'Zoznam skontrolovaný o $time. Oblasti sa pridávajú cez pull request.';
  }

  @override
  String get sh_title => 'Zdieľať kontakt';

  @override
  String get sh_hint =>
      'Pošle jeho meno a verejný kľúč ako odkaz, cez ktorý ho ktokoľvek pridá.';

  @override
  String get sh_you => 'Toto si ty.';

  @override
  String get sh_already => 'Už je v tvojich kontaktoch.';

  @override
  String get sh_adding => 'Pridáva sa…';

  @override
  String get sh_add => 'Pridať kontakt';

  @override
  String sh_added(String name) {
    return '$name pridaný.';
  }

  @override
  String sh_addFailed(String name, String error) {
    return '$name sa nepodarilo pridať: $error';
  }

  @override
  String get tr_needArea => 'Najprv stiahni oblasť, ktorá obsahuje oba body.';

  @override
  String get tr_startFar => 'Začiatok je viac ako 500 m od známeho chodníka.';

  @override
  String get tr_endFar => 'Koniec je viac ako 500 m od známeho chodníka.';

  @override
  String get tr_notJoined => 'Žiadne známe chodníky tieto body nespájajú.';

  @override
  String get tr_damaged =>
      'Údaje tejto oblasti sú poškodené. Odstráň ju a stiahni znova.';

  @override
  String tr_zoomIn(int max, int current) {
    return 'Priblíž: oblasť môže mať najviac $max km², tento pohľad má $current km².';
  }

  @override
  String get tr_downloading => 'Sťahujú sa chodníky…';

  @override
  String tr_saved(String size) {
    return 'Uložené chodníky: $size.';
  }

  @override
  String get tr_tooLarge => 'Priblíž na menšiu oblasť.';

  @override
  String get tr_full =>
      'Úložisko chodníkov je plné (500 MB). Najprv odstráň oblasť.';

  @override
  String get tr_noTrails => 'V tomto pohľade nie sú žiadne chodníky.';

  @override
  String get tr_failed =>
      'Sťahovanie zlyhalo. Mapový server môže byť zaneprázdnený; skús to neskôr.';

  @override
  String tr_routeName(String distance) {
    return 'Trasa po chodníkoch $distance';
  }

  @override
  String get tr_savedRoute => 'Uložené do tvojich trás.';

  @override
  String get tr_areas => 'Stiahnuté oblasti';

  @override
  String tr_used(String size) {
    return 'Využité $size z 500 MB';
  }

  @override
  String tr_deleteArea(String name) {
    return 'Odstrániť $name';
  }

  @override
  String get tr_title => 'Trasy po chodníkoch';

  @override
  String get tr_search => 'Hľadať miesta';

  @override
  String get tr_start => 'Začiatok trasy';

  @override
  String get tr_end => 'Koniec trasy';

  @override
  String tr_route(String distance) {
    return 'Trasa: $distance po známych chodníkoch.';
  }

  @override
  String get tr_tapStart => 'Ťukni na mapu pre začiatok, potom pre koniec.';

  @override
  String get tr_tapEnd => 'Ťukni na mapu pre koniec.';

  @override
  String get tr_download => 'Stiahnuť tento pohľad';

  @override
  String get tr_save => 'Uložiť trasu';

  @override
  String get tr_searchLabel => 'Hľadať v stiahnutých miestach';

  @override
  String get tr_searchHelp =>
      'Vrcholy, začiatky trás, voda, chaty, obce a tvoje body. Vybraný sa stane ďalším bodom trasy.';

  @override
  String get tr_nothing =>
      'Nič sa nenašlo. Vyhľadávanie pokrýva len stiahnuté oblasti; oblasti uložené pred vyhľadávaním miest treba stiahnuť znova.';

  @override
  String get tr_toolSub => 'Offline trasy po stiahnutých chodníkoch';

  @override
  String get place_peak => 'Vrchol';

  @override
  String get place_pass => 'Sedlo';

  @override
  String get place_spring => 'Prameň';

  @override
  String get place_hut => 'Chata';

  @override
  String get place_campsite => 'Kemp';

  @override
  String get place_viewpoint => 'Vyhliadka';

  @override
  String get place_shelter => 'Prístrešok';

  @override
  String get place_trailhead => 'Začiatok trasy';

  @override
  String get place_town => 'Obec';

  @override
  String get place_locality => 'Lokalita';

  @override
  String get place_waypoint => 'Uložený bod';

  @override
  String get sentinel_title => 'Moderovanie komunity';

  @override
  String get sentinel_toolSubtitle =>
      'Nahláste spam moderátorom NOTORYX a pozrite si označené uzly';

  @override
  String get sentinel_intro =>
      'Nahlásenia idú moderátorom NOTORYX, ktorí každé posúdia ručne. Schválené zákazy sa vrátia ako odporúčací zoznam: označené uzly dostanú štítok a v sieti sa nič neblokuje.';

  @override
  String get sentinel_enable => 'Používať moderovanie komunity';

  @override
  String get sentinel_enableSub =>
      'Predvolene vypnuté. Kým je vypnuté, NOTORYX nikdy nekontaktuje moderovaciu službu.';

  @override
  String get sentinel_hide => 'Skryť správy od označených odosielateľov';

  @override
  String get sentinel_hideSub =>
      'Iba správy v kanáloch. Môžete to kedykoľvek vypnúť.';

  @override
  String sentinel_synced(String time) {
    return 'Zoznam zákazov aktualizovaný $time';
  }

  @override
  String get sentinel_neverSynced => 'Zoznam zákazov ešte nie je stiahnutý';

  @override
  String sentinel_flaggedCount(int count) {
    return 'Označené uzly: $count';
  }

  @override
  String sentinel_queued(int count) {
    return 'Nahlásenia čakajúce na odoslanie: $count';
  }

  @override
  String get sentinel_refresh => 'Aktualizovať';

  @override
  String get sentinel_yourNode => 'Váš uzol';

  @override
  String get sentinel_yourNodeClear => 'Váš uzol nie je označený.';

  @override
  String sentinel_yourNodeFlagged(String caseRef) {
    return 'Váš uzol je označený (prípad $caseRef). Ak ide o omyl, môžete sa odvolať.';
  }

  @override
  String get sentinel_yourNodeUnknown =>
      'Pripojte rádio a skontrolujte svoj uzol.';

  @override
  String get sentinel_appealPending => 'Vaše odvolanie sa posudzuje.';

  @override
  String get sentinel_appeal => 'Odvolať sa';

  @override
  String get sentinel_appealOther => 'Odvolanie podľa čísla prípadu';

  @override
  String get sentinel_yourReports => 'Vaše nedávne nahlásenia';

  @override
  String get sentinel_report => 'Nahlásiť moderátorom';

  @override
  String sentinel_reportTitle(String name) {
    return 'Nahlásiť $name';
  }

  @override
  String get sentinel_reasonSpam => 'Spam alebo reklama';

  @override
  String get sentinel_reasonFlooding => 'Zahlcovanie siete';

  @override
  String get sentinel_reasonAbuse => 'Obťažovanie alebo urážky';

  @override
  String get sentinel_reasonImpersonation => 'Vydávanie sa za iného';

  @override
  String get sentinel_reasonOther => 'Iné';

  @override
  String get sentinel_note => 'Podrobnosti (nepovinné)';

  @override
  String get sentinel_includeMessage => 'Priložiť túto správu';

  @override
  String get sentinel_sends =>
      'Odošle ID a názov uzla, váš dôvod a, ak je zaškrtnuté, túto správu. Nie vaše meno, kľúč ani polohu.';

  @override
  String get sentinel_send => 'Odoslať nahlásenie';

  @override
  String sentinel_sent(String caseRef) {
    return 'Nahlásenie odoslané ($caseRef)';
  }

  @override
  String get sentinel_queuedOne =>
      'Bez pripojenia. Nahlásenie sa odošle neskôr.';

  @override
  String sentinel_rejected(String message) {
    return 'Nahlásenie neprijaté: $message';
  }

  @override
  String get sentinel_offPrompt => 'Zapnúť moderovanie komunity?';

  @override
  String get sentinel_turnOn => 'Zapnúť';

  @override
  String get sentinel_flagged => 'Označený';

  @override
  String sentinel_flaggedHint(String caseRef) {
    return 'Označený moderátormi NOTORYX (prípad $caseRef). Len odporúčanie.';
  }

  @override
  String get sentinel_caseRef => 'Číslo prípadu (SNT-1234)';

  @override
  String get sentinel_statement => 'Prečo by sa mal zákaz zrušiť?';

  @override
  String get sentinel_contact => 'Kontakt (nepovinné, vidia ho len moderátori)';

  @override
  String get sentinel_appealSend => 'Odoslať odvolanie';

  @override
  String get sentinel_appealReceived =>
      'Odvolanie odoslané. Moderátor ho posúdi.';

  @override
  String get sentinel_appealUnknown =>
      'Žiadny prípad MeshCore nemá toto číslo.';

  @override
  String get sentinel_appealNotOpen =>
      'Tento prípad nemá aktívny zákaz alebo už čaká odvolanie.';

  @override
  String get sentinel_appealTooMany =>
      'Príliš veľa odvolaní. Skúste to o minútu.';

  @override
  String get sentinel_failed =>
      'Moderovacia služba je nedostupná. Skúste neskôr.';

  @override
  String get privacy_netSentinel =>
      'Moderovanie: iba ak zapnete moderovanie komunity. Zoznam zákazov a vaše nahlásenia či odvolania idú moderátorom NOTORYX cez sentinel-relay.meshmayhem.org.';

  @override
  String get mapTrust_favoritesOnly => 'Iba obľúbené';

  @override
  String get mapTrust_favoritesOnlyHint => 'Skryť uzly bez hviezdičky';

  @override
  String get topology_flows => 'Toky';

  @override
  String get topology_network => 'Sieť';

  @override
  String get topology_hint =>
      'Kruhy ukazujú počet skokov od vás v strede. Hrubšie čiary preniesli viac správ, väčšie body preposlali viac. Ťuknutím na bod zobrazíte daný opakovač.';

  @override
  String topology_semantics(int repeaters, int rings) {
    return 'Diagram siete. $repeaters opakovačov na $rings kruhoch okolo vás.';
  }

  @override
  String get zones_title => 'Upozornenia na zóny a trasu';

  @override
  String get zones_toolSubtitle =>
      'Upozorní, keď niekto vstúpi do zóny, opustí ju alebo zíde z trasy';

  @override
  String get zones_enabled => 'Upozornenia zapnuté';

  @override
  String get zones_enabledHint =>
      'Používa polohy z oznámení, ktoré rádio počuje, takže upozornenie je len také aktuálne ako posledné oznámenie.';

  @override
  String get zones_watch => 'Sledovať';

  @override
  String get zones_scopeFavorites => 'Obľúbené';

  @override
  String get zones_scopeEveryone => 'Všetci';

  @override
  String get zones_includeSelf => 'Aj moje rádio';

  @override
  String get zones_zones => 'Zóny';

  @override
  String get zones_none =>
      'Zatiaľ žiadne zóny. Pridajte jednu okolo tábora, začiatku trasy alebo miesta stretnutia.';

  @override
  String get zones_add => 'Pridať zónu';

  @override
  String get zones_edit => 'Upraviť zónu';

  @override
  String get zones_name => 'Názov';

  @override
  String get zones_defaultName => 'Zóna';

  @override
  String get zones_center => 'Stred';

  @override
  String get zones_centerMyRadio => 'Poloha môjho rádia';

  @override
  String zones_centerWaypoint(String name) {
    return 'Bod: $name';
  }

  @override
  String get zones_noCenter =>
      'Rádio nemá polohu a nie sú žiadne body. Najprv nastavte polohu alebo uložte bod.';

  @override
  String zones_radius(String distance) {
    return 'Polomer: $distance';
  }

  @override
  String get zones_alertOn => 'Upozorniť pri';

  @override
  String get zones_onEnter => 'Vstupe';

  @override
  String get zones_onLeave => 'Odchode';

  @override
  String get zones_onBoth => 'Oboch';

  @override
  String get zones_delete => 'Odstrániť zónu';

  @override
  String zones_full(int count) {
    return 'Môžete mať najviac $count zón.';
  }

  @override
  String get zones_trail => 'Trasa';

  @override
  String get zones_trailNone => 'Žiadna sledovaná trasa';

  @override
  String get zones_trailHint =>
      'Vyberte trasu z bodov alebo nahratú stopu. Každý sledovaný, kto sa od nej vzdiali viac ako je limit, spustí upozornenie.';

  @override
  String zones_offTrailLimit(String distance) {
    return 'Mimo trasy po $distance';
  }

  @override
  String get zones_you => 'Vy';

  @override
  String zones_trackName(String date, String km) {
    return 'Stopa $date · $km km';
  }

  @override
  String zones_alertEnteredTitle(String zone) {
    return 'Vstup do $zone';
  }

  @override
  String zones_alertEnteredBody(String name, String zone) {
    return '$name je v zóne $zone.';
  }

  @override
  String zones_alertLeftTitle(String zone) {
    return 'Odchod zo $zone';
  }

  @override
  String zones_alertLeftBody(String name, String zone) {
    return '$name opustil zónu $zone.';
  }

  @override
  String get zones_alertOffTrailTitle => 'Mimo trasy';

  @override
  String zones_alertOffTrailBody(String name, String distance, String trail) {
    return '$name je $distance od: $trail.';
  }
}
