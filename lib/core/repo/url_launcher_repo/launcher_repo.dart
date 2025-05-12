import 'package:url_launcher/url_launcher.dart';

class LauncherRepo {
  // call
  Future<void> call(String phoneNumber) async {
    try {
      await launchUrl(Uri.parse('tel:${_normalizePhoneNumber(phoneNumber)}'));
    } catch (e) {
      throw Exception("Error calling $phoneNumber");
    }
  }

  // whatsapp
  Future<void> whatsapp(String phoneNumber, {String? userName}) async {
    try {
      String message =
          "Саламатсызбы $userName. Мен дарыгермин. Сиз менен байланышуу үчүн жазып жатам.";

      // Eğer doktor ismi (userName) verilmişse, ekleyelim
      if (userName != null) {
        message =
            "Саламатсызбы $userName. Мен дарыгермин. Сиз менен байланышуу үчүн жазып жатам.";
      }

      String encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';

      await launchUrl(Uri.parse(url));
    } catch (e) {
      throw Exception("WhatsApp билдирүүсүн жөнөтүүдө ката кетти: $e");
    }
  }

  String _normalizePhoneNumber(String input) {
    // Sadece rakamları al
    String digits = input.replaceAll(RegExp(r'\D'), '');

    // Eğer numara +996 ile başlıyorsa zaten doğru
    if (digits.startsWith('996') && digits.length == 12) {
      return '+$digits';
    }

    // Eğer numara 0 ile başlıyorsa (örnek: 0550611042)
    if (digits.startsWith('0') && digits.length == 10) {
      return '+996${digits.substring(1)}';
    }

    // Eğer sadece 9 haneliyse (örnek: 550611042)
    if (digits.length == 9) {
      return '+996$digits';
    }

    // Eğer zaten +996’lı 13 haneli geldiyse
    if (input.startsWith('+996') && digits.length == 12) {
      return input;
    }

    // Tanınmayan format varsa olduğu gibi döndür
    return input;
  }
}
