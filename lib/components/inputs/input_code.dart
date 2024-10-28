import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class InputCode extends StatefulWidget {
  late void Function(String) _onChange;
  TextInputAction? _textInputAction;
  void Function(String)? _onFieldSubmitted;
  FocusNode? _focusNode;

  InputCode(
      {super.key,
      required void Function(String) onChange,
      TextInputAction? textInputAction,
      void Function(String)? onFieldSubmitted,
      FocusNode? focusNode}) {
    _onChange = onChange;
    _textInputAction = textInputAction;
    _onFieldSubmitted = onFieldSubmitted;
    _focusNode = focusNode;
  }

  @override
  InputCodeState createState() => InputCodeState();
}

class InputCodeState extends State<InputCode> {
  late AnimationController controller;
  @override
  InputCode get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        focusNode: widget._focusNode,
        textInputAction: widget._textInputAction,
        onFieldSubmitted: widget._onFieldSubmitted,
        decoration: InputDecoration(
            fillColor: Theme.of(context).secondaryHeaderColor,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).secondaryHeaderColor),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            counterText: "",
            labelStyle: const TextStyle(fontWeight: FontWeight.bold)),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1)
        ],
        maxLength: 1,
        onChanged: widget._onChange);
  }
}
