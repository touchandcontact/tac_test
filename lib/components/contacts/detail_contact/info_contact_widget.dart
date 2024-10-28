import 'package:flutter/material.dart';

import '../../../models/user_contact_info_model.dart';
import '../../inputs/input_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoContactWidget extends StatelessWidget {
  final UserContactInfoModel userContact;

  const InfoContactWidget({Key? key, required this.userContact})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputText(
            label: AppLocalizations.of(context)!.telephone,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.telephone ?? ""),
        const SizedBox(
          height: 8,
        ),
        _returnListTelephone(context),
        InputText(
            label: AppLocalizations.of(context)!.address,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.address ?? ""),
        const SizedBox(
          height: 8,
        ),
        _returnListAddress(context),
        InputText(
            label: AppLocalizations.of(context)!.email,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.email ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.website,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.website ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.company,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.company ?? ""),
        const SizedBox(
          height: 8,
        ),
        InputText(
            label: AppLocalizations.of(context)!.p_iva,
            onChange: (String val) {},
            enabled: false,
            initalValue: userContact.vat ?? ""),
      ],
    );
  }

  _returnListAddress(context) {
    return userContact.addresses != null && userContact.addresses!.isNotEmpty
        ? Column(
            children: List<Widget>.generate(
                userContact.addresses!.length,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InputText(
                      label: "${AppLocalizations.of(context)!.address} ${index+2}",
                      onChange: (String val) {},
                      enabled: false,
                      initalValue:
                          userContact.addresses![index].address ?? ""),
                )).toList())
        : Container();
  }

  _returnListTelephone(context) {
    return userContact.telephones != null && userContact.telephones!.isNotEmpty
        ? Column(children: List<Widget>.generate(
            userContact.telephones!.length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InputText(
                  label: "${AppLocalizations.of(context)!.telephone} ${index+2}",
                  onChange: (String val) {},
                  enabled: false,
                  initalValue:
                      userContact.telephones![index].telephone ?? ""),
            )).toList())
        : Container();
  }
}
