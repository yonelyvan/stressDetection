import 'package:stdetector/src/ui/screens/screen_recorder_signal.dart';
import 'package:stdetector/src/ui/screens/screen_recorders.dart';
import 'package:flutter/material.dart';

import '../../bloc/record_bloc.dart';
import '../../model/status_tab_bar.dart';
import 'home.dart';

class ScreenTabs extends StatefulWidget {
  @override
  _ScreenTabs createState() => _ScreenTabs();
}

class _ScreenTabs extends State<ScreenTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String title = "Detector";
  List<String> t = ["Detector", "List", "Settings"];
  final RecordBloc _recordBloc = RecordBloc();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(_changeTitle);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recordBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          StreamBuilder<StatusMenuTab>(
              stream: _recordBloc.statusBarStream,
              builder: (BuildContext context,
                  AsyncSnapshot<StatusMenuTab> snapshot) {
                print(">>>>>>%%%%%%%%%%%%%");
                print(snapshot.data);
                Widget options = Text("");
                switch (snapshot.data!) {
                  case StatusMenuTab.option:
                    {
                      options = Text("option");
                    }
                    break;
                  case StatusMenuTab.options:
                    {
                      options = Text("options");
                    }
                    break;
                  case StatusMenuTab.none:
                    options = Text("");
                    break;
                }
                return options;
              }),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab( icon: Icon(Icons.front_hand),),
          Tab( icon: Icon(Icons.list_alt_sharp),),
          Tab( icon: Icon(Icons.settings),)
        ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        //ScreenRecorderSignal(),
        Home(),
        ScreenRecorders(),
        Text('Settings'),
      ]),
    );
  }



  Text _options() {
    Text options = Text("sdfs");
    StreamBuilder<StatusMenuTab>(
        stream: _recordBloc.statusBarStream,
        builder: (BuildContext context, AsyncSnapshot<StatusMenuTab> snapshot) {
          print(">>>>>>%%%%%%%%%%%%%");
          print(snapshot.data);
          Text option = Text("sdfs");
          return option;
          /*
        switch (status) {
          case StatusMenuTab.option:{
              options = [Text("option")];
            }
            break;
          case StatusMenuTab.options:{
              options = [Text("options")];
            }
            break;
        }*/
        });
    return options;
  }

  _changeTitle() {
    print(">>>>>>>>>>>>>>>>>>>>> ${_tabController.index}");
    setState(() {
      title = t[_tabController.index];
    });
  }
}
