import 'dart:io';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  /// Converts any exception or error into a user-friendly, secure message.
  /// Never leaks stack traces, internal paths, raw SQL/database errors, or class names.
  static String getMessage(dynamic error, [String? fallback]) {
    // Log full error details in debug mode for developer diagnosis
    if (kDebugMode) {
      debugPrint('[ErrorHandler] Full Error Details: $error');
      if (error is Error && error.stackTrace != null) {
        debugPrint('[ErrorHandler] Stack Trace:\n${error.stackTrace}');
      }
    }

    if (error == null) {
      return fallback ?? 'An unexpected error occurred. Please try again.';
    }

    final errorStr = error.toString().toLowerCase();

    // 1. Network / Connectivity Errors
    if (error is SocketException ||
        errorStr.contains('socketexception') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('network is unreachable') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('network error')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }

    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'The request took too long to respond. Please try again.';
    }

    // 2. Authentication Errors
    if (errorStr.contains('user-not-found') ||
        errorStr.contains('wrong-password') ||
        errorStr.contains('invalid-credential')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (errorStr.contains('email-already-in-use')) {
      return 'An account with this email address already exists. Please sign in instead.';
    }

    if (errorStr.contains('weak-password')) {
      return 'Password is too weak. Please use at least 9 characters with letters, numbers, and special characters.';
    }

    if (errorStr.contains('user-disabled')) {
      return 'This account has been deactivated. Please contact support.';
    }

    if (errorStr.contains('requires-recent-login')) {
      return 'Please log in again before updating your sensitive security settings.';
    }

    // 3. Permission & Database Errors
    if (errorStr.contains('permission-denied') || errorStr.contains('unauthorized')) {
      return 'You do not have permission to perform this action. Please sign in again.';
    }

    if (errorStr.contains('not-found')) {
      return 'The requested item could not be found.';
    }

    // 4. Rate Limiting (429)
    if (errorStr.contains('429') || errorStr.contains('too many requests')) {
      return 'Too many requests. Please wait a moment before trying again.';
    }

    // 5. Image & Storage Errors
    if (errorStr.contains('image') && (errorStr.contains('corrupt') || errorStr.contains('format') || errorStr.contains('decode'))) {
      return 'Unable to process the selected photo. Please choose a different image.';
    }

    // 6. Generic Safe Fallback
    return fallback ?? 'Something went wrong. Please try again later.';
  }
}
