import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/appbars/contacts_appbar.dart';
import 'package:tac/components/buttons/tab_button.dart';
import 'package:tac/screens/contacts/all_contacts.dart';
import 'package:tac/screens/contacts/companies_contacts.dart';
import 'package:tac/screens/contacts/folders/folders.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../extentions/hexcolor.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  ContactsState createState() => ContactsState();
}

class ContactsState extends State<Contacts> {
  int selectedIndex = 0;
  double height = 60;
  bool showBackAppBar = false;
  bool showFab = false;
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());

  GlobalKey<AllContactsState> contactsKey = GlobalKey();

  Future<void>? loadAll() {
    setState(() {
      selectedIndex = 0;
    });

    return null;
  }

  Future<void>? loadCompanies() {
    setState(() {
      selectedIndex = 1;
      showFab = false;
    });

    return null;
  }

  Future<void>? loadFolders() {
    setState(() {
      selectedIndex = 2;
      showFab = false;
    });

    return null;
  }

  void onScroll(bool hide) {
    setState(() {
      height = hide ? 0 : 60;
    });
  }

  void onPop() {
    contactsKey.currentState?.onPop();
  }

  Widget loadCorrectWidget() {
    switch (selectedIndex) {
      case 0:
        return AllContacts(
            key: contactsKey,
            onScroll: onScroll,
            toggleFab: toggleFab,
            showBack: showBack);
      case 1:
        return CompaniesContact(onScroll: onScroll);
      case 2:
        return Folders(onScroll: onScroll);
      default:
        return Container(height: 0);
    }
  }

  void fabClick() {
    if (selectedIndex == 0) contactsKey.currentState!.goToCreateContact();
  }

  void toggleFab(bool value) {
    setState(() {
      showFab = value;
    });
  }

  void showBack(bool value) {
    setState(() {
      showBackAppBar = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            ContactAppBar(height: 60, showBack: showBackAppBar, onBack: onPop),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Column(children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    height: height,
                    clipBehavior: Clip.antiAlias,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: TabButton(
                            onPress: loadAll,
                            text: AppLocalizations.of(context)!.all,
                            active: selectedIndex == 0,
                            inactiveLeftRadius: 10,
                            inactiveRightRadius: 0,
                          )),
                          Expanded(
                              child: TabButton(
                                  onPress: loadCompanies,
                                  text: AppLocalizations.of(context)!.companies,
                                  active: selectedIndex == 1,
                                  inactiveLeftRadius: 0,
                                  inactiveRightRadius: 0)),
                          Expanded(
                              child: TabButton(
                            onPress: loadFolders,
                            text: AppLocalizations.of(context)!.folders,
                            active: selectedIndex == 2,
                            inactiveLeftRadius: 0,
                            inactiveRightRadius: 10,
                            icon: Icons.star,
                          ))
                        ])),
                loadCorrectWidget()
              ])),
        ),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: fabClick,
                backgroundColor: color,
                child: Icon(
                  Icons.add,
                  size: 35,
                  color: color.computeLuminance() > 0.5
                      ? Theme.of(context).textTheme.bodyText2!.color
                      : Colors.white,
                ))
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat);
  }
}
