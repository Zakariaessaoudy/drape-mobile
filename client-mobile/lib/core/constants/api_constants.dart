import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  static const _wardrobeBaseUrlOverride = String.fromEnvironment(
    'WARDROBE_API_BASE_URL',
  );
  static const _aiBaseUrlOverride = String.fromEnvironment('AI_API_BASE_URL');
  static const _productionWardrobeBaseUrl = String.fromEnvironment(
    'DRAPE_PROD_WARDROBE_API_BASE_URL',
    defaultValue: 'https://drape-mobile.onrender.com',
  );
  static const _productionAiBaseUrl = String.fromEnvironment(
    'DRAPE_PROD_AI_API_BASE_URL',
    defaultValue: 'https://zkressaoudy-drape-bg-remover.hf.space',
  );
  static const _apiTarget = String.fromEnvironment(
    'DRAPE_API_TARGET',
    defaultValue: 'auto',
  );
  static const _apiHostOverride = String.fromEnvironment('DRAPE_API_HOST');
  static const _deviceHostIp = String.fromEnvironment('DRAPE_DEVICE_HOST_IP');
  static const _windowsHostIp = String.fromEnvironment(
    'DRAPE_WINDOWS_HOST_IP',
    defaultValue: '192.168.1.114',
  );
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
    if (_usesProductionBackend && _productionWardrobeBaseUrl.isNotEmpty) {
      return _productionWardrobeBaseUrl;
    }
    return 'http://$_apiHost:$_wardrobePort';
  }

  static String get aiBaseUrl {
    if (_aiBaseUrlOverride.isNotEmpty) return _aiBaseUrlOverride;
    if (_usesProductionBackend) return _productionAiBaseUrl;
    return 'http://$_apiHost:$_aiPort';
  }

  static bool get _usesProductionBackend {
    return _apiTarget == 'production' ||
        _apiTarget == 'prod' ||
        _apiTarget == 'render' ||
        _apiTarget == 'deployed';
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
      case 'ios-device':
      case 'ios-usb':
      case 'device':
        return _preferredDeviceHost;
      case 'android-usb':
      case 'android-usb-reverse':
        return '127.0.0.1';
      case 'android-device-windows':
      case 'ios-device-windows':
      case 'android-usb-windows':
      case 'ios-usb-windows':
        return _windowsHostIp;
      case 'android-device-mac':
      case 'ios-device-mac':
      case 'android-usb-mac':
      case 'ios-usb-mac':
        return _macHostIp;
    }

    if (kIsWeb) return 'localhost';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _windowsHostIp,
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

  static String get _preferredDeviceHost {
    if (_deviceHostIp.isNotEmpty) return _deviceHostIp;
    return _windowsHostIp;
  }
}
