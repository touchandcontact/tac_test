import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/loading_button.dart';
import 'package:tac/components/contacts/contact_list_item.dart';
import 'package:tac/components/searchbox.dart';
import 'package:tac/components/tag_item.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/tag.dart';
import '../../components/list_skeleton_loader.dart';
import '../../extentions/hexcolor.dart';
import '../../models/contact.dart';
import '../../models/user.dart';
import '../../services/contacts_services.dart';

class SelectContacts extends StatefulWidget {
  const SelectContacts(
      {super.key,
      required this.onButtonPress,
      required this.title,
      required this.subtitle,
      required this.onlyTac,
      this.alreadySelected,
      required this.buttonText});

  final Future Function(List<Contact>) onButtonPress;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool onlyTac;
  final List<Contact>? alreadySelected;

  @override
  SelectContactsState createState() => SelectContactsState();
}

class SelectContactsState extends State<SelectContacts> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  List<Contact>? items;
  List<Contact> selectedItems = <Contact>[];
  List<Tag> tags = <Tag>[];
  Tag? selectedTag;
  ScrollController scrollController = ScrollController();

  bool isLoading = false;
  bool searchLoading = false;
  bool scrollLoading = false;
  bool isSaving = false;
  bool expand = false;
  int page = 1;
  int pageItem = 10;
  int total = 0;
  double searchPosition = 0;
  double buttonPosition = 10;
  String? searchedText;

  @override
  SelectContacts get widget => super.widget;

  @override
  void initState() {
    setState(() {
      selectedItems = <Contact>[];
    });

    reloadAll();
    if (widget.alreadySelected != null && widget.alreadySelected!.isNotEmpty) {
      setState(() {
        selectedItems = List.from(widget.alreadySelected!);
      });
    }

    scrollController.addListener(onScroll);
    super.initState();
  }

  Future reloadAll() async {
    setState(() {
      page = 1;
      isLoading = true;
    });

    try {
      var model = await listContacts(
          user.tacUserId, page, pageItem, "nome", false, null,
          onlyTac: widget.onlyTac);

      setState(() {
        items = model.userContactlist;
        total = model.totalCount;
        isLoading = false;
      });
    } on Exception catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onScroll() async {
    if (scrollController.offset <= 30) {
      if (searchPosition < 0) {
        setState(() {
          searchPosition = 0;
          expand = false;
        });
      }
    } else {
      if (searchPosition == 0) {
        setState(() {
          searchPosition = -300;
          expand = true;
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
        if (searchedText == null || searchedText!.isEmpty) {
          var model = await listContacts(
              user.tacUserId, page, pageItem, "nome", false, null);

          for (var i = 0; i < model.userContactlist.length; i++) {
            items!.add(model.userContactlist[i]);
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
      setState(() {
        tags = <Tag>[];
        selectedTag = null;
      });
      await reloadAll();
    } else {
      try {
        setState(() {
          searchLoading = true;
        });

        var model = await searchContacts(
            user.tacUserId, page, pageItem, "nome", false, value, null,
            onlyTac: widget.onlyTac,
            disablePaging: true,
            tags: selectedTag == null ? null : [selectedTag!.tag]);

        List<Tag> dbTags = <Tag>[];
        if (model.userContactlist.isNotEmpty) {
          dbTags = await listTagsByContacts(
              model.userContactlist.map((e) => e.id).toList());
        }

        setState(() {
          items = model.userContactlist;
          total = model.totalCount;
          tags = dbTags;
          searchLoading = false;
        });
      } on Exception catch (_) {
        setState(() {
          searchLoading = false;
        });
      }
    }
  }

  void checkElement(Contact contact) {
    if (selectedItems.contains(contact)) {
      selectedItems.remove(contact);
    } else {
      selectedItems.add(contact);
    }

    setState(() {
      selectedItems = List.from(selectedItems);
    });
  }

  void checkOrUncheckAll(bool value) {
    if (!value) {
      selectedItems.clear();
    } else {
      selectedItems = List.from(items!);
    }

    setState(() {
      selectedItems = List.from(selectedItems);
    });
  }

  void onTagTapped(Tag item) async {
    setState(() {
      selectedTag = item;
    });

    await onSearch(searchedText);
  }

  Future<dynamic> confirm() async {
    if (selectedItems.isEmpty) {
      showErrorToast(AppLocalizations.of(context)!.chooseContact);
      return;
    }

    setState(() {
      isSaving = true;
    });
    try {
      await widget.onButtonPress(selectedItems);
    } catch (_) {}

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).textTheme.headline2!.color,
                        ))),
                const Spacer(),
                Text(widget.title,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headline1),
                const Spacer(),
              ]),
              const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
              isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: const ListSkeletonLoader(
                          margin: EdgeInsets.symmetric(horizontal: 0)))
                  : SizedBox(
                      child: Stack(children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.83,
                          padding: EdgeInsets.fromLTRB(
                              0,
                              expand
                                  ? 0
                                  : searchedText == null ||
                                          searchedText!.isEmpty ||
                                          searchLoading
                                      ? 130
                                      : tags.isEmpty
                                          ? 170
                                          : 225,
                              0,
                              0),
                          child: items == null || items!.isEmpty
                              ? searchLoading
                                  ? const ListSkeletonLoader(
                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0))
                                  : const SizedBox.shrink()
                              : searchLoading
                                  ? const ListSkeletonLoader(
                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0))
                                  : NotificationListener<
                                          UserScrollNotification>(
                                      onNotification: (notification) {
                                        if (notification.direction ==
                                            ScrollDirection.idle) {
                                          setState(() {
                                            buttonPosition = 10;
                                          });
                                        } else {
                                          setState(() {
                                            buttonPosition = -100;
                                          });
                                        }

                                        return true;
                                      },
                                      child: GroupedListView<dynamic, String>(
                                          elements: items!,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 0),
                                          controller: scrollController,
                                          groupBy: (element) => (element as Contact)
                                              .name[0]
                                              .toUpperCase(),
                                          groupSeparatorBuilder:
                                              (String groupByValue) => Padding(
                                                  padding: const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 5),
                                                  child: Text(groupByValue[0],
                                                      style: GoogleFonts.montserrat(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Theme.of(context)
                                                              .textTheme
                                                              .headline1!
                                                              .color))),
                                          itemBuilder: (context, dynamic element) => ContactListItem(item: (element as Contact),iconFunction: (){}, onLongPress: () {}, onTap: () => checkElement(element), onItemCheck: (value) => checkElement(element), useBackgroundColor: false, isLongPressMode: true, isChecked: selectedItems.any((e) => e.id == element.id)),
                                          order: GroupedListOrder.ASC))),
                      AnimatedPositioned(
                          top: searchPosition,
                          duration: const Duration(microseconds: 500),
                          width: MediaQuery.of(context).size.width * 0.89,
                          child: Column(children: [
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
                            Text(widget.subtitle,
                                maxLines: 2,
                                style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .color)),
                            const Padding(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                            SearchBox(onSearch: onSearch),
                            if (tags.isNotEmpty && !searchLoading)
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context)!.resultTag,
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color)),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                    SizedBox(
                                        height: 25,
                                        width: double.infinity,
                                        child: ListView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          children: tags
                                              .map((e) => TagItem(
                                                  item: e,
                                                  marginRight: 5,
                                                  onTap: () => onTagTapped(e)))
                                              .toList(),
                                        ))
                                  ]),
                            if (items != null &&
                                searchedText != null &&
                                searchedText!.isNotEmpty &&
                                !searchLoading)
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context)!.resultContact,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color)),
                                    const Spacer(),
                                    Transform.scale(
                                        scale: 1.4,
                                        child: Checkbox(
                                          checkColor:
                                              color.computeLuminance() > 0.5
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .bodyText2!
                                                      .color
                                                  : Colors.white,
                                          fillColor:
                                              MaterialStateProperty.all(color),
                                          value: selectedItems.length ==
                                              items!.length,
                                          shape: const CircleBorder(),
                                          onChanged: (bool? value) =>
                                              checkOrUncheckAll(value ?? false),
                                        ))
                                  ])
                          ])),
                      if (!scrollLoading)
                        AnimatedPositioned(
                            duration: const Duration(milliseconds: 500),
                            bottom: buttonPosition,
                            left: MediaQuery.of(context).size.width *
                                (isSaving ? 0.4 : 0.2),
                            child: LoadingButton(
                                width: 200,
                                onPress: confirm,
                                text: widget.buttonText,
                                color: color,
                                borderColor: color)),
                      if (scrollLoading)
                        Positioned(
                            bottom: 0,
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                color: Theme.of(context).backgroundColor,
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: color))))
                    ]))
            ])));
  }
}
