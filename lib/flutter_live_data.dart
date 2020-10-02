import 'dart:async';

/// Life Cycle Observer
abstract class LifeCycleObserver {
  void observeLiveData<T>(LiveData<T> lv);
}

/// Live Data Structure
class LiveData<T> {
  final String name;
  final T initialValue;
  Map<Symbol, StreamController<T>> streamControllers;
  T _currentValue;
  int streamRunningId = 0;

  LiveData({
    T initValue,
    this.name,
  })  : this.initialValue = initValue,
        this._currentValue = initValue {
    streamControllers = {};
  }

  factory LiveData.bindWith(
    LifeCycleObserver lifeCycleObserver, {
    T initValue,
    String name,
  }) {
    var liveData = LiveData(initValue: initValue, name: name);
    lifeCycleObserver?.observeLiveData(liveData);
    return liveData;
  }

  T get value => this._currentValue;

  Stream<T> get stream => stream$(#_);

  Stream<T> get stream$$ => stream$(Symbol('${++streamRunningId}'));

  Stream<T> stream$(Symbol symbol) {
    symbol ??= #_;
    if (!streamControllers.containsKey(symbol)) {
      streamControllers[symbol] = StreamController<T>();
    }
    return streamControllers[symbol].stream;
  }

  set value(T value) {
    this._currentValue = value;
    for (var con in streamControllers.values) {
      con?.add(value);
    }
  }

  void dispose() {
    for (var con in streamControllers.values ?? []) {
      con?.close();
    }
    streamControllers?.clear();
  }

  StreamSubscription<T> subscribe(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
    Symbol id = #_,
  }) {
    return stream$(id).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
