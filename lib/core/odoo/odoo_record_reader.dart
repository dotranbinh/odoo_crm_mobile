import '../network/odoo_json_rpc_client.dart';

class OdooRecordReader {
  OdooRecordReader(this._rpc);

  final OdooJsonRpcClient _rpc;

  static const _chunkSize = 80;

  Future<Map<String, dynamic>> read({
    required String model,
    required int id,
    required List<String> fieldNames,
  }) async {
    if (fieldNames.isEmpty) return {};

    final uniqueFields = [...{...fieldNames, 'id'}];
    final merged = <String, dynamic>{};

    for (var i = 0; i < uniqueFields.length; i += _chunkSize) {
      final chunk = uniqueFields.sublist(
        i,
        i + _chunkSize > uniqueFields.length
            ? uniqueFields.length
            : i + _chunkSize,
      );

      final rows = await _rpc.callKw(
        model: model,
        method: 'read',
        args: [
          [id],
          chunk,
        ],
      );

      if (rows is List && rows.isNotEmpty) {
        final row = rows.first;
        if (row is Map<String, dynamic>) {
          merged.addAll(row);
        } else if (row is Map) {
          merged.addAll(Map<String, dynamic>.from(row));
        }
      }
    }

    return merged;
  }
}
