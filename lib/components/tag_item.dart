import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/tag.dart';

class TagItem extends StatefulWidget {
  const TagItem(
      {Key? key, required this.item, this.onTap, this.marginRight = 0})
      : super(key: key);

  final Tag item;
  final double marginRight;
  final void Function()? onTap;

  @override
  State<TagItem> createState() => TagItemState();
}

class TagItemState extends State<TagItem> {
  @override
  TagItem get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
            height: 25,
            margin: EdgeInsets.only(right: widget.marginRight),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).textTheme.headline2!.color,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Text(
              widget.item.tag,
              style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            )));
  }
}
