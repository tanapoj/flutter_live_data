import 'dart:async';

import 'package:flutter_live_data/core.dart';

/// Live Data Structure
class LiveDataMultiStream<T> extends LiveData<T> {
  Map<Symbol, StreamController<T>> streamControllers;
  T _currentValue;
  int streamRunningId = 0;

  LiveDataMultiStream(
    T initValue, {
    String name,
    StreamController<T> streamController,
    LifeCycleObserver lifeCycleObserver,
  })  : this._currentValue = initValue,
        super(
          initValue,
          name: name,
          streamController: streamController,
          lifeCycleObserver: lifeCycleObserver,
        ) {
    streamControllers = {};
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
    Future.sync(() async => await value$(value));
  }

  Future<void> value$(T value) async {
    return await Future.sync(() {
      this._currentValue = value;
      for (var con in streamControllers.values) {
        con?.add(value);
      }
    });
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
    Symbol id = #__,
  }) {
    return stream$(id).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
