import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const SettingsAppBar({
    Key? key,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          toolbarHeight: height,
          actions: const [
            // Container(
            //   width: 44,
            //   height: 44,
            //   margin: const EdgeInsets.only(right: 20),
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Theme.of(context).secondaryHeaderColor,
            //   ),
            //   child: IconButton(
            //     onPressed: () {
            //       if (kDebugMode) {
            //         print("non so che fa");
            //       }
            //     },
            //     icon: const Icon(Icons.question_mark),
            //   ),
            // )
          ],
          title: Text(
            AppLocalizations.of(context)!.settings,
            style: GoogleFonts.montserrat(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline1!.color),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
