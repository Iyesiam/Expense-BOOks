import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: Colors.blue, // Color for the selected icon
      unselectedItemColor: Colors.blue.shade400, // Color for unselected icons
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold text for selected item
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // Normal text for unselected items
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.book, 0),
          label: 'Books',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.swap_horiz, 1),
          label: 'Archive',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.settings, 2),
          label: 'Settings',
        ),
      ],
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.transparent, // Background for selected icon
        shape: BoxShape.circle, // Circular shape
      ),
      padding: const EdgeInsets.all(8.0), // Add padding for better visuals
      child: Icon(icon, color: isSelected ? Colors.blue : Colors.blue.shade400),
    );
  }
}
