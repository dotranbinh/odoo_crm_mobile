import '../../../core/utils/html_stripper.dart';

enum MailMessageKind {
  logNote,
  discussion,
  tracking,
  email,
}

class MailMessage {
  const MailMessage({
    required this.id,
    required this.authorName,
    required this.bodyHtml,
    required this.date,
    required this.kind,
    this.subtypeName,
    this.emailFrom,
  });

  final int id;
  final String authorName;
  final String bodyHtml;
  final DateTime date;
  final MailMessageKind kind;
  final String? subtypeName;
  final String? emailFrom;

  String get plainBody => HtmlStripper.toPlainText(bodyHtml);

  String get displayText {
    final body = plainBody;
    if (body.isNotEmpty) return body;
    if (subtypeName != null && subtypeName!.isNotEmpty) return subtypeName!;
    return '';
  }

  factory MailMessage.fromOdoo(Map<String, dynamic> json) {
    final messageType = json['message_type']?.toString() ?? '';
    final subtype = json['subtype_id'];
    String? subtypeName;
    if (subtype is List && subtype.length > 1) {
      subtypeName = subtype[1]?.toString();
    }

    return MailMessage(
      id: json['id'] as int,
      authorName: _authorName(json),
      bodyHtml: json['body']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      kind: _kindFromOdoo(messageType, subtypeName),
      subtypeName: subtypeName,
      emailFrom: json['email_from']?.toString(),
    );
  }

  static MailMessageKind _kindFromOdoo(
    String messageType,
    String? subtypeName,
  ) {
    final sub = subtypeName?.toLowerCase() ?? '';
    if (messageType == 'email') return MailMessageKind.email;
    if (sub.contains('discussion')) return MailMessageKind.discussion;
    if (sub.contains('note')) return MailMessageKind.logNote;
    return MailMessageKind.tracking;
  }

  static String _authorName(Map<String, dynamic> json) {
    final author = json['author_id'];
    if (author is List && author.length > 1) {
      return author[1]?.toString() ?? 'Unknown';
    }
    final emailFrom = json['email_from']?.toString();
    if (emailFrom != null && emailFrom.isNotEmpty) return emailFrom;
    return 'System';
  }
}
