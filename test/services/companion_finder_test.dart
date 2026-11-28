import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/companion_finder.dart';

void main() {
  test('reads the node name, address and firmware from an advert', () {
    final c = CompanionFinder.fromAdvert(
      serviceName: 'meshcore-ab12',
      addresses: ['fe80::1', '192.168.4.20'],
      port: 5000,
      attributes: {'node-name': 'Base Camp', 'firmware-version': 'v1.19.0'},
    )!;
    expect(c.name, 'Base Camp');
    expect(c.host, '192.168.4.20');
    expect(c.port, 5000);
    expect(c.firmwareVersion, 'v1.19.0');
    expect(c.endpoint, '192.168.4.20:5000');
  });

  test('falls back to the service name and a routable IPv6 address', () {
    final c = CompanionFinder.fromAdvert(
      serviceName: 'meshcore-ab12',
      addresses: ['fe80::1', '2001:db8::5'],
      port: 5000,
      attributes: const {},
    )!;
    expect(c.name, 'meshcore-ab12');
    expect(c.host, '2001:db8::5');
    expect(c.endpoint, '[2001:db8::5]:5000');
    expect(c.firmwareVersion, isNull);
  });

  test('no usable address or port gives nothing', () {
    expect(
      CompanionFinder.fromAdvert(
        serviceName: 'x',
        addresses: ['fe80::1'],
        port: 5000,
        attributes: const {},
      ),
      isNull,
    );
    expect(
      CompanionFinder.fromAdvert(
        serviceName: 'x',
        addresses: ['10.0.0.2'],
        port: 0,
        attributes: const {},
      ),
      isNull,
    );
  });
}
