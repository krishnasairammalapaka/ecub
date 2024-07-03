import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BottomNavBar({super.key, required this.onTabChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            backgroundColor: Colors.transparent,
            gap: 8,
            activeColor:Color.fromRGBO(183, 28, 28, 1),
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[200]!,
            color: Colors.black,
            mainAxisAlignment: MainAxisAlignment.center,
            onTabChange: (value) => onTabChange!(value),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
                iconColor: Color.fromRGBO(183, 28, 28, 1),
                textColor: Color.fromRGBO(183, 28, 28, 1),
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                iconColor: Color.fromRGBO(183, 28, 28, 1),
                textColor: Color.fromRGBO(183, 28, 28, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
