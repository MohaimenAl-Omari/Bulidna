import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController{
  Future<void> assignTokenToUser() async {
  // Get current user
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }
  // Get FCM token for this device/app instance
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) {
    return;
  }

  // Reference to the token document (doc ID = token string)
  final tokenDoc = FirebaseFirestore.instance.collection('tokens').doc(token);

  // Set or update the token document with userID and lastUpdated timestamp
  await tokenDoc.set({
    'userID': user.uid,
    'lastUpdated': FieldValue.serverTimestamp(),
  });
}


  static NotificationsController get to => Get.find();

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;

  @override
  void onInit() {
    super.onInit();
    _initFirebaseMessaging();
    _initLocalNotifications();
  }

  void _initFirebaseMessaging() async {
    await Firebase.initializeApp(); // Only if not already done in main.dart

    _messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print('🔵 Notifications authorized');
    } else {
      // print('🔴 Notifications not authorized');
    }

    // Handle foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // 👉 Add your navigation logic here
    });

    // Handle background (set this in main.dart!)
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'General Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }

  void _initLocalNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidInit);

    _localNotifications.initialize(initSettings);
  }

}