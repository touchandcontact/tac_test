// ignore_for_file: use_build_context_synchronously
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/elements/element_list_item.dart';
import 'package:tac/components/rectangle_skeleton_loader.dart';
import 'package:tac/enums/document_or_link_type.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/icons_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/models/elements_management.dart';
import 'package:tac/models/icon_item.dart';
import 'package:tac/screens/elements/add_document.dart';
import 'package:tac/services/elements_service.dart';

import '../../components/buttons/outlinet_loading_button.dart';
import '../../components/generic_dialog.dart';
import '../../dialogs.dart';
import '../../extentions/hexcolor.dart';
import '../../models/user.dart';

class ElementsDocument extends StatefulWidget {
  const ElementsDocument(
      {Key? key, required this.showSearch, required this.setCustomFilters, required this.blockFab})
      : super(key: key);
  final Function(bool) showSearch;
  final Function(bool) setCustomFilters;
  final Function(bool) blockFab;

  @override
  ElementsDocumentState createState() => ElementsDocumentState();
}

class ElementsDocumentState extends State<ElementsDocument> {
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
  int page = 1;
  int pageItem = 10;
  int total = 0;
  String? searchedtext;
  List<ElementModel>? items;
  List<ElementModel> selectedItems = <ElementModel>[];
  List<IconItem> icons = getLinkAvailableIcons();
  ElementsManagement management = ElementsManagement();

  bool isInitCall = true;

  @override
  ElementsDocument get widget => super.widget;

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
          DocumentOrLinkType.document, searchedtext);
      management = await checkBlocked(user.tacUserId);
      widget.blockFab(management.documentsBlocked);

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
            DocumentOrLinkType.document, searchedtext);

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

  void goToAdd() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddDocument(reload: reloadAll)));
  }

  void onLongPress() {
    if(management.documentsBlocked) return;

    FocusScope.of(context).unfocus();
    setState(() {
      isDeleteMode = true;
      selectedItems = <ElementModel>[];
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.setCustomFilters(true);
    });
  }

  void toggleAll(bool value) async {
    showLoadingDialog(context);
    String resp = "";
    try {
      resp = await updateShowOnProfileAll(
          user.tacUserId, value, DocumentOrLinkType.document);
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
      var value = await getCheckedAll(user.tacUserId, DocumentOrLinkType.document);
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
      showErrorDialog(context, AppLocalizations.of(context)!.attention,
          AppLocalizations.of(context)!.selectDocumentToDelete);
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
                child: Text("${AppLocalizations.of(context)!.deleteDocument}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text("${AppLocalizations.of(context)!.deleteDocumentProceed}?",
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
                    isUserCompanyBlocked() ?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock,color: Theme.of(context).textTheme.headline2!.color,size: 27),
                        const SizedBox(width: 8,),
                        Expanded(
                          child:  Text(AppLocalizations.of(context)!.blockedFile,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color)),
                        )
                      ],) : Container(),
                    isUserCompanyBlocked() ?
                    const SizedBox(height: 8,) : Container(),
                    if (items != null && items!.isNotEmpty && !isDeleteMode)
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(children: [
                            Text(AppLocalizations.of(context)!.allFile,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color)),
                            const Spacer(),
                           if(!management.documentsBlocked)
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
                    if (items != null && items!.isNotEmpty) ...?getDocuments(),
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

  List<ElementListItem>? getDocuments() {
    return items
        ?.map((e) => ElementListItem(
            element: e,
            isCompanyUserBlocked: isUserCompanyBlocked(),
            isLocked: management.documentsBlocked,
            longPressMode: isDeleteMode,
            onLongPress: () => onLongPress(),
            onItemCheck: (p0) => checkItem(p0, e),
            isChecked: selectedItems.contains(e),
            reloadAllChecked: getAllToggle))
        .toList();
  }

  bool isUserCompanyBlocked(){
    return  user.isCompanyPremium &&
        user.company != null &&
        user.company!.documentsBlocked;
  }
}
