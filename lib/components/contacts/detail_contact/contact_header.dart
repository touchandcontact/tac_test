import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tac/helpers/toast_helper.dart';
import '../../../constants.dart';
import '../../../extentions/hexcolor.dart';
import '../../../helpers/dialog_helper.dart';
import '../../../helpers/util.dart';
import '../../../models/element_model.dart';
import '../../../models/tag.dart';
import '../../../models/user.dart';
import '../../../models/user_contact_info_model.dart';
import '../../../screens/contacts/mod_external_contact.dart';
import '../../../services/contacts_services.dart';
import '../../../services/statistics_service.dart';
import '../../../services/vcard_service.dart';
import '../../tac_logo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactHeader extends StatefulWidget {
  const ContactHeader({
    Key? key,
    required this.identifierUser,
    required this.contactId,
    required this.isExternal,
    required this.contact,
    this.listLinkAndDocument,
    this.reloadData,
    required this.listTag,
  }) : super(key: key);
  final bool isExternal;
  final String identifierUser;
  final int contactId;
  final UserContactInfoModel contact;
  final VoidCallback? reloadData;
  final List<Tag> listTag;
  final List<ElementModel>? listLinkAndDocument;

  @override
  ContactHeaderState createState() => ContactHeaderState();
}

class ContactHeaderState extends State<ContactHeader> {
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  _returnNameSurname() {
    if (widget.contact.name != null && widget.contact.surname != null) {
      return "${widget.contact.name} ${widget.contact.surname}";
    } else if (widget.contact.name != null) {
      return widget.contact.name;
    } else if (widget.contact.surname != null) {
      return widget.contact.surname;
    }
    return null;
  }

