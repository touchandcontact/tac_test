import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/tab_button.dart';
import 'package:tac/components/generic_dialog.dart';
import 'package:tac/components/inputs/input_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../extentions/hexcolor.dart';

class SearchBox extends StatefulWidget {
  const SearchBox(
      {Key? key,
      required this.onSearch,
      this.showFilters = false,
      this.onFilter,
      this.customFilters,
      this.label,
      this.onlyOneCustomWidgets = false})
      : super(key: key);
  final bool showFilters;
  final bool onlyOneCustomWidgets;
  final Widget? customFilters;
  final Future Function(String searchedText) onSearch;
  final Future Function(bool orderDesc, String orderby)? onFilter;
  final String? label;

  @override
  SearchBoxState createState() => SearchBoxState();
}

class SearchBoxState extends State<SearchBox> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  Timer? searchOnStoppedTyping;
  bool orderDesc = true;
  String orderBy = "datacreazione";

  @override
  SearchBox get widget => super.widget;

  onChange(String e) {
    const duration = Duration(milliseconds: 800);
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel());
    }
    setState(() =>
        searchOnStoppedTyping = Timer(duration, () => widget.onSearch(e)));
  }

  openFilters() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return GenericDialog(child: getFiltersWidget());
        });
  }

  filter(bool orderDesc, String orderBy) {
    setState(() {
      this.orderDesc = orderDesc;
      this.orderBy = orderBy;
    });
    widget.onFilter!(orderDesc, orderBy);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        height: 70,
        width: MediaQuery.of(context).size.width * 0.88,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Container(
            height: 70,
            color: Theme.of(context).backgroundColor,
            width: widget.showFilters
                ? (MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width / 10)) -
                    (widget.customFilters == null
                        ? 70
                        : widget.onlyOneCustomWidgets
                            ? 70
                            : 110)
                : MediaQuery.of(context).size.width * 0.88,
            child: InputText(
                label: widget.label ?? AppLocalizations.of(context)!.find,
                onChange: onChange,
                prefixIcon: const Icon(Icons.search, size: 30)),
          ),
          if (widget.showFilters && widget.customFilters == null)
            const Spacer(),
          widget.customFilters ?? const SizedBox.shrink(),
          if (widget.showFilters && widget.customFilters == null)
            GestureDetector(
                onTap: openFilters,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 10),
                    child: Center(
                        child: Icon(Icons.filter_list,
                            size: 30,
                            color:
                                Theme.of(context).textTheme.headline2!.color))))
        ]));
  }

  Widget getFiltersWidget() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text(AppLocalizations.of(context)!.filter,
                    style: GoogleFonts.montserrat(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: TabButton(
                    active: orderDesc == false && orderBy == "nome",
                    text: AppLocalizations.of(context)!.orderAZ,
                    padding: const EdgeInsets.fromLTRB(70, 20, 70, 20),
                    inactiveLeftRadius: 20,
                    inactiveRightRadius: 20,
                    onPress: (() => filter(false, "nome")))),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TabButton(
                    active: orderDesc == true && orderBy == "nome",
                    text: AppLocalizations.of(context)!.orderZA,
                    padding: const EdgeInsets.fromLTRB(70, 20, 70, 20),
                    inactiveLeftRadius: 20,
                    inactiveRightRadius: 20,
                    onPress: (() => filter(true, "nome")))),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TabButton(
                    active: orderDesc == true && orderBy == "datacreazione",
                    text: AppLocalizations.of(context)!.recentAdd,
                    padding: const EdgeInsets.fromLTRB(70, 20, 70, 20),
                    inactiveLeftRadius: 20,
                    inactiveRightRadius: 20,
                    onPress: (() => filter(true, "datacreazione")))),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TabButton(
                    active: orderDesc == false && orderBy == "datacreazione",
                    text: AppLocalizations.of(context)!.older,
                    padding: const EdgeInsets.fromLTRB(95, 20, 95, 20),
                    inactiveLeftRadius: 20,
                    inactiveRightRadius: 20,
                    onPress: (() => filter(false, "datacreazione"))))
          ],
        ));
  }
}
