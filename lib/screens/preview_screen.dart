import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/skeleton/principal_skeleton.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/element_model.dart';
import '../../components/contacts/detail_contact/contact_empty_error_widget.dart';
import '../../components/contacts/detail_contact/link_document_contact.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/icons_helper.dart';
import '../../models/icon_item.dart';
import '../../models/user.dart';
import '../components/preview/info_user_widget.dart';
import '../components/preview/preview_header.dart';
import '../components/skeleton/contact_header_skeleton.dart';
import '../components/skeleton/info_contact_skeleton.dart';
import '../components/skeleton/link_file_skeleton.dart';
import '../enums/type_action.dart';
import '../helpers/util.dart';
import '../models/user_edit.dart';
import '../services/account_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class PreviewScreen extends StatefulWidget {
  String identifier;

  PreviewScreen({super.key, required this.identifier});

  @override
  PreviewScreenState createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  bool isLoading = false;

  late Future<UserEditModel> _userFuture;
  late Future<List<ElementModel>> _linkDocumentsFuture;

  final ValueNotifier<bool> _isModView = ValueNotifier(false);
  List<IconItem> icons = getLinkAvailableIcons();

  @override
  void initState() {
    _userFuture = _getUserForEdit();
    _linkDocumentsFuture = _loadLinkDocument();
    super.initState();
  }

  Future<List<ElementModel>> _loadLinkDocument() {
    return getElementsForProfile(user.tacUserId);
  }

  Future<UserEditModel> _getUserForEdit() {
    try {
      return getUserForEdit(widget.identifier);
    } catch (e) {
      throw Exception();
    }
  }


  _gridItem(String? value, IconData icon, TypeAction typeAction) {
    return GestureDetector(
      onTap: (){
        Util.openLink(value!,typeAction,context);
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

  _detailWidget(UserEditModel userEditModel) {
    final List<Widget> listGridItem = [];
    if (userEditModel.userDTO.telephone != null) {
      listGridItem.add(_gridItem(userEditModel.userDTO.telephone, Icons.phone, TypeAction.TELEFONO));
    }
    if (userEditModel.userDTO.address != null) {
      listGridItem.add(_gridItem(userEditModel.userDTO.address, Icons.location_on, TypeAction.INDIRIZZO));
    }
    if (userEditModel.userDTO.email != null) {
      listGridItem.add(_gridItem(userEditModel.userDTO.email, Icons.email, TypeAction.EMAIL));
    }
    if (userEditModel.userDTO.website != null) {
      listGridItem.add(_gridItem(userEditModel.userDTO.website, Icons.public, TypeAction.LINK_WEB));
    }

    if(listGridItem.length < 4){
      for(int i=listGridItem.length; i<4; i++){
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
                _returnNameSurname(userEditModel.userDTO.name, userEditModel.userDTO.surname,userEditModel.userDTO.email) ?? "",
                Theme.of(context).textTheme.headline1!.color!,
                fontWeight: FontWeight.w600,
                fontSize: _returnFont(userEditModel.userDTO.name, userEditModel.userDTO.surname,userEditModel.userDTO.email))),
        const SizedBox(
          height: 8,
        ),
        if(userEditModel.userDTO.companyName != null)
          Align(
              alignment: Alignment.center,
              child: _generateTextWidget(userEditModel.userDTO.companyName!,
                  Theme.of(context).textTheme.headline1!.color!,
                  fontWeight: FontWeight.w600, fontSize: 15)),
        if(userEditModel.userDTO.companyName != null)
          const SizedBox(
            height: 8,
          ),
        Align(
            alignment: Alignment.center,
            child: _generateTextWidget(userEditModel.userDTO.profession ?? "",
                Theme.of(context).textTheme.headline2!.color!,
                fontWeight: FontWeight.w600, fontSize: 15)),
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
                    return InfoUserWidget(userInfoModel: userEditModel,);
                  } else {
                    return SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: listGridItem.map<Widget>((e) => e).toList(),
                      )
                    );
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

  _returnNameSurname(String? name, String? surname, String? email) {
    if (name != null && surname != null) {
      return "$name $surname";
    } else if (name != null && name.isNotEmpty) {
      return name;
    } else if (surname != null && surname.isNotEmpty) {
      return surname;
    }else if(email != null && email.isNotEmpty){
      return email;
    }
    return null;
  }

  double _returnFont(String? name, String? surname, String? email) {
    if ((name != null && name.isNotEmpty) || (surname != null && surname.isNotEmpty)) {
      return 30;
    }
    return 22;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Theme.of(context).backgroundColor),
      body: SingleChildScrollView(
        child: Container(
          padding:  EdgeInsets.zero,
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              FutureBuilder<UserEditModel>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ContactHeaderSkeleton();
                    }
                    if (snapshot.hasError) {
                      showErrorToast(AppLocalizations.of(context)!.error);
                      return
                        PreviewHeader(
                          userDetail: UserEditModel(),
                        );
                    }
                    if (snapshot.hasData) {
                      return PreviewHeader(
                        userDetail: snapshot.data!,
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
                      FutureBuilder<UserEditModel>(
                          future: _userFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                children: [
                                  InfoContactSkeleton(),
                                  PrincipalSkeleton()
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return ContactEmptyErrorWidget(label: AppLocalizations.of(context)!.error);
                            }
                            if (snapshot.hasData) {
                              UserEditModel userContactModel =
                              snapshot.data!;
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
                                          return ContactEmptyErrorWidget(label: AppLocalizations.of(context)!.error);
                                        }
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.isEmpty) {
                                            return ContactEmptyErrorWidget(label: AppLocalizations.of(context)!.elementNotFound);
                                          }
                                          return LinkDocumentContact(listaItem: snapshot.data!,isFromPreview: true,);
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
}

