import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/searchbox.dart';
import 'package:tac/screens/elements/elements_link.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/buttons/tab_button.dart';
import '../../components/generic_dialog.dart';
import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import '../../services/account_service.dart';
import '../../themes/dark_theme_provider.dart';
import '../profile/became_premium.dart';
import 'elements_document.dart';

class Elements extends StatefulWidget {
  const Elements({Key? key}) : super(key: key);

  @override
  ElementsState createState() => ElementsState();
}

class ElementsState extends State<Elements> {
  bool showSearch = false;
  bool showFab = true;
  bool blockFab = false;
  bool showCustomFiters = false;
  int selectedIndex = 0;
  ScrollController scrollController = ScrollController();
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  GlobalKey<ElementsLinkState> linksKey = GlobalKey();
  GlobalKey<ElementsDocumentState> documentsKey = GlobalKey();

  @override
  void initState() {
    scrollController.addListener(onScroll);
    init();
    super.initState();
  }

  void init() async{
    try{
      await getUserForEdit(user.identifier).then((us) async {
        await Hive.box("settings")
            .put("user", jsonEncode(us.userDTO.toJson()));
        setState(() {
          user = us.userDTO;
        });
      });
    }
    catch(_){}
  }

  Future<void>? loadLinks() {
    setState(() {
      selectedIndex = 0;
      showSearch = false;
    });

    return null;
  }

  Future<void>? loadFiles() {
    setState(() {
      selectedIndex = 1;
      showSearch = false;
    });

    return null;
  }

  void onScroll() async {
    if (selectedIndex == 0) {
      await linksKey.currentState!.pagination(scrollController);
    } else {
      await documentsKey.currentState!.pagination(scrollController);
    }
  }

  Widget loadCorrectWidget() {
    switch (selectedIndex) {
      case 0:
        return ElementsLink(
            key: linksKey,
            showSearch: toggleSearch,
            blockFab: blockFabFunction,
            setCustomFilters: setCustomFilters);
      case 1:
        return ElementsDocument(
            key: documentsKey,
            showSearch: toggleSearch,
            blockFab: blockFabFunction,
            setCustomFilters: setCustomFilters);
      default:
        return Container(height: 0);
    }
  }

  void toggleSearch(bool value) {
    setState(() {
      showSearch = value;
    });
  }

  void blockFabFunction(bool value){
    setState(() {
      blockFab = value;
      showFab = value ? false : true;
    });
  }

  Future onSearch(String value) async {
    if (selectedIndex == 0) {
      await linksKey.currentState?.onSearch(value);
    } else {
      await documentsKey.currentState!.onSearch(value);
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
                                  builder: (context) =>
                                  const BecamePremium()));
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(10))),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(18)),
                            backgroundColor:
                            MaterialStateProperty.all<Color>(
                                color)),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 25,
                              width: 25,
                              child: Icon(Icons.star,
                                  size: 14, color: color),
                            ),
                            const Padding(
                                padding:
                                EdgeInsets.fromLTRB(10, 0, 0, 0)),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.start,
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


  void fabClick() {
    if (selectedIndex == 0) {
      if ((user.subscriptionType == null || user.subscriptionType == 0) && !user.isCompanyPremium) {
        if (linksKey.currentState!.items != null &&
            linksKey.currentState!.items!.length >= 3) {
          openModalBecamePremium();
        }else{
          linksKey.currentState!.openSelectLink();
        }
      } else {
        linksKey.currentState!.openSelectLink();
      }
    } else {
      if ((user.subscriptionType == null || user.subscriptionType == 0) && !user.isCompanyPremium) {
        openModalBecamePremium();
      } else {
        documentsKey.currentState!.goToAdd();
      }
    }
  }

  void setCustomFilters(bool value) {
    setState(() {
      showCustomFiters = value;
    });
  }

  void onDelete() {
    if (selectedIndex == 0) {
      linksKey.currentState!.showDeleteDialog();
    } else {
      documentsKey.currentState!.showDeleteDialog();
    }
  }

  void onBack() {
    if (selectedIndex == 0) {
      linksKey.currentState!.canPop();
    } else {
      documentsKey.currentState!.canPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            flexibleSpace: Padding(
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
                              onPressed: () => onBack(),
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
                        child: Text(AppLocalizations.of(context)!.elements,
                            style: Theme.of(context).textTheme.headline1),
                      ))
                ],
              ),
            )),
        body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.idle && !blockFab) {
                setState(() {
                  showFab = true;
                });
              } else {
                setState(() {
                  showFab = false;
                });
              }

              return true;
            },
            child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      height: 120,
                      clipBehavior: Clip.antiAlias,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: TabButton(
                              onPress: loadLinks,
                              text: AppLocalizations.of(context)!.link,
                              active: selectedIndex == 0,
                              inactiveLeftRadius: 10,
                              inactiveRightRadius: 0,
                            )),
                            Expanded(
                                child: TabButton(
                                    onPress: loadFiles,
                                    text: AppLocalizations.of(context)!.file,
                                    active: selectedIndex == 1,
                                    inactiveLeftRadius: 0,
                                    inactiveRightRadius: 0))
                          ])),
                  if (showSearch)
                    SearchBox(
                        onSearch: onSearch,
                        showFilters: showCustomFiters,
                        onlyOneCustomWidgets: true,
                        customFilters: onLongPressWidgets(),
                        label: selectedIndex == 0
                            ? AppLocalizations.of(context)!.searchAllLink
                            : AppLocalizations.of(context)!.searchAllFile),
                  loadCorrectWidget()
                ]))),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: fabClick,
                backgroundColor: color,
                child: Icon(
                  Icons.add,
                  size: 35,
                  color: color.computeLuminance() > 0.5
                      ? Theme.of(context).textTheme.bodyText2!.color
                      : Colors.white,
                ))
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }

  Widget? onLongPressWidgets() {
    if (showCustomFiters) {
      return Transform.translate(
          offset: const Offset(0, -10),
          child: Container(
              color: Theme.of(context).backgroundColor,
              child: Row(children: [
                IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outlined,
                        size: 35,
                        color: Theme.of(context).textTheme.headline2!.color))
              ])));
    } else {
      return null;
    }
  }
}
