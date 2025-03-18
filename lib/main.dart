import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jxp_app/providers/wellness_provider.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  runApp(MyApp(isLoggedIn: userId != null));
}

// Notification Config
const notificationChannelId = 'my_foreground';
const notificationId = 888;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Step Counter
StreamSubscription<StepCount>? stepSubscription;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Background Service',
    description: 'Used for step tracking notifications.',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Step Tracker Running',
      initialNotificationContent: 'Tracking your steps...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  stepSubscription = Pedometer.stepCountStream.listen((StepCount event) async {
    // Get stored steps and last update date
    int savedSteps = prefs.getInt('stepsOffline') ?? 0;
    String? lastUpdatedDate = prefs.getString('lastStepDate');

    // Get current date
    String today = DateTime.now().toIso8601String().substring(0, 10);

    // Reset steps if a new day has started
    if (lastUpdatedDate == null || lastUpdatedDate != today) {
      savedSteps = 0;
    }

    // Update steps
    int newSteps = savedSteps + event.steps;
    await prefs.setInt('stepsOffline', newSteps);
    await prefs.setString('lastStepDate', today);

    // Show notification
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'Steps Updated',
      'Total steps: $newSteps',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'Step Tracker',
          icon: 'ic_bg_service_small',
          ongoing: false,
        ),
      ),
    );
  });

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process stopped.");
  });

  service.on("start").listen((event) {
    print("Service restarted.");
  });
}

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//
//   final prefs = await SharedPreferences.getInstance();
//
//   stepSubscription = Pedometer.stepCountStream.listen((StepCount event) async {
//     int steps = (prefs.getInt('stepsOffline') ?? 0) + event.steps;
//     await prefs.setInt('stepsOffline', steps);
//
//     flutterLocalNotificationsPlugin.show(
//       notificationId,
//       'Steps Updated',
//       'Total steps: $steps',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           notificationChannelId,
//           'Step Tracker',
//           icon: 'ic_bg_service_small',
//           ongoing: false,
//         ),
//       ),
//     );
//   });
//
//   service.on("stop").listen((event) {
//     service.stopSelf();
//     print("Background process stopped.");
//   });
//
//   service.on("start").listen((event) {
//     print("Service restarted.");
//   });
// }

// Start and Stop Service
void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (context) => WellnessProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: authProvider.userId == null ? const LoginScreen() : const BottomNavBar(),
          );
        },
      ),
    );
  }
}
