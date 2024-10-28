import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class ProfileLoader extends StatelessWidget {
  const ProfileLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(0), child: SizedBox(height: 0)),
        body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
                width: MediaQuery.of(context).size.height,
                child: const SkeletonItem(
                    child: Column(children: [
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        height: 140, width: double.infinity),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              width: 110,
                              height: 110))),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                            height: 60,
                            width: double.infinity,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ))
                ])))));
  }
}
