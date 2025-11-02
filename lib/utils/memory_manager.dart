import 'dart:convert';
import 'dart:io';

class MemoryManager {
  static const String _fileName = 'memory.json';

  static Future<Map<String, dynamic>> loadMemory() async {
    final file = File(_fileName);
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    } else {
      return {"history": [], "traits": {}};
    }
  }

  static Future<void> saveMemory(Map<String, dynamic> data) async {
    final file = File(_fileName);
    await file.writeAsString(jsonEncode(data));
  }

  static Future<void> clearMemory() async {
    final file = File(_fileName);
    if (await file.exists()) await file.delete();
  }
}
