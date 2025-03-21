import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jxp_app/providers/wellness_provider.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await initializeService();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  runApp(MyApp(isLoggedIn: userId != null));
}

void requestNotificationPermission() async {
  var status = await Permission.notification.request();

  if (status.isDenied) {
    print("Notification permission denied!");
  } else if (status.isPermanentlyDenied) {
    print("Notification permission permanently denied. Open settings.");
    openAppSettings(); // Opens device settings
  } else {
    print("Notification permission granted!");
  }
}

Future<void> requestPermissions() async {
  await [
    Permission.notification,
    Permission.activityRecognition, // Required for step counting
    Permission.ignoreBatteryOptimizations, // Helps keep the service alive
  ].request();
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

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    flutterLocalNotificationsPlugin.show(
      notificationId,
      'Step Tracker Running',
      'Tracking your steps...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'Step Tracker',
          icon: 'ic_bg_service_small',
          ongoing: true,
          importance: Importance.high, // Ensure notification is shown
          priority: Priority.high, // High priority notification
        ),
      ),
    );
  }

  // Listen to Step Count
  stepSubscription = Pedometer.stepCountStream.listen((StepCount event) async {
    int savedSteps = prefs.getInt('stepsOffline') ?? 0;
    String? lastUpdatedDate = prefs.getString('lastStepDate');
    String today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastUpdatedDate == null || lastUpdatedDate != today) {
      savedSteps = 0;
    }

    int newSteps = savedSteps + event.steps;
    await prefs.setInt('stepsOffline', newSteps);
    await prefs.setString('lastStepDate', today);

    // Update Foreground Notification
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'Steps Updated',
      'Total steps: $newSteps',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'Step Tracker',
          icon: 'ic_bg_service_small',
          ongoing: true,
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

  void requestNotificationPermission() async {
    if (await Permission.notification.request().isDenied) {
      print("Notification permission denied!");
    }
  }
}
