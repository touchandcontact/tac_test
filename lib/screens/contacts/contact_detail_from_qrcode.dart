import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/contact_profile.dart';
import 'package:tac/models/element_model.dart';
import 'package:tac/screens/associated_card/associated_cards.dart';
import '../../components/contacts/detail_contact/link_document_contact.dart';
import '../../components/contacts/detail_contact/tag_contact_widget.dart';
import '../../components/generic_dialog.dart';
import '../../components/inputs/input_text.dart';
import '../../components/skeleton/contact_header_skeleton.dart';
import '../../components/skeleton/info_contact_skeleton.dart';
import '../../components/skeleton/link_file_skeleton.dart';
import '../../components/skeleton/principal_skeleton.dart';
import '../../components/skeleton/tag_skeleton.dart';
import '../../components/tac_logo.dart';
import '../../enums/type_action.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/util.dart';
import '../../models/qr_contact_dto.dart';
import '../../models/tag.dart';
import '../../models/user.dart';
import '../../services/contacts_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/statistics_service.dart';
import '../landing.dart';

class ContactDetailFromQrCode extends StatefulWidget {
  String identifier;
  bool isFromNfc;

  ContactDetailFromQrCode(
      {super.key, required this.identifier, required this.isFromNfc});

  @override
  ContactDetailFromQrCodeState createState() => ContactDetailFromQrCodeState();
}

