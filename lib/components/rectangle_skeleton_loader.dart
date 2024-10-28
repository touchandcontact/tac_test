import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class RectangleSkeletonLoader extends StatefulWidget {
  const RectangleSkeletonLoader({Key? key, required this.margin, this.height})
      : super(key: key);
  final EdgeInsetsGeometry margin;
  final double? height;

  @override
  State<RectangleSkeletonLoader> createState() =>
      RectangleSkeletonLoaderState();
}

class RectangleSkeletonLoaderState extends State<RectangleSkeletonLoader> {
  @override
  RectangleSkeletonLoader get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.margin,
        width: MediaQuery.of(context).size.width,
        height: widget.height ??
            MediaQuery.of(context).size.height -
                (MediaQuery.of(context).size.height / 2.9),
        child: SkeletonListView(
            item: SkeletonListTile(
          hasLeading: false,
          titleStyle: SkeletonLineStyle(
              height: 45,
              minLength: MediaQuery.of(context).size.width - 20,
              randomLength: false,
              borderRadius: BorderRadius.circular(10)),
          hasSubtitle: false,
        )));
  }
}
