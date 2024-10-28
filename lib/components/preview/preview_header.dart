import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../extentions/hexcolor.dart';
import '../../../models/user.dart';
import '../../models/user_edit.dart';
import '../tac_logo.dart';

class PreviewHeader extends StatefulWidget {
  const PreviewHeader({
    Key? key,
    required this.userDetail,
  }) : super(key: key);
  final UserEditModel userDetail;

  @override
  PreviewHeaderState createState() => PreviewHeaderState();
}

class PreviewHeaderState extends State<PreviewHeader> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  _buildCoverImageWidget() {
    if (widget.userDetail.userDTO.coverImage != null &&
        widget.userDetail.userDTO.coverImage!.isNotEmpty) {
      return Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.userDetail.userDTO.coverImage!),
                fit: BoxFit.cover)),
      );
    } else {
      return Container();
    }
  }

  _buildProfileImageWidget() {
    return Positioned(
      top: 120,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: widget.userDetail.userDTO.profileImage == null ||
            widget.userDetail.userDTO.profileImage!.isEmpty
            ? Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(30)),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TacLogo(forProfileImage: true),
                Container(
                    constraints: BoxConstraints.loose(
                        const Size.fromHeight(60.0)),
                    child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Positioned(
                              top: -10,
                              child: Icon(
                                Icons.person,
                                color: color,
                                size: 70,
                              ))
                        ]))
              ]),
        )
            : Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              image: DecorationImage(
                  image: NetworkImage(widget.userDetail.userDTO.profileImage!),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      height: 240,
      child: Stack(children: [
        _buildCoverImageWidget(),
        _buildProfileImageWidget(),
        Positioned(
          left: 20,
          top: 10,
          child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  color: Theme.of(context).textTheme.bodyText2!.color)),
        ),
      ]),
    );
  }

}
