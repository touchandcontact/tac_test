import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/searchbox.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import '../../components/contacts/contact_list_item.dart';
import '../../components/list_skeleton_loader.dart';
import '../../dialogs.dart';
import '../../extentions/hexcolor.dart';
import '../../models/contact.dart';
import '../../models/user.dart';
import '../../services/contacts_services.dart';

class SendContacts extends StatefulWidget {
  const SendContacts({super.key, required this.toSend});
  final List<Contact> toSend;

  @override
  SendContactsState createState() => SendContactsState();
}

class SendContactsState extends State<SendContacts> {
  @override
  SendContacts get widget => super.widget;

  bool isLoading = false;
  bool sendLoading = false;
  bool searchLoading = false;
  List<Contact>? items;
  List<Contact> selectedItems = <Contact>[];
  var scrollController = ScrollController();
  int page = 1;
  int pageItem = 10;
  int total = 0;
  String? searchedText;
  bool scrollLoading = false;

  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

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

  void onSuccess() async {
    await reloadAll();
  }

  Future reloadAll() async {
    setState(() {
      page = 1;
      isLoading = true;
    });

    try {
      var model = await listContacts(user.tacUserId, page, pageItem,
          "datacreazione", true, widget.toSend.map((e) => e.id).toList(), onlyTac: true);

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

  void pagination() async {
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        (items!.length < total)) {
      setState(() {
        scrollLoading = true;
        page += 1;
      });

      try {
        if (searchedText != null && searchedText!.isNotEmpty) {
          var model = await searchContacts(
              user.tacUserId,
              page,
              pageItem,
              "datacreazione",
              true,
              searchedText,
              widget.toSend.map((e) => e.id).toList(),
              onlyTac: true);

          for (var i = 0; i < model.userContactlist.length; i++) {
            items!.add(model.userContactlist[i]);
          }

          setState(() {
            items = List.from(items!);
            total = model.totalCount;
            scrollLoading = false;
          });
        } else {
          var model = await listContacts(user.tacUserId, page, pageItem,
              "datacreazione", true, widget.toSend.map((e) => e.id).toList(), onlyTac: true);

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
      await reloadAll();
    } else {
      try {
        setState(() {
          searchLoading = true;
        });

        var model = await searchContacts(
            user.tacUserId,
            page,
            pageItem,
            "datacreazione",
            true,
            value,
            widget.toSend.map((e) => e.id).toList(),
            onlyTac: true);

        setState(() {
          items = model.userContactlist;
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

  void selectItem(Contact item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }

    setState(() {
      selectedItems = List.from(selectedItems);
    });
  }

  Future send(BuildContext context) async {
    if(sendLoading) return;

    if (selectedItems.isEmpty) {
      showErrorDialog(context, AppLocalizations.of(context)!.attention,
          AppLocalizations.of(context)!.selectContactToSend);
    } else {

      setState(() {
        sendLoading = true;
      });

      try {
        String? sender = user.email;
        if(user.name != null && user.surname != null){
          sender = "${user.name} ${user.surname}";
        }

        showLoadingDialog(context);
        await sendContacts(
          sender!,
            widget.toSend, selectedItems.map((e) => e.id).toList());
        setState(() {
          sendLoading = false;
        });

        // ignore: use_build_context_synchronously
        showSuccessToast(AppLocalizations.of(context)!.successContactSended);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (_) {
        showErrorToast(AppLocalizations.of(context)!.error);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back,
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          color: Theme.of(context).textTheme.bodyText2!.color)),
                  Center(
                      child: Text(AppLocalizations.of(context)!.sendTo,
                          style: Theme.of(context).textTheme.headline1)),
                  Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: () => send(context),
                        child: Text(AppLocalizations.of(context)!.send,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: color,
                                fontWeight: FontWeight.w600)),
                      ))
                ],
              ),
            )),
        body: Container(
            color: Theme.of(context).backgroundColor,
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width,
            child: isLoading
                ? const ListSkeletonLoader(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0))
                : items != null
                    ? Stack(children: [
                        searchLoading
                            ? const ListSkeletonLoader(
                                margin: EdgeInsets.fromLTRB(0, 60, 0, 0))
                            : RefreshIndicator(
                                onRefresh: onRefresh,
                                child: ListView.builder(
                                    controller: scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 100, 0, 0),
                                    itemCount: items!.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          ContactListItem(
                                            iconFunction: (){},
                                            item: items![index],
                                            hideMenu: true,
                                            isLongPressMode: true,
                                            usePadding: true,
                                            onTap: () => {},
                                            onItemCheck: (value) => selectItem(items![index]),
                                            isChecked: selectedItems
                                                .contains(items![index]),
                                            onLongPress: () {},
                                          ),
                                          if (index != items!.length - 1)
                                            Divider(
                                                height: 1,
                                                color: Theme.of(context)
                                                    .dividerColor)
                                        ],
                                      );
                                    })),
                        if (scrollLoading)
                          Positioned(
                              bottom: 0,
                              child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  color: Theme.of(context).backgroundColor,
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: color)))),
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                color: Theme.of(context).backgroundColor,
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SearchBox(
                                              onSearch: onSearch,
                                              showFilters: false)
                                        ]),
                                    Positioned(
                                        bottom: 10,
                                        left: 20,
                                        child: Text(AppLocalizations.of(context)!.contactsUp,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline1!
                                                    .color)))
                                  ],
                                )))
                      ])
                    : const SizedBox.shrink())));
  }
}
