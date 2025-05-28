import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldWithBottomNav({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // Можно добавить цвета для выбранных/невыбранных элементов
        // selectedItemColor: Colors.amber[800],
        // unselectedItemColor: Colors.grey,
      ),
    );
  }
} 