// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/contacts/contact_list_item.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/contact.dart';
import 'package:tac/screens/contacts/internal_contact_detail.dart';
import 'package:tac/services/contacts_services.dart';
import '../../../components/buttons/outlinet_loading_button.dart';
import '../../../components/generic_dialog.dart';
import '../../../components/list_skeleton_loader.dart';
import '../../../components/searchbox.dart';
import '../../../dialogs.dart';
import '../../../extentions/hexcolor.dart';
import '../../../models/contact_company.dart';
import '../../../models/user.dart';
import '../../../models/user_contact_info_model.dart';
import '../external_contact_detail.dart';
import '../mod_external_contact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanyDetail extends StatefulWidget {
  const CompanyDetail({super.key, required this.company, required this.reload});

  final ContactCompany company;
  final Function reload;

  @override
  CompanyDetailState createState() => CompanyDetailState();
}

class CompanyDetailState extends State<CompanyDetail> {
  List<Contact>? items;
  ContactCompany _company = ContactCompany();
  int total = 0;
  bool isLoading = false;
  bool searchLoading = false;
  bool scrollLoading = false;
  int page = 1;
  int pageItem = 10;
  String orderBy = "DataCreazione";
  bool orderDesc = true;
  String? searchedText;
  var scrollController = ScrollController();
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  double searchPosition = -10;
  bool expand = false;
  bool isDeleteMode = false;
  bool isDeleting = false;
  bool error = false;
  List<Contact> selectedItems = <Contact>[];

  List<String> contextMenuItems = <String>[
    "Modifica cartella",
    "Elimina cartella",
    "Aggiungi contatti"
  ];

  @override
  CompanyDetail get widget => super.widget;

