import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  final Widget foreground;

  CustomDrawer({@required this.foreground});

  CustomDrawerState createState() => new CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool _canBeDragged = false;
  static final double maxSlide = 150.0;
  var minDragStartEdge = 150;
  var maxDragStartEdge = maxSlide - 16;
  Widget foreground;

  @override
  void initState() {
    super.initState();
    foreground = widget.foreground;
    animationController = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    ); //..repeat
  }

  void close() {
    animationController.reverse();
  }

  void open() {
    animationController.forward();
  }

  void onDragstart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void onDragupdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void onDragend(DragEndDetails details) {
    if (animationController.isDismissed || animationController.isCompleted)
      return;
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  @override
  Widget build(BuildContext context) {
    var myDrawer = Container(color: Colors.white);
    return GestureDetector(
      onHorizontalDragStart: onDragstart,
      onHorizontalDragUpdate: onDragupdate,
      onHorizontalDragEnd: onDragend,
      onTap: toggle,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          //problem can occur here due to _
          double slide = maxSlide * animationController.value;
          double scale = 1 - (animationController.value * 0.3);
          return Stack(
            children: <Widget>[
              myDrawer,
              Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.centerRight,
                child: foreground,
              ),
            ],
          );
        },
      ),
    );
    //throw UnimplementedError();
  }
}

//eqRj56IYSbuxucBO4ZqEdw:APA91bGYSW2KYIw-xbwJyTL2XJ4ZXrlz068WNJgZVApT9knlwbzl9PydmZxzAqZKSiJc5TSKWWoRqamr7dKZREdm6oRTow76w490U-V7bNiP-Y2itimR-d-hGP_F4fEUrYRIGm1idNL2
//eqRj56IYSbuxucBO4ZqEdw:APA91bGYSW2KYIw-xbwJyTL2XJ4ZXrlz068WNJgZVApT9knlwbzl9PydmZxzAqZKSiJc5TSKWWoRqamr7dKZREdm6oRTow76w490U-V7bNiP-Y2itimR-d-hGP_F4fEUrYRIGm1idNL2
