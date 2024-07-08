import 'package:firebase_push_notification/notification_services.dart';
import 'package:flutter/material.dart';

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
    notificationServices.requestNotificationPermission();
    //notificationServices.isTokenRefresh();
    notificationServices.setupInteractMessage(context);
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then((value){
      print("Device Token: $value");
    });

  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
