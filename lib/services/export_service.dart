import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ExportService {
  // Exports arbitrary data map to a JSON file under app documents/exports
  // Returns saved file path.
  static Future<String> exportJson(String filename, Map<String, dynamic> data) async {
    final docs = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${docs.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final file = File('${exportDir.path}/$filename');
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonStr);
    return file.path;
  }
}
