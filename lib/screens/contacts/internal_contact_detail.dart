import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/skeleton/link_file_skeleton.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/contact_profile.dart';
import 'package:tac/models/element_model.dart';
import '../../components/contacts/detail_contact/contact_empty_error_widget.dart';
import '../../components/contacts/detail_contact/contact_header.dart';
import '../../components/contacts/detail_contact/info_contact_widget.dart';
import '../../components/contacts/detail_contact/link_document_contact.dart';
import '../../components/contacts/detail_contact/tag_contact_widget.dart';
import '../../components/inputs/input_text.dart';
import '../../components/skeleton/contact_header_skeleton.dart';
import '../../components/skeleton/info_contact_skeleton.dart';
import '../../components/skeleton/principal_skeleton.dart';
import '../../components/skeleton/tag_skeleton.dart';
import '../../enums/type_action.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/icons_helper.dart';
import '../../helpers/util.dart';
import '../../models/contact.dart';
import '../../models/icon_item.dart';
import '../../models/tag.dart';
import '../../models/user.dart';
import '../../models/user_contact_info_model.dart';
import '../../services/contacts_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InternalContactDetail extends StatefulWidget {
  Contact contact;

  InternalContactDetail({super.key, required this.contact});

  @override
  InternalContactDetailState createState() => InternalContactDetailState();
}

