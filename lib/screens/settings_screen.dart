import 'package:flutter/material.dart';
import 'package:jxp_app/widgets/main_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../widgets/sub_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var displayVersionInfo = false;
  String? userId, userName;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? 'Not Logged In';
      userName = prefs.getString('userName') ?? 'Not Logged In';
    });

    print('userId: $userId');
    print('userName: $userName');
  }

  Future<bool> showExitDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("Exit App"),
                content: Text("Are you sure you want to exit?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Yes"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: appBackground,
        appBar: MainAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              const SubAppBar(pageTitle: 'Settings'),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    setAboutInfo(Icons.info, 'About', 'v1.0.0'),
                    const SizedBox(height: 15),
                    setLogoutOptions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        bool exitApp = await showExitDialog(context);
        return exitApp;
      },
    );
  }

  Widget setAboutInfo(IconData icon, String label, String content) {
    return GestureDetector(
      onTap: () {
        setState(() {
          displayVersionInfo = !displayVersionInfo;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              // Reduce opacity for lighter shadow
              offset: const Offset(0, 1),
              // Smaller offset to bring shadow closer
              blurRadius: 2.0,
              // Reduce blur radius for a subtle effect
              spreadRadius:
                  0.5, // Decrease spread to make shadow less prominent
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the top left
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Ensure Row content aligns at the top
              children: [
                Row(
                  children: [
                    Icon(icon, size: 25, color: appthemeLight),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (displayVersionInfo) showVersion(),
          ],
        ),
      ),
    );
  }

  Row showVersion() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(width: 30),
        const Text('      Version:', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 5),
        Text(getAppVersion(), style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget setLogoutOptions() {
    return GestureDetector(
      onTap: () {
        showLogoutAlert(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              // Reduce opacity for lighter shadow
              offset: const Offset(0, 1),
              // Smaller offset to bring shadow closer
              blurRadius: 2.0,
              // Reduce blur radius for a subtle effect
              spreadRadius:
                  0.5, // Decrease spread to make shadow less prominent
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.logout, size: 25, color: Colors.red),
            SizedBox(width: 5),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LOGOUT'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
