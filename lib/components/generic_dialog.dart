import 'package:flutter/material.dart';

class GenericDialog extends StatefulWidget {
  const GenericDialog(
      {Key? key,
      required this.child,
      this.vertical = 180,
      this.disableExit = false, this.onClose})
      : super(key: key);
  final Widget child;
  final double vertical;
  final bool disableExit;
  final Function? onClose;

  @override
  State<GenericDialog> createState() => GenericDialogState();
}

class GenericDialogState extends State<GenericDialog> {
  @override
  GenericDialog get widget => super.widget;

  close() {
    if(widget.onClose != null){
      widget.onClose!();
    }
    else if (!widget.disableExit) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: 20, vertical: widget.vertical),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).backgroundColor,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          widget.child,
          Positioned(
              bottom: -30,
              child: GestureDetector(
                onTap: close,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).textTheme.headline3!.color),
                  child: const Center(
                      child: Icon(Icons.close, size: 30, color: Colors.white)),
                ),
              ))
        ],
      ),
    );
  }
}
