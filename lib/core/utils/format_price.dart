class FormatPrice {
  static String formatPrice(String? price) {
    if (price == null || price.isEmpty) return "";

    if (price.endsWith('.00')) {
      return price.substring(0, price.length - 3);
    } else if (price.endsWith('.0')) {
      return price.substring(0, price.length - 2);
    }

    return price;
  }
}
