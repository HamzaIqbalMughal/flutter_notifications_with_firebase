
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notifications_with_firebase/message_screen.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

// ************************   Part 1   ***********************************************************************************
// Getting FCM token, and Requesting Permission of notification
// ***********************************************************************************************************************
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


// ************************   Part 2   ***********************************************************************************
// Showing Notifications when app is killed, or in background, or opened
// ***********************************************************************************************************************

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
            handleMessage(context, message);
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
        print(message.data!['chat']);
        print(message.data!['id']);
        print(message.data!.toString());
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
        // await showNotification(message);
      }else{
        showNotification(message);
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
      //   importance: Importance.max,
      // priority: Priority.max,
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
        1,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
          notificationDetails
      );
    });

  }

// ************************   Part 3   ***********************************************************************************
// 1. How to handle the click or any event from notification when app is opened
// 2. Handling when app is in background
// 3. Handling when app is killed
// ***********************************************************************************************************************

  void handleMessage(BuildContext context, RemoteMessage message){
    if(message.data['chat'] == 'msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(id: message.data['id'],)));
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async{

    // When App is killed/terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    // When App is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }


}