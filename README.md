# flutter_live_data

Live Data is wrapper class over Stream, provide robust methods.

view full-document at: [https://github.com/tanapoj/flutter_live_data](https://github.com/tanapoj/flutter_live_data)

## Create

```dart
// create broadcast stream
var counter = LiveData(1);
var counter = LiveData.broadcast(1);

// create standard stream
var counter = LiveData.single(1);

// create from stream
var counter = LiveData.stream(stream);
```

or bind with life cycle observer

```dart
var counter = LiveData(1).owner(lifeCycleOwner);
```

## Update Value

```dart
var counter = LiveData(1);
counter.value = 2;
counter.value += 1;
counter.value++;
```

mutable update

```dart
var items = LiveData(<String>['A']);

//Not Work!
items.value.add('B');

//Ok
items.value = items.value + ['B'];
items.patch((list) => list.add('B'));
items.transform((list) => list + ['B']);
```
