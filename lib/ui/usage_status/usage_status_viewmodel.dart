import 'package:flutter/foundation.dart';
import '../../model/usage_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Loads the current billing-cycle usage breakdown shown on the
/// "Your Usage" screen.
class UsageStatusViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  UsageModel? usage;

  UsageStatusViewModel() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    usage = await _repository.getUsageStatus();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _load();
  }
}
