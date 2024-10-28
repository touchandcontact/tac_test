import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../extentions/hexcolor.dart';

// ignore: must_be_immutable
class ConfirmSlider extends StatefulWidget {
  String _sliderText = "";
  String _backText = "";
  double? _width = 0.0;
  late Future<void> Function() _onSwipeFinish;

  ConfirmSlider(
      {super.key,
      required String slideText,
      required String backText,
      width,
      required Future<void> Function() onSwipeFinish}) {
    _sliderText = slideText;
    _backText = backText;
    _width = width;
    _onSwipeFinish = onSwipeFinish;
  }

  @override
  State<ConfirmSlider> createState() => ConfirmSliderState();
}

class ConfirmSliderState extends State<ConfirmSlider>
    with TickerProviderStateMixin {
  @override
  ConfirmSlider get widget => super.widget;

  final _controller = ActionSliderController();
  late AnimationController animationController;

  bool isLoading = false;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ActionSlider.custom(
      sliderBehavior: SliderBehavior.move,
      width: widget._width ?? MediaQuery.of(context).size.width,
      controller: _controller,
      height: isLoading ? 60.0 : 50.0,
      toggleWidth: isLoading
          ? 60
          : (widget._width ?? MediaQuery.of(context).size.width) / 3,
      toggleMargin: EdgeInsets.zero,
      backgroundColor: Theme.of(context).backgroundColor,
      backgroundBorderRadius: BorderRadius.circular(isLoading ? 40 : 10),
      outerBackgroundBuilder: (context, state, child) => Visibility(
          visible: !isLoading,
          child: DecoratedBox(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: isLoading ? 60.0 : 50.0,
                margin: EdgeInsets.zero,
                color: Color.lerp(HexColor.fromHex('#E9F7F7'),
                    Theme.of(context).primaryColor, state.position),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(120, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(widget._backText,
                          style: GoogleFonts.montserrat(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .color)),
                    )),
              ))),
      foregroundChild: DecoratedBox(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(isLoading ? 40 : 10)),
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  isLoading ? 12 : (widget._sliderText.length > 8 ? 20 : 24),
                  0,
                  0,
                  0),
              child: Row(
                  children: [
                Visibility(
                    visible: !isLoading,
                    child: Text(
                      widget._sliderText,
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                Visibility(
                    visible: !isLoading,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Icon(Icons.arrow_right_alt_sharp,
                          color: Colors.white),
                    )),
                Visibility(
                    visible: isLoading,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: animationController.value,
                    ))
              ]))),
      foregroundBuilder: (context, state, child) => child!,
      action: (controller) async {
        try {
          controller.loading();
          setState(() {
            isLoading = true;
          });

          await widget._onSwipeFinish();
          controller.success();

          controller.reset();
          setState(() {
            isLoading = false;
          });
        } on Exception catch (_) {
          controller.reset();
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }
}
