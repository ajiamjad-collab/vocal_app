class CacheKeys {
  CacheKeys._();

  // Professional
  static String professionalOverview(String uid) => 'prof:overview:v1:$uid';
  static String professionalPosterList(String uid) => 'prof:poster:list:v1:$uid';
  static String professionalProducts(String uid) => 'prof:products:v1:$uid';
  static String professionalStatus(String uid) => 'prof:status:v1:$uid';

  // Personal
  static String personalOverview(String uid) => 'pers:overview:v1:$uid';

  // Banners
  static String bannersHome() => 'banners:home:v1';
}
