import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tac/extentions/pars_bool.dart';
import 'package:tac/models/contact_company.dart';
import 'package:tac/screens/contacts/company/company_detail.dart';
import 'package:tac/screens/contacts/contact_detail_from_qrcode.dart';
import 'package:tac/screens/contacts/folders/edit_folder.dart';
import 'package:tac/screens/contacts/folders/folder_detail.dart';
import 'package:tac/screens/contacts/send_contacts.dart';
import 'package:tac/screens/contacts/send_contacts_companies.dart';
import 'package:tac/screens/elements/elements.dart';
import 'package:tac/screens/login.dart';
import 'package:tac/screens/loginorsignup.dart';
import 'package:tac/screens/profile/edit_profile.dart';
import 'package:tac/screens/register.dart';
import 'package:tac/screens/reset_password.dart';
import 'package:tac/screens/share_profile.dart';
import 'package:tac/screens/virtual_background.dart';
import 'package:tac/services/notification_service.dart';
import 'components/contacts/error_screen_deeplink.dart';
import 'constants.dart';
import 'helpers/snackbar_helper.dart';
import 'models/contact.dart';
import 'models/user.dart';
import 'screens/landing.dart';
import 'themes/dark_theme_provider.dart';
import 'themes/theme_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Hive.initFlutter();
//   await Firebase.initializeApp();
//   await handlePush(message);
// }

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}

Future<void> handlePush(RemoteMessage event) async {
  if (!Hive.isBoxOpen(("settings"))) await Hive.openBox("settings");
  var boxIsLoggedIn = Hive.box("settings").get('isLoggedIn');
  var isLoggedIn =
      (boxIsLoggedIn == null) ? false : boxIsLoggedIn.toString().parseBool();

  if (isLoggedIn) {
    await NotificationService()
        .showNotification(event.data["title"], event.data["text"], "");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
    await handlePush(event);
  });

  await FlutterDownloader.initialize(debug: true);
  Stripe.publishableKey = Constants.stripePublicKey;
  Stripe.merchantIdentifier = 'merchant.com.touchandcontact.tac';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  final ReceivePort _port = ReceivePort();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      var status = data[1];
      if (Platform.isIOS && status == 3) {
        showSnackbar(context, AppLocalizations.of(context)!.downloadCompleted,
            Colors.green,
            duration: 2);
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      await checkLinks(appLink.toString());
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await checkLinks(uri.toString());
    });
  }

  Future<void> checkLinks(String link) async {
    if (!Hive.isBoxOpen(("settings"))) await Hive.openBox("settings");
    var boxIsLoggedIn = Hive.box("settings").get('isLoggedIn');
    var isLoggedIn =
        (boxIsLoggedIn == null) ? false : boxIsLoggedIn.toString().parseBool();
    if (isLoggedIn) {
      var boxUser = Hive.box("settings").get("user");
      if (boxUser != null) {
        User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
        link = link.split('/').last;
        if (link == user.identifier) {
          _navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const ErrorScreenDeepLink()));
        } else {
          _navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (_) => ContactDetailFromQrCode(
                  isFromNfc: link.contains("card"),
                  identifier: link.split('/').last)));
        }
      }
    }
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
    themeChangeProvider.locale =
        await themeChangeProvider.darkThemePreference.getLocale();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: themeChangeProvider.darkTheme
              ? Brightness.light
              : Brightness.dark),
    );

    return ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: false,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return ChangeNotifierProvider(
              create: (_) => themeChangeProvider,
              child: Consumer<DarkThemeProvider>(
                builder: (context, value, child) => MaterialApp(
                    title: 'Tac',
                    navigatorKey: _navigatorKey,
                    // ignore: prefer_const_literals_to_create_immutables
                    localizationsDelegates: [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    locale: themeChangeProvider.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    onGenerateRoute: (RouteSettings settings) {
                      var routes = <String, WidgetBuilder>{
                        '/': (context) => const Landing(),
                        '/loginOrSignup': (context) => const LoginOrSignup(),
                        '/login': (context) => const Login(),
                        '/register': (context) => const Register(),
                        '/resetPassword': (context) => const ResetPassword(),
                        '/sendContacts': (context) => SendContacts(
                            toSend: settings.arguments as List<Contact>),
                        '/sendContactsCompanies': (context) =>
                            SendContactsCompanies(
                                toSend:
                                    settings.arguments as List<ContactCompany>),
                        '/folderDetail': (context) => FolderDetail(
                            id: (settings.arguments as List<dynamic>)[0] as int,
                            reload: (settings.arguments as List<dynamic>)[1]
                                as Function),
                        '/companyDetail': (context) => CompanyDetail(
                            company: (settings.arguments as List<dynamic>)[0]
                                as ContactCompany,
                            reload: (settings.arguments as List<dynamic>)[1]
                                as Function),
                        '/editFolder': (context) => EditFolder(
                            id: (settings.arguments as List<dynamic>)[0] as int,
                            onSuccess: (settings.arguments as List<dynamic>)[1]
                                as Function),
                        '/shareProfile': (context) => const ShareProfile(),
                        '/elements': (context) => const Elements(),
                        '/editProfile': (context) => const EditProfile(),
                        '/virtualBackground': (context) =>
                            const VirtualBackground(),
                        // '/contactDetailFromQrCode': (context) => ContactDetailFromQrCode(identifier: settings.arguments as String),
                        // '/errorDeepLinkScreen': (context) => const ErrorScreenDeepLink(),
                      };
                      WidgetBuilder? builder = routes[settings.name];
                      return MaterialPageRoute(builder: (ctx) => builder!(ctx));
                    },

                    ///TODO cambiare qui per adattare il tema dark
                    theme: Styles.themeData(
                        themeChangeProvider.darkTheme, context)),
              ));
        });
  }
}
