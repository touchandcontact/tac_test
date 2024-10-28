import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/contacts/contact_company_list_item.dart';
import 'package:tac/services/contacts_services.dart';
import '../../components/list_skeleton_loader.dart';
import '../../components/searchbox.dart';
import '../../extentions/hexcolor.dart';
import '../../models/contact_company.dart';
import '../../models/user.dart';
import 'no_contacts.dart';

class CompaniesContact extends StatefulWidget {
  const CompaniesContact({super.key, required this.onScroll});

  final void Function(bool hide) onScroll;

  @override
  CompaniesContactState createState() => CompaniesContactState();
}

class CompaniesContactState extends State<CompaniesContact> {
  List<ContactCompany>? items;
  int total = 0;
  bool isLoading = false;
  bool searchLoading = false;
  bool scrollLoading = false;
  int page = 1;
  int pageItem = 10;
  String orderBy = "DataCreazione";
  bool orderDesc = true;
  bool isDeleteMode = false;
  bool isDeleting = false;
  String? searchedText;
  var scrollController = ScrollController();
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  List<ContactCompany> selectedItems = <ContactCompany>[];

  double searchPosition = 0;
  bool expand = false;

  @override
  CompaniesContact get widget => super.widget;

  @override
  void initState() {
    reloadAll();
    scrollController.addListener(pagination);
    super.initState();
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
      var model = await listCompanies(
          user.tacUserId, page, pageItem, orderBy, orderDesc, null);

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
      if (searchPosition < 0 && !isDeleteMode) {
        setState(() {
          searchPosition = 0;
          widget.onScroll(false);
          expand = false;
        });
      }
    } else {
      if (searchPosition == 0 && !isDeleteMode) {
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
        if (searchedText != null && searchedText!.isNotEmpty) {
          var model = await searchCompanies(user.tacUserId, page, pageItem,
              orderBy, orderDesc, searchedText, null);

          for (var i = 0; i < model.itemList.length; i++) {
            items!.add(model.itemList[i]);
          }

          setState(() {
            items = List.from(items!);
            total = model.totalCount;
            scrollLoading = false;
          });
        } else {
          var model = await listCompanies(
              user.tacUserId, page, pageItem, orderBy, orderDesc, null);

          for (var i = 0; i < model.itemList.length; i++) {
            items!.add(model.itemList[i]);
          }

          setState(() {
            items = List.from(items!);
            total = model.totalCount;
            scrollLoading = false;
          });

          scrollController.animateTo(
              scrollController.position.maxScrollExtent + 70,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn);
        }
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

        var model = await searchCompanies(
            user.tacUserId, page, pageItem, orderBy, orderDesc, value, null);

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
      if (searchedText != null && searchedText!.isNotEmpty) {
        var model = await searchCompanies(user.tacUserId, page, pageItem,
            orderBy, orderDesc, searchedText, null);
        setState(() {
          items = model.itemList;
          total = model.totalCount;
          isLoading = false;
        });
      } else {
        var model = await listCompanies(
            user.tacUserId, page, pageItem, orderBy, orderDesc, null);
        setState(() {
          items = model.itemList;
          total = model.totalCount;
          isLoading = false;
        });
      }
    } on Exception catch (_) {}

    setState(() {
      searchLoading = false;
    });
  }

  void onLongPress() {
    // FocusScope.of(context).unfocus();

    // widget.onScroll(true);
    // setState(() {
    //   isDeleteMode = true;
    //   selectedItems = <ContactCompany>[];
    // });

    // Future.delayed(const Duration(milliseconds: 200), () {
    //   setState(() {
    //     expand = true;
    //   });
    // });
  }

  void checkItem(bool value, ContactCompany item) {
    if (value) {
      selectedItems = [...selectedItems, item];
    } else {
      selectedItems.remove(item);
    }
    setState(() {});
  }

  void goToSendContact() {
    Navigator.pushNamed(context, "/sendContactsCompanies",
        arguments: selectedItems);
  }

  Future<bool> onPop() {
    FocusScope.of(context).unfocus();

    if (isDeleteMode) {
      widget.onScroll(false);

      setState(() {
        isDeleteMode = false;
        expand = false;
        selectedItems = <ContactCompany>[];
      });

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ListSkeletonLoader(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 0));
    } else {
      if (items == null || items!.isEmpty) {
        return NoContacts(
          onButtonPress: () => {},
          isCompany: true,
        );
      } else {
        return WillPopScope(
            onWillPop: onPop,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height:
                  MediaQuery.of(context).size.height * (expand ? 0.78 : 0.7),
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
                              padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                              itemCount: items!.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ContactCompanyListItem(
                                        item: items![index],
                                        onTap: () {
                                          Navigator.pushNamed(context, '/companyDetail', arguments: <dynamic>[items![index], reloadAll]);
                                        },
                                        onLongPress: onLongPress,
                                        isLongPressMode: isDeleteMode,
                                        isChecked: selectedItems
                                            .contains(items![index]),
                                        onItemCheck: (value) =>
                                            checkItem(value, items![index])),
                                    if (index != items!.length - 1)
                                      Divider(
                                          height: 10,
                                          color: Theme.of(context).dividerColor)
                                  ],
                                );
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
                                child:
                                    CircularProgressIndicator(color: color)))),
                  AnimatedPositioned(
                    top: searchPosition,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: SearchBox(
                        showFilters: true,
                        customFilters: null,
                        onSearch: onSearch,
                        onFilter: onFilter),
                  )
                ],
              ),
            ));
      }
    }
  }

  Widget onLongPressWidgets() {
    return Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
            color: Theme.of(context).backgroundColor,
            child: Row(children: [
              Transform.rotate(
                  angle: -45,
                  child: IconButton(
                      onPressed: goToSendContact,
                      icon: Icon(
                        Icons.send_outlined,
                        size: 30,
                        color: Theme.of(context).textTheme.headline2!.color,
                      )))
            ])));
  }
}
