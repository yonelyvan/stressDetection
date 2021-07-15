import 'package:flutter/material.dart';

class WidgetStressLevel extends StatelessWidget {
  final int stressLevel;

  const WidgetStressLevel({Key key, @required this.stressLevel})
      : super(key: key);

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
                color: stressLevel == 1
                    ? Color(0xff4dcc57)
                    : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              child: Image.asset("assets/img/too_happy.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                color: stressLevel == 2
                    ? Color(0xffacd91c)
                    : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset("assets/img/happy.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                color: stressLevel == 3
                    ? Color(0xffffce2a)
                    : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset("assets/img/surprised.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                color: stressLevel == 4
                    ? Color(0xfffd7e1f)
                    : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset("assets/img/sad.png")),
          Container(
              height: screenHeight,
              width: screenWidth,
              padding: EdgeInsets.all(_padding),
              margin: EdgeInsets.all(_margin),
              decoration: BoxDecoration(
                color: stressLevel == 5
                    ? Color(0xffe8344f)
                    : notFocusedColor,
                borderRadius: BorderRadius.all(Radius.circular(_border)),
              ),
              child: Image.asset("assets/img/too_sad.png")),
        ],
      ),
    );
  }
}
