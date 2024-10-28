import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class ListSkeletonLoader extends StatefulWidget {
  const ListSkeletonLoader({Key? key, required this.margin, this.height})
      : super(key: key);
  final EdgeInsetsGeometry margin;
  final double? height;

  @override
  State<ListSkeletonLoader> createState() => ListSkeletonLoaderState();
}

class ListSkeletonLoaderState extends State<ListSkeletonLoader> {
  @override
  ListSkeletonLoader get widget => super.widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.margin,
        width: MediaQuery.of(context).size.width,
        height: widget.height ??
            MediaQuery.of(context).size.height -
                (MediaQuery.of(context).size.height / 2.9),
        child: ClipRect(
            child: SkeletonListView(
                item: SkeletonListTile(
          verticalSpacing: 12,
          leadingStyle: const SkeletonAvatarStyle(
              width: 64, height: 64, shape: BoxShape.rectangle),
          titleStyle: SkeletonLineStyle(
              height: 20,
              minLength: 200,
              randomLength: false,
              borderRadius: BorderRadius.circular(5)),
          subtitleStyle: SkeletonLineStyle(
              height: 15,
              maxLength: 200,
              randomLength: false,
              borderRadius: BorderRadius.circular(5)),
          hasSubtitle: true,
        ))));
  }
}
