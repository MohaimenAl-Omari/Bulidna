import 'package:buildna/components/loading_overlay.dart';
import 'package:buildna/controller/auth_controller.dart';
import 'package:buildna/controller/loader_controller.dart';
import 'package:buildna/controller/notifications_controller.dart';
import 'package:buildna/firebase_options.dart';
import 'package:buildna/locale/locale_controller.dart';
import 'package:buildna/startpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get_storage/get_storage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if using other Firebase services
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity
  );
  Get.put(AuthController());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Get.put(LoaderController());
  Get.put(NotificationsController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: LocaleController(),
      locale: const Locale('en'),
      debugShowCheckedModeBanner: false,
      title: 'Buildna',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: LoadingOverlay(child: child ?? const SizedBox()));
      },
      home: const SplashScreen(),
    );
  }
}
