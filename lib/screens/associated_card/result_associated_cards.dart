import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../../extentions/hexcolor.dart';
import '../../services/vcard_service.dart';
import '../contacts/qr_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultAssociatedCards extends StatefulWidget {
  String link;
  int tacUserId;

  ResultAssociatedCards({Key? key, required this.link, required this.tacUserId})
      : super(key: key);

  @override
  State<ResultAssociatedCards> createState() => _ResultAssociatedCardsState();
}

class _ResultAssociatedCardsState extends State<ResultAssociatedCards> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  late Future<bool> _associatedCardDataFuture;

  @override
  void initState() {
    _associatedCardDataFuture = _associaCard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: Container(),
        ),
        body: Center(
            child: FutureBuilder<bool>(
                future: _associatedCardDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _loadingWidget(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        _resultWidget(false),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buttonWidget(
                                  AppLocalizations.of(context)!.cancel,
                                  Theme.of(context).textTheme.headline2!.color!,
                                      () => Navigator.pop(context),
                                  Colors.grey[100]),
                              const SizedBox(
                                width: 8,
                              ),
                              _buttonWidget(
                                  AppLocalizations.of(context)!.tryAgain, Colors.white, associaCard, color),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        _resultWidget(true),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Expanded(child: SizedBox(),),
                              _buttonWidget(
                                  AppLocalizations.of(context)!.ok, Colors.white, ()=> Navigator.pop(context,true), color),
                              const Expanded(child: SizedBox(),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                })),
      ),
    );
  }

  Future<bool> _associaCard() async {
    return await associateCard(widget.tacUserId, widget.link);
  }

  Future<String?> openQr() async {
    String? link = await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => QrCodeScreen(),
      ),
    )
        .then((value) => value);
    return link;
  }

  associaCard() async {
    try {
      final link = await openQr();
      if (link == null || link.isEmpty) return;
      setState(() {
        _associatedCardDataFuture = associateCard(widget.tacUserId, link);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _buttonWidget(label, colorText, onPressed, backgroundColor) {
    return Expanded(
        child: TextButton(
          child: _generateTextWidget(
            label,
            colorText,
          ),
          onPressed: onPressed,
          style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.all(16)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              backgroundColor: MaterialStateProperty.all(backgroundColor)),
        ));
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

  List<Widget> _loadingWidget() {
    return List<Widget>.from([
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(50.0)),
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(color: color),
      ),
      const SizedBox(
        height: 14,
      ),
      _generateTextWidget(
          AppLocalizations.of(context)!.wait, Theme.of(context).textTheme.headline2!.color!),
      const SizedBox(
        height: 20,
      ),
      _generateTextWidget(
          AppLocalizations.of(context)!.associatedCardProgress,
          Theme.of(context).textTheme.headline2!.color!,
          textAlign: TextAlign.center),
    ]).toList();
  }

  _resultWidget(bool result) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          result ? Icon(Icons.check_circle_outline, size: 120, color: color) : const Icon(Icons.error_outline, size: 120, color: Colors.red),
          const SizedBox(
            height: 40,
          ),
          _generateTextWidget(
              result ? "${AppLocalizations.of(context)!.associatedCardComplete}!" : "${AppLocalizations.of(context)!.ops}!", Theme.of(context).textTheme.headline1!.color!,
              fontWeight: FontWeight.w600, fontSize: 22),
          const SizedBox(
            height: 20,
          ),
          _generateTextWidget(
              result ? AppLocalizations.of(context)!.activatedCardSuccess : AppLocalizations.of(context)!.activatedCardError,
              Theme.of(context).textTheme.headline2!.color!,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

}
