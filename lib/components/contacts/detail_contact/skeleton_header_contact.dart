import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonHeaderContact extends StatefulWidget {
  SkeletonHeaderContact({Key? key,this.margin, this.height})
      : super(key: key);
  EdgeInsetsGeometry? margin;
  double? height;

  @override
  State<SkeletonHeaderContact> createState() => SkeletonHeaderContactState();
}

class SkeletonHeaderContactState extends State<SkeletonHeaderContact> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.margin ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
        width: MediaQuery.of(context).size.width,
        child: const SkeletonAvatar(style: SkeletonAvatarStyle(
          height: 60,
          width: 60
        )));
  }
}
