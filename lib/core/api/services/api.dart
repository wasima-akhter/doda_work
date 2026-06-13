import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../utils/app_storage.dart';
import '../../utils/basic_import.dart';
import 'auths.dart';

class ApiRequest {
  /// ✅ Header Generator with skipAuth option
  static Future<Map<String, String>> _bearerHeaderInfo([
    String? token,
    bool skipAuth = false,
  ]) async {
    final authToken = token ?? AppStorage.token;
    return {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
      // Only add authorization if not skipping auth AND token is not empty
      if (!skipAuth && authToken.isNotEmpty)
        HttpHeaders.authorizationHeader: "Bearer $authToken",
    };
  }

  static void printBody(Map<String, dynamic> body) {
    body.forEach((key, value) {
      debugPrint("🔹 '$key': '$value'");
    });
    debugPrint(
      '╚════════════════════════════════════════════════════════════════════════════════════════════╚═══',
    );
  }

  static void printUrl(String url) {
    debugPrint(
      '╔════════════════════════════════════════════════════════════════════════════════════════════',
    );
    debugPrint("📍 'End Point': '$url'");
  }

  static void printBodyLineByLine(Map<String, dynamic> body) {
    body.forEach((key, value) {
      debugPrint("🔹 '$key': '$value'");
      debugPrint(
        '╚════════════════════════════════════════════════════════════════',
      );
    });
  }

  static void printEndPointLog(String url) {
    debugPrint(
      '╔════════════════════════════════════════════════════════════════',
    );
    debugPrint("📍 'End Point': '$url'");
  }

  /// =========================================================== ✅ POST REQUEST =========================================================== ///
  static Future<R> post<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    String? id,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
    bool skipAuth = false,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('|📤|---------[ 📦 POST REQUEST STARTED ]---------|📤|');

      // ✅ Fix: Properly handle slashes
      String finalEndPoint = endPoint;
      if (id != null) {
        // Remove trailing slash from endpoint if exists
        if (finalEndPoint.endsWith('/')) {
          finalEndPoint = finalEndPoint.substring(0, finalEndPoint.length - 1);
        }
        finalEndPoint = '$finalEndPoint/$id';
      }