class InternalContactDetailState extends State<InternalContactDetail> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  ContactProfile contact = ContactProfile();
  bool isLoading = false;

  late Future<UserContactInfoModel> _contactInformationFuture;
  late Future<List<ElementModel>> _linkDocumentsFuture;
  late Future<List<Tag>> _contactTagsFuture;

  final ValueNotifier<bool> _isModView = ValueNotifier(false);
  final ValueNotifier<bool> _isModNoteView = ValueNotifier(false);
  String? _noteToUpdate;

  List<IconItem> icons = getLinkAvailableIcons();

  //Per insight
  late Timer _timerViewNotifica;
  int _tacContactId = 0;

  @override
  void initState() {
    _timerViewNotifica = Timer(const Duration(seconds: 10),
        () => _saveInsights());
    _contactInformationFuture = _loadDetailContact();
    _linkDocumentsFuture = _loadLinkDocument();
    _contactTagsFuture = _loadTag();
    super.initState();
  }

  Future<UserContactInfoModel> _loadDetailContact() {
    try {
      return getContact(widget.contact.id);
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<ElementModel>> _loadLinkDocument() {
    return getContactDocumentAndLink(widget.contact.id);
  }

  Future<List<Tag>> _loadTag() {
    return listTagsByContact(widget.contact.id);
  }

  _gridItem(String? value, IconData icon, TypeAction typeAction) {
    return GestureDetector(
      onTap: () {
        Util.openLink(value!, typeAction,context);
      },
      child: Container(
        alignment: Alignment.center,
        width: 70,
        decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(18.0)),
        child: ListTile(
          minVerticalPadding: 0,
          contentPadding: EdgeInsets.zero,
          title: Icon(icon),
          subtitle: _generateTextWidget(
              Util.returnCorrectLabel(typeAction,context) ?? "---", Theme.of(context).textTheme.headline1!.color!,
              fontSize: 8, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  void _saveUpdateNote(int contactId, String? notes) async {
    try {
      await upateContactNote(contactId, notes!);
      showSuccessToast(AppLocalizations.of(context)!.mod);
      setState(() {
        _contactInformationFuture = _loadDetailContact();
        _linkDocumentsFuture = _loadLinkDocument();
      });
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  void _saveInsights(){
    Util.saveInsights(_tacContactId,user.tacUserId);
    if(_timerViewNotifica.isActive){
      _timerViewNotifica.cancel();
    }
  }

  _detailWidget(UserContactInfoModel userContact) {
    final List<Widget> listGridItem = [];

    if (userContact.telephone != null) {
      listGridItem.add(
          _gridItem(userContact.telephone, Icons.phone, TypeAction.TELEFONO));
    }
    if (userContact.address != null) {
      listGridItem.add(_gridItem(
          userContact.address, Icons.location_on, TypeAction.INDIRIZZO));
    }
    if (userContact.email != null) {
      listGridItem
          .add(_gridItem(userContact.email, Icons.email, TypeAction.EMAIL));
    }
    if (userContact.website != null) {
      listGridItem.add(
          _gridItem(userContact.website, Icons.public, TypeAction.LINK_WEB));
    }

    if (listGridItem.length < 4) {
      for (int i = listGridItem.length; i < 4; i++) {
        listGridItem.add(Container(
          width: 70,
        ));
      }
    }
    return Column(
      children: [
        Align(
            alignment: Alignment.center,
            child: _generateTextWidget(
                _returnNameSurname(userContact.name, userContact.surname) ?? "",
                Theme.of(context).textTheme.headline1!.color!,
                fontWeight: FontWeight.w600,
                fontSize: 30)),
        const SizedBox(
          height: 8,
        ),
        if(userContact.company != null)
          Align(
              alignment: Alignment.center,
              child: _generateTextWidget(userContact.company!,
                  Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.w600, fontSize: 15)),
        if(userContact.company != null)
          const SizedBox(
            height: 8,
          ),
        Align(
            alignment: Alignment.center,
            child: _generateTextWidget(userContact.profession ?? "",
                Theme.of(context).textTheme.headline2!.color!,
                fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(
          height: 30,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _generateTextWidget(
              AppLocalizations.of(context)!.note, Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600),
          GestureDetector(
            onTap: () {
              _isModNoteView.value = !_isModNoteView.value;
            },
            child: userContact.notes != null && userContact.notes!.isNotEmpty
                ? _generateTextWidget(
                AppLocalizations.of(context)!.modInphrase, Theme.of(context).textTheme.headline2!.color!,
                    fontWeight: FontWeight.w400, fontSize: 14)
                : _generateTextWidget(
                AppLocalizations.of(context)!.add, Theme.of(context).textTheme.headline2!.color!,
                    fontWeight: FontWeight.w400, fontSize: 14),
          )
        ]),
        const SizedBox(
          height: 16,
        ),
        ValueListenableBuilder(
            valueListenable: _isModNoteView,
            builder: (context, valueNotifier, child) {
              if (valueNotifier) {
                return Column(
                  children: [
                    InputText(
                      label: "",
                      initalValue: userContact.notes,
                      onChange: (String value) {
                        _noteToUpdate = value;
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      onPressed: () {
                        if (_noteToUpdate == null || _noteToUpdate!.isEmpty) {
                          showErrorToast(AppLocalizations.of(context)!.requiredField);
                          return;
                        }
                        _saveUpdateNote(userContact.id, _noteToUpdate);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Text(AppLocalizations.of(context)!.save,
                            style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white)),
                      ),
                    )
                  ],
                );
              } else {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: _generateTextWidget(userContact.notes ?? "",
                      Theme.of(context).textTheme.headline2!.color!),
                );
              }
            }),
        const SizedBox(
          height: 30,
        ),
        Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _generateTextWidget(
                  AppLocalizations.of(context)!.principals, Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.w600),
              GestureDetector(
                child: _generateTextWidget(
                    AppLocalizations.of(context)!.seeAll, Theme.of(context).textTheme.headline2!.color!,
                    fontWeight: FontWeight.w400, fontSize: 14),
                onTap: () {
                  _isModView.value = !_isModView.value;
                },
              ),
            ]),
            const SizedBox(
              height: 16,
            ),
            ValueListenableBuilder(
                valueListenable: _isModView,
                builder: (context, valueNotifier, child) {
                  if (valueNotifier) {
                    return InfoContactWidget(userContact: userContact);
                  } else {
                    return SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listGridItem.map<Widget>((e) => e).toList(),
                        ));
                  }
                })
          ],
        )
      ],
    );
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 16,
          FontWeight fontWeight = FontWeight.w500,
          TextAlign? textAlign}) =>
      Text(
        value,
        textAlign: textAlign,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  _returnNameSurname(String? name, String? surname) {
    if (name != null && surname != null) {
      return "$name $surname";
    } else if (name != null) {
      return name;
    } else if (surname != null) {
      return surname;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Theme.of(context).backgroundColor),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.zero,
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              FutureBuilder<dynamic>(
                  future: Future.wait([_contactInformationFuture, _contactTagsFuture, _linkDocumentsFuture]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ContactHeaderSkeleton();
                    }
                    if (snapshot.hasError) {
                      showErrorToast(AppLocalizations.of(context)!.error);
                      return ContactHeader(
                        identifierUser: user.identifier,
                        isExternal: false,
                        contactId: widget.contact.id,
                        listTag: const [],
                        contact: UserContactInfoModel(id: 0),
                      );
                    }
                    if (snapshot.hasData) {
                      _tacContactId = snapshot.data[0]!.tacUserId!;
                      return ContactHeader(
                        identifierUser: user.identifier,
                        isExternal: false,
                        contact: snapshot.data[0],
                        listTag: snapshot.data[1],
                        listLinkAndDocument: snapshot.data[2],
                        contactId: widget.contact.id,
                      );
                    }
                    return Container();
                  }),
              const SizedBox(
                height: 20,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      FutureBuilder<UserContactInfoModel>(
                          future: _contactInformationFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return InfoContactSkeleton();
                            }
                            if (snapshot.hasError) {
                              return ContactEmptyErrorWidget(
                                  label: AppLocalizations.of(context)!.error);
                            }
                            if (snapshot.hasData) {
                              UserContactInfoModel userContactModel =
                                  snapshot.data!;
                              _noteToUpdate = snapshot.data!.notes;
                              return Column(
                                children: [
                                  _detailWidget(userContactModel),
                                  // const SizedBox(
                                  //   height: 60,
                                  // ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _generateTextWidget(
                                            AppLocalizations.of(context)!.addTag,
                                            Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color!,
                                            fontWeight: FontWeight.w600),
                                      ]),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  FutureBuilder<List<Tag>>(
                                      future: _contactTagsFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Column(
                                            children: [
                                              TagSkeleton(),
                                              PrincipalSkeleton(),
                                            ],
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return ContactEmptyErrorWidget(
                                              label:
                                              AppLocalizations.of(context)!.error);
                                        }
                                        if (snapshot.hasData) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: RawMaterialButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  TagContactWidget(
                                                                    idContact:
                                                                        userContactModel
                                                                            .id,
                                                                    listaTagContact:
                                                                        snapshot
                                                                            .data!,
                                                                  ))).then(
                                                          (value) {
                                                        if (value != null &&
                                                            value) {
                                                          setState(() {
                                                            _contactTagsFuture =
                                                                _loadTag();
                                                          });
                                                        }
                                                      });
                                                    },
                                                    fillColor: color,
                                                    shape: const CircleBorder(),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 36.0,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: snapshot.data!.isEmpty
                                                    ? Text(
                                                    AppLocalizations.of(context)!.elementNotFound)
                                                    : SizedBox(
                                                        height: 60,
                                                        child: ListView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          children: snapshot
                                                              .data!
                                                              .map<Widget>(
                                                                  (e) =>
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(horizontal: 8),
                                                                        child:
                                                                            FilterChip(
                                                                          label: Text(
                                                                              e.tag,
                                                                              style: TextStyle(color: color)),
                                                                          backgroundColor:
                                                                              Theme.of(context).backgroundColor,
                                                                          shape:
                                                                              StadiumBorder(side: BorderSide(color: color)),
                                                                          onSelected:
                                                                              (bool value) {},
                                                                        ),
                                                                      ))
                                                              .toList(),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          );
                                        }
                                        return Container();
                                      }),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _generateTextWidget(
                                            AppLocalizations.of(context)!.linkAndFile,
                                            Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color!,
                                            fontWeight: FontWeight.w600),
                                      ]),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  FutureBuilder<List<ElementModel>>(
                                      future: _linkDocumentsFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return LinkFileSkeleton();
                                        }
                                        if (snapshot.hasError) {
                                          return ContactEmptyErrorWidget(
                                              label:
                                              AppLocalizations.of(context)!.error);
                                        }
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.isEmpty) {
                                            return ContactEmptyErrorWidget(
                                                label:
                                                AppLocalizations.of(context)!.elementNotFound);
                                          }
                                          return LinkDocumentContact(
                                            listaItem: snapshot.data!,
                                            tacUserId: _tacContactId,
                                          );
                                        }
                                        return Container();
                                      })
                                ],
                              );
                            }
                            return Container();
                          }),
                      const SizedBox(
                        height: 60,
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    if(_timerViewNotifica.isActive){
      _timerViewNotifica.cancel();
    }
    super.dispose();
  }
}
