// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/elements/element_list_item.dart';
import 'package:tac/components/elements/suggested_link.dart';
import 'package:tac/components/rectangle_skeleton_loader.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/icons_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/models/elements_management.dart';
import 'package:tac/models/icon_item.dart';
import 'package:tac/screens/elements/add_link.dart';
import 'package:tac/services/elements_service.dart';

import '../../components/buttons/outlinet_loading_button.dart';
import '../../components/generic_dialog.dart';
import '../../dialogs.dart';
import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import '../profile/became_premium.dart';

class ElementsLink extends StatefulWidget {
  const ElementsLink(
      {Key? key, required this.showSearch, required this.setCustomFilters, required this.blockFab})
      : super(key: key);
  final Function(bool) showSearch;
  final Function(bool) setCustomFilters;
  final Function(bool) blockFab;

  @override
  ElementsLinkState createState() => ElementsLinkState();
}

class ElementsLinkState extends State<ElementsLink> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  double height = 120;
  int selectedIndex = 0;
  bool error = true;
  bool isLoading = false;
  bool allChecked = false;
  bool scrollLoading = false;
  bool isDeleteMode = false;
  bool isDeleting = false;
  bool isInitCall = true;
  int page = 1;
  int pageItem = 10;
  int total = 0;
  String? searchedtext;
  List<ElementModel>? items;
  List<ElementModel> selectedItems = <ElementModel>[];
  List<IconItem> icons = getLinkAvailableIcons();
  ElementsManagement management = ElementsManagement();

  @override
  ElementsLink get widget => super.widget;

  @override
  void initState() {
    reloadAll();
    super.initState();
  }

  Future reloadAll() async {
    setState(() {
      page = 1;
      isLoading = true;
    });

    try {
      var model = await listElements(user.tacUserId, page, pageItem,
          DocumentOrLinkType.link, searchedtext);
      if(user.isCompanyPremium && user.companyId != null && user.companyId != 0 ){
        management = await checkBlocked(user.tacUserId);
        widget.blockFab(management.linksBlocked);
      }

      if (model != null) {
        setState(() {
          items = model.itemList;
          total = model.totalCount;
          isLoading = false;
        });
      }
      if (searchedtext != null && searchedtext!.isNotEmpty) {
        widget.showSearch(true);
      } else {
        widget.showSearch(items != null && items!.isNotEmpty);
      }

      await getAllToggle();
    } catch (e) {
      setState(() {
        error = true;
        isLoading = false;
      });
    }
  }

  Future onSearch(String value) async {
    setState(() {
      searchedtext = value;
    });
    await reloadAll();
  }

  Future pagination(ScrollController scrollController) async {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        (items!.length < total)) {
      setState(() {
        scrollLoading = true;
        page += 1;
      });

      try {
        var model = await listElements(user.tacUserId, page, pageItem,
            DocumentOrLinkType.link, searchedtext);

        if (model != null) {
          for (var i = 0; i < model.itemList.length; i++) {
            items!.add(model.itemList[i]);
          }

          setState(() {
            items = List.from(items!);
            total = model.totalCount;
            scrollLoading = false;
          });

          scrollController.animateTo(
              scrollController.position.maxScrollExtent + 50,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        }
      } catch (e) {
        setState(() {
          error = true;
          scrollLoading = false;
        });
      }
    }
  }

  openModalBecamePremium() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(
              child: Container(
            color: color,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BecamePremium()));
                    },
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(18)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(color)),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          height: 25,
                          width: 25,
                          child: Icon(Icons.star, size: 14, color: color),
                        ),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("${AppLocalizations.of(context)!.becamePro}!",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              Text(
                                  AppLocalizations.of(context)!.proBenefits,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 35, color: Colors.white)
                      ],
                    )),
              ],
            ),
          ));
        });
  }

  void openAddWithIcon(String icon, bool fromBottomSheet) {
    if ((user.subscriptionType == null || user.subscriptionType == 0) && !user.isCompanyPremium) {
      if (items != null && items!.length >= 3) {
        openModalBecamePremium();
        return;
      }
    }

    if (fromBottomSheet) Navigator.pop(context);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddLink(icon: icon, reload: reloadAll)));
  }

  void openSelectLink() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => bottomSheet(context));
  }

  void onLongPress() {
    if(management.linksBlocked) return;

    FocusScope.of(context).unfocus();
    setState(() {
      isDeleteMode = true;
      selectedItems = <ElementModel>[];
    });
    widget.setCustomFilters(true);
  }

  void toggleAll(bool value) async {
    showLoadingDialog(context);
    String resp = "";
    try {
      resp = await updateShowOnProfileAll(
          user.tacUserId, value, DocumentOrLinkType.link);
      Navigator.pop(context);
      if(!isUserCompanyBlocked()){
        await reloadAll();
      }else{
        if(resp.isNotEmpty){
          showDialog(
              context: context,
              builder: (context) {
                return GenericDialog(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                        child: Text(resp,
                            style: GoogleFonts.montserrat(fontSize: 16))));
              });
        }
        else{
          showSuccessToast(AppLocalizations.of(context)!.requestToLinkFile);
        }
      }
    } catch (_) {
      Navigator.pop(context);
      if(resp != null && resp.isNotEmpty){
        showDialog(
            context: context,
            builder: (context) {
              return GenericDialog(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                      child: Text(resp,
                          style: GoogleFonts.montserrat(fontSize: 16))));
            });
      }
      else{
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    }
  }

  Future getAllToggle() async {
    try {
      var value = await getCheckedAll(user.tacUserId, DocumentOrLinkType.link);
      if(isInitCall){
        setState(() {
          allChecked = value;
          isInitCall = false;
        });
      }else{
        if(isUserCompanyBlocked()){
          return;
        }
        setState(() {
          allChecked = value;
        });
      }
    } catch (_) {}
  }

  void checkItem(bool value, ElementModel item) {
    if (value) {
      selectedItems.add(item);
    } else {
      selectedItems.remove(item);
    }

    setState(() {
      selectedItems = List.from(selectedItems);
    });
  }

  Future deleteItems() async {
    try {
      await deleteElements(selectedItems.map((e) => e.id).toList());
      setState(() {
        isDeleteMode = false;
      });
      widget.setCustomFilters(false);
      Navigator.pop(context);

      await reloadAll();
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  void showDeleteDialog() {
    if (selectedItems.isEmpty) {
      showErrorDialog(
          context, AppLocalizations.of(context)!.attention, AppLocalizations.of(context)!.selectLinkToDelete);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericDialog(
                vertical: 220,
                disableExit: isDeleting,
                child: deleteDialog(context));
          });
    }
  }

  Future<bool> onPop() {
    FocusScope.of(context).unfocus();

    if (isDeleteMode) {
      setState(() {
        isDeleteMode = false;
        selectedItems = <ElementModel>[];
      });
      widget.setCustomFilters(false);

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void canPop() {
    FocusScope.of(context).unfocus();
    if (isDeleteMode) {
      setState(() {
        isDeleteMode = false;
        selectedItems = <ElementModel>[];
      });
      widget.setCustomFilters(false);
    } else {
      Navigator.pop(context);
    }
  }

  Widget deleteDialog(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("${AppLocalizations.of(context)!.deleteLink}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text("${AppLocalizations.of(context)!.deleteLinkProceed}?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: OutlinedLoadingButton(
                  color: Colors.red,
                  borderColor: Colors.red,
                  onPress: deleteItems,
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const RectangleSkeletonLoader(margin: EdgeInsets.all(0));
    } else {
      return WillPopScope(
          onWillPop: onPop,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isUserCompanyBlocked()
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color,
                                  size: 27),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                    AppLocalizations.of(context)!.blockedLink,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .color)),
                              )
                            ],
                          )
                        : Container(),
                    isUserCompanyBlocked()
                        ? const SizedBox(
                            height: 8,
                          )
                        : Container(),
                    if (items != null && items!.isNotEmpty && !isDeleteMode)
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(children: [
                            Text(AppLocalizations.of(context)!.all,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const Spacer(),
                           if(!management.linksBlocked)
                             Transform.scale(
                                 scale: 0.9,
                                 child: CupertinoSwitch(
                                     value: allChecked,
                                     onChanged: toggleAll,
                                     activeColor: Theme.of(context)
                                         .textTheme
                                         .headline1!
                                         .color))
                          ])),
                    if (items != null && items!.isNotEmpty) ...?getLinks(),
                    if (searchedtext == null || searchedtext!.isEmpty)
                      getSuggested(),
                    if (scrollLoading)
                      Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          color: Theme.of(context).backgroundColor,
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: CircularProgressIndicator(color: color)))
                  ])));
    }
  }

  List<ElementListItem>? getLinks() {
    return items
        ?.map((e) => ElementListItem(
            element: e,
            isCompanyUserBlocked: isUserCompanyBlocked(),
            longPressMode: isDeleteMode,
            onLongPress: () => onLongPress(),
            onItemCheck: (p0) => checkItem(p0, e),
            isChecked: selectedItems.contains(e),
            isLocked: management.linksBlocked,
            reloadAllChecked: getAllToggle))
        .toList();
  }

  bool isUserCompanyBlocked(){
    return  user.isCompanyPremium &&
        user.company != null &&
        user.company!.linksBlocked;
  }

  Widget getSuggested() {
    if (items == null || items!.isEmpty) {
      return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.suggested,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color)),
                SuggestedLink(
                    text: "Custom Link",
                    icon: Icons.link,
                    onAddClick: () => openAddWithIcon("Custom Link", false)),
                SuggestedLink(
                    text: "Whatsapp",
                    icon: FontAwesomeIcons.whatsapp,
                    onAddClick: () => openAddWithIcon("Whatsapp", false)),
                SuggestedLink(
                    text: "Telegram",
                    icon: Icons.telegram,
                    onAddClick: () => openAddWithIcon("Telegram", false)),
                SuggestedLink(
                    text: "Linkedin",
                    icon: FontAwesomeIcons.linkedin,
                    onAddClick: () => openAddWithIcon("Linkedin", false))
              ]));
    } else if (items != null && items!.isNotEmpty && items!.length < 7) {
      return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 5)),
                Text(AppLocalizations.of(context)!.suggested,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headline1!.color)),
                ...icons
                    .where((element) => items!
                        .where((e) =>
                            e.icon.toLowerCase() == element.name.toLowerCase())
                        .isEmpty)
                    .map((e) => SuggestedLink(
                        text: e.name,
                        icon: e.icon,
                        onAddClick: () => openAddWithIcon(e.name, false)))
                    .take(4)
                    .toList()
              ]));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        decoration: BoxDecoration(
            color: Theme.of(context).textTheme.headline1!.color,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AppLocalizations.of(context)!.addLink,
            style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Wrap(
              alignment: WrapAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: icons
                  .map((e) => GestureDetector(
                      onTap: () => openAddWithIcon(e.name, true),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.29,
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Column(children: [
                            Icon(e.icon, color: Colors.white, size: 40),
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(e.name,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)))
                          ]))))
                  .toList())
        ])));
  }
}
