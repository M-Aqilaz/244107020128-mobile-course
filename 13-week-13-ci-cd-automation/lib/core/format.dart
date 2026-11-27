String formatAnnouncementDate(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final day = dateTime.day.toString().padLeft(2, '0');
  final month = months[dateTime.month - 1];
  final year = dateTime.year;
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '$day $month $year, $hour:$minute WIB';
}

String maskSecurityToken(String? token) {
  if (token == null || token.isEmpty) return 'Belum tersedia';
  if (token.length <= 16) return token;
  final start = token.substring(0, 8);
  final end = token.substring(token.length - 6);
  return '$start...$end';
}
