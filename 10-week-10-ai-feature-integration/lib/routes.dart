class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementPattern = '/pengumuman/:id';
  static const announcementDetail = '/pengumuman/:id';
  static String announcement(String id) => '/pengumuman/$id';
  static const aiChat = '/ai-chat';
  static const aiKey = '/ai-key';
}
