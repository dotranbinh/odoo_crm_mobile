import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../domain/mail_message.dart';

class LeadChatterRepository {
  LeadChatterRepository(this._rpc);

  final OdooJsonRpcClient _rpc;

  static const _leadModel = 'crm.lead';
  static const _messageModel = 'mail.message';

  Future<List<MailMessage>> fetchMessages(int leadId, {int limit = 40}) async {
    if (!AppConfig.useRealApi) {
      return _mockMessages(leadId);
    }

    final rows = await _rpc.callKw(
      model: _messageModel,
      method: 'search_read',
      args: [
        [
          ['model', '=', _leadModel],
          ['res_id', '=', leadId],
          ['message_type', '!=', 'user_notification'],
        ],
      ],
      kwargs: {
        'fields': [
          'id',
          'body',
          'date',
          'author_id',
          'message_type',
          'subtype_id',
          'email_from',
        ],
        'order': 'date desc',
        'limit': limit,
      },
    );

    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) MailMessage.fromOdoo(row),
    ];
  }

  Future<void> postLogNote({
    required int leadId,
    required String body,
  }) =>
      _postMessage(
        leadId: leadId,
        body: body,
        subtypeXmlId: 'mail.mt_note',
      );

  Future<void> postDiscussion({
    required int leadId,
    required String body,
  }) =>
      _postMessage(
        leadId: leadId,
        body: body,
        subtypeXmlId: 'mail.mt_comment',
      );

  Future<void> _postMessage({
    required int leadId,
    required String body,
    required String subtypeXmlId,
  }) async {
    if (!AppConfig.useRealApi) return;

    await _rpc.callKw(
      model: _leadModel,
      method: 'message_post',
      args: [
        [leadId],
      ],
      kwargs: {
        'body': body,
        'message_type': 'comment',
        'subtype_xmlid': subtypeXmlId,
      },
    );
  }

  List<MailMessage> _mockMessages(int leadId) {
    final now = DateTime.now();
    return [
      MailMessage(
        id: 1,
        authorName: 'Administrator',
        bodyHtml: '<p>Follow-up call scheduled for lead #$leadId.</p>',
        date: now.subtract(const Duration(hours: 2)),
        kind: MailMessageKind.logNote,
        subtypeName: 'Note',
      ),
      MailMessage(
        id: 2,
        authorName: 'Jane Doe',
        bodyHtml: '<p>Customer asked for pricing details.</p>',
        date: now.subtract(const Duration(days: 1)),
        kind: MailMessageKind.discussion,
        subtypeName: 'Discussions',
      ),
      MailMessage(
        id: 3,
        authorName: 'System',
        bodyHtml: '',
        date: now.subtract(const Duration(days: 2)),
        kind: MailMessageKind.tracking,
        subtypeName: 'Stage Changed',
      ),
    ];
  }
}

final leadChatterRepositoryProvider = Provider<LeadChatterRepository>(
  (ref) => LeadChatterRepository(ref.watch(odooJsonRpcClientProvider)),
);
