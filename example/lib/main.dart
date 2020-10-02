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

class HomePageState extends State<HomePage> {
  LiveData liveData;

  HomePageState() {
    liveData = LiveData<int>(initValue: 0);

    Timer.periodic(Duration(seconds: 1), (timer) {
      liveData.value += 1;
    });
  }

  @override
  void dispose() {
    liveData.dispose();
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
}
