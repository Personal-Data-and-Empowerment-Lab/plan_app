import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:planv3/entities/GoogleTaskEntity.dart';
import 'package:planv3/entities/GoogleTaskListEntity.dart';
import 'package:planv3/utils/GoogleHttpClient.dart';

class GoogleTasksProvider {
  static final scopes = ["https://www.googleapis.com/auth/tasks.readonly"];
  static var _googleSignIn = GoogleSignIn(scopes: scopes);

//  GoogleHttpClient _httpClient;

  GoogleTasksProvider() {
    _googleSignIn = GoogleSignIn(scopes: scopes);
  }

//  void getGoogleTasks() async {
//
//    await _googleSignIn.signIn();
//
//    final authHeaders = await _googleSignIn.currentUser.authHeaders;
//
//    final httpClient = GoogleHttpClient(authHeaders);
//
//    var tasksAPI = new TasksApi(httpClient);
//
//    tasksAPI.tasklists.list().then((lists) {
//
//      for (var aList in lists.items) {
//        print(aList.title);
//        print(aList.id);
//      }
//
//    });
//  }

  static Future<Map<String, String>> signIn() async {
    await _googleSignIn.signIn();
    return _googleSignIn.currentUser.authHeaders;
  }

  static Future<GoogleHttpClient> getHttpClient() async {
    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      try {
        await _googleSignIn.signIn();
      } catch (error1) {
        throw error1;
      }
    }

    return GoogleHttpClient(await _googleSignIn.currentUser.authHeaders);
  }

  static Future signOut() async {
    return await _googleSignIn.signOut();
  }

  static Future<List<GoogleTaskListEntity>> getGoogleTaskLists() async {
    final httpClient = await getHttpClient();

    var tasksAPI = new TasksApi(httpClient);

    List<GoogleTaskListEntity> taskLists = [];
    var retrievedTaskLists = await tasksAPI.tasklists.list();
    for (var aList in retrievedTaskLists.items) {
      taskLists.add(GoogleTaskListEntity.fromAPIObject(aList));
    }

    httpClient.close();
    return taskLists;
  }

  static Future<List<GoogleTaskEntity>> getGoogleTasksFromList(
      String listID) async {
    final httpClient = await getHttpClient();

    var tasksAPI = new TasksApi(httpClient);

    var tasksInList = await tasksAPI.tasks.list(listID);

    List<GoogleTaskEntity> tasks = [];
    if (tasksInList.items != null) {
      for (var task in tasksInList.items) {
        tasks.add(GoogleTaskEntity.fromAPIObject(task));
      }
    }

    httpClient.close();
    return tasks;
  }
}
