import 'package:flutter/foundation.dart';
import '../../model/subscription_plan_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns the plan selection (yearly/monthly) and the subscribe() action
/// for the "Go Pro" paywall.
class GoProViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  bool isSubscribing = false;

  List<SubscriptionPlanModel> plans = const [
    SubscriptionPlanModel(id: 'yearly', label: 'Yearly', priceLabel: '\$79.99 / year', badge: 'Save 20%'),
    SubscriptionPlanModel(id: 'monthly', label: 'Monthly', priceLabel: '\$9.99 / month'),
  ];

  String selectedPlanId = 'yearly';

  GoProViewModel() {
    loadPlans();
  }

  Future<void> loadPlans() async {
    isLoading = true;
    notifyListeners();

    try {
      final loadedPlans = await _repository.getSubscriptionPlans();
      if (loadedPlans.isNotEmpty) {
        plans = loadedPlans;
        if (!plans.any((p) => p.id == selectedPlanId)) {
          selectedPlanId = plans.first.id;
        }
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectPlan(String id) {
    selectedPlanId = id;
    notifyListeners();
  }

  Future<bool> startFreeTrial() async {
    isSubscribing = true;
    notifyListeners();

    final success = await _repository.subscribe(selectedPlanId);

    isSubscribing = false;
    notifyListeners();
    return success;
  }
}
