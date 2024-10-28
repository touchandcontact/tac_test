import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';

import '../../extentions/hexcolor.dart';

class TagSkeleton extends StatelessWidget {
  TagSkeleton({Key? key}) : super(key: key);
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        const SizedBox(
          height: 16,
        ),
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
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            SkeletonItem(
              child: SizedBox(
                  height: 60,
                  width: 60,
                  child: RawMaterialButton(
                    onPressed: () {
                    },
                    fillColor: color,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add,
                      size: 36.0,
                      color: Colors.white,
                    ),
                  )),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SkeletonItem(
                child: SizedBox(
                  height: 60,
                  child: ListView(
                      scrollDirection:
                      Axis.horizontal,
                      children: List<Widget>.generate(8, (index) => Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                        child:
                        FilterChip(
                          label: Text(
                              "",
                              style: TextStyle(color: color)),
                          backgroundColor:
                          Theme.of(context).backgroundColor,
                          shape:
                          StadiumBorder(side: BorderSide(color: color)),
                          onSelected:
                              (bool value) {},
                        ),
                      )).toList()
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
