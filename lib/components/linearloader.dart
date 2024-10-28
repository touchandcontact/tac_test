import 'package:flutter/material.dart';

class LinearIndicator extends StatefulWidget {
  const LinearIndicator({Key? key}) : super(key: key);

  @override
  State<LinearIndicator> createState() => _LinearIndicatorState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _LinearIndicatorState extends State<LinearIndicator>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LinearProgressIndicator(
          value: controller.value,
          color: Colors.white,
        ),
      ],
    );
  }
}
