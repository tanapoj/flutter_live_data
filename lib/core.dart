import 'dart:async';

import 'package:flutter_live_data/broadcast.dart';
import 'package:flutter_live_data/multi_stream.dart';

/// Life Cycle Observer
abstract class LifeCycleObserver {
  void observeLiveData<T>(LiveData<T> lv);
}

/// Live Data Structure
class LiveData<T> {
  final String name;
  final T initialValue;
  StreamController<T> streamController;
  Stream<T> _stream;
  T _currentValue;
  LifeCycleObserver lifeCycleObserver;

  LiveData(
    T initValue, {
    this.name,
    StreamController<T> streamController,
    LifeCycleObserver lifeCycleObserver,
  })  : this.initialValue = initValue,
        this._currentValue = initValue {
    this.streamController = streamController ?? StreamController<T>();
    bind(lifeCycleObserver);
  }

  LiveData<T> bind(LifeCycleObserver lifeCycleObserver) {
    if (lifeCycleObserver != null) {
      this.lifeCycleObserver = lifeCycleObserver;
      lifeCycleObserver?.observeLiveData<T>(this);
    }
    return this;
  }

  LiveData.fromStream(
    Stream stream, {
    T initValue,
    this.name,
  })  : this._stream = stream,
        this.initialValue = initValue,
        this._currentValue = initValue;

  Stream<T> get stream => streamController?.stream ?? _stream;

  Stream<T> get stream$$ => streamController?.stream ?? _stream;

  Stream<T> stream$(Symbol _) => stream;

  set value(T value) {
    this._currentValue = value;
    try {
      streamController?.add(value);
    } catch (e) {
      streamController?.close();
      streamController = null;
    }
  }

  T get value => this._currentValue;

  void mutate(void Function(T) setter){
    setter(this._currentValue);
    value = this._currentValue;
  }

  void transform(T Function(T) setter){
    value = setter(this._currentValue);
  }

  void dispose() {
    streamController.close();
  }

  StreamSubscription<T> subscribe(
    void onData(T event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
    Symbol id = #__,
  }) {
    return streamController.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension Transform<T> on LiveData<T> {
  LiveData<T> asBroadcast() => LiveDataBroadcast(
        initialValue,
        name: name,
        lifeCycleObserver: lifeCycleObserver,
        streamController: streamController,
      );

  LiveData<T> asMultiStream() => LiveDataMultiStream(
        initialValue,
        name: name,
        lifeCycleObserver: lifeCycleObserver,
        streamController: streamController,
      );
}
