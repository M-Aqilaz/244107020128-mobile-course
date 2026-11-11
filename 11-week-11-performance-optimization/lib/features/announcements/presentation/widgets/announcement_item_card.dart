import 'package:flutter/material.dart';
import '../../domain/entities/announcement.dart';

/// Widget item pengumuman terisolasi untuk optimasi rendering (Step 3 & 4 Codelab Minggu 11).
///
/// Menggunakan:
/// 1. `const` constructor untuk mencegah rebuild widget saat state parent berubah.
/// 2. `RepaintBoundary` untuk membatasi area render/repaint GPU pada masing-masing item list.
/// 3. Tear-off / method reference untuk menghindari pembuatan closure baru per frame.
class AnnouncementItemCard extends StatelessWidget {
  const AnnouncementItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Announcement item;
  final VoidCallback onTap;

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Akademik':
        return Colors.blue;
      case 'Infrastruktur':
        return Colors.orange;
      case 'Workshop':
        return Colors.teal;
      case 'Prestasi':
        return Colors.amber.shade800;
      default:
        return Colors.purple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Akademik':
        return Icons.assignment_rounded;
      case 'Infrastruktur':
        return Icons.cloud_sync_rounded;
      case 'Workshop':
        return Icons.handyman_rounded;
      case 'Prestasi':
        return Icons.emoji_events_rounded;
      default:
        return Icons.room_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(item.category);
    final icon = _getCategoryIcon(item.category);

    return RepaintBoundary(
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.category} • ${item.date}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
