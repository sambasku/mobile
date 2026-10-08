import 'dart:async';

import '../../domain/repositories/network_monitor_repository.dart';
import '../models/network_request_record.dart';

class InMemoryNetworkMonitorRepository implements NetworkMonitorRepository {
  final List<NetworkRequestRecord> _records = <NetworkRequestRecord>[];
  final StreamController<List<NetworkRequestRecord>> _controller =
      StreamController<List<NetworkRequestRecord>>.broadcast();

  /// Cap memori riwayat (#73) - dev tool, cukup ringkasan terkini.
  static const _maxRecords = 200;

  @override
  void clear() {
    _records.clear();
    _emit();
  }

  @override
  List<NetworkRequestRecord> getRecords() => List.unmodifiable(_records);

  @override
  void upsertRecord(NetworkRequestRecord record) {
    final index = _records.indexWhere((item) => item.id == record.id);

    if (index == -1) {
      _records.insert(0, record);
      if (_records.length > _maxRecords) {
        _records.removeLast();
      }
    } else {
      _records[index] = record;
    }

    _emit();
  }

  @override
  Stream<List<NetworkRequestRecord>> watchRecords() async* {
    yield getRecords();
    yield* _controller.stream;
  }

  void _emit() {
    _controller.add(getRecords());
  }
}
