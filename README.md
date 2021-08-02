# flutter_live_data

Live Data in Flutter

## Create

```dart
var counter = LiveData(1);
var counter = LiveData(1).asBroadcast();
var counter = LiveData(1).asMultiStream();
```

or bind with life cycle observer

```dart
var counter = LiveData(1).bind(observer);
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
items.mutate((list) => list.add('B'));
items.transform((list) => list + ['B']);
```

## Get Stream

```dart
var counter = LiveData(1);

var stream = counter.stream;
var stream = counter.stream$(#id1);

counter.dispose();
```