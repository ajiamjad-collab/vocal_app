enum BrandCategory { personal, professional }

extension BrandCategoryX on BrandCategory {
  String get wire => this == BrandCategory.personal ? 'personal' : 'professional';
}

BrandCategory brandCategoryFromWire(String v) {
  final t = v.trim().toLowerCase();
  return t == 'professional' ? BrandCategory.professional : BrandCategory.personal;
}
