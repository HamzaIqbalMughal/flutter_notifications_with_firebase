
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ***************************************************************************
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initLocalNotifications(BuildContext context, RemoteMessage message) async{


    var androidInitializationSettings = AndroidInitializationSettings('app_icon');
    var iOSInitializationSettings = DarwinInitializationSettings();


    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iOSInitializationSettings,
      macOS: null
    );

    try{
      // here is the exception
      bool? isInitialized = await _flutterLocalNotificationsPlugin.initialize(
          initializationSetting,
          // onDidReceiveBackgroundNotificationResponse: (payload){
          //
          // },
          onDidReceiveNotificationResponse: (payload){

          }
      );
      if(isInitialized == true) {
        print('Initization Successfull');
      }
    }catch(e){
      print('Error initializing local notifications plugin: $e');
    }

  }

  void firebaseInit(BuildContext context){
    // the below listen function is catching the notification from firebase
    FirebaseMessaging.onMessage.listen((message) {
      if(kDebugMode){
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
        // await showNotification(message);
      }

      // showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async{

    // ------------------ The below is for Android -------------------
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
      'High Importance Notifications',
      importance: Importance.max
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );
    // The above is for Android -------------------

    // ------------------ The below is for iOS -------------------
    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    // The above is for iOS ------------------

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, (){
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
          notificationDetails
      );
    });

  }

  // ***************************************************************************
  void requestNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, // if it is false notification can not be displayed,
      announcement: true,  // if it is false ...,
      badge: true,
      carPlay: true,
      provisional: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('user granted permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('user granted provisional permission');
    }else{
      print('user denied permission');
    }
  }

  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('refresh');
    });
  }

}