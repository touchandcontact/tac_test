// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:tac/helpers/icons_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/services/elements_service.dart';

import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddLink extends StatefulWidget {
  const AddLink({Key? key, required this.icon, required this.reload})
      : super(key: key);
  final String icon;
  final Future Function() reload;

  @override
  AddLinkState createState() => AddLinkState();
}

class AddLinkState extends State<AddLink> {
  double height = 120;
  String name = "";
  String link = "";
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  FocusNode fNode = FocusNode();
  FocusNode fNode2 = FocusNode();

  @override
  AddLink get widget => super.widget;

  @override
  void initState() {
    super.initState();
  }

  Future addLink() async {
    fNode.unfocus();
    fNode2.unfocus();

    if (widget.icon != "Custom Link") {
      setState(() {
        name = widget.icon;
      });
    }

    if (name.isEmpty) {
      showErrorToast(AppLocalizations.of(context)!.insertName);
      return;
    }

    if (link.isEmpty) {
      showErrorToast(AppLocalizations.of(context)!.insertLink);
      return;
    }

    ElementModel model = ElementModel();
    model.userId = user.tacUserId;
    model.icon =
        widget.icon == "Custom Link" ? "link" : widget.icon.toLowerCase();
    model.name = name;
    model.description = "";
    model.link = link;
    model.shared = false;
    model.sharedById = null;
    model.showOnProfile = false;
    model.type = DocumentOrLinkType.link;

    try {
      await insertLink(model);
      await widget.reload();
      Navigator.pop(context);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  void setName(String value) {
    setState(() {
      name = value;
    });
  }

  void setLink(String value) {
    setState(() {
      link = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.bottomLeft,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color),
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .color))),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(widget.icon,
                            style: Theme.of(context).textTheme.headline1),
                      ))
                ],
              ),
            )),
        body: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                  Center(
                      child: Icon(getLinkIconFromString(widget.icon),
                          size: 90,
                          color: Theme.of(context).textTheme.headline1!.color)),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            AppLocalizations.of(context)!.chooseLinkName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ))),
                  Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: InputText(
                        node: fNode2,
                          label: AppLocalizations.of(context)!.nameOfLink,
                          initalValue:
                              widget.icon == "Custom Link" ? name : widget.icon,
                          onChange: setName)),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextFormField(
                          textAlign: TextAlign.center,
                          autocorrect: false,
                          focusNode: fNode,
                          onChanged: setLink,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                              hintText: "Es: www.touchandcontact.com",
                              hintStyle: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color!))),
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .color))),
                  Expanded(
                      flex: 2,
                      child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: MaterialButton(
                              onPressed: () => {},
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: LoadingButton(
                                      onPress: addLink,
                                      width: 200,
                                      text: AppLocalizations.of(context)!.add,
                                      color: color,
                                      borderColor: color)))))
                ])));
  }
}
