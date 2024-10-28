import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/constants.dart';
import 'package:tac/enums/type_action.dart';
import 'package:tac/helpers/util.dart';
import 'package:tac/screens/associated_card/result_associated_cards.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/buttons/outlinet_loading_button.dart';
import '../../components/generic_dialog.dart';
import '../../components/list_skeleton_loader.dart';
import '../../components/my_card/card_animation_slider.dart';
import '../../components/my_card/ios_pass_button.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/toast_helper.dart';
import '../../models/app_user_card.dart';
import '../../models/user.dart';
import '../../services/account_service.dart';
import '../../services/vcard_service.dart';
import '../contacts/qr_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssociatedCards extends StatefulWidget {
  AssociatedCards({
    super.key,
  });

  @override
  AssociatedCardsState createState() => AssociatedCardsState();
}

class AssociatedCardsState extends State<AssociatedCards> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  late Future<List<AppUserCard>> _listCardFuture;
  AppUserCard? selectedCard;

  final String _linkNuovaSmartCard = "www.example.com";

  String barcodeValue = "";

  @override
  void initState() {
    _listCardFuture = loadUserCard();
    super.initState();
  }

  Future<List<AppUserCard>> loadUserCard(
      {bool isRefresh = false, bool isDelete = false}) async {
    List<AppUserCard> listCard = await getBusinessCards(user.tacUserId);
    if (listCard == null || listCard.isEmpty) {
      selectedCard = null;
    } else if (isDelete || !isRefresh || listCard.length == 1) {
      selectedCard = listCard.first;
    } else {
      selectedCard =
          listCard.firstWhere((element) => element.id == selectedCard!.id);
    }
    return listCard;
  }

  changeCard(AppUserCard? userCard) {
    setState(() {
      selectedCard = userCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(AppLocalizations.of(context)!.myCards,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.headline1),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).textTheme.headline2!.color!,
              )),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FutureBuilder<List<AppUserCard>>(
                  future: _listCardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListSkeletonLoader(
                          height: 300,
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0));
                    }
                    if (snapshot.hasError) {
                      showErrorToast(AppLocalizations.of(context)!.error);
                      return Text(AppLocalizations.of(context)!.error);
                    }
                    if (snapshot.data!.isEmpty) {
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Spacer(),
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                        ),
                                        side: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .color!),
                                      ),
                                      onPressed: associaCard,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.fromLTRB(8, 22, 8, 22),
                                        child: Text(
                                            AppLocalizations.of(context)!.associateCard,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline2!
                                                    .color)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8,),
                            !user.isCompanyPremium
                                ? Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      side: const BorderSide(
                                          width: 0, color: Colors.transparent),
                                    ),
                                    onPressed: () {
                                      Util.openLink(_linkNuovaSmartCard,
                                          TypeAction.LINK_WEB, context);
                                    },
                                    // onPressed: () => associaCard,
                                    child: GestureDetector(
                                        onTap: () async {
                                          await launchUrl(
                                              Uri.parse(Constants.orderCardUrl),
                                              mode: LaunchMode.externalApplication);
                                        },
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(8, 22, 8, 22),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .orderNewSmartCard,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white)),
                                        )),
                                  ),
                                )
                              ],
                            )
                                : Container(),
                            const Spacer(),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        CardAnimationSlider(
                          listCard: snapshot.data!,
                          onChangeCard: changeCard,
                          indexSelectedCard:
                              snapshot.data!.indexOf(selectedCard!),
                          onDeleteCard: _showModalBottomSheet,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(18.0)),
                          child: ListTile(
                            minVerticalPadding: 0,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: _generateTextWidget(
                              AppLocalizations.of(context)!.activeCard,
                              Theme.of(context).textTheme.headline2!.color!,
                              fontSize: 16,
                            ),
                            trailing: Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                  value: selectedCard!.active,
                                  activeColor: color,
                                  onChanged: activeDisactiveCard),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  side: BorderSide(
                                      width: 1,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color!),
                                ),
                                onPressed: associaCard,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 22, 8, 22),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .associateCard,
                                      style: GoogleFonts.montserrat(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline2!
                                              .color)),
                                ),
                              ),
                            )
                          ],
                        ),
                        !user.isCompanyPremium ? const SizedBox(
                          height: 20,
                        ) : const SizedBox(),
                        !user.isCompanyPremium
                            ? Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                        ),
                                        side: const BorderSide(
                                            width: 0, color: Colors.transparent),
                                      ),
                                      onPressed: () {
                                        Util.openLink(_linkNuovaSmartCard,
                                            TypeAction.LINK_WEB, context);
                                      },
                                      // onPressed: () => associaCard,
                                      child: GestureDetector(
                                          onTap: () async {
                                            await launchUrl(
                                                Uri.parse(Constants.orderCardUrl),
                                                mode: LaunchMode.externalApplication);
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.fromLTRB(8, 22, 8, 22),
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .orderNewSmartCard,
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                          )),
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    );
                  }),
              const SizedBox(
                height: 8,
              )
            ])));
  }

  Future<String?> openQr() async {
    String? link = await Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => QrCodeScreen(isFromAssociateCard: true),
          ),
        )
        .then((value) => value);
    return link;
  }

  refresh(bool isDelete) {
    setState(() {
      _listCardFuture = loadUserCard(isRefresh: true, isDelete: isDelete);
    });
  }

  void _showModalBottomSheet(int idCard) {
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
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GenericDialog(child: deleteDialog(idCard));
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

  Widget deleteDialog(int idCard) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("${AppLocalizations.of(context)!.deleteCard}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.deleteCardProceed}?",
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
                  onPress: () => deleteItems(idCard),
                  text: AppLocalizations.of(context)!.delete,
                  width: 300,
                )),
            const SizedBox(
              height: 20,
            )
          ],
        ));
  }

  Future deleteItems(int idCard) async {
    try {
      await deleteBusinessCard(idCard);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      refresh(true);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  associaCard() async {
    try {
      final link = await openQr();
      if (link == null || link.isEmpty) return;
      if (!mounted) return;
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ResultAssociatedCards(
                      link: link, tacUserId: user.tacUserId)))
          .then((value) => value == null || !value ? null : refresh(false));
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
  }

  activeDisactiveCard(bool value) async {
    showLoadingDialog(context);
    try {
      await toggleBusinessCard(selectedCard!.id, value);
      if (!mounted) return;
      Navigator.pop(context);
      refresh(false);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void toggleShowOnProfile(bool value) async {
    showLoadingDialog(context);
    try {} catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }
    Navigator.pop(context);
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
}
