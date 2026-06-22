import 'package:url_launcher/url_launcher.dart';

abstract final class UrlLauncherUtil {
  static Future<bool> launchPhone(String phone) =>
      _launch(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  static Future<bool> launchSms(String phone) =>
      _launch(Uri(scheme: 'sms', path: phone.replaceAll(' ', '')));

  static Future<bool> launchEmail(String email) =>
      _launch(Uri(scheme: 'mailto', path: email));

  static Future<bool> _launch(Uri uri) async {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
