import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final bool showBack;
  final void Function() onBack;

  const ContactAppBar(
      {Key? key,
      required this.height,
      this.showBack = false,
      required this.onBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).backgroundColor,
        flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Stack(children: [
              if (showBack)
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                            splashRadius: 20,
                            onPressed: () => onBack(),
                            icon: Icon(Icons.arrow_back,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color),
                            color:
                                Theme.of(context).textTheme.bodyText2!.color))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        AppLocalizations.of(context)!.contactsUp,
                        style: GoogleFonts.montserrat(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.headline1!.color),
                      )))
            ])));
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
