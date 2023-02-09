import 'dart:async';
import 'live_data.dart';

@deprecated
class LiveDataSource<T> extends LiveData<T> {
  DataSourceInterface? _dataSourceInterface;

  LiveDataSource(
    super.initValue, {
    super.name,
    super.verifyDataChange,
    super.streamController,
    super.owner,
    super.logger,
    DataSourceInterface? dataSourceInterface,
  }) {
    _init();
  }

  _init() async {
    if (_dataSourceInterface != null) {
      T initValue = await _dataSourceInterface!.loadValue();
      if (initValue != null) {
        value = initValue;
      }
    }
  }

  set dataSourceInterface(DataSourceInterface dataSourceInterface) {
    _dataSourceInterface = dataSourceInterface;
  }

  @override
  set value(T value) {
    setValueAsync(value);
  }

  setValueAsync(T value) async {
    bool hasChange = super.value != value;
    super.value = value;
    await _dataSourceInterface?.onValueUpdated(value, hasChange);
  }
}

@deprecated
abstract class DataSourceInterface<T> {
  Future<void> onValueUpdated(T value, bool hasChange);

  Future<T?> loadValue();
}

DataSourceInterface<T> createDataSourceInterface<T>({
  Future<T> Function()? loadValueAction,
  Future<void> Function(T value, bool hasChange)? onValueUpdatedAction,
}) {
  return _DataSourceInterface<T>(
    loadValueAction: loadValueAction,
    onValueUpdatedAction: onValueUpdatedAction,
  );
}

@deprecated
class _DataSourceInterface<T> extends DataSourceInterface<T> {
  Future<T> Function()? loadValueAction;
  Future<void> Function(T value, bool hasChange)? onValueUpdatedAction;

  _DataSourceInterface({
    this.loadValueAction,
    this.onValueUpdatedAction,
  });

  @override
  Future<T?> loadValue() async {
    return await loadValueAction?.call();
  }

  @override
  Future<void> onValueUpdated(T value, bool hasChange) async {
    await onValueUpdatedAction?.call(value, hasChange);
  }
}
