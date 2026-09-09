import 'package:flutter/foundation.dart';
import '../../model/subscription_plan_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns the plan being purchased and the submitPayment() action for
/// the Checkout screen reached from "Go Pro".
class CheckoutPaymentViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isProcessing = false;
  String? errorMessage;

  /// The plan being checked out. Defaults to the monthly Pro plan;
  /// swap via [setPlan] when arriving from a specific plan selection.
  SubscriptionPlanModel plan = const SubscriptionPlanModel(
    id: 'monthly',
    label: 'Pro Plan',
    priceLabel: '\$9.99 / mo',
  );

  void setPlan(SubscriptionPlanModel newPlan) {
    plan = newPlan;
    notifyListeners();
  }

  Future<bool> submitPayment({required String cardholderName, required String cardNumber}) async {
    isProcessing = true;
    errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      success = await _repository.submitPayment(
        planId: plan.id,
        cardholderName: cardholderName,
        cardNumber: cardNumber,
      );
    } catch (_) {
      errorMessage = 'Payment could not be processed. Please try again.';
    }

    isProcessing = false;
    notifyListeners();
    return success;
  }
}
