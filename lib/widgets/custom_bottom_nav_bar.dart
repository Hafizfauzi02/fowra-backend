import 'package:flutter/material.dart';
import 'package:fowra/screens/agribot_screen.dart';
import 'package:fowra/screens/calendar_screen.dart';
import 'package:fowra/screens/my_diary_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const AgribotScreen();
        break;
      case 1:
        targetScreen = const CalendarScreen();
        break;
      case 2:
        targetScreen = const MyDiaryScreen();
        break;
      default:
        targetScreen = const CalendarScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => targetScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50), // Main green bottom bar
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                iconData: Icons.local_florist_outlined,
                index: 0,
              ),
              // Placeholder for Calendar to keep spacing
              const SizedBox(width: 80),
              _buildNavItem(
                context,
                iconData: Icons.menu_book_outlined,
                index: 2,
              ),
            ],
          ),
          // Floating Calendar Icon
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => _onItemTapped(context, 1),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: currentIndex == 1
                      ? const Color(0xFFF44336) // Red circle for selected
                      : const Color(
                          0xFF4CAF50,
                        ), // Green for unselected (optional visual tweak, keeping red as per design usually)
                  shape: BoxShape.circle,
                  border: currentIndex != 1
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: currentIndex == 1
                      ? [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 30),
                    SizedBox(height: 4),
                    Text(
                      'Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData iconData,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          iconData,
          color: isSelected ? Colors.white : Colors.white70,
          size: 30,
        ),
      ),
    );
  }
}
