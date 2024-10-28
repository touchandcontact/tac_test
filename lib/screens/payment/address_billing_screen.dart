import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../components/inputs/input_text.dart';
import '../../extentions/hexcolor.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/toast_helper.dart';
import '../../models/billing.dart';
import '../../models/shipping.dart';
import '../../services/billing_service.dart';

class AddressBillingScreen extends StatefulWidget {
  BillingAddress? billingAddress;
  int tacUserId;
  bool isMod;

  AddressBillingScreen({Key? key, this.billingAddress,required this.tacUserId, this.isMod = false}) : super(key: key);

  @override
  State<AddressBillingScreen> createState() => _AddressBillingScreenState();
}

class _AddressBillingScreenState extends State<AddressBillingScreen> {
  final formKey = GlobalKey<FormState>();
  final _formInfoSpedizioneKey = GlobalKey<FormState>();
  final formKeyTitolare = GlobalKey<FormState>();
  Color color = HexColor.fromHex(Hive.box("settings").get("color").toString());
  final ValueNotifier<bool> _autoCompleteBilling = ValueNotifier(false);
  final _country = TextEditingController();
  final BillingAddress _billingAddress = BillingAddress();
  ShippingAddress shippingAddress = ShippingAddress();

  @override
  void initState() {
    if(widget.isMod) {
      _country.text = widget.billingAddress!.country!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(AppLocalizations.of(context)!.billing,
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme
                        .of(context)
                        .textTheme
                        .headline1!
                        .color)),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(8.8, 0, 0, 0),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme
                      .of(context)
                      .secondaryHeaderColor,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20.0, 0, 20.0, 0.0),
                    child: widget.isMod ? shippingBillingFormEdit(
                        widget.billingAddress) : shippingBillingFormNew(),
                  )))),
    );
  }

  ///gestione aggiunta nuova fatturazione
  Widget shippingBillingFormNew() {
    return SingleChildScrollView(
        child: Column(
          children: [
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                      key: formKey,
                      child: Column(children: [
                        const SizedBox(height: 30),
                        Row(children: [
                          Text(AppLocalizations.of(context)!.infoBilling,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                  fontWeight: FontWeight.w600))
                        ]),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.nominative,
                            initalValue: _billingAddress.nominative,
                            onChange: (e) => _billingAddress.nominative = e),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.billingAddress,
                            initalValue: _billingAddress.address,
                            onChange: (e) => _billingAddress.address = e,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.country,
                            initalValue: _billingAddress.country,
                            onChange: (e) => _billingAddress.country = e,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.cap,
                            initalValue: _billingAddress.cap,
                            keyboardType: TextInputType.number,
                            onChange: (e) =>
                            _billingAddress.cap = e.toString(),
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.city,
                            initalValue: _billingAddress.city,
                            onChange: (e) => _billingAddress.city = e,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.province,
                            initalValue: _billingAddress.province,
                            onChange: (e) {
                              _billingAddress.province = e;
                            },
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.number,
                            initalValue: _billingAddress.number,
                            keyboardType: TextInputType.number,
                            onChange: (e) =>
                            _billingAddress.number = e.toString(),
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label:AppLocalizations.of(context)!.uniqueCode,
                            initalValue: _billingAddress.uniqueCode,
                            onChange: (e) => _billingAddress.uniqueCode = e),
                        const SizedBox(height: 10),
                        InputText(
                            label:AppLocalizations.of(context)!.vat,
                            initalValue: _billingAddress.vat,
                            onChange: (e) => _billingAddress.vat = e),
                        const SizedBox(height: 10),
                        InputText(
                            label:AppLocalizations.of(context)!.businessName,
                            initalValue: _billingAddress.businessName,
                            onChange: (e) => _billingAddress.businessName = e),
                        const SizedBox(height: 10),
                      ])),
                  ValueListenableBuilder<bool>(
                      valueListenable: _autoCompleteBilling,
                      builder: (context, value, child) =>
                          Row(
                            children: [
                              Checkbox(
                                value: _autoCompleteBilling.value,
                                checkColor: color.computeLuminance() > 0.5
                                    ? Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText2!
                                    .color
                                    : Colors.white,
                                fillColor: MaterialStateProperty.all(color),
                                shape: const CircleBorder(),
                                onChanged: (value) {
                                  _autoCompleteBilling.value = value!;
                                },
                              ),
                              Expanded(
                                  child:
                                  Text(AppLocalizations.of(context)!.shippingLikeBilling))
                            ],
                          )),
                  Divider(height: 5, color: Theme
                      .of(context)
                      .backgroundColor),
                  ValueListenableBuilder(
                    valueListenable: _autoCompleteBilling,
                    builder: (context, value, child) =>
                    value
                        ? const SizedBox()
                        : Form(
                      key: _formInfoSpedizioneKey,
                      child: Column(children: [
                        const SizedBox(height: 30),
                        Row(children: [
                          Text(AppLocalizations.of(context)!.infoShipping,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .headline1!
                                      .color,
                                  fontWeight: FontWeight.w600))
                        ]),
                        const SizedBox(height: 10),
                        InputText(
                            label:AppLocalizations.of(context)!.nominative,
                            initalValue: _billingAddress.nominative,
                            onChange: (e) => _billingAddress.nominative = e),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.addressShipping,
                            onChange: (e) => shippingAddress.address = e,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }

                              return null;
                            }),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            InputText(
                                label: AppLocalizations.of(context)!.country,
                                enabled: false,
                                controller: _country,
                                onChange: (e) =>
                                    () {
                                  _country.text = e;
                                  shippingAddress.country = e;
                                },
                                validator: (value) {
                                  if (value == null || value == "") {
                                    return AppLocalizations.of(context)!
                                        .requiredField;
                                  }
                                  return null;
                                }),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child:  IconButton(
                                onPressed: () {
                                  showCountryPicker(
                                    favorite: <String>['IT'],
                                    context: context,
                                    showPhoneCode: false,
                                    onSelect: (Country country) {
                                      _country.text = country.countryCode;
                                      shippingAddress.country =
                                          country.countryCode;
                                    },
                                    // Optional. Sets the theme for the country list picker.
                                    countryListTheme: CountryListThemeData(
                                      backgroundColor:
                                      Theme
                                          .of(context)
                                          .backgroundColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(40.0),
                                        topRight: Radius.circular(40.0),
                                      ),
                                      // Optional. Styles the search field.
                                      inputDecoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!.find,
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: const Color(0xFF8C98A8)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                      // Optional. Styles the text in the search field
                                      searchTextStyle: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.manage_search),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.cap,
                            initalValue: shippingAddress.cap,
                            keyboardType: TextInputType.number,
                            onChange: (e) => shippingAddress.cap = e.toString(),
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            }),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.city,
                            initalValue: shippingAddress.city,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                            onChange: (e) => shippingAddress.city = e),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.province,
                            initalValue: shippingAddress.province,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                            onChange: (e) => shippingAddress.province = e),
                        const SizedBox(height: 10),
                        InputText(
                            label: AppLocalizations.of(context)!.number,
                            initalValue: shippingAddress.number,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!
                                    .requiredField;
                              }
                              return null;
                            },
                            onChange: (e) =>
                            shippingAddress.number = e.toString()),
                        const SizedBox(height: 10)
                      ]),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 270,
                        child: TextButton(
                            onPressed: saveNew,
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    color),
                                side: MaterialStateProperty.all(
                                    BorderSide(width: 1.0, color: color)),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.fromLTRB(20, 20, 20, 20)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(15),
                                            right: Radius.circular(15))))),
                            child: Text(
                              AppLocalizations.of(context)!.add,
                              style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  )
                ]),
          ],
        ));
  }

  Future saveNew() async {
    try {
      if (formKey.currentState!.validate() &&
          (_autoCompleteBilling.value ||
              (!_autoCompleteBilling.value &&
                  _formInfoSpedizioneKey.currentState!.validate()))) {
        showLoadingDialog(context);
        shippingAddress.userId = widget.tacUserId;
        shippingAddress.companyId = null;
        shippingAddress.nominative = shippingAddress.nominative ?? "-";
        _billingAddress.userId = widget.tacUserId;
        _billingAddress.nominative = _billingAddress.nominative ?? "-";
        _billingAddress.shipmentAddressId = 0;
        _billingAddress.vat = _billingAddress.vat ?? "-";
        _billingAddress.uniqueCode = _billingAddress.uniqueCode ?? "-";
        _billingAddress.businessName = _billingAddress.businessName ?? "-";
        _billingAddress.id = 0;
        return await insertBilling(_autoCompleteBilling.value ? null : shippingAddress,
            _billingAddress)
            .then((value) {
          Navigator.pop(context);
          showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        })
            .then((value) => Navigator.pop(context,true));
      } else {
        showErrorToast(AppLocalizations.of(context)!.missedFields);
      }
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
    return Future.value();
  }

  ///modifica info fatturazione
  Widget shippingBillingFormEdit(BillingAddress? billing) {
    return SingleChildScrollView(
        child: Column(
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              Form(
                  key: formKey,
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Row(children: [
                      Text(AppLocalizations.of(context)!.infoBilling,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .headline1!
                                  .color,
                              fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.nominative,
                        initalValue: billing?.nominative,
                        onChange: (e) => billing?.nominative = e),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.billingAddress,
                        initalValue: billing?.address,
                        onChange: (e) => billing?.address = e,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.country,
                        initalValue: billing?.country,
                        onChange: (e) => billing?.country = e,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.cap,
                        initalValue: billing?.cap,
                        keyboardType: TextInputType.number,
                        onChange: (e) => billing?.cap = e.toString(),
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.city,
                        initalValue: billing?.city,
                        onChange: (e) => billing?.city = e,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.province,
                        initalValue: billing?.province,
                        onChange: (e) => billing?.province = e,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.number,
                        initalValue: billing?.number,
                        keyboardType: TextInputType.number,
                        onChange: (e) => billing?.number = e.toString(),
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!
                                .requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label:AppLocalizations.of(context)!.uniqueCode,
                        initalValue: billing?.uniqueCode,
                        onChange: (e) => billing?.uniqueCode = e),
                    const SizedBox(height: 10),
                    InputText(
                        label:AppLocalizations.of(context)!.vat,
                        initalValue: billing?.vat,
                        onChange: (e) => billing?.vat = e),
                    const SizedBox(height: 10),
                    InputText(
                        label:AppLocalizations.of(context)!.businessName,
                        initalValue: billing?.businessName,
                        onChange: (e) => billing?.businessName = e),
                    const SizedBox(height: 10),
                  ])),
              ValueListenableBuilder<bool>(
                  valueListenable: _autoCompleteBilling,
                  builder: (context, value, child) =>
                      Row(
                        children: [
                          Checkbox(
                            value: _autoCompleteBilling.value,
                            checkColor: color.computeLuminance() > 0.5
                                ? Theme
                                .of(context)
                                .textTheme
                                .bodyText2!
                                .color
                                : Colors.white,
                            fillColor: MaterialStateProperty.all(color),
                            shape: const CircleBorder(),
                            onChanged: (value) {
                              _autoCompleteBilling.value = value!;
                            },
                          ),
                          Expanded(
                              child: Text(
                                  AppLocalizations.of(context)!.shippingLikeBilling))
                        ],
                      )),
              Divider(height: 5, color: Theme
                  .of(context)
                  .backgroundColor),
              ValueListenableBuilder(
                valueListenable: _autoCompleteBilling,
                builder: (context, value, child) =>
                value
                    ? const SizedBox()
                    : Form(
                  key: _formInfoSpedizioneKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Text(AppLocalizations.of(context)!.infoShipping,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .headline1!
                                  .color,
                              fontWeight: FontWeight.w600))
                    ]),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.nominative,
                        initalValue: billing?.shipmentAddress?.nominative,
                        onChange: (e) =>
                        billing?.shipmentAddress?.nominative = e),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.addressShipping,
                        initalValue: billing?.shipmentAddress?.address,
                        onChange: (e) => billing?.shipmentAddress?.address = e,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!.requiredField;
                          }

                          return null;
                        }),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        InputText(
                            label: AppLocalizations.of(context)!.country,
                            enabled: false,
                            controller: _country,
                            onChange: (e) {
                              _country.text = e;
                              billing?.shipmentAddress?.country = e;
                            },
                            validator: (value) {
                              if (value == null || value == "") {
                                return AppLocalizations.of(context)!.requiredField;
                              }
                              return null;
                            }),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child:  IconButton(
                            onPressed: () {
                              showCountryPicker(
                                favorite: <String>['IT'],
                                context: context,
                                showPhoneCode: false,
                                onSelect: (Country country) {
                                  _country.text = country.countryCode;
                                  billing?.shipmentAddress?.country =
                                      country.countryCode;
                                },
                                // Optional. Sets the theme for the country list picker.
                                countryListTheme: CountryListThemeData(
                                  backgroundColor: Theme
                                      .of(context)
                                      .backgroundColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(40.0),
                                    topRight: Radius.circular(40.0),
                                  ),
                                  // Optional. Styles the search field.
                                  inputDecoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.find,
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                        const Color(0xFF8C98A8).withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                  // Optional. Styles the text in the search field
                                  searchTextStyle: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.manage_search),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.cap,
                        initalValue: billing?.shipmentAddress?.cap,
                        keyboardType: TextInputType.number,
                        onChange: (e) =>
                        billing?.shipmentAddress?.cap = e.toString(),
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        }),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.city,
                        initalValue: billing?.shipmentAddress?.city,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                        onChange: (e) => billing?.shipmentAddress?.city = e),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.province,
                        initalValue: billing?.shipmentAddress?.province,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                        onChange: (e) =>
                        billing?.shipmentAddress?.province = e),
                    const SizedBox(height: 10),
                    InputText(
                        label: AppLocalizations.of(context)!.number,
                        initalValue: billing?.shipmentAddress?.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2)
                        ],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value == "") {
                            return AppLocalizations.of(context)!.requiredField;
                          }
                          return null;
                        },
                        onChange: (e) =>
                        billing?.shipmentAddress?.number = e.toString()),
                   const SizedBox(height: 10)
                  ]),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 270,
                    child: TextButton(
                        onPressed: () => editAddress(billing),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(color),
                            side: MaterialStateProperty.all(
                                BorderSide(width: 1.0, color: color)),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.fromLTRB(20, 20, 20, 20)),
                            shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(15),
                                        right: Radius.circular(15))))),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              )
            ]),
          ],
        ));
  }

  Future editAddress(BillingAddress? billing) async {
    try {
      if (formKey.currentState!.validate() &&
          (_autoCompleteBilling.value ||
              (!_autoCompleteBilling.value &&
                  _formInfoSpedizioneKey.currentState!.validate()))) {
        showLoadingDialog(context);
        billing?.shipmentAddress?.nominative = billing.shipmentAddress?.nominative ?? "-";
        billing?.shipmentAddress?.userId = widget.tacUserId;
        billing?.shipmentAddress?.companyId = null;
        billing?.shipmentAddressId = billing.shipmentAddress?.id;
        billing?.nominative = billing.nominative ?? "-";
        billing?.vat = billing.vat ?? "-";
        billing?.businessName = billing.businessName ?? "-";
        billing?.uniqueCode = billing.uniqueCode ?? "-";

        return await updateBilling(
            _autoCompleteBilling.value ? null : billing!.shipmentAddress!,
            billing!)
            .then((value) {
          Navigator.pop(context);
          showSuccessToast(AppLocalizations.of(context)!.operationComplete);
        })
            .then((value) => Navigator.pop(context,true));
      } else {
        showErrorToast(AppLocalizations.of(context)!.missedFields);
      }
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
    return Future.value();
  }
}
