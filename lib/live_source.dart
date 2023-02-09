import 'package:flutter_live_data/index.dart';

class LiveSource<T> extends LiveData<T> {
  LiveDataSourceAdapter<T> adapter;

  LiveSource(
    super.initValue, {
    super.name,
    super.verifyDataChange = false,
    super.streamController,
    super.owner,
    super.logger,
    required this.adapter,
  }) {
    _init();
  }

  Future<LiveSource<T>> asyncInit({required Future<T> Function() loadData}) async {
    value = await loadData();
    return this;
  }

  _init() async {
    if (adapter.loadData != null) {
      value = await adapter.loadData!();
    }
  }

  @override
  set value(T value) => _set(value);

  void _set(T value) {
    if (adapter.saveData != null) {
      if (this.value != value) {
        adapter.saveData!(value);
      }
    }
    super.value = value;
  }

  Future<T> asyncValue(T value) async {
    if (adapter.saveData != null) {
      if (this.value != value) {
        await adapter.saveData!(value);
      }
    }
    super.value = value;
    return value;
  }
}

class LiveDataSourceAdapter<T> {
  final Future<T> Function()? loadData;
  final Future<void> Function(T value)? saveData;

  LiveDataSourceAdapter({
    this.loadData,
    required this.saveData,
  });
}
