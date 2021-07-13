import 'package:flutter/material.dart';

class StressLevelLegend extends StatefulWidget {
  //final int width;
  //StressLevelLegend({Key key, @required this.width});

  @override
  State<StatefulWidget> createState() => _StressLevelLegend();
}

class _StressLevelLegend extends State<StressLevelLegend> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = (MediaQuery.of(context).size.width)-60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: (screenWidth/3)-2,
            padding: const EdgeInsets.all(10.0),
            color: Colors.blue,
            child: Center(
              child: Text(
                " Bajo ",
                style: TextStyle(color: Colors.white),
              ),
            )
        ),
        Container(
            width: (screenWidth/3)-2,
            padding: const EdgeInsets.all(10.0),
            color: Colors.orange,
            child: Center(
              child: Text(
                "Medio",
                style: TextStyle(color: Colors.white),
              ),
            )
        ),
        Container(
            width: (screenWidth/3)-2,
            padding: const EdgeInsets.all(10.0),
            color: Colors.red,
            child: Center(
              child: Text(
                " Alto ",
                style: TextStyle(color: Colors.white),
              ),
            )
        )
      ],
    );
  }
}
