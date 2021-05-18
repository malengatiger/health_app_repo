import "package:dio/dio.dart";

class Client {
  Dio init() {
    Dio _dio = new Dio();
    _dio.interceptors.add(new ApiInterceptors());
    _dio.options.baseUrl = "http://example.com/api";
    return _dio;
  }
}

class ApiInterceptors extends Interceptor {}
