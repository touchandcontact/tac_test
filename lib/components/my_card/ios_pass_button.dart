import 'dart:convert';
import 'dart:io';
import 'package:add_to_wallet/widgets/add_to_wallet_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../helpers/dialog_helper.dart';
import '../../helpers/toast_helper.dart';
import '../../screens/profile/became_premium.dart';
import '../../services/vcard_service.dart';

class IosPassButton extends StatefulWidget {
  final int cardId;
  final bool isFree;

  const IosPassButton({Key? key, required this.cardId, this.isFree = true})
      : super(key: key);

  @override
  State<IosPassButton> createState() => _IosPassButtonState();
}

class _IosPassButtonState extends State<IosPassButton> {
  List<int>? _pkPassData = [];

  @override
  void initState() {
    loadAppleWallet();
    super.initState();
  }

  loadAppleWallet() async {
    try {
      var response = await createAppleWalletById(widget.cardId);
      setState(() {
        _pkPassData = convertFileInListInt(response);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((_pkPassData != null && _pkPassData!.isNotEmpty)) {
      if (widget.isFree) {
        return Stack(children: [
          GestureDetector(
            onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BecamePremium()));
              },
              child: Container(
                color: Colors.transparent,
                  width: MediaQuery.of(context).size.width * 0.65, height: 50)),
          IgnorePointer(
              ignoring: true,
              child: AddToWalletButton(
                  pkPass: _pkPassData!,
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 50,
                  unsupportedPlatformChild: GestureDetector(
                    onTap: () {
                      createItemAppleWallet(widget.cardId);
                    },
                    child: SvgPicture.asset(
                      "assets/images/IT_Add_to_Apple_Wallet_RGB_101821.svg",
                      height: 68,
                    ),
                  )))
        ]);
      } else {
        return AddToWalletButton(
            pkPass: _pkPassData!,
            width: MediaQuery.of(context).size.width * 0.65,
            height: 50,
            unsupportedPlatformChild: GestureDetector(
              onTap: () {
                createItemAppleWallet(widget.cardId);
              },
              child: SvgPicture.asset(
                "assets/images/IT_Add_to_Apple_Wallet_RGB_101821.svg",
                height: 68,
              ),
            ));
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  createItemAppleWallet(int idCard) async {
    showLoadingDialog(context);
    try {
      String response = "";
      response = await createAppleWallet(idCard);
      _pkPassData = convertFileInListInt(response);
      if (!mounted) return;
      Navigator.pop(context);
      File passFile = await writePassFile();
      Share.shareXFiles([XFile(passFile.path)]);
    } catch (e) {
      showErrorToast(AppLocalizations.of(context)!.error);
      Navigator.pop(context);
    }
  }

  convertFileInListInt(String value) {
    return base64Decode(value.replaceAll("\"", ""));
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localPassFile async {
    final path = await _localPath;
    return File('$path/pass.pkpass');
  }

  Future<File> writePassFile() async {
    final file = await _localPassFile;
    return file.writeAsBytes(_pkPassData!);
  }
}