class ContactDetailFromQrCodeState extends State<ContactDetailFromQrCode> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  ContactProfile contact = ContactProfile();
  bool isLoading = false;

  late Future<QrContactDto> _contactInformationFuture;
  late Future<List<ElementModel>> _linkDocumentsFuture;
  late Future<List<Tag>> _contactTagsFuture;

  final ValueNotifier<bool> _isModView = ValueNotifier(false);
  final ValueNotifier<bool> _isModNoteView = ValueNotifier(false);
  final ValueNotifier<List<Tag>> _listTagCopy = ValueNotifier<List<Tag>>([]);

  String? _noteToUpdate;

  @override
  void initState() {
    _contactInformationFuture = _loadDetailContact();
    _linkDocumentsFuture = _loadLinkDocument();
    _saveInsightNfc();

    super.initState();
  }

  Future<QrContactDto> _loadDetailContact() {
    try {
      return getContactByIdentifier(widget.identifier);
    } catch (e) {
      if (e.toString().contains("Carta non associata")) {
        Navigator.pop(context);
        Navigator.pop(context);

        Navigator.push(
            context, MaterialPageRoute(builder: (_) => AssociatedCards()));
        return Future.error("Carta non associata");
      } else {
        throw Exception();
      }
    }
  }

  Future<List<ElementModel>> _loadLinkDocument() {
    return getElementsByIdentifier(widget.identifier);
  }

  Future<List<Tag>> _loadTag(int idContact) {
    return listTagsByContact(idContact);
  }

  _gridItem(String? value, IconData icon, TypeAction typeAction) {
    return GestureDetector(
      onTap: () {
        Util.openLink(value!, typeAction, context);
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
              Util.returnCorrectLabel(typeAction, context) ?? "---",
              Theme.of(context).textTheme.headline1!.color!,
              fontSize: 8,
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  _errorProfileWidget(String text) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _generateTextWidget(AppLocalizations.of(context)!.principals,
              Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600),
          _generateTextWidget(AppLocalizations.of(context)!.seeAll, Colors.grey,
              fontWeight: FontWeight.w400),
        ]),
        const SizedBox(
          height: 16,
        ),
        Text(text)
      ],
    );
  }

  _detailWidget(QrContactDto userContact) {
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
        if (userContact.companyName != null)
          Align(
              alignment: Alignment.center,
              child: _generateTextWidget(userContact.companyName!,
                  Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.w600, fontSize: 15)),
        if (userContact.companyName != null)
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    side: const BorderSide(width: 0, color: Colors.transparent),
                  ),
                  onPressed: () {
                    _saveContact(userContact);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
                    child: Text(AppLocalizations.of(context)!.saveContact,
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                        .primaryColor
                                        .computeLuminance() >
                                    0.5
                                ? Theme.of(context).textTheme.bodyText2!.color
                                : Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _generateTextWidget(AppLocalizations.of(context)!.note,
              Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600),
          GestureDetector(
              onTap: () {
                _isModNoteView.value = !_isModNoteView.value;
              },
              child: _generateTextWidget(
                  AppLocalizations.of(context)!.modInphrase,
                  Theme.of(context).textTheme.headline2!.color!,
                  fontWeight: FontWeight.w400,
                  fontSize: 14))
        ]),
        const SizedBox(
          height: 16,
        ),
        ValueListenableBuilder<bool>(
            valueListenable: _isModNoteView,
            builder: (context, value, child) {
              if (value) {
                return Column(
                  children: [
                    InputText(
                      label: "",
                      initalValue: _noteToUpdate,
                      onChange: (String value) {
                        _noteToUpdate = value;
                      },
                    ),
                  ],
                );
              } else {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: _generateTextWidget(_noteToUpdate ?? "",
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
              _generateTextWidget(AppLocalizations.of(context)!.principals,
                  Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.w600),
              GestureDetector(
                child: _generateTextWidget(AppLocalizations.of(context)!.seeAll,
                    Theme.of(context).textTheme.headline2!.color!,
                    fontWeight: FontWeight.w400, fontSize: 14),
                onTap: () {
                  _isModView.value = !_isModView.value;
                },
              ),
            ]),
            const SizedBox(
              height: 16,
            ),
            ValueListenableBuilder<bool>(
                valueListenable: _isModView,
                builder: (context, value, child) {
                  if (!value) {
                    return SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listGridItem.map<Widget>((e) => e).toList(),
                        ));
                  } else {
                    return Column(
                      children: [
                        InputText(
                            keyboardType: TextInputType.phone,
                            label: AppLocalizations.of(context)!.telephone,
                            onChange: (String val) {},
                            enabled: false,
                            initalValue: userContact.telephone ?? ""),
                        const SizedBox(
                          height: 8,
                        ),
                        InputText(
                            label: AppLocalizations.of(context)!.address,
                            onChange: (String val) {},
                            enabled: false,
                            initalValue: userContact.address ?? ""),
                        const SizedBox(
                          height: 8,
                        ),
                        InputText(
                            keyboardType: TextInputType.emailAddress,
                            label: AppLocalizations.of(context)!.email,
                            onChange: (String val) {},
                            enabled: false,
                            initalValue: userContact.email ?? ""),
                        const SizedBox(
                          height: 8,
                        ),
                        InputText(
                            label: AppLocalizations.of(context)!.website,
                            onChange: (String val) {},
                            keyboardType: TextInputType.url,
                            enabled: false,
                            initalValue: userContact.website ?? ""),
                      ],
                    );
                  }
                })
          ],
        )
      ],
    );
  }

  Future<void> _saveIdentifier() async {
    try {
      final tacUserIdConact = await getTacUserId(widget.identifier);
      if (tacUserIdConact != null && tacUserIdConact != 0) {
        await Util.saveInsights(tacUserIdConact, user.tacUserId);
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  _saveContact(QrContactDto userContact) async {
    FocusScope.of(context).unfocus();
    showLoadingDialog(context);
    try {
      final response = await insertContact(widget.identifier, user.tacUserId,
          _noteToUpdate ?? "", _listTagCopy.value);
      if (response) {
        _saveIdentifier();
        if (!mounted) return;
        Navigator.pop(context);
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => GenericDialog(
                child: _contentDialogSaveContatto(userContact),
                onClose: () {
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Landing()),
                    ModalRoute.withName('/'),
                  );
                }));
      } else {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  _contentDialogSaveContatto(QrContactDto userContact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              color: Theme.of(context).primaryColor, size: 80),
          const SizedBox(
            height: 16,
          ),
          _generateTextWidget(
              "${AppLocalizations.of(context)!.saveContactSuccess}!",
              Theme.of(context).textTheme.headline1!.color!,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          const SizedBox(
            height: 16,
          ),
          _generateTextWidget(
              AppLocalizations.of(context)!.saveContactSuccessInfo,
              Theme.of(context).textTheme.headline2!.color!,
              fontSize: 16,
              textAlign: TextAlign.center),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(width: 1.0, color: color),
                      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(15),
                              right: Radius.circular(15)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.compare_arrows,
                        size: 32,
                        color: color,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(AppLocalizations.of(context)!.swapContact,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  onPressed: () async {
                    _swapContact(userContact);
                  },
                ),
              ),
            ],
          )
        ],
      ),
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

  _swapContact(QrContactDto userContact) async {
    showLoadingDialog(context);
    try {
      final tacUserIdContact = await getTacUserId(widget.identifier);
      if (tacUserIdContact != null && tacUserIdContact != 0) {
        await insertContact(user.identifier, tacUserIdContact, "", []);
        if (!mounted) return;
        Navigator.pop(context);
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      } else {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  _buildCoverImageWidget(String? coverImage) {
    if (coverImage != null && coverImage.isNotEmpty) {
      return Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(coverImage), fit: BoxFit.cover)),
      );
    } else {
      return Container();
    }
  }

  _buildProfileImageWidget(String? profileImage) {
    return Positioned(
      top: 120,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: profileImage == null || profileImage.isEmpty
            ? Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TacLogo(forProfileImage: true),
                      Container(
                          constraints:
                              BoxConstraints.loose(const Size.fromHeight(60.0)),
                          child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Positioned(
                                    top: -10,
                                    child: Icon(
                                      Icons.person,
                                      color: color,
                                      size: 70,
                                    ))
                              ]))
                    ]),
              )
            : Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    image: DecorationImage(
                        image: NetworkImage(profileImage), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(30)),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 0, backgroundColor: Theme.of(context).backgroundColor),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.zero,
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              FutureBuilder<QrContactDto>(
                  future: _contactInformationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ContactHeaderSkeleton();
                    }
                    if (snapshot.hasError) {
                      late String text;
                      if (snapshot.error
                          .toString()
                          .toLowerCase()
                          .trim()
                          .contains(AppLocalizations.of(context)!
                              .cardNotActive
                              .toLowerCase()
                              .trim())) {
                        text = AppLocalizations.of(context)!.cardNotActive;
                      } else if (snapshot.error
                          .toString()
                          .toLowerCase()
                          .trim()
                          .contains(AppLocalizations.of(context)!
                              .cardNotFound
                              .toLowerCase()
                              .trim())) {
                        text = AppLocalizations.of(context)!.cardNotFound;
                      } else if (snapshot.error
                          .toString()
                          .toLowerCase()
                          .trim()
                          .contains(AppLocalizations.of(context)!
                              .cardNotAssociated
                              .toLowerCase()
                              .trim())) {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => Navigator.pop(context));
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AssociatedCards())));
                      } else {
                        text = AppLocalizations.of(context)!.error;
                      }
                      showErrorToast(text);
                      // showErrorToast(AppLocalizations.of(context)!.error);
                      return _headerWidget(null, null);
                    }
                    if (snapshot.hasData) {
                      return _headerWidget(snapshot.data?.coverImage,
                          snapshot.data?.profileImage);
                    }
                    return Container();
                  }),
              const SizedBox(
                height: 60,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      FutureBuilder<QrContactDto>(
                          future: _contactInformationFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return InfoContactSkeleton(
                                isFromQrCode: true,
                              );
                            }
                            if (snapshot.hasError) {
                              late String text;
                              if (snapshot.error
                                  .toString()
                                  .toLowerCase()
                                  .trim()
                                  .contains(AppLocalizations.of(context)!
                                      .cardNotActive
                                      .toLowerCase()
                                      .trim())) {
                                text =
                                    AppLocalizations.of(context)!.cardNotActive;
                              } else if (snapshot.error
                                  .toString()
                                  .toLowerCase()
                                  .trim()
                                  .contains(AppLocalizations.of(context)!
                                      .cardNotFound
                                      .toLowerCase()
                                      .trim())) {
                                text =
                                    AppLocalizations.of(context)!.cardNotFound;
                              } else if (snapshot.error
                                  .toString()
                                  .toLowerCase()
                                  .trim()
                                  .contains(AppLocalizations.of(context)!
                                      .cardNotAssociated
                                      .toLowerCase()
                                      .trim())) {
                                text = AppLocalizations.of(context)!
                                    .cardNotAssociated;
                              } else {
                                text = AppLocalizations.of(context)!.error;
                              }
                              return _errorProfileWidget(text);
                            }
                            if (snapshot.hasData) {
                              QrContactDto userContactModel = snapshot.data!;
                              _contactTagsFuture =
                                  _loadTag(userContactModel.id);
                              return Column(
                                children: [
                                  _detailWidget(userContactModel),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _generateTextWidget(
                                            AppLocalizations.of(context)!
                                                .addTag,
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
                                          return Column(
                                            children: [
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Text(AppLocalizations.of(context)!
                                                  .error)
                                            ],
                                          );
                                        }
                                        if (snapshot.hasData) {
                                          _listTagCopy.value = snapshot.data!;
                                          return ValueListenableBuilder<
                                                  List<Tag>>(
                                              valueListenable: _listTagCopy,
                                              builder: (context, valueNotifier,
                                                  child) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        height: 60,
                                                        width: 60,
                                                        child:
                                                            RawMaterialButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        TagContactWidget(
                                                                          isAggiungiContatto:
                                                                              true,
                                                                          idContact:
                                                                              userContactModel.id,
                                                                          listaTagContact:
                                                                              valueNotifier,
                                                                        ))).then(
                                                                (value) {
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                _listTagCopy
                                                                    .value
                                                                    .clear();
                                                                _listTagCopy
                                                                        .value =
                                                                    value;
                                                              }
                                                            });
                                                          },
                                                          fillColor: color,
                                                          shape:
                                                              const CircleBorder(),
                                                          child: const Icon(
                                                            Icons.add,
                                                            size: 36.0,
                                                            color: Colors.white,
                                                          ),
                                                        )),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: valueNotifier
                                                              .isEmpty
                                                          ? Text(AppLocalizations
                                                                  .of(context)!
                                                              .elementNotFound)
                                                          : SizedBox(
                                                              height: 60,
                                                              child: ListView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                children:
                                                                    valueNotifier
                                                                        .map<Widget>((e) =>
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                              child: FilterChip(
                                                                                label: Text(e.tag, style: TextStyle(color: color)),
                                                                                backgroundColor: Theme.of(context).backgroundColor,
                                                                                shape: StadiumBorder(side: BorderSide(color: color)),
                                                                                onSelected: (bool value) {},
                                                                              ),
                                                                            ))
                                                                        .toList(),
                                                              ),
                                                            ),
                                                    ),
                                                  ],
                                                );
                                              });
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
                                            AppLocalizations.of(context)!
                                                .linkAndFile,
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
                                          return Column(
                                            children: [
                                              const SizedBox(
                                                height: 16,
                                              ),
                                              Text(AppLocalizations.of(context)!
                                                  .error)
                                            ],
                                          );
                                        }
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.isEmpty) {
                                            return Column(
                                              children: [
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Text(AppLocalizations.of(
                                                        context)!
                                                    .elementNotFound)
                                              ],
                                            );
                                          }
                                          return LinkDocumentContact(
                                            listaItem: snapshot.data!,
                                            identifier: widget.identifier,
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

  _headerWidget(String? coverImage, String? profileImage) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          _buildCoverImageWidget(coverImage),
          _buildProfileImageWidget(profileImage),
          Positioned(
            left: 20,
            top: 10,
            child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(15)),
                child: IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil<void>(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Landing()),
                        ModalRoute.withName('/'),
                      );
                    },
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).textTheme.bodyText1!.color),
                    color: Theme.of(context).textTheme.bodyText2!.color)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveInsightNfc() async {
    try {
      await addInsightUserCount(widget.identifier);
      // ignore: empty_catches
    } catch (e) {
      debugPrint("errore per l'insight");
    }
  }
}
