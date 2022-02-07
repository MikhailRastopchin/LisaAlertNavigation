import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';


Future<String> getFilesPath({
  final String? path,
  final bool create = false,
}) async
{
  _filesRootDir ??= await getApplicationSupportDirectory();
  String fullPath = _filesRootDir!.path;
  if (path != null && path.isNotEmpty) {
    fullPath += '/' + path;
  }
  if (create) {
    await Directory(fullPath).create(recursive: true);
  }
  return fullPath;
}


Future<String> getDocumentsPath({
  final String? path,
  final bool create = false,
}) async
{
  _docsRootDir ??= await getApplicationDocumentsDirectory();
  String fullPath = _docsRootDir!.path;
  if (path != null && path.isNotEmpty) {
    fullPath += '/' + path;
  }
  if (create) {
    await Directory(fullPath).create(recursive: true);
  }
  return fullPath;
}


Future<String> getCachePath({
  final String? path,
  final bool create = false,
  final bool profiled = true,
}) async
{
  _cacheRootDir ??= await getTemporaryDirectory();
  String fullPath = _cacheRootDir!.path;
  if (path != null && path.isNotEmpty) {
    fullPath += '/' + path;
  }
  if (create) {
    await Directory(fullPath).create(recursive: true);
  }
  return fullPath;
}


Future<String?> loadText(final String fileName) async
{
  final file = File(fileName);
  final fileExists = await file.exists();
  if (!fileExists) {
    return null;
  }
  return file.readAsString(encoding: utf8);
}


Future<dynamic> loadJson(final String fileName) async
{
  final file = File(fileName);
  final fileExists = await file.exists();
  if (!fileExists) {
    return null;
  }
  final size = await file.length();
  if (size <= 0) {
    return null;
  }
  final objects = await file.openRead()
    .transform(utf8.decoder)
    .transform(json.decoder)
    .toList();
  return objects.isNotEmpty ? objects.first : null;
}


Future<void> saveText(final String fileName, final String text) async
{
  final file = File(fileName);
  await file.writeAsString(text, flush: true);
}


Future<void> saveJson(final String fileName, final dynamic jsonValue, {
  final Object Function(dynamic)? toEncodable,
  final bool solid = true
}) async
{
  final file = File(fileName);
  final sink = file.openWrite();
  final stream = Stream.value(jsonValue)
    .transform(JsonEncoder(toEncodable))
    .transform(const Utf8Encoder());
  try {
    if (solid) {
      await sink.addStream(stream);
    } else {
      const batchSize = 4 * 1024;
      var saved = 0;
      await for (var data in stream) {
        sink.add(data);
        saved += data.length;
        if (saved >= batchSize) {
          saved -= batchSize;
          await null;
        }
      }
    }
  } finally {
    await sink.close();
  }
}


Future<void> remove(final String path) async
{
  final file = File(path);
  final fileExists = await file.exists();
  if (!fileExists) return;
  await file.delete(recursive: true);
}


Directory? _filesRootDir;
Directory? _docsRootDir;
Directory? _cacheRootDir;