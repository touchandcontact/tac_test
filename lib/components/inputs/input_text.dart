import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class InputText extends StatefulWidget {
  String _label = "";
  String? _initialValue;
  Widget? _suffixIcon;
  Icon? _prefixIcon;
  bool _obscureText = false;
  bool _enableInteractiveSelection = true;
  bool _enabled = true;
  bool _outsideLabel = false;
  int _maxLines = 1;
  TextInputType? _keyboardType;
  List<TextInputFormatter>? _inputFormatters;
  TextEditingController? _controller;
  TextStyle? labelStyle;
  late String? Function(String?)? _validator;
  late void Function(String) _onChange;
  TextCapitalization? _textCapitalization;
  FocusNode? _node;

  InputText(
      {super.key,
      required String label,
      required void Function(String) onChange,
      this.labelStyle,
      bool? obscureText,
      bool? enableInteractiveSelection,
      Widget? suffixIcon,
      Icon? prefixIcon,
      TextInputType? keyboardType,
      bool? enabled,
      bool? outsideLabel,
      int? maxLines,
      String? initalValue,
      String? Function(String?)? validator,
      TextEditingController? controller,
      inputFormatters,
        TextCapitalization? textCapitalization,
        FocusNode? node
      }) {
    _label = label;
    _onChange = onChange;
    _suffixIcon = suffixIcon;
    _validator = validator;
    _enableInteractiveSelection = enableInteractiveSelection ?? true;
    _obscureText = obscureText ?? false;
    _enabled = enabled ?? true;
    _outsideLabel = outsideLabel ?? false;
    _keyboardType = keyboardType ?? TextInputType.text;
    _maxLines = maxLines ?? 1;
    _prefixIcon = prefixIcon;
    _initialValue = initalValue;
    _controller = controller;
    _inputFormatters = inputFormatters;
    _textCapitalization = textCapitalization;
    _node = node;
  }

  @override
  InputTextState createState() => InputTextState();
}

class InputTextState extends State<InputText> {
  late AnimationController controller;
  @override
  InputText get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    if (widget._outsideLabel) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget._label,
          style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Theme.of(context).textTheme.headline1!.color,
              fontWeight: FontWeight.w600),
        ),
        Divider(height: 5, color: Theme.of(context).backgroundColor),
        TextFormField(
          focusNode: widget._node,
            controller: widget._controller,
            validator: widget._validator,
            obscureText: widget._obscureText,
            enableInteractiveSelection: widget._enableInteractiveSelection,
            keyboardType: widget._keyboardType,
            inputFormatters: widget._inputFormatters,
            onChanged: widget._onChange,
            enabled: widget._enabled,
            maxLines: widget._maxLines,
            initialValue: widget._initialValue,
            textCapitalization: widget._textCapitalization ?? TextCapitalization.none,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
                fillColor: Theme.of(context).secondaryHeaderColor,
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: GoogleFonts.montserrat(
                    color: Theme.of(context).textTheme.headline2!.color,
                    fontWeight: FontWeight.w600),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).errorColor),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor),
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                suffixIcon: widget._suffixIcon))
      ]);
    } else {
      return TextFormField(
          controller: widget._controller,
          validator: widget._validator,
          obscureText: widget._obscureText,
          enableInteractiveSelection: widget._enableInteractiveSelection,
          keyboardType: widget._keyboardType,
          onChanged: widget._onChange,
          enabled: widget._enabled,
          inputFormatters: widget._inputFormatters,
          initialValue: widget._initialValue,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
          textCapitalization: widget._textCapitalization ?? TextCapitalization.none,
          decoration: InputDecoration(
              fillColor: Theme.of(context).secondaryHeaderColor,
              filled: true,
              isDense: true,
              labelStyle: widget.labelStyle ??
                  GoogleFonts.montserrat(
                      color: Theme.of(context).textTheme.headline2!.color,
                      fontWeight: FontWeight.w600),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              disabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).secondaryHeaderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).secondaryHeaderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              suffixIcon: widget._suffixIcon,
              prefixIcon: widget._prefixIcon,
              labelText: widget._label));
    }
  }
}
