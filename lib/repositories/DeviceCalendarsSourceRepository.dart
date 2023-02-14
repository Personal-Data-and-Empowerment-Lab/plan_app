import 'dart:convert';
import 'dart:io';
import 'package:planv3/models/DeviceCalendarsSource.dart';
import 'package:path_provider/path_provider.dart';

class DeviceCalendarsSourceRepository {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _deviceCalendarsSettingsFile async {
    final path = await _localPath;
    return File('$path/deviceCalendarsSettings.txt');
  }

  static Future<File> writeDeviceCalendarsSettings(
      DeviceCalendarsSource data) async {
    final file = await _deviceCalendarsSettingsFile;

    return file.writeAsString(jsonEncode(data));
  }

  static Future<DeviceCalendarsSource> readDeviceCalendarsSettings() async {
    try {
      final file = await _deviceCalendarsSettingsFile;

      // Read the file.
      String contents = await file.readAsString();

      return DeviceCalendarsSource.fromJson(jsonDecode(contents));
    } catch (e) {
      return null;
    }
  }
}
