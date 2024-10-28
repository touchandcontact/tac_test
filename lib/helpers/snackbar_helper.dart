import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showSnackbar(BuildContext context, String text, Color color,
    {int duration = 2}) {
  var snackBar = SnackBar(
      content: Text(text,
          style: GoogleFonts.montserrat(
              fontSize: 14, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      duration: Duration(seconds: duration));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
