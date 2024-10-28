import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class InputCutText extends StatefulWidget {
  String _label = "";
  String? _initialValue;
  Widget? _suffixIcon;
  Icon? _prefixIcon;
  bool _obscureText = false;
  bool _enableInteractiveSelection = true;
  bool _enabled = true;
  TextInputType? _keyboardType;
  List<TextInputFormatter>? _inputFormatters;
  TextStyle? labelStyle;
  late String? Function(String?)? _validator;
  late void Function(String) _onChange;

  InputCutText(
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
      inputFormatters}) {
    _label = label;
    _onChange = onChange;
    _suffixIcon = suffixIcon;
    _validator = validator;
    _enableInteractiveSelection = enableInteractiveSelection ?? true;
    _obscureText = obscureText ?? false;
    _enabled = enabled ?? true;
    _keyboardType = keyboardType ?? TextInputType.text;
    _prefixIcon = prefixIcon;
    _initialValue = initalValue;
    _inputFormatters = inputFormatters;
  }

  @override
  InputCutTextState createState() => InputCutTextState();
}

class InputCutTextState extends State<InputCutText> {
  late AnimationController controller;

  TextEditingController? _displayController;
  final FocusNode _focusNode = FocusNode();
  String? _currentValue = "";

  @override
  void initState() {
    super.initState();
    _currentValue = widget._initialValue;
    _displayController = TextEditingController(
        text: _currentValue != null &&
                _currentValue != "" &&
                _currentValue!.length > 32
            ? "${_currentValue!.substring(0, 32)}..."
            : _currentValue);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_displayController!.text.isNotEmpty &&
            _displayController!.text.length > 32) {
          final text = "${_displayController!.text.substring(0, 32)}...";
          _displayController!.value = _displayController!.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      }
      if (_focusNode.hasFocus) {
        _displayController!.text = _currentValue ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: _focusNode,
        controller: _displayController,
        validator: widget._validator,
        obscureText: widget._obscureText,
        enableInteractiveSelection: widget._enableInteractiveSelection,
        keyboardType: widget._keyboardType,
        onChanged: (String value) {
          widget._onChange(value);
          _currentValue = value;
        },
        enabled: widget._enabled,
        inputFormatters: widget._inputFormatters,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
