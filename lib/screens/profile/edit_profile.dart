// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:tac/components/buttons/outlinet_loading_button.dart';
import 'package:tac/components/cover_image_picker.dart';
import 'package:tac/components/profile_image_picker.dart';
import 'package:tac/components/profile_loader.dart';
import 'package:tac/helpers/dialog_helper.dart';
import 'package:tac/helpers/toast_helper.dart';
import 'package:tac/helpers/util.dart';
import 'package:tac/models/field_management.dart';
import 'package:tac/models/user_address.dart';
import 'package:tac/models/user_edit.dart';
import 'package:tac/models/user_email.dart';
import 'package:tac/models/user_telephone.dart';
import 'package:tac/services/account_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:email_validator/email_validator.dart';
import '../../components/generic_dialog.dart';
import '../../components/inputs/input_cut_text.dart';
import '../../components/inputs/input_text.dart';
import '../../extentions/hexcolor.dart';
import '../../models/registry_request.dart';
import '../../models/user.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  User boxUser = User.fromJson(jsonDecode(Hive.box("settings").get("user")));
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  bool isLoading = false;
  bool error = false;
  bool showCompanyAlert = false;
  String? companyLogo;
  final formKey = GlobalKey<FormState>();
  User user = User();
  List<UserTelephone> telephones = <UserTelephone>[];
  List<UserAddress> addresses = <UserAddress>[];
  List<UserEmail> emails = <UserEmail>[];
  List<FieldManagement> fieldMangement = <FieldManagement>[];
  File? profileImage;
  File? coverImage;

  Map<String, dynamic> userCopy = {};
  List<UserTelephone> telephonesCopy = [];
  List<UserAddress> addressesCopy = [];
  List<UserEmail> emailsCopy = [];

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    companyLogo = user.isCompanyPremium ? user.company?.logo : null;
    try {
      getUserForEdit(boxUser.identifier).then((us) {
        if (boxUser.companyId != null) {
          listFieldManagement(boxUser.tacUserId, boxUser.companyId!)
              .then((value) {
            setState(() {
              fieldMangement = value;
            });
            setUser(us);
          });
        } else {
          setUser(us);
        }
      });
    } catch (_) {
      setState(() {
        error = true;
        isLoading = false;
      });
    }
    super.initState();
  }

  String? base64ProfileImageCopy;

  setUser(UserEditModel model) {
    setState(() {
      user = model.userDTO;
      telephones = model.userTelephoneDTO;
      addresses = model.userAddressDTO;
      emails = model.userEmailsDTO;
      userCopy = model.userDTO.toJson();
      telephonesCopy = List.from(model.userTelephoneDTO);
      addressesCopy = List.from(model.userAddressDTO);
      emailsCopy = List.from(model.userEmailsDTO);
      base64ProfileImageCopy = model.userDTO.profileImage;
      isLoading = false;
    });
  }

  Future beforSave() async {
    if(formKey.currentState!.validate()){
      FocusScope.of(context).unfocus();
      if (user.isCompanyPremium &&
          user.companyId != null &&
          user.companyId != 0 &&
          showCompanyAlert) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return GenericDialog(
                  vertical: 240, child: companyAlertDialog(context));
            });
      } else {
        await saveNotCompany();
      }
    }
  }

  Future saveNotCompany() async {
    showLoadingDialog(context);

    try {
      await updateProfile(
          user, telephones, addresses, emails, profileImage, coverImage);

      var tempUser = await getUserForEdit(boxUser.identifier);

      boxUser.profileImage = tempUser.userDTO.profileImage;
      boxUser.coverImage = tempUser.userDTO.coverImage;
      boxUser.name = tempUser.userDTO.name;
      boxUser.surname = tempUser.userDTO.surname;
      boxUser.profession = tempUser.userDTO.profession;
      boxUser.companyName = tempUser.userDTO.companyName;
      await Hive.box("settings").put("user", jsonEncode(boxUser.toJson()));

      showSuccessToast(AppLocalizations.of(context)!.mod);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }

    Navigator.pop(context);
  }

  List<UserTelephone> secondaryTelephoneListToSend(
      CustomObjToSendRequest customObjectToSendForRequest) {
    if (customObjectToSendForRequest.canTelephoneModify) {
      return telephonesCopy;
    }
    return telephones;
  }

  List<UserAddress> secondaryAddressListToSend(
      CustomObjToSendRequest customObjectToSendForRequest) {
    if (customObjectToSendForRequest.canAddressModify) {
      return addressesCopy;
    }
    return addresses;
  }

  List<UserEmail> secondaryEmailsListToSend(
      CustomObjToSendRequest customObjectToSendForRequest) {
    if (customObjectToSendForRequest.canTelephoneModify) {
      return emailsCopy;
    }
    return emails;
  }

  File? profileImageToSend(
      CustomObjToSendRequest customObjectToSendForRequest) {
    if (customObjectToSendForRequest.canProfileImageModify) {
      return null;
    } else {
      return profileImage;
    }
  }

  Future saveWithCompany() async {
    bool isSuccess = false;
    if (showCompanyAlert) {
      showLoadingDialog(context);
    }
    try {
      final customObjectToSendForRequest = addModFieldForSave();
      if (customObjectToSendForRequest.listFieldModificati.isNotEmpty) {
        await sendRegistryRequest(
            customObjectToSendForRequest.listFieldModificati);
      }

      List<UserTelephone> listTelephoneToSend =
          secondaryTelephoneListToSend(customObjectToSendForRequest);
      List<UserAddress> listAddressToSend =
          secondaryAddressListToSend(customObjectToSendForRequest);
      List<UserEmail> listEmailsToSend =
          secondaryEmailsListToSend(customObjectToSendForRequest);
      File? imageToSend = profileImageToSend(customObjectToSendForRequest);

      await updateProfile(user, listTelephoneToSend, listAddressToSend,
          listEmailsToSend, imageToSend, coverImage);
      isSuccess = true;
      showSuccessToast(AppLocalizations.of(context)!.mod);
    } catch (_) {
      showErrorToast(AppLocalizations.of(context)!.error);
    }

    if (showCompanyAlert) {
      Navigator.pop(context);
    }
    if (isSuccess) {
      refreshDataUserWithCompany();
    }
  }

  void onImageProfilePicker(File file) async {
    final bytes = await file.readAsBytes();
    var base64img = base64Encode(bytes);
    setState(() {
      profileImage = file;
      base64ProfileImageCopy = base64img;
      checkEnabled("profileImage");
    });
  }

  void onImageCoverPicker(File file) {
    setState(() {
      coverImage = file;
    });
  }

  void addTelephone() {
    setState(() {
      telephones = [...telephones, UserTelephone()];
      checkEnabled("telephone");
    });
  }

  void addEmail() {
    setState(() {
      emails = [...emails, UserEmail()];
      checkEnabled("email");
    });
  }

  void removeTelephone(UserTelephone item) {
    telephones.remove(item);
    setState(() {
      telephones = List.from(telephones);
    });
  }

  void removeEmail(UserEmail item) {
    emails.remove(item);
    setState(() {
      emails = List.from(emails);
    });
  }

  void addAddress() {
    setState(() {
      addresses = [...addresses, UserAddress()];
      checkEnabled("address");
    });
  }

  void removeAddress(UserAddress item) {
    addresses.remove(item);
    setState(() {
      addresses = List.from(addresses);
    });
  }

  bool checkIfImageIsEqual(String? firstValue, File? secondValue) {
    bool isEqual = false;
    Future<void> returnResultOfImage(
        String? firstValue, File? secondValue) async {
      if ((firstValue == null || firstValue.isEmpty) && secondValue == null) {
        isEqual = true;
      }
      if ((firstValue != null && firstValue.isNotEmpty) &&
          secondValue == null) {
        isEqual = false;
      }
      var bytes = await secondValue!.readAsBytes();
      var base64img = base64Encode(bytes);
      if (firstValue?.toLowerCase() == base64img.toLowerCase()) {
        isEqual = true;
      }
      isEqual = false;
    }

    return isEqual;
  }

  bool checkIfValueIsEqual(String? firstValue, String? secondValue) {
    if ((firstValue == null && secondValue == "") ||
        (firstValue == "" && secondValue == null) ||
        (firstValue?.toLowerCase() == secondValue?.toLowerCase())) {
      return true;
    }
    return false;
  }

  void setValueInListFieldModificati(List<RegistryRequest> listElement,
      String propertyName, String? newValue, String? oldValue) {
    listElement.add(RegistryRequest(
        title: "",
        companyId: user.companyId!,
        from: oldValue != null && oldValue.isNotEmpty ? oldValue : "-",
        propertyName: propertyName,
        requestedById: user.tacUserId,
        state: 0,
        to: newValue ?? ""));
  }

  void checkTelephoneMod(List<RegistryRequest> listFieldModificati) {
    if (telephonesCopy.isEmpty && telephones.isEmpty) {
      return;
    } else {
      if (telephones.isEmpty) {
        int i = 2;
        for (var element in telephonesCopy) {
          setValueInListFieldModificati(listFieldModificati,
              "telephone${element.id}", "-", element.telephone);
          i++;
        }
      } else if (telephonesCopy.isEmpty) {
        for (var element in telephones) {
          int i = 2;
          setValueInListFieldModificati(listFieldModificati,
              "telephone${element.id}", element.telephone, "-");
          i++;
        }
      } else {
        int maxLength = telephones.length > telephonesCopy.length
            ? telephones.length
            : telephonesCopy.length;
        for (int i = 0; i < maxLength; i++) {
          if (i >= telephones.length) {
            setValueInListFieldModificati(
              listFieldModificati,
              "telephone${telephonesCopy[i].id}",
              "-",
              telephonesCopy[i].telephone,
            );
          } else if (i >= telephonesCopy.length) {
            setValueInListFieldModificati(listFieldModificati,
                "telephone${i + 2}", telephones[i].telephone, "-");
          } else {
            bool isEquals = telephones[i] == telephonesCopy[i];
            if (!isEquals) {
              setValueInListFieldModificati(
                  listFieldModificati,
                  "telephone${telephones[i].id}",
                  telephones[i].telephone,
                  telephonesCopy[i].telephone);
            }
          }
        }
      }
    }
  }

  void checkAddressMod(List<RegistryRequest> listFieldModificati) {
    if (addressesCopy.isEmpty && addresses.isEmpty) {
      return;
    } else {
      if (addresses.isEmpty) {
        int i = 2;
        for (var element in addressesCopy) {
          setValueInListFieldModificati(listFieldModificati,
              "address${element.id}", "-", element.address);
          i++;
        }
      } else if (addressesCopy.isEmpty) {
        for (var element in addresses) {
          int i = 2;
          setValueInListFieldModificati(listFieldModificati,
              "address${element.id}", element.address, "-");
          i++;
        }
      } else {
        int maxLength = addresses.length > addressesCopy.length
            ? addresses.length
            : addressesCopy.length;
        for (int i = 0; i < maxLength; i++) {
          if (i >= addresses.length) {
            setValueInListFieldModificati(
              listFieldModificati,
              "address${addresses[i].id}",
              "-",
              addressesCopy[i].address,
            );
          } else if (i >= addressesCopy.length) {
            setValueInListFieldModificati(listFieldModificati,
                "address${addresses[i].id}", addresses[i].address, "-");
          } else {
            bool isEquals = addresses[i] == addressesCopy[i];
            if (!isEquals) {
              setValueInListFieldModificati(
                  listFieldModificati,
                  "address${addresses[i].id}",
                  addresses[i].address,
                  addressesCopy[i].address);
            }
          }
        }
      }
    }
  }

  void checkEmailMod(List<RegistryRequest> listFieldModificati) {
    if (emailsCopy.isEmpty && emails.isEmpty) {
      return;
    } else {
      if (emails.isEmpty) {
        int i = 2;
        for (var element in emailsCopy) {
          setValueInListFieldModificati(
              listFieldModificati, "email${element.id}", "-", element.email);
          i++;
        }
      } else if (emailsCopy.isEmpty) {
        for (var element in emails) {
          int i = 2;
          setValueInListFieldModificati(
              listFieldModificati, "email${element.id}", element.email, "-");
          i++;
        }
      } else {
        int maxLength = emails.length > emailsCopy.length
            ? emails.length
            : emailsCopy.length;
        for (int i = 0; i < maxLength; i++) {
          if (i >= emails.length) {
            setValueInListFieldModificati(
              listFieldModificati,
              "email${emails[i].id}",
              "-",
              emailsCopy[i].email,
            );
          } else if (i >= emailsCopy.length) {
            setValueInListFieldModificati(listFieldModificati,
                "email${emails[i].id}", emails[i].email, "-");
          } else {
            bool isEquals = emails[i] == emailsCopy[i];
            if (!isEquals) {
              setValueInListFieldModificati(listFieldModificati,
                  "email${emails[i].id}", emails[i].email, emailsCopy[i].email);
            }
          }
        }
      }
    }
  }

  CustomObjToSendRequest addModFieldForSave() {
    CustomObjToSendRequest customObjToSendRequest = CustomObjToSendRequest();
    for (FieldManagement fieldManagement in fieldMangement) {
      if (!fieldManagement.canEdit) {
        switch (fieldManagement.fieldName.toLowerCase()) {
          case "name":
            final valueToMod = userCopy["name"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.name);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "name",
                user.name,
                userCopy["name"]);
            user.name = userCopy["name"];
            break;
          case "surname":
            final valueToMod = userCopy["surname"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.surname);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "surname",
                user.surname,
                userCopy["surname"]);
            user.surname = userCopy["surname"];
            break;
          case "profileimage":
            customObjToSendRequest.canProfileImageModify = true;
            final valueToMod = userCopy["profileImage"] as String?;
            bool isNotChanged =
                checkIfValueIsEqual(valueToMod, base64ProfileImageCopy);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "profileImage",
                base64ProfileImageCopy,
                userCopy["profileImage"]);
            user.profileImage = userCopy["profileImage"];
            break;
          case "profession":
            final valueToMod = userCopy["profession"] as String?;
            bool isNotChanged =
                checkIfValueIsEqual(valueToMod, user.profession);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "profession",
                user.profession,
                userCopy["profession"]);
            user.profession = userCopy["profession"];
            break;
          case "address":
            customObjToSendRequest.canAddressModify = true;
            final valueToMod = userCopy["address"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.address);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "address",
                user.address,
                userCopy["address"]);
            user.address = userCopy["address"];
            break;
          case "website":
            final valueToMod = userCopy["website"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.website);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "website",
                user.website,
                userCopy["website"]);
            user.website = userCopy["website"];
            break;
          case "vat":
            final valueToMod = userCopy["vat"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.vat);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "vat",
                user.vat,
                userCopy["vat"]);
            user.vat = userCopy["vat"];
            break;
          case "telephone":
            customObjToSendRequest.canTelephoneModify = true;
            final valueToMod = userCopy["telephone"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.telephone);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "telephone",
                user.telephone,
                userCopy["telephone"]);
            user.telephone = userCopy["telephone"];
            break;
          case "email":
            customObjToSendRequest.canEmailModify = true;
            final valueToMod = userCopy["email"] as String?;
            bool isNotChanged = checkIfValueIsEqual(valueToMod, user.email);
            if (isNotChanged) {
              break;
            }
            setValueInListFieldModificati(
                customObjToSendRequest.listFieldModificati,
                "email",
                user.email,
                userCopy["email"]);
            user.email = userCopy["email"];
            break;
        }
      }
    }
    if (customObjToSendRequest.canTelephoneModify) {
      checkTelephoneMod(customObjToSendRequest.listFieldModificati);
    }
    if (customObjToSendRequest.canAddressModify) {
      checkAddressMod(customObjToSendRequest.listFieldModificati);
    }
    if (customObjToSendRequest.canEmailModify) {
      checkEmailMod(customObjToSendRequest.listFieldModificati);
    }
    return customObjToSendRequest;
  }

  void checkEnabled(String fieldName) {
    if (user.companyId != null &&
        user.companyId != 0 &&
        user.isCompanyPremium) {
      var canEdit = fieldMangement
          .where((element) =>
              element.fieldName.toLowerCase() == fieldName.toLowerCase())
          .first
          .canEdit;
      if (!canEdit) {
        setState(() {
          showCompanyAlert = true;
        });
      }
    }
  }

  bool checkLocked(String fieldName) {
    if (user.companyId != null &&
        user.companyId != 0 &&
        user.isCompanyPremium) {
      return fieldMangement
          .where((element) =>
              element.fieldName.toLowerCase() == fieldName.toLowerCase())
          .first
          .fullLocked;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ProfileLoader();
    } else {
      return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
              toolbarHeight: 40,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).backgroundColor,
              flexibleSpace: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Stack(children: [
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
                                onPressed: () => {Navigator.pop(context)},
                                icon: Icon(Icons.arrow_back,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .color))),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(AppLocalizations.of(context)!.profile,
                              style: Theme.of(context).textTheme.headline1),
                        )),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: beforSave,
                            child: Text(AppLocalizations.of(context)!.save,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          )),
                    )
                  ]))),
          body: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [
                          SizedBox(
                              height: user.isCompanyPremium ? 160 : 230,
                              child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (!user.isCompanyPremium)
                                      Positioned(
                                          top: 20,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 140,
                                              child: CoverImagePicker(
                                                  disabled:
                                                      user.isCompanyPremium,
                                                  hideEditIcon:
                                                      user.isCompanyPremium,
                                                  initialImage: companyLogo ??
                                                      (user.coverImage !=
                                                                  null &&
                                                              user.coverImage!
                                                                  .isNotEmpty
                                                          ? user.coverImage
                                                          : null),
                                                  onPickComplete:
                                                      onImageCoverPicker))),
                                    Positioned(
                                        top: user.isCompanyPremium ? 20 : 90,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: ProfileImagePicker(
                                                iconOnRight: true,
                                                enabled: !checkLocked(
                                                    "ProfileImage"),
                                                initialImage:
                                                    user.profileImage != null &&
                                                            user.profileImage!
                                                                .isNotEmpty
                                                        ? user.profileImage
                                                        : null,
                                                useBoxShadow: true,
                                                onPickComplete:
                                                    onImageProfilePicker)))
                                  ])),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                              child: Form(
                                  key: formKey,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .infoProfile,
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline1!
                                                      .color,
                                                  fontWeight: FontWeight.w600))
                                        ]),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .name,
                                            initalValue: user.name != null &&
                                                    user.name!.isNotEmpty
                                                ? user.name!
                                                : null,
                                            enabled: !checkLocked("Name"),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            onChange: (e) => setState(() {
                                                  user.name = e;
                                                  checkEnabled("name");
                                                }),
                                            validator: (value) {
                                              if (value == null ||
                                                  value == "") {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .requiredField;
                                              }

                                              return null;
                                            }),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .surname,
                                            initalValue: user.surname != null &&
                                                    user.surname!.isNotEmpty
                                                ? user.surname
                                                : null,
                                            enabled: !checkLocked("Surname"),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            onChange: (e) => setState(() {
                                                  user.surname = e;
                                                  checkEnabled("surname");
                                                }),
                                            validator: (value) {
                                              if (value == null ||
                                                  value == "") {
                                                return AppLocalizations.of(
                                                        context)!
                                                    .requiredField;
                                              }
                                              return null;
                                            }),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        Stack(
                                          children: [
                                            InputText(
                                                label: AppLocalizations.of(
                                                        context)!
                                                    .email,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                enabled: !checkLocked("email"),
                                                initalValue: user.email,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value == "") {
                                                    return AppLocalizations.of(
                                                            context)!
                                                        .requiredField;
                                                  }
                                                  if (!EmailValidator.validate(
                                                      value)) {
                                                    return AppLocalizations.of(
                                                            context)!
                                                        .insertValidEmail;
                                                  }

                                                  return null;
                                                },
                                                onChange: (e) => setState(() {
                                                      user.email = e;
                                                      checkEnabled("email");
                                                    })),
                                            if (!checkLocked("email"))
                                              Positioned(
                                                  right: 5,
                                                  child: TextButton(
                                                      onPressed: addEmail,
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .add,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  color: color,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600))))
                                          ],
                                        ),
                                        getEmails(context),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 20, 20, 0)),
                                        Row(children: [
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .additionalInfo,
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .headline1!
                                                      .color,
                                                  fontWeight: FontWeight.w600))
                                        ]),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .profession,
                                            initalValue: user.profession,
                                            enabled: !checkLocked("Profession"),
                                            onChange: (e) => setState(() {
                                                  user.profession = e;
                                                  checkEnabled("profession");
                                                })),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .company,
                                            enabled: user.companyId == null ||
                                                user.companyId == 0,
                                            initalValue: user.company != null
                                                ? user.company!.name
                                                : user.companyName,
                                            onChange: (e) =>
                                                user.companyName = e),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .department,
                                            enabled: user.companyId == null ||
                                                user.companyId == 0,
                                            initalValue: user.departmentName,
                                            onChange: (e) => setState(() {
                                                  user.departmentName = e;
                                                })),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        Stack(
                                          children: [
                                            InputText(
                                                label: AppLocalizations.of(
                                                        context)!
                                                    .telephone,
                                                keyboardType:
                                                    TextInputType.phone,
                                                enabled:
                                                    !checkLocked("Telephone"),
                                                initalValue: user.telephone,
                                                onChange: (e) => setState(() {
                                                      user.telephone = e;
                                                      checkEnabled("telephone");
                                                    })),
                                            if (!checkLocked("Telephone"))
                                              Positioned(
                                                  right: 5,
                                                  child: TextButton(
                                                      onPressed: addTelephone,
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .add,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  color: color,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600))))
                                          ],
                                        ),
                                        getTelephones(context),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        Stack(
                                          children: [
                                            InputCutText(
                                              label:
                                                  AppLocalizations.of(context)!
                                                      .address,
                                              enabled: !checkLocked("Address"),
                                              initalValue: user.address,
                                              onChange: (e) => setState(() {
                                                user.address = e;
                                                checkEnabled("address");
                                              }),
                                              suffixIcon: !checkLocked(
                                                      "Address")
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5.0),
                                                      child: TextButton(
                                                          onPressed: addAddress,
                                                          child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .add,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      color:
                                                                          color,
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600))),
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                        getAddresses(context),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .website,
                                            keyboardType: TextInputType.url,
                                            enabled: !checkLocked("Website"),
                                            initalValue: user.website,
                                            onChange: (e) => setState(() {
                                                  user.website = e;
                                                  checkEnabled("website");
                                                })),
                                        const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0)),
                                        InputText(
                                            label: AppLocalizations.of(context)!
                                                .p_iva,
                                            enabled: !checkLocked("VAT"),
                                            initalValue: user.vat,
                                            onChange: (e) => setState(() {
                                                  user.vat = e;
                                                  checkEnabled("vat");
                                                }))
                                      ])))
                        ])))
              ])));
    }
  }

  refreshDataUserWithCompany() async {
    setState(() {
      isLoading = true;
    });
    try {
      showCompanyAlert = false;
      getUserForEdit(boxUser.identifier).then((us) async {
        boxUser.profileImage = us.userDTO.profileImage;
        boxUser.coverImage = us.userDTO.coverImage;
        boxUser.name = us.userDTO.name;
        boxUser.surname = us.userDTO.surname;
        boxUser.profession = us.userDTO.profession;
        await Hive.box("settings").put("user", jsonEncode(boxUser.toJson()));
        listFieldManagement(boxUser.tacUserId, boxUser.companyId!)
            .then((value) {
          setState(() {
            fieldMangement = value;
          });
          setUser(us);
        });
      });
    } catch (_) {
      setState(() {
        error = true;
        isLoading = false;
      });
    }
  }

  Widget getAddresses(BuildContext context) {
    if (addresses.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: List<Widget>.generate(
            addresses.length,
            (index) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Stack(children: [
                  InputCutText(
                    key: ValueKey(addresses[index]),
                    enabled: !checkLocked("Address"),
                    label:
                        "${AppLocalizations.of(context)!.address} ${index + 2}",
                    initalValue: addresses[index].address,
                    onChange: (e) => addresses[index].address = e,
                    suffixIcon: !checkLocked("Address")
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: IconButton(
                                onPressed: () =>
                                    removeAddress(addresses[index]),
                                icon: Icon(
                                  Icons.delete,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .color,
                                )),
                          )
                        : null,
                  ),
                  // if(!checkLocked("Address"))
                  //   Positioned(
                  //       right: 5,
                  //       child: IconButton(
                  //           onPressed: () => removeAddress(addresses[index]),
                  //           icon: Icon(
                  //             Icons.delete,
                  //             color: Theme.of(context).textTheme.headline2!.color,
                  //           )))
                ]))).toList());
  }

  Widget companyAlertDialog(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Text("${AppLocalizations.of(context)!.modProfile}?",
                    style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headline1!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                    "${AppLocalizations.of(context)!.modRequestToCompany}?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.headline2!.color))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: OutlinedLoadingButton(
                  color: color,
                  borderColor: color,
                  onPress: () async {
                    Navigator.pop(context);
                    await saveWithCompany();
                  },
                  text: AppLocalizations.of(context)!.send,
                  width: 300,
                ))
          ],
        ));
  }

  Widget getTelephones(BuildContext context) {
    if (telephones.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: List.generate(
            telephones.length,
            (index) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Stack(children: [
                  InputText(
                      key: ValueKey(telephones[index]),
                      enabled: !checkLocked("Telephone"),
                      keyboardType: TextInputType.phone,
                      label:
                          "${AppLocalizations.of(context)!.telephone} ${index + 2}",
                      initalValue: telephones[index].telephone,
                      onChange: (e) => setState(() {
                            telephones[index].telephone = e;
                          })),
                  if (!checkLocked("Telephone"))
                    Positioned(
                        right: 5,
                        child: IconButton(
                            onPressed: () => removeTelephone(telephones[index]),
                            icon: Icon(
                              Icons.delete,
                              color:
                                  Theme.of(context).textTheme.headline2!.color,
                            )))
                ]))).toList());
  }

  Widget getEmails(BuildContext context) {
    if (emails.isEmpty) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Column(
        children: List.generate(
            emails.length,
            (index) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Stack(children: [
                  InputText(
                      key: ValueKey(emails[index]),
                      enabled: !checkLocked("email"),
                      keyboardType: TextInputType.emailAddress,
                      label:
                          "${AppLocalizations.of(context)!.email} ${index + 2}",
                      initalValue: emails[index].email,
                      validator: (value) {
                        if (value == null || value == "") {
                          return AppLocalizations.of(context)!.requiredField;
                        }
                        if (!EmailValidator.validate(value)) {
                          return AppLocalizations.of(context)!.insertValidEmail;
                        }

                        return null;
                      },
                      onChange: (e) => setState(() {
                            emails[index].email = e;
                          })),
                  if (!checkLocked("email"))
                    Positioned(
                        right: 5,
                        child: IconButton(
                            onPressed: () => removeEmail(emails[index]),
                            icon: Icon(
                              Icons.delete,
                              color:
                                  Theme.of(context).textTheme.headline2!.color,
                            )))
                ]))).toList());
  }
}

class CustomObjToSendRequest {
  List<RegistryRequest> listFieldModificati = [];
  bool canTelephoneModify = false;
  bool canAddressModify = false;
  bool canEmailModify = false;
  bool canProfileImageModify = false;
}
