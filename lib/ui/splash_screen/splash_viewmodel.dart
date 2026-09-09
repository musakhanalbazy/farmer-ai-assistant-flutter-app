import 'package:flutter/foundation.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Checks for an existing local session and reports where the View
/// should navigate next — the View owns the actual navigation call.
class SplashViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  Future<String> resolveStartRoute() async {
    final hasSession = await _repository.hasActiveSession();
    return hasSession ? '/home' : '/onboarding';
  }
}
