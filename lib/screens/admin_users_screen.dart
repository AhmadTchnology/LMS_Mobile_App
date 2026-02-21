import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../theme/app_color_extension.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Registered Users',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                ),
              ),
            );
          }

          final users = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(context, user, isDark, firestoreService);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    UserModel user,
    bool isDark,
    FirestoreService service,
  ) {
    Color roleBadgeColor;
    switch (user.role.toLowerCase()) {
      case 'admin':
        roleBadgeColor = Theme.of(context).colorScheme.primary;
        break;
      case 'teacher':
        roleBadgeColor = AppTheme.success;
        break;
      default:
        roleBadgeColor = const Color(0xFFF59E0B);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Role badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 12, right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: roleBadgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role.substring(0, 1).toUpperCase() +
                    user.role.substring(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // User avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              user.name,
              style: TextStyle(
                color: isDark
                    ? AppTheme.textPrimary
                    : AppTheme.lightTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              user.email,
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                      .withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _showEditDialog(context, user, service),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _confirmDelete(context, user, service),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.danger,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    UserModel user,
    FirestoreService service,
  ) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit ${user.name}'),
          content: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'student', child: Text('Student')),
              DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (val) => setDialogState(() => selectedRole = val!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await service.updateUserRole(user.id, selectedRole);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    UserModel user,
    FirestoreService service,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteUser(user.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
