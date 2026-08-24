import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class CloudflareStorageService {
  /// Uploads an image securely through the FitLens Backend Storage Proxy,
  /// with automatic fallback to Firebase Storage and resilient data URI fallback.
  static Future<String> uploadImage(Uint8List imageBytes, String filename) async {
    final safeName = filename.replaceAll(' ', '_');
    final user = FirebaseAuth.instance.currentUser;

    // 1. Try Backend Storage Proxy with Bearer Auth Token
    try {
      final idToken = await user?.getIdToken();
      final url = Uri.parse('${ApiConstants.backendBaseUrl}/api/storage/upload');
      final body = jsonEncode({
        'fileName': safeName,
        'imageBase64': base64Encode(imageBytes),
      });

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (idToken != null) 'Authorization': 'Bearer $idToken',
              ...ApiConstants.defaultHeaders,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final publicUrl = jsonResponse['url'] as String?;
        if (publicUrl != null && publicUrl.isNotEmpty) {
          return publicUrl;
        }
      }
    } catch (e) {
      debugPrint('[StorageService] Backend proxy upload skipped/failed: $e. Using Firebase Storage.');
    }

    // 2. Fallback: Direct Firebase Storage Upload
    try {
      final uid = user?.uid ?? 'anonymous';
      final storageRef = FirebaseStorage.instance.ref().child('uploads/$uid/$safeName');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': uid,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = await storageRef.putData(imageBytes, metadata).timeout(
        const Duration(seconds: 15),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      if (downloadUrl.isNotEmpty) {
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('[StorageService] Firebase Storage upload error: $e');
    }

    // 3. Fallback: Data URI (for smaller compressed images up to 400KB)
    if (imageBytes.lengthInBytes <= 400 * 1024) {
      debugPrint('[StorageService] Generated Data URI fallback.');
      return 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
    }

    throw Exception('Failed to upload image to cloud storage. Please check your internet connection.');
  }
}
