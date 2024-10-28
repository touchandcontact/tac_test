import 'package:flutter/material.dart';
import '../../models/user_edit.dart';
import '../inputs/input_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoUserWidget extends StatelessWidget {
  final UserEditModel userInfoModel;

  const InfoUserWidget({Key? key, required this.userInfoModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputText(
            label: AppLocalizations.of(context)!.telephone,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.telephone ?? ""),
        const SizedBox(
          height: 8,
        ),
        _returnListTelephone(context),
        InputText(
            label: AppLocalizations.of(context)!.address,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.address ?? ""),
        const SizedBox(
          height: 8,
        ),
        _returnListAddress(context),
        InputText(
            label: AppLocalizations.of(context)!.email,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.email ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.website,
            keyboardType: TextInputType.url,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.website ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.company,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.companyName ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.p_iva,
            onChange: (String val) {},
            enabled: false,
            initalValue: userInfoModel.userDTO.vat ?? ""),
      ],
    );
  }

  _returnListAddress(context) {
    return userInfoModel.userAddressDTO != null &&
            userInfoModel.userAddressDTO.isNotEmpty
        ? Column(children: List<Widget>.generate(
            userInfoModel.userAddressDTO.length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InputText(
                  label: "${AppLocalizations.of(context)!.address} ${index+2}",
                  onChange: (String val) {},
                  enabled: false,
                  initalValue:
                      userInfoModel.userAddressDTO[index].address ?? ""),
            )).toList())
        : Container();
  }

  _returnListTelephone(context) {
    return userInfoModel.userTelephoneDTO != null &&
            userInfoModel.userTelephoneDTO.isNotEmpty
        ? Column(
            children: List<Widget>.generate(
                userInfoModel.userTelephoneDTO.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InputText(
                      label: "${AppLocalizations.of(context)!.telephone} ${index+2}",
                      onChange: (String val) {},
                      enabled: false,
                      initalValue:
                          userInfoModel.userTelephoneDTO[index].telephone ??
                              ""),
                )).toList())
        : Container();
  }
}
