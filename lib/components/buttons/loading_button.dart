import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingButton extends StatefulWidget {
  final Future Function() onPress;
  const LoadingButton(
      {Key? key,
      required this.onPress,
      required this.text,
      this.width = 100,
      required this.color,
      this.textColor,
      required this.borderColor,
      this.textSize})
      : super(key: key);
  final Color color;
  final Color borderColor;
  final Color? textColor;
  final double width;
  final String text;
  final double? textSize;

  @override
  LoadingButtonState createState() => LoadingButtonState();
}

class LoadingButtonState extends State<LoadingButton> {
  @override
  LoadingButton get widget => super.widget;

  bool isLoading = false;

  onPress() async {
    setState(() {
      isLoading = true;
    });
    await widget.onPress();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        width: isLoading ? 60 : widget.width,
        duration: const Duration(milliseconds: 300),
        child: isLoading
            ? Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: const BorderRadius.all(Radius.circular(60))),
                child: Center(
                  child: CircularProgressIndicator(
                      color: widget.color.computeLuminance() > 0.5
                          ? Theme.of(context).textTheme.bodyText2!.color
                          : Colors.white),
                ),
              )
            : TextButton(
                onPressed: onPress,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(widget.color),
                    side: MaterialStateProperty.all(
                        BorderSide(width: 1.0, color: widget.borderColor)),
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.fromLTRB(20, 20, 20, 20)),
                    shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(15),
                                right: Radius.circular(15))))),
                child: Text(
                  widget.text,
                  style: GoogleFonts.montserrat(
                      fontSize: widget.textSize ?? 20,
                      color: widget.textColor != null
                          ? widget.textColor!
                          : widget.color.computeLuminance() > 0.5
                              ? Theme.of(context).textTheme.bodyText2!.color
                              : Colors.white,
                      fontWeight: FontWeight.w600),
                )));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
