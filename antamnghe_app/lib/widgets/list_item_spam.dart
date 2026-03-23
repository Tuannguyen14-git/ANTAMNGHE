import 'package:flutter/material.dart';

class ListItemSpam extends StatelessWidget {
  final String phone;
  final String? label;
  final VoidCallback? onTap;

  const ListItemSpam({super.key, required this.phone, this.label, this.onTap});

  Color _badgeColor(String phone) {
    // simple deterministic color based on last digit
    final code = phone.isNotEmpty ? phone.codeUnitAt(phone.length - 1) : 0;
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
    ];
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeColor(phone);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromARGB(
                  (0.12 * 255).round(),
                  (badge.value >> 16) & 0xFF,
                  (badge.value >> 8) & 0xFF,
                  badge.value & 0xFF,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: badge,
                child: Text(
                  phone.length >= 2 ? phone.substring(phone.length - 2) : phone,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phone, style: Theme.of(context).textTheme.bodyMedium),
                  if (label != null) const SizedBox(height: 4),
                  if (label != null)
                    Text(
                      label!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
