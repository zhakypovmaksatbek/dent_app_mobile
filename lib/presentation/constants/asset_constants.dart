enum AssetConstants { toothLogo, logo, whatsapp, teeth }

enum TeethAssetConstants {
  tooth11,
  tooth12,
  tooth13,
  tooth14,
  tooth15,
  tooth16,
  tooth17,
  tooth18,
  tooth21,
  tooth22,
  tooth23,
  tooth24,
  tooth25,
  tooth26,
  tooth27,
  tooth28,
  tooth31,
  tooth32,
  tooth33,
  tooth34,
  tooth35,
  tooth36,
  tooth37,
  tooth38,
  tooth41,
  tooth42,
  tooth43,
  tooth44,
  tooth45,
  tooth46,
  tooth47,
  tooth48,
}

extension AssetConstantsExtension on AssetConstants {
  String get png => 'assets/png/$name.png';
  String get svg => 'assets/svg/$name.svg';
}

extension TeethAssetConstantsExtension on TeethAssetConstants {
  String get svg =>
      'assets/teeth/${name.toString().replaceAll('tooth', '')}.svg';
}