  @override
  void initState() {
    _company = widget.company;
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
      var model = await getCompanyContacts(user.tacUserId, widget.company.id,
          page, pageItem, orderBy, orderDesc, searchedText);
      setState(() {
        items = model.userContactlist;
        total = model.totalCount;
        isLoading = false;
      });
    } on Exception catch (_) {
      setState(() {
        isLoading = false;
        error = true;
      });
    }
  }

  void goToDetail(Contact item) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => item.tacUserId == null || item.tacUserId == 0
                ? ExternalContactDetail(contactId: item.id)
                : InternalContactDetail(contact: item)));
  }

  void pagination() async {
    if (scrollController.offset <= 30) {
      if (searchPosition < -10) {
        setState(() {
          searchPosition = -10;
          expand = false;
        });
      }
    } else {
      if (searchPosition == -10) {
        setState(() {
          searchPosition = -70;
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
        var model = await getCompanyContacts(user.tacUserId, widget.company.id,
            page, pageItem, orderBy, orderDesc, searchedText);

        for (var i = 0; i < model.userContactlist.length; i++) {
          items!.add(model.userContactlist[i]);
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

        var model = await getCompanyContacts(user.tacUserId, widget.company.id,
            page, pageItem, orderBy, orderDesc, searchedText);

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
      var model = await getCompanyContacts(user.tacUserId, widget.company.id,
          page, pageItem, orderBy, orderDesc, searchedText);

      setState(() {
        items = model.userContactlist;
        total = model.totalCount;
      });
    } on Exception catch (_) {}

    setState(() {
      searchLoading = false;
    });
  }

  Future<bool> onPop() {
    FocusScope.of(context).unfocus();

    if (isDeleteMode) {
      setState(() {
        isDeleteMode = false;
        expand = false;
        selectedItems = <Contact>[];
      });

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void onLongPress() {
    FocusScope.of(context).unfocus();
    setState(() {
      isDeleteMode = true;
      selectedItems = <Contact>[];
    });
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

  Future deleteContactsFromCompany(BuildContext context,
      {int? idDetail}) async {
    try {
      await deleteContacts(idDetail != null && idDetail != 0
          ? [idDetail]
          : selectedItems.map((e) => e.id).toList());
      await widget.reload();
      Navigator.pop(context);
      if (idDetail != null && idDetail != 0) {
        Navigator.pop(context);
      }

      await reloadAll();
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
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
                    : (MediaQuery.of(context).size.height > 845 ? 250 : 230),
                disableExit: isDeleting,
                child: deleteDialog());
          });
    }
  }

  void goToSendContact() {
    if (selectedItems.isEmpty) {
      showErrorDialog(
          context, AppLocalizations.of(context)!.attention, AppLocalizations.of(context)!.selectionContactSendError);
      return;
    }

    Navigator.pushNamed(context, "/sendContacts", arguments: selectedItems);
  }

  Future delete() async {
    await deleteFolder(widget.company.id);
    await widget.reload();

    Navigator.pop(context);
    Navigator.pop(context);
    try {} catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: isLoading || _company.id == 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(85),
                child: _company.id == 0 || isLoading
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                        child: Stack(children: [
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
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .color)),
                          Center(
                              child: Text(_company.companyName,
                                  style:
                                      Theme.of(context).textTheme.headline1)),
                        ]))),
        body: isLoading || _company.id == 0
            ? ListSkeletonLoader(
                height: MediaQuery.of(context).size.height * 0.9,
                margin: const EdgeInsets.fromLTRB(20, 100, 20, 0))
            : items == null || items!.isEmpty
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/nodata.png",
                            width: MediaQuery.of(context).size.width * 0.8),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
                        Text(AppLocalizations.of(context)!.noOneHere,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1),
                      ],
                    ),
                  )
                : WillPopScope(
                    onWillPop: onPop,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height *
                            (expand ? 1 : 0.9),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Stack(
                            clipBehavior: searchPosition == -10
                                ? Clip.none
                                : Clip.antiAlias,
                            children: [
                              searchLoading
                                  ? const ListSkeletonLoader(
                                      margin: EdgeInsets.fromLTRB(0, 60, 0, 0))
                                  : RefreshIndicator(
                                      onRefresh: onRefresh,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          physics:
                                              const ClampingScrollPhysics(),
                                          padding: EdgeInsets.fromLTRB(
                                              0, expand ? 0 : 75, 0, 0),
                                          itemCount: items!.length,
                                          itemBuilder: (context, index) {
                                            return Column(children: [
                                              ContactListItem(
                                                  iconFunction: () =>
                                                      _showModalBottomSheet(
                                                          items![index]),
                                                  item: items![index],
                                                  onTap: () =>
                                                      goToDetail(items![index]),
                                                  onLongPress: onLongPress,
                                                  isLongPressMode: isDeleteMode,
                                                  isChecked: selectedItems
                                                      .contains(items![index]),
                                                  onItemCheck: (value) =>
                                                      checkItem(value,
                                                          items![index])),
                                              if (index != items!.length - 1)
                                                Divider(
                                                    height: 10,
                                                    color: Theme.of(context)
                                                        .dividerColor)
                                            ]);
                                          })),
                              if (scrollLoading)
                                Positioned(
                                    bottom: 0,
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 0),
                                        color:
                                            Theme.of(context).backgroundColor,
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: color)))),
                              AnimatedPositioned(
                                  top: searchPosition,
                                  duration: const Duration(milliseconds: 200),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  curve: Curves.elasticOut,
                                  child: SearchBox(
                                      showFilters: true,
                                      customFilters: !isDeleteMode
                                          ? null
                                          : onLongPressWidgets(),
                                      onSearch: onSearch,
                                      onFilter: onFilter))
                            ]))));
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
                child: Text("${AppLocalizations.of(context)!.deleteContact}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text("${AppLocalizations.of(context)!.deleteContactProceed}?",
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
                  onPress: () => deleteContactsFromCompany(context,
                      idDetail: idContactDetail),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                )),
            const SizedBox(
              height: 20,
            )
          ],
        ));
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

  void _showModalBottomSheet(Contact contact) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      elevation: 10,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Theme.of(context).backgroundColor),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
              child: Column(
                children: [
                  contact.tacUserId == null || contact.tacUserId == 0
                      ? GestureDetector(
                          onTap: () {
                            _goToEditContact(contact);
                          },
                          child: Row(children: [
                            const Icon(Icons.mode, size: 18),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            Text(AppLocalizations.of(context)!.modContactLabel,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color))
                          ]),
                        )
                      : Container(),
                  contact.tacUserId == null || contact.tacUserId == 0
                      ? const SizedBox(
                          height: 30,
                        )
                      : Container(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GenericDialog(
                                child: deleteSingleDialog(contact.id));
                          });
                    },
                    child: Row(children: [
                      const Icon(Icons.delete, size: 18),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Text(AppLocalizations.of(context)!.delete,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).textTheme.headline1!.color))
                    ]),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
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
                child: Text("${AppLocalizations.of(context)!.deleteContactsProceed}?",
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
                  onPress: (() => deleteContactsFromCompany(context)),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                ))
          ],
        ));
  }

  Widget deleteFolderDialog() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("${AppLocalizations.of(context)!.deleteFolder}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text("${AppLocalizations.of(context)!.deleteFolderProceed}?",
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
                  onPress: (() => delete()),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                ))
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
