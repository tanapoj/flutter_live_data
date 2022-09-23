import 'live_data.dart';

abstract class LifeCycleOwner {
  void observeLiveData<T>(LiveData<T> liveData);
}

abstract class LifeCycleObservable {
  void close();
}