      // ✅ Fix: Remove leading slash from endpoint if baseUrl ends with slash
      if (finalEndPoint.startsWith('/') && ApiEndPoints.baseUrl.endsWith('/')) {
        finalEndPoint = finalEndPoint.substring(1);
      }

      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$finalEndPoint',
      ).replace(queryParameters: queryParams);

      printEndPointLog(uri.toString());
      printBodyLineByLine(body);

      final response = await http
          .post(
            uri,
            headers: await _bearerHeaderInfo(null, skipAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      debugPrint(
        '|📬|---------[ RESPONSE STATUS: ${response.statusCode} ]---------|📬|',
      );
      debugPrint(
        '|📬|---------[ RESPONSE BODY: ${response.body} ]---------|📬|',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }

        if (onSuccess != null) onSuccess(result);
        return result;
        // } else {
        //   final error = jsonDecode(response.body);
        //   final errorMessage = error['message'] ?? 'Something went wrong!';
        //   debugPrint('❌ Error: $errorMessage');
        //   CustomSnackBar.error(errorMessage);
        //   throw Exception(errorMessage);
        // }
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body ?? '{}');

        final errorMessage = error['message'] ?? 'Something went wrong!';

        debugPrint('❌ Error: $errorMessage');

        // ============================
        // 🔥 OTP ACTIVATION CASE
        // ============================
        if (errorMessage.toString().toLowerCase().contains("activate")) {
          debugPrint(' activate  ');
          throw OtpRequiredException(
            errorMessage.toString(),
            body['email'].toString() ?? '',
            companyName: body['email'].toString() ?? '',
          );
        }

        CustomSnackBar.error(errorMessage.toString());
        return fromJson({
          "statusCode": response.statusCode,
          "success": false,
          "message": errorMessage,
          "data": null,
        });
      }
    } catch (e) {
      debugPrint('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');

      if (e is OtpRequiredException) {
        CustomSnackBar.error(e.message.toString());
        rethrow;
      }
      CustomSnackBar.error(e.toString());
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
      debugPrint('|✅|---------[ ✅ POST REQUEST COMPLETED ]---------|✅|');
    }
  }

  /// =========================================================== ✅ GET REQUEST =========================================================== ///
  static Future<R> get<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    String? id,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    bool showResponse = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('|📥|---------[ 🌐 GET REQUEST STARTED ]---------|📥|');

      String fullUrl = '${ApiEndPoints.baseUrl}$endPoint';
      if (id != null && id.isNotEmpty) {
        fullUrl += '/$id';
      }
      final uri = Uri.parse(fullUrl).replace(
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      printEndPointLog(uri.toString());

      final response = await http
          .get(uri, headers: await _bearerHeaderInfo())
          .timeout(const Duration(seconds: 120));

      if (showResponse) {
        try {
          final prettyJson = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonDecode(response.body));
          debugPrint('|📤|---------[ RESPONSE BODY ]---------|📤|');
          debugPrint(prettyJson);
          debugPrint('|📤|---------------------------------|📤|');
        } catch (_) {
          debugPrint('|📤| RESPONSE (raw) |📤|: ${response.body}');
        }
      }
      debugPrint('|✅|---------[ ✅ GET REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        debugPrint('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ PATCH REQUEST =========================================================== ///
  static Future<R> patch<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('|📤|---------[ 📦 PATCH REQUEST STARTED ]---------|📤|');

      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$endPoint',
      ).replace(queryParameters: queryParams);

      printEndPointLog(uri.toString());
      printBodyLineByLine(body);

      final response = await http
          .patch(
            uri,
            headers: await _bearerHeaderInfo(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      debugPrint('|✅|---------[ ✅ PATCH REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        debugPrint('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ PUT REQUEST =========================================================== ///
  static Future<R> put<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('|📤|---------[ 📦 PUT REQUEST STARTED ]---------|📤|');

      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$endPoint',
      ).replace(queryParameters: queryParams);

      printEndPointLog(uri.toString());
      printBodyLineByLine(body);

      final response = await http
          .put(uri, headers: await _bearerHeaderInfo(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 120));

      debugPrint('|✅|---------[ ✅ PUT REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        debugPrint('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// =========================================================== ✅ DELETE REQUEST =========================================================== ///
  static Future<R> delete<R>({
    required R Function(Map<String, dynamic>) fromJson,
    required String endPoint,
    required RxBool isLoading,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('|📤|---------[ 📦 DELETE REQUEST STARTED ]---------|📤|');

      final token = AppStorage.token;

      if (token.isEmpty) {
        throw Exception("Token missing");
      }

      final uri = Uri.parse(
        '${ApiEndPoints.baseUrl}$endPoint',
      ).replace(queryParameters: queryParams);

      printEndPointLog(uri.toString());
      if (body != null) printBodyLineByLine(body);

      final response = await http
          .delete(
            uri,
            headers: await _bearerHeaderInfo(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 120));

      debugPrint('|✅|---------[ ✅ DELETE REQUEST COMPLETED ]---------|✅|');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final Map<String, dynamic> json = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};
        final result = fromJson(json);

        final successMessage =
            json['message'] ?? Strings.requestCompletedSuccessfully;
        if (showSuccessSnackBar) {
          CustomSnackBar.success(
            title: Strings.success,
            message: successMessage,
          );
        }
        if (onSuccess != null) onSuccess(result);

        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        debugPrint('❌ Error: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('🐞🐞🐞 UNHANDLED ERROR: ${e.toString()}');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ======================================================== ✅ Multipart POST Method ========================================================= ///
  static Future<R> multiMultipartRequest<R>({
    required String endPoint,
    required RxBool isLoading,
    required String reqType,
    required Map<String, dynamic> body,
    required Map<String, File?> files,
    Map<String, List<File>>? filesList,
    RxList<File>? selectedImages,
    List<String>? sizes,
    String? singleQueryParam,
    required R Function(Map<String, dynamic>) fromJson,
    bool showSuccessSnackBar = false,
    Function(R result)? onSuccess,
    String? token,
    bool skipAuth = false, // ✅ Added skipAuth parameter
  }) async {
    try {
      isLoading.value = true;
      final headers = await _bearerHeaderInfo(
        token,
        skipAuth,
      ); // ✅ Pass skipAuth

      // Build URL
      String fullUrl = '${ApiEndPoints.baseUrl}$endPoint';
      if (singleQueryParam != null && singleQueryParam.isNotEmpty) {
        if (!singleQueryParam.startsWith('/')) fullUrl += '/';
        fullUrl += singleQueryParam;
      }
      final uri = Uri.parse(fullUrl);
      debugPrint('📤 MULTIPART REQUEST STARTED');
      debugPrint('🔗 Method  : $reqType');
      debugPrint('🔐 Skip Auth: $skipAuth'); // ✅ Log auth status
      printBody(body);
      printUrl(uri.toString());

      final request = http.MultipartRequest(reqType.toUpperCase(), uri);
      request.headers.addAll(headers);

      // Add body fields safely
      body.forEach((key, value) {
        if (value is List || value is Map) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value?.toString() ?? '';
        }
      });

      if (sizes != null && sizes.isNotEmpty) {
        request.fields['sizes'] = jsonEncode(sizes);
        debugPrint('📏 SIZES: $sizes');
      }

      // Add single files safely
      for (var entry in files.entries) {
        final file = entry.value;
        if (file == null) continue;

        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        debugPrint('🧪 MIME TYPE for ${entry.key}: $mimeType');

        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Add multiple files from filesList
      if (filesList != null && filesList.isNotEmpty) {
        for (var entry in filesList.entries) {
          final key = entry.key;
          final fileList = entry.value;

          for (var file in fileList) {
            final mimeType =
                lookupMimeType(file.path) ?? 'application/octet-stream';
            debugPrint('📁 Adding file: ${file.path} | MIME: $mimeType');

            request.files.add(
              await http.MultipartFile.fromPath(
                key, // Use the key directly (backend expects 'attachments')
                file.path,
                contentType: MediaType.parse(mimeType),
              ),
            );
          }
        }
      }

      if (selectedImages != null && selectedImages.isNotEmpty) {
        for (var file in selectedImages) {
          final mimeType =
              lookupMimeType(file.path) ?? 'application/octet-stream';
          debugPrint('🖼️ Adding image: ${file.path} | MIME: $mimeType');

          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              file.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📬 RESPONSE STATUS: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final result = fromJson(json);

        if (showSuccessSnackBar) {
          final successMessage =
              json['message'] ?? 'Request completed successfully';
          CustomSnackBar.success(title: 'Success', message: successMessage);
        }

        if (onSuccess != null) onSuccess(result);
        return result;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Something went wrong!';
        debugPrint('❌ MULTIPART ERROR: $errorMessage');
        CustomSnackBar.error(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('🐞 MULTIPART UNHANDLED ERROR: $e');
      throw Exception(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
