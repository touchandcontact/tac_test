import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class VirtualBackgroundLoader extends StatefulWidget {
  const VirtualBackgroundLoader({Key? key}) : super(key: key);

  @override
  State<VirtualBackgroundLoader> createState() =>
      VirtualBackgroundLoaderState();
}

class VirtualBackgroundLoaderState extends State<VirtualBackgroundLoader> {
  @override
  VirtualBackgroundLoader get widget => super.widget;

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
                child: SkeletonItem(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Padding(
                          padding: EdgeInsets.all(20),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                height: 140,
                                width: double.infinity),
                          )),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 15,
                                width: 150,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          )),
                      Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          width: double.infinity,
                          child: Row(children: [
                            const SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                  height: 60,
                                  width: 80,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                  height: 60,
                                  width:
                                      MediaQuery.of(context).size.width * 0.62,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                            )
                          ])),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 15,
                                width: 150,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          )),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 70,
                                width: double.infinity,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 70,
                                width: double.infinity,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 70,
                                width: double.infinity,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 15,
                                width: 150,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          )),
                      Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          width: double.infinity,
                          child: Row(children: [
                            SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                  height: 60,
                                  width:
                                      MediaQuery.of(context).size.width * 0.62,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            const SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                  height: 60,
                                  width: 80,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            )
                          ])),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                                height: 15,
                                width: 150,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          )),
                      Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: const [
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                      height: 60,
                                      width: 80,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                )
                              ])),
                    ])))));
  }
}
