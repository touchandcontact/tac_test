import 'dart:convert';
import 'dart:io';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/contacts/contact_list_item.dart';
import 'package:tac/components/generic_dialog.dart';
import 'package:tac/components/list_skeleton_loader.dart';
import 'package:tac/components/searchbox.dart';
import 'package:tac/dialogs.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/contact.dart';
import 'package:tac/screens/contacts/add_external_contact.dart';
import 'package:tac/screens/contacts/external_contact_detail.dart';
import 'package:tac/screens/contacts/no_contacts.dart';
import 'package:tac/services/contacts_services.dart';
import '../../components/buttons/outlinet_loading_button.dart';
import '../../extentions/hexcolor.dart';
import '../../models/user.dart';
import '../../models/user_contact_info_model.dart';
import 'internal_contact_detail.dart';
import 'mod_external_contact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AllContacts extends StatefulWidget {
  const AllContacts(
      {super.key,
      required this.onScroll,
      required this.toggleFab,
      required this.showBack});

  final void Function(bool hide) onScroll;
  final void Function(bool show) toggleFab;
  final void Function(bool show) showBack;

  @override
  AllContactsState createState() => AllContactsState();
}

class AllContactsState extends State<AllContacts> {
  List<Contact>? items;
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
  List<Contact> selectedItems = <Contact>[];

  double searchPosition = 0;
  bool expand = false;
  bool isError = false;

  @override
  AllContacts get widget => super.widget;

  @override
  void initState() {
    Hive.box("settings").watch(key: "reloadAfterAdd").listen((event) {
      reloadAll();
    });
    reloadAll();
    scrollController.addListener(pagination);
    super.initState();
  }

