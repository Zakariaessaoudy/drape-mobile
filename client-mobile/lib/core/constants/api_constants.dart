import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  static const _wardrobeBaseUrlOverride = String.fromEnvironment(
    'WARDROBE_API_BASE_URL',
  );
  static const _aiBaseUrlOverride = String.fromEnvironment('AI_API_BASE_URL');
  static const _apiTarget = String.fromEnvironment(
    'DRAPE_API_TARGET',
    defaultValue: 'auto',
  );
  static const _apiHostOverride = String.fromEnvironment('DRAPE_API_HOST');
  static const _macHostIp = String.fromEnvironment(
    'DRAPE_MAC_HOST_IP',
    defaultValue: '192.168.1.166',
  );
  static const _wardrobePort = String.fromEnvironment(
    'WARDROBE_API_PORT',
    defaultValue: '8084',
  );
  static const _aiPort = String.fromEnvironment(
    'AI_API_PORT',
    defaultValue: '8000',
  );

  static String get wardrobeBaseUrl {
    if (_wardrobeBaseUrlOverride.isNotEmpty) return _wardrobeBaseUrlOverride;
    return 'http://$_apiHost:$_wardrobePort';
  }

  static String get aiBaseUrl {
    if (_aiBaseUrlOverride.isNotEmpty) return _aiBaseUrlOverride;
    return 'http://$_apiHost:$_aiPort';
  }

  static String get _apiHost {
    if (_apiHostOverride.isNotEmpty) return _apiHostOverride;

    switch (_apiTarget) {
      case 'android-emulator':
      case 'android-simulator':
        return '10.0.2.2';
      case 'ios-simulator':
      case 'local':
        return 'localhost';
      case 'android-device':
      case 'android-usb':
        return _macHostIp;
    }

    if (kIsWeb) return 'localhost';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _macHostIp,
      TargetPlatform.iOS => 'localhost',
      _ => 'localhost',
    };
  }

  static const authRegister = '/api/auth/register';
  static const authLogin = '/api/auth/login';

  static const items = '/api/items';
  static const itemTops = '/api/items/tops';
  static const itemBottoms = '/api/items/bottoms';
  static const itemShoes = '/api/items/shoes';

  static const outfits = '/api/outfits';

  static const categoryTop = 'TOP';
  static const categoryBottom = 'BOTTOM';
  static const categoryShoe = 'SHOE';
}
