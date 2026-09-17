// lib/services/api_models.dart
// Extraído de api_client.dart (ApiResponse/ApiMeta/ApiException/
// ApiResponseExtensions) sin cambios de comportamiento.
class ApiResponse<T> {
  final bool success;
  final T data;
  final ApiMeta? meta;

  ApiResponse({
    required this.success,
    required this.data,
    this.meta,
  });

  @override
  String toString() => 'ApiResponse(success: $success, data: $data, meta: $meta)';
}

class ApiMeta {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  ApiMeta({this.page, this.limit, this.total, this.totalPages});

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page:       json['page']       as int?,
      limit:      json['limit']      as int?,
      total:      json['total']      as int?,
      totalPages: json['totalPages'] as int?,
    );
  }

  @override
  String toString() => 'ApiMeta(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) return 'ApiException ($statusCode): $message';
    return 'ApiException: $message';
  }
}

extension ApiResponseExtensions<T> on ApiResponse<T> {
  bool get hasPagination => meta != null;
  int  get currentPage   => meta?.page       ?? 1;
  int  get totalPages    => meta?.totalPages  ?? 1;
  bool get hasMorePages  => currentPage < totalPages;
}
