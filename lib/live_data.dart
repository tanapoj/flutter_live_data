import 'dart:async';
import 'package:logger/logger.dart' as leisim;
import 'log.dart';
import 'life_cycle.dart';

/// Live Data Structure
class LiveData<T> implements LifeCycleObservable {
  final String? name;
  final T initialValue;
  final bool verifyDataChange;
  T _currentValue;
  LifeCycleOwner? _lifeCycleObserver;
  late StreamController<T> streamController;
  late leisim.Logger logger;
  Map<dynamic, dynamic> attachedItems = {};
  List<void Function(LiveData<T> liveData)> apples = [];

  LiveData(
      T initValue, {
        this.name,
        this.verifyDataChange = false,
        StreamController<T>? streamController,
        LifeCycleOwner? owner,
        leisim.Logger? logger,
      })  : initialValue = initValue,
        _currentValue = initValue {
    this.logger = logger ?? Logger.instance;
    this.streamController = streamController ?? StreamController<T>.broadcast();
    if (owner != null) {
      this.owner(owner);
    }
  }

  factory LiveData.broadcast(
      T initValue, {
        String? name,
        bool verifyDataChange = false,
        StreamController<T>? streamController,
        LifeCycleOwner? observeOn,
        Logger? logger,
      }) {
    return LiveData(
      initValue,
      name: name,
      verifyDataChange: verifyDataChange,
      streamController: streamController,
      owner: observeOn,
      logger: logger,
    );
  }

  factory LiveData.single(
      T initValue, {
        String? name,
        bool verifyDataChange = false,
        StreamController<T>? streamController,
        LifeCycleOwner? observeOn,
        Logger? logger,
      }) {
    LiveData<T> _this = LiveData<T>(
      initValue,
      name: name,
      verifyDataChange: verifyDataChange,
    );
    _this.streamController = streamController ?? StreamController<T>();
    _this._currentValue = initValue;
    _this.logger = logger ?? Logger.instance;
    _this.streamController = streamController ?? StreamController<T>();
    if (observeOn != null) {
      _this.owner(observeOn);
    }
    return _this;
  }

  factory LiveData.stream(
      T initValue,
      Stream<T> stream, {
        String? name,
        bool verifyDataChange = false,
        StreamController<T>? streamController,
        LifeCycleOwner? observeOn,
        Logger? logger,
      }) {
    streamController ??= StreamController<T>.broadcast();
    streamController.addStream(stream);
    return LiveData(
      initValue,
      name: name,
      verifyDataChange: verifyDataChange,
      streamController: streamController,
      owner: observeOn,
      logger: logger,
    );
  }

  LiveData<T> owner(LifeCycleOwner lifeCycleOwner) {
    logger.i('${Logger.tag('[LIVEDATA${name == null ? '' : ': $name'}]')} '
        'subscribe on lifeCycleOwner: $lifeCycleOwner');
    _lifeCycleObserver = lifeCycleOwner;
    _lifeCycleObserver?.observeLiveData<T>(this);
    return this;
  }

  Stream<T>? get stream => streamController.stream;

  LifeCycleOwner? get lifeCycleObserver => _lifeCycleObserver;

  // Setter & Getter
  set value(T value) => _set(value, verifyDataChange);

  T get value => _currentValue;

  void _set(T value, bool verifyDataChange) {
    if (streamController.isClosed) {
      logger.e('[LIVEDATA${name == null ? '' : ': $name'}] is called after close stream!');
      return;
    }

    if (verifyDataChange && _currentValue == value) {
      logger.i('${Logger.tag('[LIVEDATA${name == null ? '' : ': $name'}]')} '
          'value not changed (old:$_currentValue = new:$value), do not update LiveData');
      return;
    }

    logger.i('${Logger.tag('[LIVEDATA${name == null ? '' : ': $name'}]')} '
        'set value: $_currentValue --> $value');
    _currentValue = value;

    if (apples.isNotEmpty) {
      for (var fn in apples) {
        applyOnce(fn);
      }
    }

    try {
      streamController.add(value);
    } catch (e) {
      close();
    }
  }

