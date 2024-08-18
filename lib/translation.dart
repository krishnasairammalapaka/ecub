import 'package:translator/translator.dart';
import 'package:ecub_s1_v2/globals.dart' as globals;

class Translate {
  static final GoogleTranslator _translator = GoogleTranslator();

  static Future<String> translateText(String text, {String to = 'en'}) async {
    try {
      var translation =
          await _translator.translate(text, to: globals.selectedLanguage);
      return translation.text;
    } catch (e) {
      return text;
    }
  }
}
