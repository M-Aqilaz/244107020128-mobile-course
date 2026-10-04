import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server timeout. Silakan periksa koneksi Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server kampus. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) {
          return 'Sesi login telah kedaluwarsa (401). Silakan login kembali.';
        } else if (code == 403) {
          return 'Akses ditolak (403). Anda tidak memiliki hak akses.';
        } else if (code == 404) {
          return 'Data pengumuman tidak ditemukan di server (404).';
        } else if (code != null && code >= 500) {
          return 'Terjadi kendala pada server kampus ($code).';
        }
        return 'Respons server tidak valid ($code).';
      default:
        return 'Terjadi kendala jaringan tidak terduga.';
    }
  }
  return error.toString().replaceAll('Exception: ', '');
}
