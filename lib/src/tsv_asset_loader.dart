import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'asset_loader.dart';

//
// load example/resources/langs/langs.csv
//
class TsvAssetLoader extends AssetLoader {
  TSVParser? tsvParser;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (tsvParser == null) {
      log('easy localization loader: load tsv file $path');
      tsvParser = TSVParser(await rootBundle.loadString(path));
    } else {
      log('easy localization loader: TSV parser already loaded, read cache');
    }
    return tsvParser!.getLanguageMap(locale.toString());
  }
}

class TSVParser {
  final String strings;
  final List<List<dynamic>> lines;

  TSVParser(this.strings)
      : lines = _convert(strings);

  static List<List<dynamic>> _convert(String str) {
    final lines = str.split('\n')
        .map<List<String>>((e) => e.split('\t').map(
            (e) => e.trim()
            .replaceAll('\\n', '\n')
            .replaceAllMapped(RegExp(r'\\u([0-9A-Fa-f]{4})'), (Match match) {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        })
            .replaceAllMapped(RegExp(r'\\x([0-9A-Fa-f]{2})'), (Match match) {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        })).toList()
    ).toList();

    return lines;
  }

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, dynamic> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);
    if (indexLocale < 0) {
      throw Exception("Locale $localeName not found in tsv file. Available locales: ${lines.first}");
    }
    var translations = <String, dynamic>{};
    for (var i = 1; i < lines.length; i++) {
      translations.addAll({lines[i][0]: lines[i][indexLocale]});
    }
    return translations;
  }
}