  // LiveData<T> preSet(T value) {
  //   _set(value, verifyDataChange);
  //   return this;
  // }

  _Just<T> get just => _Just(onSet: (value) => _set(value, verifyDataChange));

  // mutate
  LiveData<T> patch(void Function(T) setter) {
    setter(_currentValue);
    // value = _currentValue;
    _set(_currentValue, verifyDataChange);
    return this;
  }

  LiveData<T> transform(T Function(T) setter) {
    // value = setter(_currentValue);
    _set(setter(_currentValue), verifyDataChange);
    return this;
  }

  LiveData<T> tick({bool? verifyDataChange}) {
    // value = _currentValue;
    _set(_currentValue, verifyDataChange ?? this.verifyDataChange);
    return this;
  }

  LiveData<T> apply(void Function(LiveData<T> liveData) apply) {
    apples.add(apply);
    applyOnce(apply);
    return this;
  }

  LiveData<T> applyOnce(void Function(LiveData<T> liveData) apply) {
    apply(this);
    return this;
  }

  @override
  void close() {
    logger.i('${Logger.tag('[LIVEDATA${name == null ? '' : ': $name'}]')} '
        'close.');
    if (attachedItems.isNotEmpty) {
      for (var l in attachedItems.values) {
        if (l is LiveData) {
          l.close();
        }
      }
    }
    streamController.close();
  }

  StreamSubscription<T>? listen(
      void Function(T value) onData, {
        void Function()? onDone,
        Function? onError,
        bool? cancelOnError,
      }) {
    StreamSubscription<T>? subscription = stream?.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    return subscription;
  }

  @override
  String toString() {
    // return 'LiveData{name: $name, initialValue: $initialValue, _currentValue: $_currentValue, _lifeCycleObserver: $_lifeCycleObserver, streamController: $streamController, logger: $logger, attachedItems: $attachedItems, apples: $apples}';
    return 'LiveData{$name, $_currentValue}';
  }
}

class _Just<T> {
  late final void Function(T value) _onSet;

  _Just({
    required void Function(T value) onSet,
  }) {
    _onSet = onSet;
  }

  set value(T value) {
    _onSet(value);
  }
}

LiveData<C> attach<P, C>(
    LiveData<P> parent,
    C child, {
      String? name,
    }) {
  return parent.attachedItems[child] = LiveData<C>(
    child,
    name: name ?? (parent.name != null ? '${parent.name}-child' : null),
  );
}

bool unAttach<P, C>(LiveData<P> parent, C child) {
  var len = parent.attachedItems.length;
  parent.attachedItems.removeWhere((key, value) => identical(key, child));
  return parent.attachedItems.length < len;
}

LiveData<C>? detach<P, C>(LiveData<P> parent, C child) {
  for (var item in parent.attachedItems.keys) {
    if (identical(item, child)) {
      return parent.attachedItems.containsKey(child) ? parent.attachedItems[child] : null;
    }
  }
  return null;
}

extension DetachLiveData<P, C> on LiveData<P> {
  LiveData<C>? detachBy(C Function(LiveData<P> lv) detacher) {
    return detach<P, C>(this, detacher(this));
  }

  // O let<I, O>(I value, O Function(I value) runner) {
  //   return runner(value);
  // }

  C then<T>(C Function(LiveData<P> value) runner) {
    return runner(this);
  }
}

void Function(LiveData<List<T>> liveData) eachItemsInListAsLiveData<T>({
  void Function(LiveData<T> item)? then,
}) {
  return (LiveData<List<T>> liveData) {
    int i = 0;
    for (var element in liveData.value) {
      LiveData<T> lv = attach(
        liveData,
        element,
        name: '${liveData.name ?? ''}[$i]',
      );
      then?.call(lv);
      i++;
    }
  };
}
