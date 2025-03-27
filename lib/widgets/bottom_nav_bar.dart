import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:jxp_app/constants/app_constants.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../screens/home_screen.dart';
import '../screens/wellness_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 1);
  int _selectedIndex = 1; // Track selected index

  List<Widget> _screens() {
    return [
      const WellnessScreen(),
      HomeScreen(key: ValueKey(_selectedIndex)), // Rebuild WebView on switch
      const SettingsScreen(),
    ];
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


/*  void _onItemTapped(int index) {
    if (_selectedIndex == index && index == 1) {
      setState(() {}); // Force WebView refresh
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
    _controller.jumpToTab(index);
  }*/

  void _onItemTapped(int index) {
    print('_selectedIndex: $index');
    if (_selectedIndex == index && index == 1) {
      // Force refresh
      Navigator.of(context).pushAndRemoveUntil(  MaterialPageRoute(builder: (context) => const BottomNavBar()),      (route) => false,);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
    _controller.jumpToTab(index);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Image.asset("assets/add.png", height: 25),
        title: "Wellness",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white70,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset("assets/home.png", height: 25),
        title: "Home",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white70,
      ),
      PersistentBottomNavBarItem(
        icon: Image.asset("assets/add.png", height: 25),
        title: "Settings",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.white70,
      ),
    ];
  }

  final List<Widget> _pages = [
    const WellnessScreen(),
    const HomeScreen(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: 1,
        style: TabStyle.react,
        backgroundColor: appthemeLight,
        items: [
          TabItem(icon: Image.asset('assets/BottomBar/Wellness.png', color: Colors.white), title: '', activeIcon: Image.asset('assets/BottomBar/Wellness.png', color: Colors.white)),
          TabItem(icon: Image.asset('assets/BottomBar/home.png'), ),
          TabItem(icon: Image.asset('assets/BottomBar/Settings.png', color: Colors.white), title: '', activeIcon: Image.asset('assets/BottomBar/Settings.png', color: Colors.white)),
        ],
        onTap: _onItemTapped,
      ),
      body: _pages[_selectedIndex],
    );
  }

}
