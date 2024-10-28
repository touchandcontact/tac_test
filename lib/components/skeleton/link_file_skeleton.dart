import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';

import '../../extentions/hexcolor.dart';

class LinkFileSkeleton extends StatelessWidget {
  LinkFileSkeleton({Key? key}) : super(key: key);
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        SkeletonItem(
          child: GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16),
              children: List.generate(3, (index) => Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(10.0)),
                child: ListTile(
                  minVerticalPadding: 0,
                  contentPadding: EdgeInsets.zero,
                  title: Icon(Icons.account_circle,
                      color: Theme.of(context).textTheme.headline1!.color),
                  subtitle: const Text(""),
                ),
              )).toList()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
