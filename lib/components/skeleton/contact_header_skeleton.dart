import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class ContactHeaderSkeleton extends StatelessWidget {
  const ContactHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        color: Colors.amber,
        height: 200,
      ),
    );


  }
}
