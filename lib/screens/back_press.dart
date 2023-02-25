import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class backpress extends StatefulWidget {
  backpress({
   required this.child,
  });
  Widget child = Container();
  @override
  State<backpress> createState() => _backpressState();
}

class _backpressState extends State<backpress> {
  DateTime ? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                Duration(seconds: 2)) {
          _lastPressedAt = DateTime.now();
          return false;
        }
        return true;
      },
      child:  widget.child// Your existing widget tree
    );
  }
}
