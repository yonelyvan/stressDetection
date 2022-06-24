import 'package:flutter/material.dart';

class WidgetStressLevel extends StatelessWidget {
  final int stressLevel;

  const WidgetStressLevel({required this.stressLevel});

  @override
  Widget build(BuildContext context) {
    double dim = MediaQuery.of(context).size.width - 70;
    double screenWidth = dim / 5; //(MediaQuery.of(context).size.width-50) /5;
    double screenHeight = dim / 5;
    double _padding = 3;
    double _margin = 1;
    double _border = (dim / 5) / 2;
    //------

    Color notFocusedColor = Colors.black12;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: screenHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                //color: stressLevel == 1 ? Color(0xff4dcc57) : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              child: Image.asset(
                  stressLevel == 1 ? "assets/img/1.png" : "assets/img/1b.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                //color: stressLevel == 2 ? Color(0xffacd91c) : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset(
                  stressLevel == 2 ? "assets/img/2.png" : "assets/img/2b.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                //color: stressLevel == 3 ? Color(0xffffce2a) : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset(
                  stressLevel == 3 ? "assets/img/3.png" : "assets/img/3b.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                //color: stressLevel == 4 ? Color(0xfffd7e1f) : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset(
                  stressLevel == 4 ? "assets/img/4.png" : "assets/img/4b.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                //color: stressLevel == 5 ? Color(0xffe8344f) : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset(
                  stressLevel == 5 ? "assets/img/6.png" : "assets/img/6b.png")),
        ],
      ),
    );
  }
}
