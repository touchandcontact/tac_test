import 'dart:convert';
import 'dart:ui';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tac/models/user_documents_or_links.dart';
import 'package:tac/models/user_green_insight_model.dart';
import '../../components/list_skeleton_loader.dart';
import '../../components/safearea_custom.dart';
import '../../enums/document_or_link_type.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/icons_helper.dart';
import '../../models/user.dart';
import '../../models/user_insight_counters_model.dart';
import '../../services/statistics_service.dart';
import '../profile/became_premium.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Insight extends StatefulWidget {
  const Insight({Key? key}) : super(key: key);

  @override
  State<Insight> createState() => _InsightState();
}

class _InsightState extends State<Insight> {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  final ValueNotifier<int> _filterSelect = ValueNotifier(1);

  late Future<UserInsightCountersModel> _userFirstInsight;
  late Future<List<UserDocumentsOrLinks>> _userDownloadInsight;
  late Future<UserGreenInsightModel> _userThirdInsight;

  Future<UserInsightCountersModel> getUserFirstInsight() {
    return getUserInsight(user.tacUserId, _filterSelect.value);
  }

  Future<List<UserDocumentsOrLinks>> getUserDownloadInsight() {
    return getUserDocumentsDowloadClicked(user.tacUserId, _filterSelect.value);
  }

  Future<UserGreenInsightModel> getUserThirdInsight() {
    return getUserGreenInsight(user.tacUserId, _filterSelect.value);
  }

  @override
  void initState() {
    _userFirstInsight = getUserFirstInsight();
    _userDownloadInsight = getUserDownloadInsight();
    _userThirdInsight = getUserThirdInsight();
    super.initState();
  }

