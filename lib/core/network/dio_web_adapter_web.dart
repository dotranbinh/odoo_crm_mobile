import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

void applyWebAdapter(Dio dio) {
  final adapter = BrowserHttpClientAdapter();
  // Web auth uses external /jsonrpc (uid + password), not session cookies.
  // withCredentials must stay false so Odoo can respond with cors='*'.
  adapter.withCredentials = false;
  dio.httpClientAdapter = adapter;
}
