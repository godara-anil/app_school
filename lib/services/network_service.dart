import 'dart:async';
import 'dart:io';

class NetworkService {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'www.googleapis.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty &&
          result.any(
            (address) => address.rawAddress.isNotEmpty,
          );
    } on Object {
      return false;
    }
  }
}
