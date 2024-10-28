import 'package:flutter/material.dart';

class ContactEmptyErrorWidget extends StatelessWidget {
  final String label;
  const ContactEmptyErrorWidget({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children:  [
        const SizedBox(
          height: 16,
        ),
        Text(label)
      ],
    );
  }
}
