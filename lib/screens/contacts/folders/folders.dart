// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/contacts/folder_list_item.dart';
import 'package:tac/models/folder.dart';
import 'package:tac/screens/contacts/folders/add_folder.dart';
import 'package:tac/services/contacts_services.dart';

import '../../../components/list_skeleton_loader.dart';
import '../../../components/rectangle_skeleton_loader.dart';
import '../../../components/searchbox.dart';
import '../../../extentions/hexcolor.dart';
import '../../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Folders extends StatefulWidget {
  const Folders({super.key, required this.onScroll});

  final void Function(bool hide) onScroll;

  @override
  FoldersState createState() => FoldersState();
}

class FoldersState extends State<Folders> {
  List<Folder>? items;
  int total = 0;
  bool isLoading = false;
  bool searchLoading = false;
  bool scrollLoading = false;
  int shared = 3;
  int page = 1;
  int pageItem = 10;
  String orderBy = "DataCreazione";
  bool orderDesc = true;
  String? searchedText;
  var scrollController = ScrollController();
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  double searchPosition = 0;
  bool expand = false;

  @override
  Folders get widget => super.widget;

  @override
  void initState() {
    reloadAll();
    scrollController.addListener(pagination);
    super.initState();
  }

  Future onSuccess() async {
    await reloadAll();
  }

  Future<void> onRefresh() async {
    await reloadAll();
    return Future<void>.delayed(const Duration(seconds: 3));
  }

  Future reloadAll() async {
    setState(() {
      page = 1;
      isLoading = true;
    });

    try {
      var model = await listFolders(
          user.tacUserId, page, pageItem, orderBy, orderDesc, shared,
          searchText: searchedText);

      setState(() {
        items = model.itemList;
        total = model.totalCount;
        isLoading = false;
      });
    } on Exception catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void pagination() async {
    if (scrollController.offset <= 30) {
      if (searchPosition < 0) {
        setState(() {
          searchPosition = 0;
          widget.onScroll(false);
          expand = false;
        });
      }
    } else {
      if (searchPosition == 0) {
        setState(() {
          searchPosition = -70;
          widget.onScroll(true);
          if (Platform.isAndroid || items!.length > 9) {
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                expand = true;
              });
            });
          }
        });
      }
    }

    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        (items!.length < total)) {
      setState(() {
        scrollLoading = true;
        page += 1;
      });

      try {
        var model = await listFolders(
            user.tacUserId, page, pageItem, orderBy, orderDesc, shared,
            searchText: searchedText);

        for (var i = 0; i < model.itemList.length; i++) {
          items!.add(model.itemList[i]);
        }

        setState(() {
          items = List.from(items!);
          total = model.totalCount;
          scrollLoading = false;
        });

        scrollController.animateTo(
            scrollController.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
      } on Exception catch (_) {}
    }
  }

  Future onSearch(String? value) async {
    setState(() {
      searchedText = value;
    });

    if (value == null || value.isEmpty) {
      await reloadAll();
    } else {
      try {
        setState(() {
          searchLoading = true;
        });

        var model = await listFolders(
            user.tacUserId, page, pageItem, orderBy, orderDesc, shared,
            searchText: searchedText);

        setState(() {
          items = model.itemList;
          total = model.totalCount;
          searchLoading = false;
        });
      } on Exception catch (_) {
        setState(() {
          searchLoading = false;
        });
      }
    }
  }

  Future onFilter(bool orderDesc, String orderBy) async {
    setState(() {
      searchLoading = true;
      this.orderBy = orderBy;
      this.orderDesc = orderDesc;
      page = 1;
    });

    try {
      var model = await listFolders(
          user.tacUserId, page, pageItem, orderBy, orderDesc, shared,
          searchText: searchedText);

      setState(() {
        items = model.itemList;
        total = model.totalCount;
      });
    } on Exception catch (_) {}

    setState(() {
      searchLoading = false;
    });
  }

  Future<bool> onPop() {
    FocusScope.of(context).unfocus();
    return Future.value(true);
  }

  void onTypeChange(String? value) async {
    Navigator.pop(context);
    if (value == null) return;

    try {
      setState(() => shared = int.parse(value));
      await reloadAll();
    } catch (_) {}
  }

  void goToDetail(Folder item) {
    Navigator.pushNamed(context, '/folderDetail',
        arguments: <dynamic>[item.id, reloadAll]);
  }

  void openAddFolder() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddFolderModal(onSuccess: onSuccess)));
  }

  void openSelect() {
    showAdaptiveActionSheet(
        context: context,
        androidBorderRadius: 20,
        bottomSheetColor: Theme.of(context).backgroundColor,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.allFolder,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                onTypeChange("3");
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.notShared,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                onTypeChange("0");
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.sharedByMe,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                onTypeChange("1");
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.shareWithMe,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                onTypeChange("2");
              }),
        ],
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const RectangleSkeletonLoader(
          margin: EdgeInsets.fromLTRB(10, 20, 10, 0));
    } else {
      return WillPopScope(
          onWillPop: onPop,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * (expand ? 0.78 : 0.7),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Stack(
              children: [
                searchLoading
                    ? const ListSkeletonLoader(
                        margin: EdgeInsets.fromLTRB(0, 60, 0, 0))
                    : RefreshIndicator(
                        onRefresh: onRefresh,
                        child: ListView.builder(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(0, 125, 0, 0),
                            itemCount: items!.length,
                            itemBuilder: (context, index) {
                              return Column(children: [
                                FolderListItem(
                                  item: items![index],
                                  onTap: () => goToDetail(items![index]),
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 10))
                              ]);
                            })),
                if (scrollLoading)
                  Positioned(
                      bottom: 0,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          color: Theme.of(context).backgroundColor,
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: CircularProgressIndicator(color: color)))),
                AnimatedPositioned(
                    top: searchPosition,
                    duration: const Duration(milliseconds: 200),
                    width: MediaQuery.of(context).size.width * 0.9,
                    curve: Curves.elasticOut,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SearchBox(
                              showFilters: true,
                              onSearch: onSearch,
                              onFilter: onFilter),
                          Container(
                              color: Theme.of(context).backgroundColor,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                        onTap: () => openSelect(),
                                        child: Row(children: [
                                          Text(
                                              shared == 0
                                                  ? AppLocalizations.of(context)!.notShared
                                                  : (shared == 1
                                                      ? AppLocalizations.of(context)!.sharedByMe
                                                      : shared == 2
                                                          ?  AppLocalizations.of(context)!.shareWithMe
                                                          : AppLocalizations.of(context)!.allFolder),
                                              style: GoogleFonts.montserrat(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline1!
                                                      .color,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          Icon(Icons.arrow_drop_down,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline1!
                                                  .color)
                                        ])),
                                    const Spacer(),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: TextButton(
                                            onPressed: openAddFolder,
                                            style: ButtonStyle(
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            18.0))),
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Theme.of(context)
                                                            .textTheme
                                                            .headline1!
                                                            .color)),
                                            child: Text(AppLocalizations.of(context)!.newFolder,
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600))))
                                  ]))
                        ]))
              ],
            ),
          ));
    }
  }
}
