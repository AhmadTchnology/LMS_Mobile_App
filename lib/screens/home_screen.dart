import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/announcement_provider.dart';
import '../theme/app_color_extension.dart';
import 'lectures_screen.dart';
import 'ai_chat_screen.dart';
import 'announcements_screen.dart';
import 'about_screen.dart';
import 'customize_colors_screen.dart';
import 'admin_management_screen.dart';
import 'admin_users_screen.dart';
import 'admin_announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    LecturesScreen(),
    AiChatScreen(),
    AnnouncementsScreen(),
    AboutScreen(),
    CustomizeColorsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'AI Assistant',
    'Announcements',
    'About Us',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final user = authProvider.user;

    // Check unread announcements
    final unreadCount = announcementProvider.announcements.where((a) {
      return !(user?.unreadAnnouncements.contains(a.id) ?? false);
    }).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? AppTheme.textPrimary
                : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode
            ? AppTheme.darkCard
            : AppTheme.lightCard,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode
              ? AppTheme.textPrimary
              : AppTheme.lightTextPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  setState(() => _currentIndex = 2);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? AppTheme.darkCard
              : AppTheme.lightCard,
          border: Border(
            top: BorderSide(
              color: themeProvider.isDarkMode
                  ? AppTheme.darkBorder.withValues(alpha: 0.3)
                  : AppTheme.lightBorder.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: themeProvider.isDarkMode
              ? AppTheme.textMuted
              : AppTheme.lightTextMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Lectures',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount.toString()),
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
              activeIcon: const Icon(Icons.notifications),
              label: 'Alerts',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.color_lens_outlined),
              activeIcon: Icon(Icons.color_lens),
              label: 'Theme',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, dynamic user) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              user?.name ?? 'User Name',
              style: TextStyle(
                color: isDark
                    ? AppTheme.textPrimary
                    : AppTheme.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? 'email@university.edu',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'STUDENT',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
                _buildDrawerItem(Icons.chat_bubble_outline, 'AI Assistant', 1),
                _buildDrawerItem(Icons.notifications_none, 'Announcements', 2),
                const Divider(indent: 20, endIndent: 20),
                if (user?.isAdmin ?? false) ...[
                  ListTile(
                    leading: Icon(
                      Icons.admin_panel_settings_outlined,
                      color: isDark
                          ? AppTheme.textMuted
                          : AppTheme.lightTextMuted,
                    ),
                    title: Text(
                      'User Management',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lightTextPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminManagementScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.people_outline,
                      color: isDark
                          ? AppTheme.textMuted
                          : AppTheme.lightTextMuted,
                    ),
                    title: Text(
                      'Users List',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lightTextPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersScreen(),
                        ),
                      );
                    },
                  ),
                ],
                if (user?.canCreateAnnouncement ?? false) ...[
                  ListTile(
                    leading: Icon(
                      Icons.campaign_outlined,
                      color: isDark
                          ? AppTheme.textMuted
                          : AppTheme.lightTextMuted,
                    ),
                    title: Text(
                      'Manage Announcements',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lightTextPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAnnouncementsScreen(),
                        ),
                      );
                    },
                  ),
                ],
                _buildDrawerItem(Icons.info_outline, 'About System', 3),
                _buildDrawerItem(
                  Icons.color_lens_outlined,
                  'Color Customization',
                  4,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: context.colors.danger),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: context.colors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppTheme.textMuted : AppTheme.lightTextMuted),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
