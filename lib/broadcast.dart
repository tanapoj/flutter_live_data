import 'dart:async';

import 'core.dart';

/// Live Data Structure
class LiveDataBroadcast<T> extends LiveData<T> {
  LiveDataBroadcast(
    T initValue, {
    String name,
    LifeCycleObserver lifeCycleObserver,
    StreamController<T> streamController,
  }) : super(
          initValue,
          name: name,
          streamController: StreamController<T>.broadcast(),
          lifeCycleObserver: lifeCycleObserver,
        );
}
