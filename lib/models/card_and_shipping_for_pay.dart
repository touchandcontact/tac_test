import 'package:tac/models/billing.dart';
import 'package:tac/models/payment_list_card.dart';

class CardShip{

  PaymentListCard? paymentListCard;
  BillingAddress? billingAddress;

  CardShip(
      this.billingAddress,
      this.paymentListCard
      );
}