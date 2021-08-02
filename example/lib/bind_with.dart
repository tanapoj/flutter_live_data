import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_live_data/flutter_live_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Data',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with LifeCycleObserver {
  LiveData liveData;
  List<LiveData> _toDisposes;

  HomePageState() {
    _toDisposes = [];

    liveData = LiveData(0).bind(this);

    Timer.periodic(Duration(seconds: 1), (timer) {
      liveData.value += 1;
    });
  }

  @override
  void dispose() {
    for (var lv in _toDisposes) {
      lv?.dispose();
    }
    _toDisposes.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: liveData.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Text('count: ${snapshot.data}');
      },
    );
  }

  @override
  void observeLiveData<T>(LiveData<T> lv) {
    _toDisposes.add(lv);
  }
}
