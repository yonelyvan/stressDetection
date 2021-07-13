import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:detector/utils/circle_painter.dart';
import 'package:detector/utils/curve_wave.dart';

class AnimationButton extends StatefulWidget {
  final double size;
  final Color color;
  final Widget child;
  final bool animate;

  const AnimationButton({
    Key key,
    this.size = 80.0,
    this.color = Colors.red,
    this.animate = true,
    @required this.child,
  }) : super(key: key);

  @override
  _AnimationButton createState() => _AnimationButton();
}

class _AnimationButton extends State<AnimationButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _runAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _runAnimation(){
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color, Colors.black, .05)
              ],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: CurveWave(),
                ),
              ),
              child: widget.child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.animate){
      _controller.stop();
    }else{
      _runAnimation();
    }
    return CustomPaint(
      painter: CirclePainter(
        _controller,
        color: widget.color,
      ),
      child: SizedBox(
        width: widget.size * 4.125,
        height: widget.size * 4.125,
        child: _button(),
      ),
    );
  }
}