  void goToCreateContact() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddExternalContactModal(
                  contactParam: null,
                  onSuccess: onSuccess,
                )));
  }

  void goToDetail(Contact item) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => item.tacUserId == null || item.tacUserId == 0
                ? ExternalContactDetail(contactId: item.id)
                : InternalContactDetail(contact: item))).then((value) {
      if (value != null && value) onRefresh();
    });
  }

  void _showModalBottomSheet(Contact contact) {
    showAdaptiveActionSheet(
        androidBorderRadius: 20,
        bottomSheetColor: Theme.of(context).backgroundColor,
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))),
        actions: [
          if(contact.tacUserId == null || contact.tacUserId == 0)
          BottomSheetAction(
            leading: const Icon(Icons.mode, size: 18),
              title: Text(AppLocalizations.of(context)!.modContactLabel,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (BuildContext context) {_goToEditContact(contact);}),
          BottomSheetAction(
              leading: const Icon(Icons.delete, size: 18),
              title:Text(AppLocalizations.of(context)!.delete,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                      Theme.of(context).textTheme.headline1!.color)),
              onPressed: (BuildContext context) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return GenericDialog(
                          child: deleteSingleDialog(contact.id));
                    });
              })
        ],
        context: context);
  }

  void _goToEditContact(Contact contact) async {
    late UserContactInfoModel userMod;
    try {
      userMod = await _loadDetailContact(contact.id);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      return;
    }
    if (!mounted) return;
    if (userMod.id != null && userMod.id != 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ModExternalContactModal(
                    idContattoDaLista: contact.id,
                    contactMod: userMod,
                  ))).then((value) {
        if (value != null && value) {
          Navigator.of(context).pop();
          reloadAll();
        }
      });
    } else {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  Future<UserContactInfoModel> _loadDetailContact(int idContact) {
    try {
      return getExternalContact(idContact);
    } catch (e) {
      throw Exception();
    }
  }

  Widget deleteSingleDialog(int idContactDetail) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.deleteContact,
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteContactProceed}?",
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
                  onPress: () => delete(idDetail: idContactDetail),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                )),
            const SizedBox(
              height: 50,
            )
          ],
        ));
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
      var model = await listContacts(
          user.tacUserId, page, pageItem, orderBy, orderDesc, null);

      setState(() {
        items = model.userContactlist;
        total = model.totalCount;
        isLoading = false;
      });

      if (items == null || items!.isEmpty) {
        widget.toggleFab(false);
      } else {
        widget.toggleFab(true);
      }
    } on Exception catch (_) {
      setState(() {
        isLoading = false;
        isError = false;
      });
      widget.toggleFab(false);
    }
  }

  resetFromError() async {
    setState(() {
      isError = false;
    });
    widget.toggleFab(true);
    await reloadAll();
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
          var model = await searchContacts(user.tacUserId, page, pageItem,
              orderBy, orderDesc, searchedText, null);

          for (var i = 0; i < model.userContactlist.length; i++) {
            items!.add(model.userContactlist[i]);
          }

          setState(() {
            items = List.from(items!);
            total = model.totalCount;
            scrollLoading = false;
          });
        } else {
          var model = await listContacts(
              user.tacUserId, page, pageItem, orderBy, orderDesc, null);

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
            user.tacUserId, page, pageItem, orderBy, orderDesc, value, null);

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

  Future onFilter(bool orderDesc, String orderBy) async {
    setState(() {
      searchLoading = true;
      this.orderBy = orderBy;
      this.orderDesc = orderDesc;
      page = 1;
    });

    try {
      if (searchedText != null && searchedText!.isNotEmpty) {
        var model = await searchContacts(user.tacUserId, page, pageItem,
            orderBy, orderDesc, searchedText, null);
        setState(() {
          items = model.userContactlist;
          total = model.totalCount;
          isLoading = false;
        });
      } else {
        var model = await listContacts(
            user.tacUserId, page, pageItem, orderBy, orderDesc, null);
        setState(() {
          items = model.userContactlist;
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
    FocusScope.of(context).unfocus();

    widget.onScroll(true);
    widget.toggleFab(false);

    setState(() {
      isDeleteMode = true;
      selectedItems = <Contact>[];
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        expand = true;
      });
      widget.showBack(true);
    });
  }

  void showDeleteDialog() {
    if (selectedItems.isEmpty) {
      showErrorDialog(context, AppLocalizations.of(context)!.attention,
          AppLocalizations.of(context)!.selectionContactDeleteError);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return GenericDialog(
                vertical: Platform.isAndroid
                    ? 240
                    : 230,
                disableExit: isDeleting,
                child: deleteDialog());
          });
    }
  }

  void checkItem(bool value, Contact item) {
    if (value) {
      selectedItems = [...selectedItems, item];
    } else {
      selectedItems.remove(item);
    }
    setState(() {
      selectedItems = List.from(selectedItems);
    });
  }

  void goToSendContact() {
    if (selectedItems.isEmpty) {
      showErrorDialog(context, AppLocalizations.of(context)!.attention,
          AppLocalizations.of(context)!.selectionContactSendError);
      return;
    }

    Navigator.pushNamed(context, "/sendContacts", arguments: selectedItems);
  }

  Future<bool> onPop() {
    FocusScope.of(context).unfocus();

    if (isDeleteMode) {
      widget.onScroll(false);

      setState(() {
        isDeleteMode = false;
        expand = false;
        selectedItems = <Contact>[];
      });
      widget.toggleFab(true);
      widget.showBack(false);

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future delete({int? idDetail}) async {
    setState(() {
      isDeleting = true;
    });

    try {
      await deleteContacts(idDetail != null && idDetail != 0
          ? [idDetail]
          : selectedItems.map((e) => e.id).toList());
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      if (idDetail != null && idDetail != 0) {
        Navigator.of(context).pop();
      }
      showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      await reloadAll();
    } catch (_) {
      Navigator.of(context).pop();
      showErrorToast(AppLocalizations.of(context)!.error);
    }

    setState(() {
      isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ListSkeletonLoader(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 0));
    } else {
      if (items == null || items!.isEmpty) {
        return NoContacts(onButtonPress: goToCreateContact);
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
                      :  NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                if (notification.direction ==
                                        ScrollDirection.idle &&
                                    !isDeleteMode) {
                                  widget.toggleFab(true);
                                } else if (!isDeleteMode) {
                                  widget.toggleFab(false);
                                }
                                return true;
                              },
                              child: RefreshIndicator(onRefresh: onRefresh, child: ListView.builder(
                                  controller: scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding:
                                  const EdgeInsets.fromLTRB(0, 80, 0, 0),
                                  itemCount: items!.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ContactListItem(
                                            item: items![index],
                                            onTap: () {
                                              if (!isDeleteMode)
                                                goToDetail(items![index]);
                                            },
                                            onLongPress: onLongPress,
                                            isLongPressMode: isDeleteMode,
                                            iconFunction: () =>
                                                _showModalBottomSheet(
                                                    items![index]),
                                            isChecked: selectedItems
                                                .contains(items![index]),
                                            onItemCheck: (value) => checkItem(
                                                value, items![index])),
                                        if (index != items!.length - 1)
                                          Divider(
                                              height: 10,
                                              color: Theme.of(context)
                                                  .dividerColor)
                                      ],
                                    );
                                  }))),
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
                        customFilters:
                            !isDeleteMode ? null : onLongPressWidgets(),
                        onSearch: onSearch,
                        onFilter: onFilter),
                  )
                ],
              ),
            ));
      }
    }
  }

  Widget deleteDialog() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("${AppLocalizations.of(context)!.deleteContacts}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteContactsProceed}?",
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
                  onPress: delete,
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                )),
            const SizedBox(height: 20)
          ],
        ));
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
                      ))),
              IconButton(
                  onPressed: showDeleteDialog,
                  icon: Icon(Icons.delete_outlined,
                      size: 35,
                      color: Theme.of(context).textTheme.headline2!.color))
            ])));
  }
}
