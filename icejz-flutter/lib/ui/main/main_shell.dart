import 'package:flutter/material.dart';
import 'package:icejz_app/theme/app_colors.dart';
import 'package:icejz_app/ui/home/home_page.dart';
import 'package:icejz_app/ui/mine/mine_page.dart';
import 'package:icejz_app/ui/workbench/workbench_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.authEpoch,
    required this.onNavigate,
    required this.onLogout,
  });

  final int authEpoch;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iceCanvas,
      body: IndexedStack(
        index: tab,
        children: [
          HomePage(
            authEpoch: widget.authEpoch,
            onNavigate: widget.onNavigate,
            onOpenWorkbench: () => setState(() => tab = 1),
          ),
          WorkbenchPage(
            authEpoch: widget.authEpoch,
            onNavigate: widget.onNavigate,
          ),
          MinePage(
            authEpoch: widget.authEpoch,
            onNavigate: widget.onNavigate,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        indicatorColor: AppColors.iceCyan.withValues(alpha: 0.12),
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_outlined, color: AppColors.iceCyan),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_outlined, color: AppColors.iceCyan),
            label: '工作台',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person_outline, color: AppColors.iceCyan),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
