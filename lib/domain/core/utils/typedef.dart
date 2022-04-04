import 'package:dio/dio.dart';
import 'package:pastiin_mobile_app/domain/core/interface/i_network_service.dart';

typedef ShouldRefresh = bool Function(Response? response);

typedef RefreshToken<T> = Future<T?> Function(
    T? token,
    INetworkService httpClient,
    );

typedef ShouldRequest<T> = Future<T?> Function(
    T? token,
    INetworkService httpClient,
    );

typedef TokenHeaderBuilder<T> = Map<String, String> Function(
    T? token,
    );