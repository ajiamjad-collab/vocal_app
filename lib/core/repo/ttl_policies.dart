class TtlPolicies {
  TtlPolicies._();

  // frequently updated
  static const feed = Duration(minutes: 1);

  // moderate changes
  static const list = Duration(minutes: 3);

  // almost static
  static const profile = Duration(minutes: 10);

  // banners change rarely
  static const banners = Duration(minutes: 30);
}
