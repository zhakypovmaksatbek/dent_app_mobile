enum AssetConstants { toothLogo, logo }

extension AssetConstantsExtension on AssetConstants {
  String get png => 'assets/png/$name.png';
  String get svg => 'assets/svg/$name.svg';
}
