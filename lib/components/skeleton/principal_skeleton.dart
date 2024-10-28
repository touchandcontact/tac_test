import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';

import '../../extentions/hexcolor.dart';

class PrincipalSkeleton extends StatelessWidget {
  PrincipalSkeleton({Key? key}) : super(key: key);
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Align(alignment: Alignment.center, child:  SkeletonParagraph(
            style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 6,
                lineStyle: SkeletonLineStyle(
                  width: 60,
                  borderRadius: BorderRadius.circular(8),
                  randomLength: false,
                )),
          ),),
          Align(alignment: Alignment.center, child:  SkeletonParagraph(
            style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 6,
                lineStyle: SkeletonLineStyle(
                  width: 60,
                  borderRadius: BorderRadius.circular(8),
                  randomLength: false,
                )),
          ),),
        ]),
        const SizedBox(
          height: 16,
        ),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(8, (index) => SkeletonItem(child:  Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 8),
              width: 70,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(18.0)),
              child: const ListTile(
                minVerticalPadding: 0,
                contentPadding: EdgeInsets.zero,
                title: Icon(Icons.account_circle),
                subtitle: Text(""),
              ),
            ))).toList(),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
