import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tac/screens/profile/free.dart';
import 'package:tac/screens/profile/premium.dart';
import 'package:tac/services/account_service.dart';
import '../../components/appbars/free_profile_appbar.dart';
import '../../components/appbars/premium_profile_appbar.dart';
import '../../models/user.dart';

class Profile extends StatefulWidget {
   Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> with WidgetsBindingObserver {
  User user = User.fromJson(jsonDecode(Hive.box("settings").get("user")));

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && user.company != null) {
      var vb = await getVirtualBackground(user.tacUserId);
      user.coverImage = vb.image;
      await Hive.box("settings").put("user", jsonEncode(user.toJson()));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  PreferredSizeWidget getAppBar() {
    if ((user.subscriptionType != null && user.subscriptionType == 2) ||
        user.isCompanyPremium) {
      return const PremiumProfileAppbar(height: 150);
    } else {
      return const FreeProfileAppbar(height: 150);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: getAppBar(),
        body: ((user.subscriptionType != null && user.subscriptionType == 2) ||
                user.isCompanyPremium)
            ?  const PremiumProfile()
            :  const FreeProfile());
  }
}
