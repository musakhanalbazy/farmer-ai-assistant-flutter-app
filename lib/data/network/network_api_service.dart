import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../app_exceptions.dart';
import 'base_api_service.dart';

/// DATA / NETWORK
/// The only class in the app that imports `package:http`.
/// Every request goes through here, every response goes through
/// [_returnResponse] so status-code handling is written exactly once.
class NetworkApiService extends BaseApiService {
  static const _timeout = Duration(seconds: 15);

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  @override
  Future<dynamic> getGetResponse(String url, {String? token}) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers(token))
          .timeout(_timeout);
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  @override
  Future<dynamic> getPostApiResponse(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(url), headers: _headers(token), body: jsonEncode(data))
          .timeout(_timeout);
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  @override
  Future<dynamic> getMultipartApiResponse(
    String url, {
    required String filePath,
    Map<String, String> fields = const {},
    String? token,
    String fileFieldName = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName, filePath),
      );

      final streamed = await request.send().timeout(_timeout);
      final responseBody = await streamed.stream.bytesToString();
      return _returnResponse(
        http.Response(responseBody, streamed.statusCode),
      );
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  @override
  Future<dynamic> getMultipartApiResponseFromBytes(
    String url, {
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? fields,
    String? token,
    String fileFieldName = 'image',
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      request.files.add(
        http.MultipartFile.fromBytes(fileFieldName, fileBytes, filename: fileName),
      );

      final streamed = await request.send().timeout(_timeout);
      final responseBody = await streamed.stream.bytesToString();
      return _returnResponse(
        http.Response(responseBody, streamed.statusCode),
      );
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  @override
  Future<dynamic> getPutApiResponse(
    String url,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http
          .put(Uri.parse(url), headers: _headers(token), body: jsonEncode(data))
          .timeout(_timeout);
      return _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  @override
  Future<dynamic> getPutMultipartApiResponse(
    String url, {
    required String filePath,
    String? token,
    String fieldName = 'file',
  }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse(url));
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      final streamed = await request.send().timeout(_timeout);
      final responseBody = await streamed.stream.bytesToString();
      return _returnResponse(http.Response(responseBody, streamed.statusCode));
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } on http.ClientException {
      throw FetchDataException('Communication Error');
    }
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body.isEmpty ? '{}' : response.body);
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      default:
        throw FetchDataException(
            'Error occurred with code: ${response.statusCode}');
    }
  }
}
