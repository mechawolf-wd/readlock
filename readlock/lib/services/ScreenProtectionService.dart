import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

class ScreenProtectionService {
  static Future<void> enableProtection() async {
    final bool isWebPlatform = kIsWeb;

    if (isWebPlatform) {
      return;
    }

    final bool isAndroidDevice = Platform.isAndroid;
    final bool isIosDevice = Platform.isIOS;

    try {
      if (isAndroidDevice) {
        await ScreenProtector.preventScreenshotOn();
      }

      if (isIosDevice) {
        await ScreenProtector.preventScreenshotOn();
        await ScreenProtector.protectDataLeakageWithBlur();
      }
    } on Exception catch (error) {
      developer.log('Failed to enable screen protection: $error');
    }
  }

  static Future<void> disableProtection() async {
    final bool isWebPlatform = kIsWeb;

    if (isWebPlatform) {
      return;
    }

    final bool isAndroidDevice = Platform.isAndroid;
    final bool isIosDevice = Platform.isIOS;

    try {
      if (isAndroidDevice) {
        await ScreenProtector.preventScreenshotOff();
      }

      if (isIosDevice) {
        await ScreenProtector.preventScreenshotOff();
        await ScreenProtector.protectDataLeakageWithBlurOff();
      }
    } on Exception catch (error) {
      developer.log('Failed to disable screen protection: $error');
    }
  }
}
