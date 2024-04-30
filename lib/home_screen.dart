import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notifications_with_firebase/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print('Device token '+value);
    });
    notificationServices.setupInteractMessage(context);
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: TextButton(
          onPressed: (){
            notificationServices.getDeviceToken().then((value) async{
              var data = {
                // 'to' : value.toString(),  // value contains token of this device (sending notification to itself)
                'to' : 'cBXHTKdqRfWMdP0B7m_YNm:APA91bEf2el0k0REvV7ptYIQPHhhF3VSu7---ow-qeeqs7WDpizm8x6BO6bFfjtSi_nKhqSrUF6BUW1ll1LkQ8B2G0VJSn2vSF_mxE3kdDsPU9ajq_V6BcLO9hPXYMTDl_tX8NY2SAUI',
                // 'to' : 'dJzr-EVrSNSynzd8uUu95w:APA91bEMc0pSbTu71OC7BALwi15F5RGJzZ-8vCQ6CMdKrR_NxqvM8nJ6MWlrRzdZ97hSgTBV2UITz-g3edLPyuVOrXtqnv8BRVNPkpZQQ2exIJmYIwdal_7K1WYRVuV-jN0v0iRdJXN7',
                'priority' : 'high',
                'notification' : {
                  'title' : 'Noti from device 1',
                  'body' : 'Hello there other device'
                },
                'data': {
                  'type': 'msg',
                  'id': 'hamza123'
                }
              };
              http.post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: {
                  'Content-Type' : 'application/json; charset=UTF-8',
                  'Authorization' : 'key=AAAAjYvvtIM:APA91bHOmjUksV5g5DTBDmQKRiIGvVszU-_gxXWEFz9Nq4g6hHsAtwD1FJKpp3Wl4RxGTMYQL6HtpXEQbpwH7X-M2POWA7QuCHn7SMURbkmKGgyWK6lEHnR9MIXbVkrhB7nx1EiMurC3'
                  },
                  body: jsonEncode(data)
              );
            });
          },
          child: Text('Send Notification'),
        ),
      ),
    );
  }
}
