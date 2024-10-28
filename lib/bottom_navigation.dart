// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/models/user.dart';
import 'package:tac/screens/contacts/contact_detail_from_qrcode.dart';
import 'package:tac/screens/contacts/contacts.dart';
import 'package:tac/screens/contacts/qr_screen.dart';
import 'package:tac/screens/insight/insight.dart';
import 'package:tac/screens/profile/profile.dart';
import 'package:tac/screens/settings.dart';
import 'package:tac/services/account_service.dart';
import 'package:tac/services/statistics_service.dart';
import 'package:tac/themes/dark_theme_provider.dart';
import 'components/camera_app.dart';
import 'components/contacts/error_screen_deeplink.dart';
import 'extentions/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      DarkThemeProvider themeChangeProvider =
          Provider.of<DarkThemeProvider>(context, listen: false);
      setLocale(themeChangeProvider);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
        await getUserForEdit(user.identifier).then((user) async {
          await Hive.box("settings")
              .put("user", jsonEncode(user.userDTO.toJson()));
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  final List<Widget> _pages = <Widget>[
    Profile(),
    const Contacts(),
    const Insight(),
    const Settings()
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      return imageTemp;
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  Future<void> setLocale(DarkThemeProvider provider) async {
    try {
      var lang = await getLanguage(user.tacUserId);
      var pLocale = Platform.localeName.split("_")[0];
      pLocale = pLocale != "it" && pLocale != "en" ? "en" : pLocale;
      provider.locale =
          lang == null || lang == "" ? Locale(pLocale) : Locale(lang);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(children: [
          Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Theme.of(context).backgroundColor,
              body: PageTransitionSwitcher(
                  transitionBuilder: (widget, anim1, anim2) {
                    return SharedAxisTransition(
                      animation: anim1,
                      secondaryAnimation: anim2,
                      transitionType: SharedAxisTransitionType.scaled,
                      child: widget,
                    );
                  },
                  duration: const Duration(milliseconds: 500),
                  child: LazyIndexedStack(
                    index: selectedIndex,
                    key: ValueKey<int>(selectedIndex),
                    children: _pages,
                  )),
              bottomNavigationBar: Container(
                width: size.width,
                height: 55,
                color: Theme.of(context).backgroundColor,
                child: Stack(
                  children: [
                    Center(
                        child: SpeedDial(
                            openCloseDial: isDialOpen,
                            backgroundColor: color,
                            onPress: () {
                              isDialOpen.value = !isDialOpen.value;
                            },
                            overlayOpacity: .5,
                            spaceBetweenChildren: 5,
                            overlayColor: Colors.black,
                            children: [
                              SpeedDialChild(
                                  label: AppLocalizations.of(context)!.ocr,
                                  labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                  child: IconButton(
                                  onPressed: () async {
                                    if (!user.isCompanyPremium &&
                                        (user.subscriptionType == null ||
                                            user.subscriptionType == 0)) {
                                      int numberOfUsage =
                                          await getCountOcr(user.tacUserId);
                                      if (numberOfUsage < 5) {
                                        List<CameraDescription> _cameras =
                                            await availableCameras();
                                        isDialOpen.value = false;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => CameraApp(
                                                camera: _cameras[0],
                                                user: user.tacUserId),
                                          ),
                                        );
                                      } else {
                                        showErrorToast(
                                            AppLocalizations.of(context)!
                                                .ocrFreeError);
                                      }
                                    } else {
                                      List<CameraDescription> _cameras =
                                          await availableCameras();
                                      isDialOpen.value = false;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CameraApp(
                                              camera: _cameras[0],
                                              user: user.tacUserId),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.sensor_occupied))),
                              SpeedDialChild(
                                  label: AppLocalizations.of(context)!.qrCode,
                                  labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                  child: IconButton(
                                      onPressed: () {
                                        isDialOpen.value = false;
                                        Navigator.of(context)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (context) => QrCodeScreen(),
                                          ),
                                        )
                                            .then((value) {
                                          if (value != null && value != "") {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => value ==
                                                  user.identifier
                                                  ? const ErrorScreenDeepLink()
                                                  : ContactDetailFromQrCode(
                                                  isFromNfc: false,
                                                  identifier: value),
                                            ))
                                                .then((value) {
                                              if (value != null && value) {
                                                _onItemTapped(0);
                                              }
                                            });
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.qr_code)))
                            ],
                            iconTheme: IconThemeData(
                                color: color.computeLuminance() > 0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .color
                                    : Colors.white),
                            icon: Icons.document_scanner_outlined)),
                    Positioned(
                        top: 0,
                        child: SizedBox(
                          width: size.width,
                          height: 55,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              Stack(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _onItemTapped(0);
                                      },
                                      splashRadius: 25,
                                      icon: Icon(Icons.person,
                                          size: 25,
                                          color: selectedIndex == 0
                                              ? color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color),
                                      isSelected: selectedIndex == 0),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Visibility(
                                        visible: selectedIndex == 0,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .profile,
                                          style: GoogleFonts.montserrat(
                                              color: color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _onItemTapped(1);
                                      },
                                      splashRadius: 25,
                                      icon: Icon(Icons.contacts,
                                          size: 25,
                                          color: selectedIndex == 1
                                              ? color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color)),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Visibility(
                                        visible: selectedIndex == 1,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .contactsUp,
                                          style: GoogleFonts.montserrat(
                                              color: color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Container(width: size.width * 0.25),
                              Stack(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _onItemTapped(2);
                                      },
                                      splashRadius: 25,
                                      icon: Icon(Icons.donut_large_sharp,
                                          size: 25,
                                          color: selectedIndex == 2
                                              ? color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color)),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Visibility(
                                        visible: selectedIndex == 2,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .insights,
                                          style: GoogleFonts.montserrat(
                                              color: color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _onItemTapped(3);
                                      },
                                      splashRadius: 25,
                                      icon: Icon(Icons.more_horiz,
                                          size: 35,
                                          color: selectedIndex == 3
                                              ? color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color)),
                                  Positioned.fill(
                                    bottom: 0,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Visibility(
                                        visible: selectedIndex == 3,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .bottomSettings,
                                          style: GoogleFonts.montserrat(
                                              color: color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              ))
        ]));
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xffffffff).withOpacity(1.0);
    canvas.drawRect(
        Rect.fromLTWH(size.width * 0.9750000, size.height * 0.8318900,
            size.width * 0.02500000, size.height * 0.1154639),
        paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.02481481, size.height * 1.034227);
    path_1.lineTo(0, size.height * 1.034227);
    path_1.cubicTo(
        size.width * 0.008333333,
        size.height * 1.034777,
        size.width * 0.01657407,
        size.height * 1.034777,
        size.width * 0.02481481,
        size.height * 1.034227);
    path_1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = const Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(size.width, size.height * 1.034227);
    path_2.lineTo(size.width * 0.9751852, size.height * 1.034227);
    path_2.cubicTo(
        size.width * 0.9834259,
        size.height * 1.034777,
        size.width * 0.9916667,
        size.height * 1.034777,
        size.width,
        size.height * 1.034227);
    path_2.close();

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = const Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_2, paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.6325926, size.height * 0.4294158);
    path_3.cubicTo(
        size.width * 0.5875926,
        size.height * 0.02694158,
        size.width * 0.5000000,
        size.height * 0.03463918,
        size.width * 0.5000000,
        size.height * 0.03463918);
    path_3.cubicTo(
        size.width * 0.5000000,
        size.height * 0.03463918,
        size.width * 0.4124074,
        size.height * 0.02666667,
        size.width * 0.3674074,
        size.height * 0.4291409);
    path_3.cubicTo(
        size.width * 0.3271296,
        size.height * 0.6895533,
        size.width * 0.1926852,
        size.height * 1.022955,
        size.width * 0.02481481,
        size.height * 1.033952);
    path_3.lineTo(size.width * 0.9751852, size.height * 1.033952);
    path_3.cubicTo(
        size.width * 0.8073148,
        size.height * 0.98,
        size.width * 0.7027778,
        size.height * 0.7898282,
        size.width * 0.6325926,
        size.height * 0.4294158);
    path_3.close();

    Paint paint3Fill = Paint()..style = PaintingStyle.fill;
    paint3Fill.color = const Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_3, paint3Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
