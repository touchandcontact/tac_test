import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletons/skeletons.dart';
import '../../../models/tag.dart';
import '../../../services/contacts_services.dart';
import '../../inputs/input_debounce_text.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TagContactExternalWidget extends StatefulWidget {
  List<Tag> listaTagContact;
  int idContact;

  TagContactExternalWidget(
      {Key? key, required this.listaTagContact, required this.idContact})
      : super(key: key);

  @override
  State<TagContactExternalWidget> createState() =>
      _TagContactExternalWidgetState();
}

class _TagContactExternalWidgetState extends State<TagContactExternalWidget> {
  late Future<List<Tag>> _tagRecommendedFuture;
  late Future<List<Tag>> _searchTagFuture;

  final int _maxRecommendedTag = 10;

  List<Tag> _temporaneyListTag = [];

  @override
  void initState() {
    _temporaneyListTag = [...widget.listaTagContact];
    _tagRecommendedFuture = _loadRecommendedTags();
    _searchTagFuture = Future.value([]);
    super.initState();
  }

  _loadRecommendedTags() {
    return listRecommendedTag(_maxRecommendedTag);
  }

  _loadSearchTags(String? value) async {
    final List<Tag> listaTags = await searchTags(value ?? "");
    if (value != null && value.isNotEmpty) {
      listaTags.insert(0, Tag()..tag = value);
    }
    _searchTagFuture = Future.value(listaTags);
  }

  _generateTextWidget(String value, Color color,
          {double fontSize = 16, FontWeight fontWeight = FontWeight.w500}) =>
      Text(
        value,
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: fontWeight, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: _generateTextWidget(
            AppLocalizations.of(context)!.addTag, Theme.of(context).textTheme.headline1!.color!,
            fontSize: 20, fontWeight: FontWeight.bold),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8.8, 0, 0, 0),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 42,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: InputDebounceText(callback: (value) async {
                if (value != null && value.isNotEmpty) {
                  await _loadSearchTags(value);
                } else {
                  _searchTagFuture = Future.value([]);
                }
                setState(() {});
              }),
            ),
            const SizedBox(
              height: 42,
            ),
            FutureBuilder<List<Tag>>(
                future: _searchTagFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  SkeletonItem(child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Container(color: Colors.red,child: const Text(""),),),
                          Checkbox(
                              fillColor: MaterialStateColor.resolveWith((states) {
                                if(!states.contains(MaterialState.selected)){
                                  return Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color!;
                                }
                                return Theme.of(context).primaryColor;
                              }),
                              shape: const CircleBorder(),
                              value: true, onChanged: (bool? val){
                          })
                        ],
                      ),
                    ));
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
                    return snapshot.data!.isEmpty
                        ? Container()
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final e = snapshot.data![index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _generateTextWidget(
                                          e.tag,
                                          index == 0
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .headline2!
                                                  .color!
                                              : Theme.of(context)
                                                  .textTheme
                                                  .headline1!
                                                  .color!,
                                          fontWeight: FontWeight.w600),
                                      Checkbox(
                                          fillColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) {
                                            if (!states.contains(
                                                MaterialState.selected)) {
                                              return Theme.of(context)
                                                  .textTheme
                                                  .headline2!
                                                  .color!;
                                            }
                                            return Theme.of(context)
                                                .primaryColor;
                                          }),
                                          shape: const CircleBorder(),
                                          value: _temporaneyListTag.contains(e),
                                          onChanged: (bool? val) {
                                            if (val!) {
                                              _temporaneyListTag.add(e);
                                            } else {
                                              _temporaneyListTag.remove(e);
                                            }
                                            setState(() {});
                                          })
                                    ],
                                  ),
                                ),
                              );
                            });
                  }
                  return Container();
                }),
            const SizedBox(
              height: 42,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _generateTextWidget(
                    AppLocalizations.of(context)!.suggested, Theme.of(context).textTheme.headline1!.color!,
                    fontWeight: FontWeight.w600),
              ),
            ),
            FutureBuilder<List<Tag>>(
                future: _tagRecommendedFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 60,
                      child: Column(
                        children: [
                          SkeletonItem(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                height: 60,
                                child: ListView(
                                    scrollDirection:
                                    Axis.horizontal,
                                    children: List<Widget>.generate(8, (index) => Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                      child:
                                      FilterChip(
                                        label: const Text(
                                          "test",),
                                        backgroundColor:
                                        Theme.of(context).backgroundColor,
                                        shape:
                                        const StadiumBorder(side: BorderSide()),
                                        onSelected:
                                            (bool value) {},
                                      ),
                                    )).toList()
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
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
                    return snapshot.data!.isEmpty
                        ? Text(AppLocalizations.of(context)!.elementNotFound)
                        : SizedBox(
                            height: 60,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data!
                                  .map<Widget>((e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: FilterChip(
                                          label: Text(e.tag,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline2!
                                                      .color!)),
                                          backgroundColor:
                                              Theme.of(context).backgroundColor,
                                          shape: StadiumBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline2!
                                                      .color!)),
                                          onSelected: (bool value) {
                                            if (!_temporaneyListTag
                                                .contains(e)) {
                                              setState(() {
                                                _temporaneyListTag.add(e);
                                              });
                                            }
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ));
                  }
                  return Container();
                }),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _generateTextWidget(
                    AppLocalizations.of(context)!.paired, Theme.of(context).textTheme.headline1!.color!,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            _temporaneyListTag.isEmpty
                ? Text(AppLocalizations.of(context)!.elementNotFound)
                : Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: _temporaneyListTag
                        .map<Widget>((e) => Chip(
                              deleteIcon: const Icon(Icons.close),
                              deleteIconColor: Colors.white,
                              onDeleted: () {
                                setState(() {
                                  _temporaneyListTag.remove(e);
                                });
                              },
                              label: Text(e.tag,
                                  style: const TextStyle(color: Colors.white)),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: const StadiumBorder(
                                  side: BorderSide(
                                      width: 0, color: Colors.transparent)),
                            ))
                        .toList(),
                  ),
            const SizedBox(
              height: 60,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
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
                        Navigator.pop(context, _temporaneyListTag);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
                        child: Text(AppLocalizations.of(context)!.confirmation,
                            style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                            .primaryColor
                                            .computeLuminance() >
                                        0.5
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .color
                                    : Colors.white)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
