import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AnimatedSync extends AnimatedWidget {
  VoidCallback callback;
  AnimatedSync({Key key, Animation<double> animation, this.callback})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
          icon: Icon(Icons.sync, color: Colors.white), // <-- Icon
          onPressed: callback),
    );
  }
}
