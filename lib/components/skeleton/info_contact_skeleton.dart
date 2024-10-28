import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';

import '../../extentions/hexcolor.dart';

class InfoContactSkeleton extends StatelessWidget {
  bool isFromQrCode;
  InfoContactSkeleton({Key? key, this.isFromQrCode = false}) : super(key: key);
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonParagraph(
          style: SkeletonParagraphStyle(
              lines: 1,
              spacing: 6,
              lineStyle: SkeletonLineStyle(
                width: 160,
                alignment: Alignment.center,
                borderRadius: BorderRadius.circular(8),
                randomLength: false,
              )),
        ),
        const SizedBox(
          height: 8,
        ),
        SkeletonParagraph(
          style: SkeletonParagraphStyle(
              lines: 1,
              spacing: 6,
              lineStyle: SkeletonLineStyle(
                width: 140,
                alignment: Alignment.center,
                borderRadius: BorderRadius.circular(8),
                randomLength: false,
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        isFromQrCode ? SkeletonItem(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      side: const BorderSide(width: 0, color: Colors.transparent),
                    ),
                    onPressed: () {
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
                      child: Text("Salva Contatto",
                          style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .primaryColor
                                  .computeLuminance() >
                                  0.5
                                  ? Theme.of(context).textTheme.bodyText2!.color
                                  : Colors.white)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ) : Container(),
        isFromQrCode ? const SizedBox(
          height: 30,
        ) : Container(),
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
          height: 30,
        ),
        SkeletonParagraph(
          style: SkeletonParagraphStyle(
              lines: 1,
              spacing: 6,
              lineStyle: SkeletonLineStyle(
                borderRadius: BorderRadius.circular(8),
                randomLength: false,
              )),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
