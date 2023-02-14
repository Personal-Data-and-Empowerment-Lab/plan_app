import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NetworkChecker.dart';

enum FileUploadStatus { succeeded, failed_other, failed_no_network }

class FirebaseFileUploader {
  static Future<FileUploadStatus> uploadData(
      {@required String data,
      @required String fileExtension,
      @required String fileName}) async {
    FileUploadStatus uploadStatus = FileUploadStatus.failed_other;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID");

    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final userType = prefs.getBool("studyVersion") ? "study" : "dev";
    final firebaseDirectory = "PHASE_3";
    String dateString = _readableDateText(DateTime.now());
    File file = File(
        '$path/${fileName}_user_${userID}_date_$dateString.$fileExtension');

    await file.writeAsString(data);

    if (await isInternet()) {
      // upload to Firebase
      StorageReference storageReference = FirebaseStorage.instance.ref().child(
          '$firebaseDirectory/$userType/user_$userID/${fileName}_date_$dateString.$fileExtension');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.onComplete;

      if (uploadTask.isSuccessful) {
        uploadStatus = FileUploadStatus.succeeded;
      } else {
        uploadStatus = FileUploadStatus.failed_other;
      }
    } else {
      uploadStatus = FileUploadStatus.failed_no_network;
    }

    return uploadStatus;
  }

  static String _readableDateText(DateTime date) {
    return date.year.toString() +
        "_" +
        date.month.toString().padLeft(2, '0') +
        "_" +
        date.day.toString().padLeft(2, '0') +
        "T" +
        date.hour.toString().padLeft(2, '0') +
        ":" +
        date.minute.toString().padLeft(2, '0') +
        ":" +
        date.second.toString().padLeft(2, '0');
  }
}
