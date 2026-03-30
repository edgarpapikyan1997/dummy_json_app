import 'package:dio/dio.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _logError(error);
          handler.next(error);
        },
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  late final Dio _dio;

  Dio get dio => _dio;

  void _logError(DioException error) {
    final message = error.message ?? 'Unknown error';
    final response = error.response;
    final statusCode = response?.statusCode;
    final url = error.requestOptions.uri.toString();
    // ignore: avoid_print
    print('[DioClient] ERROR: $message | url=$url | statusCode=$statusCode');
    if (response?.data != null) {
      // ignore: avoid_print
      print('[DioClient] response.data: ${response?.data}');
    }
  }
}
