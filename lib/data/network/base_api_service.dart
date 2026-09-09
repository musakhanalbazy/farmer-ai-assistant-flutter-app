/// DATA / NETWORK
/// The contract every HTTP call in this app goes through.
/// Repository never calls `http` directly — it only ever talks to this.
abstract class BaseApiService {
  Future<dynamic> getGetResponse(String url, {String? token});

  Future<dynamic> getPostApiResponse(
    String url,
    Map<String, dynamic> data, {
    String? token,
  });

  Future<dynamic> getMultipartApiResponse(
    String url, {
    required String filePath,
    Map<String, String> fields,
    String? token,
    String fileFieldName = 'file',
  });

  Future<dynamic> getMultipartApiResponseFromBytes(
    String url, {
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? fields,
    String? token,
    String fileFieldName = 'image',
  });

  Future<dynamic> getPutApiResponse(
    String url,
    Map<String, dynamic> data, {
    String? token,
  });

  Future<dynamic> getPutMultipartApiResponse(
    String url, {
    required String filePath,
    String? token,
    String fieldName = 'file',
  });
}
