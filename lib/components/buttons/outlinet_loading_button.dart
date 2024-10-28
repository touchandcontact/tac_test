import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OutlinedLoadingButton extends StatefulWidget {
  const OutlinedLoadingButton(
      {Key? key,
      required this.onPress,
      required this.text,
      this.width = 100,
      required this.color,
      required this.borderColor})
      : super(key: key);
  final Future Function() onPress;
  final Color color;
  final Color borderColor;
  final double width;
  final String text;

  @override
  OutlinedLoadingButtonState createState() => OutlinedLoadingButtonState();
}

class OutlinedLoadingButtonState extends State<OutlinedLoadingButton> {
  @override
  OutlinedLoadingButton get widget => super.widget;

  bool isLoading = false;

  onPress() async {
    setState(() {
      isLoading = true;
    });
    await widget.onPress();
    //TODO: va in errore perchè vuole fare un setState ma il widget già non esiste più
    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        width: isLoading ? 300 : widget.width,
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
            : OutlinedButton(
                onPressed: onPress,
                style: OutlinedButton.styleFrom(
                    foregroundColor: widget.color,
                    side: BorderSide(width: 1.0, color: widget.borderColor),
                    padding: const EdgeInsets.fromLTRB(100, 20, 100, 20),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(15),
                            right: Radius.circular(15)))),
                child: Text(
                  widget.text,
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: widget.color,
                      fontWeight: FontWeight.w600),
                )));
  }
}
