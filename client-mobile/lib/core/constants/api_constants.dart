class ApiConstants {
  const ApiConstants._();

  static const wardrobeBaseUrl = String.fromEnvironment(
    'WARDROBE_API_BASE_URL',
    defaultValue: 'http://localhost:8084',
  );

  static const aiBaseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

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
