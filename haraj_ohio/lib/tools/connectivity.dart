// connectivity.dart

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtil {
  // Check if we have internet connection
  static Future<bool> isOnline() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        // No network at all, return false instantly
        print('No network connectivity detected');
        return false;
      }

      print('Network type: $connectivityResult, checking internet...');

      // There is a network, but check for real internet
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('Internet connection confirmed');
          return true;
        } else {
          print('No internet connection despite network being available');
          return false;
        }
      } catch (e) {
        print('Internet check failed: $e');
        return false;
      }
    } catch (e) {
      print('Connectivity check failed: $e');
      return false;
    }
  }

  // Check internet connectivity with custom timeout
  static Future<bool> checkInternetConnection(
      {Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final result =
          await InternetAddress.lookup('google.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get connectivity status as string
  static Future<String> getConnectivityStatus() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    switch (connectivityResult) {
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      case ConnectivityResult.vpn:
        return 'vpn';
      case ConnectivityResult.bluetooth:
        return 'bluetooth';
      case ConnectivityResult.other:
        return 'other';
      case ConnectivityResult.none:
        return 'none';
    }
  }
}
