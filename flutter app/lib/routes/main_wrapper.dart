import 'package:flutter/material.dart';
import '../presentation/screens/home/home_page.dart';
import '../presentation/screens/addcard/addCard.dart';
import '../presentation/screens/profile/profilePage.dart';
import '../presentation/widgets/navBar.dart';

/// Main wrapper widget that handles bottom navigation between Home, Add Card, and Profile
class MainWrapper extends StatefulWidget {
  final int initialIndex;
  
  const MainWrapper({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _currentIndex;
  
  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
    const AddCardScreen(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
