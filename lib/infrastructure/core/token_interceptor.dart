// import 'package:dio/dio.dart';
// import 'package:pastiin_mobile_app/domain/core/failures/network/network_failure.dart';
// import 'package:pastiin_mobile_app/domain/core/interface/i_network_service.dart';
// import 'package:pastiin_mobile_app/domain/core/utils/typedef.dart';
// import 'package:pastiin_mobile_app/infrastructure/core/network_service.dart';
//
// class Refresh<T> extends Interceptor with TokenMixin<T>{
//   late INetworkService _httpClient;
//   final TokenHeaderBuilder<T?> _tokenHeader;
//   final ShouldRefresh _shouldRefresh;
//   final ShouldRequest<T>? _shouldRequest;
//   final RefreshToken<T>? _refreshToken;
//
//   Refresh({
//     required TokenHeaderBuilder<T> tokenHeader,
//     required TokenStorage<T> tokenStorage,
//     RefreshToken<T>? refreshToken,
//
//     /// Should Request for the request if you want to check if the T class have timeout Token.
//     ShouldRequest<T>? shouldRequest,
//     ShouldRefresh? shouldRefresh,
//   })  : _refreshToken = refreshToken,
//         _tokenHeader = tokenHeader,
//         _shouldRequest = shouldRequest,
//         _shouldRefresh = shouldRefresh ?? _defaultShouldRefresh {
//     this.tokenStorage = tokenStorage;
//     _httpClient = NetworkService();
//   }
//
//   void updateHttpClient({required NetworkService service}) {
//     _httpClient = service;
//   }
//
//   @override
//   Future<dynamic> onRequest(
//       RequestOptions options,
//       RequestInterceptorHandler handler,
//       ) async {
//     T? currentToken;
//     if (_shouldRequest != null) {
//       currentToken = await _shouldRequest!(await token, _httpClient);
//     } else {
//       currentToken = await token;
//     }
//     final headers = currentToken != null
//         ? _tokenHeader(currentToken)
//         : const <String, String>{};
//     options.headers.addAll(headers);
//     handler.next(options);
//   }
//
//   @override
//   Future<dynamic> onResponse(
//       Response response,
//       ResponseInterceptorHandler handler,
//       ) async {
//     if (await token == null || !_shouldRefresh(response)) {
//       return handler.next(response);
//     }
//     try {
//       final refreshResponse = await _tryRefresh(response);
//       handler.resolve(refreshResponse);
//     } on DioError catch (error) {
//       handler.reject(error);
//     }
//   }
//
//   @override
//   Future<dynamic> onError(
//       DioError err,
//       ErrorInterceptorHandler handler,
//       ) async {
//     final response = err.response;
//     if (response == null ||
//         await token == null ||
//         err.error is RevokeTokenException ||
//         !_shouldRefresh(response)) {
//       return handler.next(err);
//     }
//     try {
//       final refreshResponse = await _tryRefresh(response);
//       handler.resolve(refreshResponse);
//     } on DioError catch (error) {
//       handler.next(error);
//     }
//   }
//
//   Future<Response<dynamic>> _tryRefresh(Response response) async {
//     T? refreshedToken;
//     if (_refreshToken != null) {
//       try {
//         refreshedToken = await _refreshToken!(await token, _httpClient);
//       } on RevokeTokenException catch (error) {
//         await clearToken();
//         throw DioError(
//           requestOptions: response.requestOptions,
//           error: error,
//           response: response,
//         );
//       }
//
//       await setToken(refreshedToken);
//       final Dio _newDio = Dio();
//       _newDio.options.baseUrl = response.requestOptions.baseUrl;
//       return _newDio.request<dynamic>(
//         response.requestOptions.path,
//         cancelToken: response.requestOptions.cancelToken,
//         data: response.requestOptions.data,
//         onReceiveProgress: response.requestOptions.onReceiveProgress,
//         onSendProgress: response.requestOptions.onSendProgress,
//         queryParameters: response.requestOptions.queryParameters,
//         options: Options(
//           method: response.requestOptions.method,
//           sendTimeout: response.requestOptions.sendTimeout,
//           receiveTimeout: response.requestOptions.receiveTimeout,
//           extra: response.requestOptions.extra,
//           headers: response.requestOptions.headers
//             ..addAll(_tokenHeader(refreshedToken)),
//           responseType: response.requestOptions.responseType,
//           contentType: response.requestOptions.contentType,
//           validateStatus: response.requestOptions.validateStatus,
//           receiveDataWhenStatusError:
//           response.requestOptions.receiveDataWhenStatusError,
//           followRedirects: response.requestOptions.followRedirects,
//           maxRedirects: response.requestOptions.maxRedirects,
//           requestEncoder: response.requestOptions.requestEncoder,
//           responseDecoder: response.requestOptions.responseDecoder,
//           listFormat: response.requestOptions.listFormat,
//         ),
//       );
//     } else {
//       throw NetworkFailure;
//     }
//   }
//
//   static bool _defaultShouldRefresh(Response? response) {
//     return response?.statusCode == 401;
//   }
//
// }