  _buildCoverImageWidget() {
    if (widget.contact.coverImage != null &&
        widget.contact.coverImage!.isNotEmpty) {
      return Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.contact.coverImage!),
                fit: BoxFit.cover)),
      );
    } else if (!widget.isExternal) {
      return Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: widget.contact.coverImage != null &&
                    widget.contact.coverImage!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(widget.contact.coverImage!),
                    fit: BoxFit.cover)
                : null),
      );
    } else {
      return Container();
    }
  }

  _buildProfileImageWidget() {
    return Positioned(
      top: 120,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: widget.contact.profileImage == null ||
                widget.contact.profileImage!.isEmpty
            ? Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TacLogo(forProfileImage: true),
                      Container(
                          constraints:
                              BoxConstraints.loose(const Size.fromHeight(60.0)),
                          child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Positioned(
                                    top: -10,
                                    child: Icon(
                                      Icons.person,
                                      color: color,
                                      size: 70,
                                    ))
                              ]))
                    ]),
              )
            : Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    image: widget.contact.profileImage != null &&
                            widget.contact.profileImage!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.contact.profileImage!),
                            fit: BoxFit.cover)
                        : null,
                    borderRadius: BorderRadius.circular(30)),
              ),
      ),
    );
  }

  _returnNameOrEmail() {
    if (widget.contact.name != null &&
        widget.contact.surname != null &&
        widget.contact.surname!.isNotEmpty &&
        widget.contact.name!.isNotEmpty) {
      return "${widget.contact.name} ${widget.contact.surname}.vcf";
    } else if (widget.contact.name != null && widget.contact.name!.isNotEmpty) {
      return "${widget.contact.name}.vcf";
    } else if (widget.contact.surname != null &&
        widget.contact.surname!.isNotEmpty) {
      return "${widget.contact.surname}.vcf";
    } else if (widget.contact.email != null &&
        widget.contact.email!.isNotEmpty) {
      return "${widget.contact.email}.vcf";
    }
    return "nd.vcf";
  }

  _swapContact() async {
    showLoadingDialog(context);
    try {
      if (widget.contact.tacUserId != null && widget.contact.tacUserId != 0) {
        await insertContact(user.identifier, widget.contact.tacUserId!, "", []);
        if (!mounted) return;
        Navigator.pop(context);
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      } else {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    } catch (e) {
      Navigator.pop(context);
      if (e.toString().contains(Constants.alreadyExistSwapContact)) {
        showErrorToast(AppLocalizations.of(context)!.alreadySwapContact);
      } else {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    }
  }

  _condividiProfilo() async {
    showLoadingDialog(context);
    try {
      final response = await createContactVCard(widget.contactId);
      Directory tempDir = await getTemporaryDirectory();
      final imagePath = "${tempDir.path}/${_returnNameOrEmail()}";
      final imageFile = File(imagePath);
      imageFile.writeAsBytesSync(base64Decode(response));
      final file = XFile(imagePath);
      await Share.shareXFiles([file]).then((value) => Navigator.pop(context));
      if (widget.contact.tacUserId != null && widget.contact.tacUserId != 0) {
        _saveInsightNfc();
      }
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  _deleteContact() async {
    Navigator.pop(context);
    showLoadingDialog(context);
    try {
      final response = await deleteContacts([widget.contactId]);
      if (response) {
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        showErrorToast(AppLocalizations.of(context)!.error);
        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  _openModalDeletedContact() {
    return showAdaptiveActionSheet(
        context: context,
        androidBorderRadius: 20,
        bottomSheetColor: Theme.of(context).backgroundColor,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.yes,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) async {
                await _deleteContact();
              }),
          BottomSheetAction(
              title: Text(AppLocalizations.of(context)!.no,
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.headline1!.color)),
              onPressed: (context) {
                Navigator.pop(context);
              }),
        ],
        cancelAction: CancelAction(
            title: Text(AppLocalizations.of(context)!.close,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      height: 240,
      child: Stack(children: [
        _buildCoverImageWidget(),
        _buildProfileImageWidget(),
        Positioned(
          left: 20,
          top: 10,
          child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  color: Theme.of(context).textTheme.bodyText2!.color)),
        ),
        Positioned(
          right: 20,
          top: 10,
          child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(15)),
              child: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    _showModalBottomSheet(context);
                  },
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).textTheme.bodyText1!.color),
                  color: Theme.of(context).textTheme.bodyText2!.color)),
        ),
      ]),
    );
  }

  _bottomSheetItem(String label, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),
      leading: Icon(icon, color: Theme.of(context).textTheme.headline1!.color),
      title: Text(label,
          style:
              TextStyle(color: Theme.of(context).textTheme.headline1!.color)),
    );
  }

  _bottomSheetItemFavourite(String label, IconData icon, Color color) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),
      leading: Icon(icon, color: color),
      title: Text(label,
          style:
              TextStyle(color: Theme.of(context).textTheme.headline1!.color)),
    );
  }

  _addContactToFavourite() async {
    showLoadingDialog(context);
    try {
      final response =
          await addContactToFavourite(user.tacUserId, widget.contactId);
      if (response == "ALREADY_FAVOURITE") {
        showSuccessToast(AppLocalizations.of(context)!.favoriteContactError);
        return;
      }
      showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      widget.contact.isInFavourites = true;
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    } finally {
      Navigator.pop(context);
    }
  }

  void _goToEditContact() async {
    Navigator.pop(context);
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ModExternalContactModal(
                      idContattoDaLista: widget.contactId,
                      contactMod: widget.contact,
                    )))
        .then((value) => value != null && value ? widget.reloadData!() : null);
  }

  _saveContactInRubrica() async {
    if (widget.contact.telephone == null ||
        (widget.contact.telephone!.isEmpty)) {
      showErrorToast(AppLocalizations.of(context)!.telephoneNumberError);
      return;
    }
    if (Platform.isIOS) {
      FlutterContacts.config.includeNotesOnIos13AndAbove = true;
    }
    if (await FlutterContacts.requestPermission()) {
      try {
        final newContact = Contact()
          ..name.first = widget.contact.name ?? ""
          ..name.last = widget.contact.surname ?? ""
          ..phones = returnListTelephone()
          ..addresses = returnListAddress()
          ..photo = await returnPhotoImage()
          ..notes = widget.listTag.isNotEmpty
              ? widget.listTag.map<Note>((e) => Note(e.tag)).toList()
              : []
          ..websites = returnListDocumentsAndLink();
        await newContact.insert();
        if (widget.contact.tacUserId != null && widget.contact.tacUserId != 0) {
          _saveInsightNfc();
        }
        showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      } catch (e) {
        showErrorToast(AppLocalizations.of(context)!.error);
      }
    }
  }

  Future<Uint8List?> returnPhotoImage() async {
    if (widget.contact.profileImage != null &&
        widget.contact.profileImage!.isNotEmpty) {
      return await Util.downloadImage(widget.contact.profileImage!);
    }
    return null;
  }

  returnListDocumentsAndLink() {
    List<Website> listDocumentAndLinkAndWebsites = [];
    if (widget.contact.website != null && widget.contact.website!.isNotEmpty) {
      listDocumentAndLinkAndWebsites.add(Website(widget.contact.website!));
    }
    if (!widget.isExternal &&
        widget.listLinkAndDocument != null &&
        widget.listLinkAndDocument!.isNotEmpty) {
      listDocumentAndLinkAndWebsites.addAll(widget.listLinkAndDocument!
          .map<Website>((e) => Website(e.link))
          .toList());
    }
    return listDocumentAndLinkAndWebsites;
  }

  returnListTelephone() {
    List<Phone> listTelephones = [];
    listTelephones.add(Phone(widget.contact.telephone!, label: PhoneLabel.custom, customLabel: getPhoneLabel(widget.contact.telephone!)));
    if (widget.contact.telephones != null &&
        widget.contact.telephones!.isNotEmpty) {
      listTelephones.addAll(widget.contact.telephones!
          .map<Phone>((e) => Phone(e.telephone!, label: PhoneLabel.custom, customLabel: getPhoneLabel(e.telephone!)))
          .toList());
    }
    return listTelephones;
  }

  returnListAddress() {
    List<Address> listAddresses = [];
    if (widget.contact.address != null && widget.contact.address!.isNotEmpty) {
      listAddresses.add(Address(widget.contact.address!));
    }
    if (widget.contact.addresses != null &&
        widget.contact.addresses!.isNotEmpty) {
      listAddresses.addAll(widget.contact.addresses!
          .map<Address>((e) => Address(e.address!))
          .toList());
    }
    return listAddresses;
  }

  void _showModalBottomSheet(BuildContext context) {
    final ValueNotifier<bool> _isFavoriteNotifier = ValueNotifier(widget.contact.isInFavourites ?? false);
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      elevation: 10,
      builder: (BuildContext context) {
        final isFavorite = widget.contact.isInFavourites;
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
                  _returnNameSurname() != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  image: widget.contact.profileImage != null &&
                                          widget
                                              .contact.profileImage!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              widget.contact.profileImage!),
                                          fit: BoxFit.cover)
                                      : null,
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_returnNameSurname()!,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline1!
                                            .color!,
                                        fontWeight: FontWeight.bold)),
                                widget.contact.profession != null
                                    ? Text(
                                        widget.contact.profession!,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .color!,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : const SizedBox()
                              ],
                            ))
                          ],
                        )
                      : const SizedBox(),
                  _returnNameSurname() != null
                      ? const SizedBox(height: 30)
                      : const SizedBox(),
                  GestureDetector(
                    onTap: () async {
                      if(widget.contact.isInFavourites!){
                        await _removeFromFavorite();
                      }else{
                        await _addContactToFavourite();
                      }
                      _isFavoriteNotifier.value = widget.contact.isInFavourites!;
                    },
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isFavoriteNotifier,
                      builder: (context, valueNotifier, child){
                        return  _bottomSheetItemFavourite(
                            valueNotifier
                                ?  AppLocalizations.of(context)!.removeFromFavorite : AppLocalizations.of(context)!.addFavoritesContact,
                            valueNotifier
                                ? Icons.favorite : Icons.favorite_outline,
                            valueNotifier
                                ? Colors.red
                                : Theme.of(context).textTheme.headline1!.color!);
                      },
                    )
                  ),
                  widget.isExternal
                      ? GestureDetector(
                          onTap: () => _goToEditContact(),
                          child: _bottomSheetItem(
                              AppLocalizations.of(context)!.modContactLabel,
                              Icons.manage_accounts),
                        )
                      : Container(),
                  widget.contact.tacUserId != null &&
                          widget.contact.tacUserId != 0
                      ? GestureDetector(
                          onTap: () => _swapContact(),
                          child: _bottomSheetItem(
                              AppLocalizations.of(context)!.swapContact,
                              Icons.compare_arrows))
                      : Container(),
                  GestureDetector(
                      onTap: () => _condividiProfilo(),
                      child: _bottomSheetItem(
                          AppLocalizations.of(context)!.shareProfile,
                          Icons.share_outlined)),
                  GestureDetector(
                    onTap: () => _saveContactInRubrica(),
                    child: _bottomSheetItem(
                        AppLocalizations.of(context)!.addAddressBook,
                        Icons.account_circle_outlined),
                  ),
                  GestureDetector(
                    onTap: () => _openModalDeletedContact(),
                    child: _bottomSheetItem(
                        AppLocalizations.of(context)!.deleteContact,
                        Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveInsightNfc() async {
    try {
      await addInsightProfileDownload(
          widget.contact.tacUserId!, user.tacUserId);
      // ignore: empty_catches
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _removeFromFavorite() async {
    showLoadingDialog(context);
    try {
       await removeContactFromFavourite(user.tacUserId, widget.contactId);
      showSuccessToast(AppLocalizations.of(context)!.operationComplete);
      widget.contact.isInFavourites = false;
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
    } finally {
      Navigator.pop(context);
    }
  }

  String getPhoneLabel(String phone){
    phone = phone.replaceAll("+39", "").trim();
    return phone.startsWith("3") ? "cellulare" : "telefono";
  }
}
