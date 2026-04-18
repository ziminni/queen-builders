import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queen Builders Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool _isSidebarExpanded = true;
  int _selectedIndex = 0;

  // Menu items configuration
  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.dashboard_outlined, label: 'Dashboard', index: 0),
    MenuItem(icon: Icons.build_outlined, label: 'Projects', index: 1),
    MenuItem(icon: Icons.inventory_2_outlined, label: 'Inventory', index: 2),
    MenuItem(icon: Icons.people_outline, label: 'Staff', index: 3),
    MenuItem(icon: Icons.bar_chart_outlined, label: 'Reports', index: 4),
    MenuItem(icon: Icons.settings_outlined, label: 'Settings', index: 5),
  ];

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Admin Sidebar Widget
          AdminSidebar(
            isExpanded: _isSidebarExpanded,
            selectedIndex: _selectedIndex,
            menuItems: _menuItems,
            onItemTapped: _onItemTapped,
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Header with toggle button
                HeaderWidget(
                  isSidebarExpanded: _isSidebarExpanded,
                  onToggleSidebar: _toggleSidebar,
                ),
                // Dynamic content based on selected menu item
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const Center(child: Text('Projects Content'));
      case 2:
        return const Center(child: Text('Inventory Content'));
      case 3:
        return const Center(child: Text('Staff Content'));
      case 4:
        return const Center(child: Text('Reports Content'));
      case 5:
        return const Center(child: Text('Settings Content'));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ========== ADMIN SIDEBAR WIDGET ==========
class AdminSidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final List<MenuItem> menuItems;
  final Function(int) onItemTapped;

  const AdminSidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.menuItems,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A), // Dark admin sidebar color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo / Brand Area
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // App Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'QUEEN BUILDERS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == item.index;

                return _buildMenuItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onItemTapped(item.index),
                );
              },
            ),
          ),
          // Logout Button at Bottom
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              isSelected: false,
              onTap: () {
                // Handle logout action
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade800 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[400],
              size: 22,
            ),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========== HEADER WIDGET WITH TOGGLE BUTTON ==========
class HeaderWidget extends StatelessWidget {
  final bool isSidebarExpanded;
  final VoidCallback onToggleSidebar;

  const HeaderWidget({
    super.key,
    required this.isSidebarExpanded,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Toggle button on the very top left
          IconButton(
            onPressed: onToggleSidebar,
            icon: Icon(
              isSidebarExpanded ? Icons.menu_open : Icons.menu,
              size: 28,
              color: const Color(0xFF1A2A3A),
            ),
            tooltip: isSidebarExpanded ? 'Collapse sidebar' : 'Expand sidebar',
          ),
          const SizedBox(width: 16),
          // Page Title (optional, shows current selected page)
          const Text(
            'Admin Portal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2A3A),
            ),
          ),
          const Spacer(),
          // Admin profile or other header items can go here
          CircleAvatar(
            backgroundColor: Colors.amber[700],
            child: const Text(
              'A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Admin',
            style: TextStyle(color: Color(0xFF1A2A3A)),
          ),
        ],
      ),
    );
  }
}

// ========== DASHBOARD CONTENT ==========
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Admin!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2A3A),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your projects today.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          // Dashboard cards
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildDashboardCard('Active Projects', '12', Icons.build),
              _buildDashboardCard('Inventory Items', '245', Icons.inventory),
              _buildDashboardCard('Staff Members', '18', Icons.people),
              _buildDashboardCard('Pending Reports', '3', Icons.bar_chart),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Text('Activity feed will appear here'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.amber[700]),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ========== HELPER MODEL ==========
class MenuItem {
  final IconData icon;
  final String label;
  final int index;

  MenuItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}