  refreshCall() {
    setState(() {
      _userFirstInsight = getUserFirstInsight();
      _userDownloadInsight = getUserDownloadInsight();
      _userThirdInsight = getUserThirdInsight();
    });
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 16, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  String _filtroSelezionatoSwitch() {
    switch (_filterSelect.value) {
      case 0:
        return AppLocalizations.of(context)!.week;
      case 1:
        return AppLocalizations.of(context)!.month;
      default:
        return AppLocalizations.of(context)!.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaCustom(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).backgroundColor,
          title: _generateTextWidget(
              "Insights", Theme.of(context).textTheme.headline1!.color!,
              fontSize: 30, fontWeight: FontWeight.bold),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 42,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _generateTextWidget(
                        "${AppLocalizations.of(context)!.hello} ${user.name ?? user.email}!",
                        Theme.of(context).textTheme.headline1!.color!,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _generateTextWidget(
                              AppLocalizations.of(context)!.infoInsight,
                              Theme.of(context).textTheme.headline2!.color!,
                              fontSize: 14),
                        ),
                        const Spacer(),
                        ValueListenableBuilder(
                            valueListenable: _filterSelect,
                            builder: (context, valueNotifier, child) =>
                                GestureDetector(
                                  child: _generateTextWidget(
                                    _filtroSelezionatoSwitch(),
                                    Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color!,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onTap: () {
                                    openSelect();
                                  },
                                ))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: FutureBuilder(
                  future: _userFirstInsight,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListSkeletonLoader(
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0));
                    }
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Text(AppLocalizations.of(context)!.error)
                        ],
                      );
                    }
                    return SizedBox(
                      height: 180,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          _itemListViewInsights(
                              "TAC",
                              AppLocalizations.of(context)!.shares,
                              snapshot.data!.tacCount,
                              0),
                          _itemListViewInsights(
                              AppLocalizations.of(context)!.profile,
                              AppLocalizations.of(context)!.views,
                              snapshot.data!.profileViewCount,
                              snapshot.data!.changeRateProfileViewCount),
                          _itemListViewInsights(
                              AppLocalizations.of(context)!.profile,
                              AppLocalizations.of(context)!.downloadEng,
                              snapshot.data!.profileDowloadCount,
                              snapshot.data!.changeRateProfileDowloadCount),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: _generateTextWidget(
                          AppLocalizations.of(context)!.clickedLink,
                          Theme.of(context).textTheme.headline1!.color!,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    FutureBuilder<List<UserDocumentsOrLinks>>(
                        future: _userDownloadInsight,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                                height: 60,
                                child: SkeletonListView(
                                    itemCount: 3,
                                    item: SkeletonListTile(
                                      verticalSpacing: 12,
                                      titleStyle: SkeletonLineStyle(
                                          height: 20,
                                          minLength: 200,
                                          randomLength: false,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    )));
                          }
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(AppLocalizations.of(context)!.error)
                              ],
                            );
                          }
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return Text(AppLocalizations.of(context)!
                                  .elementNotFound);
                            }
                            Map<int, CustomUserDocumentsOrLinks> customMap = {};
                            for (var element in snapshot.data!) {
                              if (customMap.containsKey(element.id)) {
                                customMap[element.id]?.size++;
                              } else {
                                CustomUserDocumentsOrLinks obj =
                                    CustomUserDocumentsOrLinks(element, 1);
                                customMap[obj.userDocumentsOrLinks.id] = obj;
                              }
                            }
                            return ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: customMap.entries
                                    .map<Widget>((e) => _itemLink(
                                        e.value.userDocumentsOrLinks.type,
                                        e.value.userDocumentsOrLinks.icon,
                                        e.value.userDocumentsOrLinks
                                            .name,
                                        e.value.userDocumentsOrLinks.link,
                                        e.value.size))
                                    .toList());
                          }
                          return Container();
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    user.isCompanyPremium || user.subscriptionType == 2 || user.subscriptionGifted
                        ? const SizedBox()
                        : TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BecamePremium()));
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(18)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(color)),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  height: 25,
                                  width: 25,
                                  child:
                                      Icon(Icons.star, size: 14, color: color),
                                ),
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${AppLocalizations.of(context)!.unlockAllLink}!",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                      Text(
                                          "${AppLocalizations.of(context)!.unlockToSeeClickedLink}.",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    size: 35, color: Colors.white)
                              ],
                            )),
                    const SizedBox(
                      height: 30,
                    ),
                    _generateTextWidget(AppLocalizations.of(context)!.thanks,
                        Theme.of(context).textTheme.headline1!.color!,
                        fontWeight: FontWeight.bold, fontSize: 20),
                    const SizedBox(
                      height: 5,
                    ),
                    _generateTextWidget(AppLocalizations.of(context)!.saving,
                        Theme.of(context).textTheme.headline2!.color!,
                        fontSize: 14)
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder<UserGreenInsightModel>(
                future: _userThirdInsight,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListSkeletonLoader(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 0));
                  }
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Text(AppLocalizations.of(context)!.error)
                      ],
                    );
                  }
                  return SizedBox(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        _itemListRisparmio(AppLocalizations.of(context)!.paper,
                            snapshot.data!.paperSaved.toDouble()),
                        _itemListRisparmio(AppLocalizations.of(context)!.co2,
                            snapshot.data!.c02Saved),
                        _itemListRisparmio(AppLocalizations.of(context)!.water,
                            snapshot.data!.waterSaved.toDouble()),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openSelect() {
    showAdaptiveActionSheet(
        context: context,
        androidBorderRadius: 20,
        bottomSheetColor: Theme.of(context).backgroundColor,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.week,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                _filterSelect.value = 0;
                refreshCall();
                Navigator.pop(context);
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.month,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                _filterSelect.value = 1;
                refreshCall();
                Navigator.pop(context);
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.year,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                _filterSelect.value = 2;
                refreshCall();
                Navigator.pop(context);
              }),
        ],
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))));
  }

  _itemListViewInsights(
      String label, String secondaryLabel, int value, int percentage) {
    return Container(
      height: 140,
      width: 170,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _generateTextWidget(label, color,
              fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(
            height: 10,
          ),
          _generateTextWidget(
              secondaryLabel, Theme.of(context).textTheme.headline1!.color!,
              fontSize: 14),
          const SizedBox(
            height: 4,
          ),
          SizedBox(
              height: 63,
              width: 125,
              child: user.isCompanyPremium || user.subscriptionType == 2
                  ? FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.fitHeight,
                      child: Text(value.toString()))
                  : _blurWidget(FittedBox(
                      fit: BoxFit.fitHeight, child: Text(value.toString())))),
          _generateTextWidget(_calculateTextPercentage(percentage),
              Theme.of(context).textTheme.headline2!.color!,
              fontSize: 14),
        ],
      ),
    );
  }

  _calculateTextPercentage(int value) {
    if (value < 0) {
      return "$value${AppLocalizations.of(context)!.percentageLess}";
    } else if(value > 0){
      return "$value${AppLocalizations.of(context)!.percentagePlus}";
    }
    else{
      return "";
    }
  }

  _itemLink(DocumentOrLinkType typeDocumentOrLink, String iconValue,
      String? labelValue, String? linkValue, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 21),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Theme.of(context).secondaryHeaderColor,
        leading: Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10)),
          height: 40,
          width: 40,
          child: Icon(
              typeDocumentOrLink == DocumentOrLinkType.document
                  ? getDocumentIconFromString(iconValue)
                  : getLinkIconFromString(iconValue),
              color: Colors.white,
              size: 24),
        ),
        title: user.isCompanyPremium || user.subscriptionType == 2
            ? _generateTextWidget(
                labelValue ?? "---",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                Theme.of(context).textTheme.headline1!.color!)
            : _blurWidget(
                _generateTextWidget(
                    labelValue ?? "---",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    Theme.of(context).textTheme.headline1!.color!),
                sigmaY: 5,
                sigmaX: 5),
        // subtitle: user.isCompanyPremium || user.subscriptionType == 2
        //     ? _generateTextWidget(
        //         "${AppLocalizations.of(context)!.link}: ${{
        //           linkValue != null ? '${linkValue.substring(0, 50)}...' : '---'
        //         }}",
        //         fontSize: 12,
        //         fontWeight: FontWeight.w400,
        //         Theme.of(context).textTheme.headline1!.color!)
        //     : _blurWidget(
        //         _generateTextWidget(
        //             "${AppLocalizations.of(context)!.link}: ${{
        //               linkValue != null
        //                   ? '${linkValue.substring(0, 50)}...'
        //                   : '---'
        //             }}",
        //             fontSize: 12,
        //             fontWeight: FontWeight.w400,
        //             Theme.of(context).textTheme.headline1!.color!),
        //         sigmaY: 5,
        //         sigmaX: 5),
        trailing: user.isCompanyPremium || user.subscriptionType == 2
            ? _generateTextWidget(
                "$count click",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                Theme.of(context).textTheme.headline1!.color!)
            : _blurWidget(
                _generateTextWidget(
                    "$count click",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    Theme.of(context).textTheme.headline1!.color!),
                sigmaY: 5,
                sigmaX: 5),
      ),
    );
  }

  _blurWidget(Widget child, {double sigmaX = 11, double sigmaY = 11}) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );
  }

  _itemListRisparmio(String label, double value) {
    return Container(
      height: 60,
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).secondaryHeaderColor,
          borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _generateTextWidget(
              label, Theme.of(context).textTheme.headline2!.color!,
              fontSize: 14),
          const SizedBox(
            height: 3,
          ),
          SizedBox(
            height: 41,
            width: 71,
            child: user.isCompanyPremium || user.subscriptionType == 2
                ? FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("$value g"),
                  )
                : _blurWidget(
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text("$value g"),
                    ),
                    sigmaX: 10,
                    sigmaY: 10),
          ),
        ],
      ),
    );
  }
}

class CustomUserDocumentsOrLinks {
  UserDocumentsOrLinks userDocumentsOrLinks;
  int size = 0;

  CustomUserDocumentsOrLinks(this.userDocumentsOrLinks, this.size);
}
