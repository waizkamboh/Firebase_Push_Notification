
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification/message_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotifications = FlutterLocalNotificationsPlugin();



  void requestNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true

    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
        print('User granted permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
        print('User granted provisional permission');
    }else{
        print('User denied permission');
    }
  }

  void initLocalNotification(BuildContext context, RemoteMessage message) async{
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );

    await _flutterLocalNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload){
          handleMessage(context, message);

        }
    );
  }


  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message){
      if(kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data['type']);
        print(message.data['id']);
      }

      if(Platform.isAndroid){
        initLocalNotification(context, message);
        showNotification(message);

      }else{
        showNotification(message);

      }


    });
  }

  Future<void> showNotification(RemoteMessage message)async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Important Notification'
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'Your Channel Description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'

    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );
    
    Future.delayed(Duration.zero, (){
      _flutterLocalNotifications.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    }
    );

  }

  Future<String> getDeviceToken() async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event){
      event.toString();
      print('refresh');

    });
  }

  Future<void> setupInteractMessage(BuildContext context)async{
    // WHEN APP IS TERMINATED
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    // WHEN APP IS IN BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((event){
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message){

    if(message.data['type'] == 'msj'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>  MessageScreen(
        id: message.data['id'],
      )));
    }
    
  }

}