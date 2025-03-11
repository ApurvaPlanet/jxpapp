import 'package:flutter/material.dart';
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

  void _onItemTapped(int index) {
    if (_selectedIndex == index && index == 1) {
      setState(() {}); // Force WebView refresh
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

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: const Color(0xFF111C68),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: false, // Disable state management to force refresh
      onItemSelected: _onItemTapped, // Handle tab switch
      navBarStyle: NavBarStyle.style15,
    );
  }
}
