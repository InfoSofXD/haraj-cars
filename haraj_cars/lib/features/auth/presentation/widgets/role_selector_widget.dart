import 'package:flutter/material.dart';
import '../../../../core/constants/user_roles.dart';

class RoleSelectorWidget extends StatelessWidget {
  final UserRole selectedRole;
  final Function(UserRole) onRoleChanged;

  const RoleSelectorWidget({
    Key? key,
    required this.selectedRole,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildRoleOption(
                context,
                UserRole.client,
                'Client',
                'Browse cars and manage favorites',
                Icons.person,
              ),
              const Divider(height: 1),
              _buildRoleOption(
                context,
                UserRole.worker,
                'Worker',
                'Add, edit, and manage cars',
                Icons.work,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    UserRole role,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = selectedRole == role;
    
    return InkWell(
      onTap: () => onRoleChanged(role),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF1565C0).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? const Color(0xFF1565C0)
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? const Color(0xFF1565C0)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1565C0),
                size: 24,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
