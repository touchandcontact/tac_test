import 'dart:async';

import 'package:flutter/material.dart';

import 'input_text.dart';

class InputDebounceText extends StatefulWidget {
  String? label;
  Function(String? value) callback;
  InputDebounceText({Key? key,required this.callback, this.label}) : super(key: key);

  @override
  State<InputDebounceText> createState() => _InputDebounceTextState();
}

class _InputDebounceTextState extends State<InputDebounceText> {

  Timer? _debounce;
  String? lastInputValue;

  @override
  Widget build(BuildContext context) {
    return InputText(
        prefixIcon: const Icon(Icons.search),
        label: widget.label ?? "",
        onChange: _onSearchChanged);
  }

  _onSearchChanged(String value) {
    if(lastInputValue != value){
      lastInputValue = value;
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () => widget.callback(value));
    }

  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}