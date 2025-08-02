import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'package:share_plus/share_plus.dart';

class FileWriterService {
  Future<void> writeListToFile(List<int> data, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');

      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      final buffer = StringBuffer();
      buffer.writeln('--- Session Start: ${DateTime.now()} ---');
      for (int value in data) {
        buffer.writeln(value);
      }
      buffer.writeln('--- Session End ---\n');

      await file.writeAsString(buffer.toString(), mode: FileMode.append);

      developer.log('Data appended to file: ${file.path}');
    } catch (e) {
      developer.log('Error writing to file: $e');
    }
  }

  Future<void> shareFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName.txt';
    final file = File(filePath);

    if (await file.exists()) {
      await Share.shareXFiles([XFile(filePath)], text: 'Breathing data file: $fileName');
    } else {
      developer.log('File not found: $filePath');
    }
  } catch (e) {
    developer.log('Error sharing file: $e');
  }
}

  Future<String> getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName.txt';
  }
}
