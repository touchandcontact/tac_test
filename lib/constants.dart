abstract class Constants {
  // static const String apiUrl = String.fromEnvironment('API_URL',
  //     defaultValue: 'https://typically-on-starfish.ngrok-free.app/api');
  // static const String shareUrl = String.fromEnvironment('SHARE_URL',
  //     defaultValue: "https://tac2-test-user.azurewebsites.net/SharedContact");
  // static const String stripePublicKey = String.fromEnvironment(
  //     "STRIPE_PUBLIC_KEY",
  //     defaultValue:
  //         "pk_test_51MAVSOKZDJAxIsT3pc8F6vUAWUcmKR8HFhiWLF6yd6tqbfVa2i6NOk0lLXXLhmTJMq0MtftJ5Mfq4n7NaX8bJv1j0092D7VHcI");
  // static const String stripePrivateKey = String.fromEnvironment(
  //     "STRIPE_PRIVATE_KEY",
  //     defaultValue:
  //         "sk_test_51MAVSOKZDJAxIsT3AKZyCQRwnjtkubKnKL0HnDEALVAn7E6fRbTGUVUCnwVumb7eGvSyB0tQrQQfR2pnuUe4NsPL006CNQU6DV");
  // static const String orderCardUrl = String.fromEnvironment("ORDER_CARD_URL",
  //     defaultValue:
  //         "https://touchandcontact.com/pages/biglietti-visita-nfc-qr-code");
  //
  // static const String appleLoginUrl = String.fromEnvironment("APPL_LOGIN_URL",
  //     defaultValue:
  //         "https://tac2-test-user.azurewebsites.net/signinwithapplemobile");
  //
  // static const bool isTestEnv = true;

  static const String apiUrl = String.fromEnvironment('API_URL',
      defaultValue: 'https://tac2-test-api.azurewebsites.net/api'
  );
  static const String shareUrl = String.fromEnvironment('SHARE_URL',
      defaultValue: "https://tac2-test-user.azurewebsites.net/SharedContact");
  static const String stripePublicKey = String.fromEnvironment(
      "STRIPE_PUBLIC_KEY",
      defaultValue:
      "pk_test_51MAVSOKZDJAxIsT3pc8F6vUAWUcmKR8HFhiWLF6yd6tqbfVa2i6NOk0lLXXLhmTJMq0MtftJ5Mfq4n7NaX8bJv1j0092D7VHcI");
  static const String stripePrivateKey = String.fromEnvironment(
      "STRIPE_PRIVATE_KEY",
      defaultValue:
      "sk_test_51MAVSOKZDJAxIsT3AKZyCQRwnjtkubKnKL0HnDEALVAn7E6fRbTGUVUCnwVumb7eGvSyB0tQrQQfR2pnuUe4NsPL006CNQU6DV");
  static const String orderCardUrl = String.fromEnvironment("ORDER_CARD_URL",
      defaultValue: "https://touchandcontact.com/pages/biglietti-visita-nfc-qr-code");

  static const String appleLoginUrl = String.fromEnvironment("APPL_LOGIN_URL",
      defaultValue: "https://tac2-test-user.azurewebsites.net/signinwithapplemobile");
  static const bool isTestEnv = false;

  static const Map<int, dynamic> languageSelected = {
    0: "it",
    1: "gb-eng"
    // 2: "fr",
    // 3: "es",
    // 4: "de"
  };

  static const String url = '';
  static const String privacyUrl =
      'https://tac2-test-user.azurewebsites.net/privacy-policy';
  static const String alreadyExistSwapContact = "CONTACT_ALREADY_PRESENT";
  static const String twilioSid = "REDACTED";
  static const String twilioAuthToken = "REDACTED";
  static const String twilioNumber = "REDACTED";
}
