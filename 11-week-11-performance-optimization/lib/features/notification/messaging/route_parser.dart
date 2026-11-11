String routeFromMessage(Map<String, dynamic> data) {
  if (data.containsKey('id') &&
      data['id'] != null &&
      data['id'].toString().trim().isNotEmpty) {
    return '/pengumuman/${data['id']}';
  }
  final route = data['route'] as String? ?? '/';
  if (route.isEmpty) return '/';
  return route.startsWith('/') ? route : '/$route';
}
