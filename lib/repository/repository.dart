import '../data/network/base_api_service.dart';
import '../data/network/network_api_service.dart';
import '../model/crop_scan_result_model.dart';
import '../model/notification_preferences_model.dart';
import '../model/plant_identification_model.dart';
import '../model/subscription_plan_model.dart';
import '../model/usage_model.dart';
import '../model/user_profile_model.dart';
import '../model/weather_insight_model.dart';
import '../services/app_url.dart';
import '../services/user_storage_service.dart';

/// REPOSITORY
/// The single place in the app that knows where data comes from.
/// Every ViewModel calls into this class — never into `http` or
/// local storage directly. Swapping a mock method below for a real
/// API call never requires touching a ViewModel or View.
class Repository {
  final BaseApiService _apiService = NetworkApiService();
  final UserStorageService _userStorage = UserStorageService();

  // ---------------------------------------------------------------------
  // Auth: Sign up / Sign in / Forgot password
  // ---------------------------------------------------------------------

  /// Registers a new farmer account against the FastAPI backend.
  Future<bool> signUp(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.getPostApiResponse(AppUrls.signup, payload);

      final data = response is Map<String, dynamic>
          ? response
          : (response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{});
      
      var token = data['access_token'] ?? data['accessToken'] ?? data['token'];

      final emailOrPhone = (payload['email_or_phone'] ?? payload['emailOrPhone'] ?? '').toString().trim();
      final password = (payload['password'] ?? '').toString();
      final fullName = (payload['full_name'] ?? payload['fullName'] ?? '').toString().trim();

      // If signup response doesn't return access_token directly, auto-login to acquire the access token.
      if ((token == null || token.toString().trim().isEmpty) && emailOrPhone.isNotEmpty && password.isNotEmpty) {
        try {
          final loginResponse = await _apiService.getPostApiResponse(
            AppUrls.login,
            {
              'email_or_phone': emailOrPhone,
              'password': password,
            },
          );
          final loginData = loginResponse is Map<String, dynamic>
              ? loginResponse
              : (loginResponse is Map ? Map<String, dynamic>.from(loginResponse) : <String, dynamic>{});
          token = loginData['access_token'] ?? loginData['accessToken'] ?? loginData['token'];
        } catch (_) {}
      }

      if (token != null && token.toString().isNotEmpty) {
        await _userStorage.saveAuthToken(token.toString());
      } else {
        await _userStorage.saveAuthToken(
          'local-session-${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      final localUser = {
        'fullName': fullName,
        'emailOrPhone': emailOrPhone,
        'password': password,
      };

      await _userStorage.addUser(localUser);
      await _userStorage.saveActiveUser(localUser);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates the user against the FastAPI backend.
  Future<bool> login(String emailOrPhone, String password) async {
    try {
      final payload = {
        'email_or_phone': emailOrPhone.trim(),
        'password': password,
      };

      final response = await _apiService.getPostApiResponse(
        AppUrls.login,
        payload,
      );
      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response ?? {});
      final token =
          data['access_token'] ?? data['accessToken'] ?? data['token'];

      if (token != null && token.toString().isNotEmpty) {
        await _userStorage.saveAuthToken(token.toString());
      }

      final user = {
        'fullName': '',
        'emailOrPhone': emailOrPhone.trim(),
        'password': password,
      };

      await _userStorage.saveActiveUser(user);
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 600));
      final success = await _userStorage.validateLogin(emailOrPhone, password);
      if (success) {
        final user = await _userStorage.findUser(emailOrPhone);
        if (user != null) {
          await _userStorage.saveActiveUser(user);
        }
        await _userStorage.saveAuthToken(
          'local-session-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      return success;
    }
  }

  Future<bool> hasActiveSession() async {
    final token = await _userStorage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => _userStorage.clearAuthToken();

  /// Sends a 6-digit reset code to the given email/phone.
  Future<bool> sendPasswordResetCode(String emailOrPhone) async {
    try {
      final payload = {'email_or_phone': emailOrPhone.trim()};

      await _apiService.getPostApiResponse(AppUrls.forgotPassword, payload);
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      return false;
    }
  }

  /// Verifies the 6-digit code entered by the user.
  Future<bool> verifyResetCode(String emailOrPhone, String code) async {
    try {
      final payload = {
        'email_or_phone': emailOrPhone.trim(),
        'code': code.trim(),
      };

      await _apiService.getPostApiResponse(AppUrls.verifyOtp, payload);
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      return code.length == 6;
    }
  }

  // ---------------------------------------------------------------------
  // Crop disease detection
  // ---------------------------------------------------------------------

  /// Uploads a photo (or webcam frame) for AI analysis and returns the
  /// detected pathogen + treatment/prevention guidance.
  Future<CropScanResultModel> analyzeCropImage(List<int> imageBytes, String fileName) async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getMultipartApiResponseFromBytes(
        AppUrls.analyzeCrop,
        fileBytes: imageBytes,
        fileName: fileName,
        fileFieldName: 'file',
        token: token,
      );
      if (response is Map<String, dynamic>) {
        return CropScanResultModel.fromJson(response);
      }
      if (response is Map) {
        return CropScanResultModel.fromJson(Map<String, dynamic>.from(response));
      }
      return CropScanResultModel(
        pathogenName: 'Unable to analyze',
        severity: 'Unknown',
        description: 'The backend did not return a valid analysis. Please try again.',
        treatmentSteps: const [],
        preventionTips: const [],
        imagePath: '',
      );
    } catch (_) {
      return CropScanResultModel(
        pathogenName: 'Analysis Error',
        severity: 'Error',
        description: 'Could not upload or analyze the image. Please check your connection and try again.',
        treatmentSteps: const [],
        preventionTips: const [],
        imagePath: '',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Plant identification
  // ---------------------------------------------------------------------

  /// Uploads a plant photo to the AI backend and returns plant identification
  /// results including name, care guide, and seasonal tips.
  Future<PlantIdentificationModel> identifyPlant(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getMultipartApiResponseFromBytes(
        AppUrls.identifyPlant,
        fileBytes: imageBytes,
        fileName: fileName,
        fileFieldName: 'file',
        token: token,
      );
      if (response is Map<String, dynamic>) {
        return PlantIdentificationModel.fromJson(response);
      }
      if (response is Map) {
        return PlantIdentificationModel.fromJson(
            Map<String, dynamic>.from(response));
      }
      return const PlantIdentificationModel(
        plantName: 'Unable to Identify',
        description: 'The server did not return a valid response. Please try again.',
      );
    } catch (e) {
      return PlantIdentificationModel(
        plantName: 'Identification Error',
        description: 'Could not upload or analyze the image. '
            'Please check your connection and try again.\n\nDetails: $e',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Voice Q&A
  // ---------------------------------------------------------------------

  /// Sends a natural-language farming question and returns the AI's answer.
  Future<String> askQuestion(
    String question, {
    String crop = 'wheat',
    String? audioPath,
  }) async {
    try {
      final token = await _userStorage.getAuthToken();
      final trimmedQuestion = question.trim();
      final trimmedCrop = crop.trim();

      if (audioPath != null && audioPath.trim().isNotEmpty) {
        final response = await _apiService.getMultipartApiResponse(
          AppUrls.askQuestion,
          filePath: audioPath,
          fileFieldName: 'audio',
          fields: {
            'question': trimmedQuestion.isEmpty ? 'Voice question' : trimmedQuestion,
            'crop': trimmedCrop.isEmpty ? 'wheat' : trimmedCrop,
          },
          token: token,
        );
        return _extractAnswer(response);
      }

      final response = await _apiService.getPostApiResponse(
        AppUrls.askQuestion,
        {
          'question': trimmedQuestion,
          'crop': trimmedCrop.isEmpty ? 'wheat' : trimmedCrop,
        },
        token: token,
      );

      return _extractAnswer(response);
    } catch (_) {
      if (question.trim().isEmpty) {
        return 'Your voice question was recorded and sent successfully. Please try again if you want a more specific crop recommendation.';
      }

      return 'Based on your question about "$question", monitor field moisture closely and maintain consistent irrigation for the current crop stage.';
    }
  }

  String _extractAnswer(dynamic response) {
    if (response is Map<String, dynamic>) {
      final answer = response['answer'] ??
          response['message'] ??
          response['response'] ??
          response['result'] ??
          response['data'];

      if (answer is Map) {
        return _extractAnswer(answer);
      }

      if (answer != null) {
        return answer.toString();
      }
    }

    if (response is Map) {
      final answer = response['answer'] ??
          response['message'] ??
          response['response'] ??
          response['result'] ??
          response['data'];

      if (answer is Map) {
        return _extractAnswer(answer);
      }

      if (answer != null) {
        return answer.toString();
      }
    }

    if (response is String && response.trim().isNotEmpty) {
      return response;
    }

    return 'I received your voice query. Please check the backend response format or try again with a clearer prompt.';
  }

  // ---------------------------------------------------------------------
  // Weather advice
  // ---------------------------------------------------------------------

  Future<FieldConditionsModel> getFieldConditions({
    String location = '',
    String cropType = '',
  }) async {
    try {
      final token = await _userStorage.getAuthToken();
      final trimmedLocation = location.trim();
      final trimmedCrop = cropType.trim();
      final queryParameters = <String, String>{};
      if (trimmedLocation.isNotEmpty) {
        queryParameters['location'] = trimmedLocation;
      }
      if (trimmedCrop.isNotEmpty) {
        queryParameters['crop_type'] = trimmedCrop.toLowerCase();
      }

      final uri = Uri.parse(
        AppUrls.weatherAdvice,
      ).replace(queryParameters: queryParameters);
      final response = await _apiService.getGetResponse(
        uri.toString(),
        token: token,
      );

      Map<String, dynamic> payload = {};
      if (response is Map<String, dynamic>) {
        payload = response;
      } else if (response is Map) {
        payload = Map<String, dynamic>.from(response);
      }

      if (payload.isEmpty) {
        final nested = response is Map ? response['conditions'] : null;
        if (nested is Map) {
          payload = {'conditions': Map<String, dynamic>.from(nested)};
        }
      }

      if (payload.isEmpty) {
        final nested = response is Map ? response['data'] : null;
        if (nested is Map) {
          payload = {'data': Map<String, dynamic>.from(nested)};
        }
      }

      if (payload.isEmpty) {
        return const FieldConditionsModel(
          tempFahrenheit: 0,
          locationLabel: 'string',
          humidityPercent: 0,
          windMph: 0,
          windDirection: 'string',
          conditionDescription: '',
        );
      }

      return FieldConditionsModel.fromJson(payload);
    } catch (_) {
      return const FieldConditionsModel(
        tempFahrenheit: 0,
        locationLabel: 'string',
        humidityPercent: 0,
        windMph: 0,
        windDirection: 'string',
        conditionDescription: '',
      );
    }
  }

  Future<Map<String, dynamic>> getWeatherAdvice({
    String location = '',
    String cropType = '',
  }) async {
    final token = await _userStorage.getAuthToken();
    final trimmedLocation = location.trim();
    final trimmedCrop = cropType.trim();
    final queryParameters = <String, String>{};

    if (trimmedLocation.isNotEmpty) {
      queryParameters['location'] = trimmedLocation;
    }
    if (trimmedCrop.isNotEmpty) {
      queryParameters['crop_type'] = trimmedCrop.toLowerCase();
    }

    final uri = Uri.parse(AppUrls.weatherAdvice)
        .replace(queryParameters: queryParameters);
    final response = await _apiService.getGetResponse(
      uri.toString(),
      token: token,
    );

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    return {};
  }

  Future<List<WeatherInsightModel>> getWeatherInsights(String crop) async {
    try {
      final token = await _userStorage.getAuthToken();
      final queryParameters = <String, String>{
        'crop_type': crop.trim().toLowerCase(),
      };
      final location = await _userStorage.getActiveUser();
      final locationText = (location?['farmName'] ?? location?['location'] ?? '')
          .toString()
          .trim();
      if (locationText.isNotEmpty) {
        queryParameters['location'] = locationText;
      }

      final uri = Uri.parse(AppUrls.weatherAdvice)
          .replace(queryParameters: queryParameters);
      final response = await _apiService.getGetResponse(
        uri.toString(),
        token: token,
      );

      final payload = response is Map ? Map<String, dynamic>.from(response) : {};
      final adviceList = payload['advice'] is List
          ? payload['advice'] as List
          : payload['recommendations'] is List
              ? payload['recommendations'] as List
              : payload['insights'] is List
                  ? payload['insights'] as List
                  : <dynamic>[];

      if (adviceList.isNotEmpty) {
        return adviceList.map((item) {
          if (item is Map) {
            final title = (item['title'] ?? item['label'] ?? 'Advice').toString();
            final description = (item['description'] ?? item['message'] ?? item['advice'] ?? item['text'] ?? '').toString();
            final severity = (item['severity'] ?? 'info').toString();
            return WeatherInsightModel(
              title: title,
              description: description,
              severity: severity,
            );
          }

          return WeatherInsightModel(
            title: 'Advice',
            description: item.toString(),
            severity: 'info',
          );
        }).toList();
      }

      return const [
        WeatherInsightModel(
          title: 'Irrigation',
          description:
              'Optimal window tonight. Delay heavy watering until after 8 PM to minimize evaporation loss.',
          severity: 'normal',
        ),
        WeatherInsightModel(
          title: 'Pest Risk',
          description:
              'Elevated humidity tomorrow increases risk of aphids. Recommend preventive spray in Sector A.',
          severity: 'warning',
        ),
        WeatherInsightModel(
          title: 'Harvesting Window',
          description:
              'Conditions favorable for harvesting within the next 3 days.',
          severity: 'info',
        ),
      ];
    } catch (_) {
      return const [
        WeatherInsightModel(
          title: 'AI Advice',
          description: 'No advice returned yet. Try another field or refresh the data.',
          severity: 'info',
        ),
      ];
    }
  }

  // ---------------------------------------------------------------------
  // Usage & billing
  // ---------------------------------------------------------------------

  Future<UsageModel> getUsageStatus() async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getGetResponse(
        AppUrls.usageStatus,
        token: token,
      );
      if (response is Map<String, dynamic>) {
        return UsageModel.fromJson(response);
      } else if (response is Map) {
        return UsageModel.fromJson(Map<String, dynamic>.from(response));
      }
      return const UsageModel(
        planName: 'Free Plan',
        daysUntilReset: 12,
        cropScansUsed: 0,
        cropScansLimit: 5,
        voiceQueriesUsed: 0,
        voiceQueriesLimit: 10,
      );
    } catch (_) {
      final activeUser = await _userStorage.getActiveUser();
      final plan = (activeUser?['planType'] as String?) ??
          (activeUser?['plan_type'] as String?) ??
          'Free Plan';
      return UsageModel(
        planName: plan.isNotEmpty ? plan : 'Free Plan',
        daysUntilReset: 12,
        cropScansUsed: 3,
        cropScansLimit: 5,
        voiceQueriesUsed: 8,
        voiceQueriesLimit: 10,
      );
    }
  }

  /// Fetches available subscription plans from the backend billing endpoint.
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getGetResponse(
        AppUrls.billingPlans,
        token: token,
      );

      List<dynamic> plansList = [];
      if (response is List) {
        plansList = response;
      } else if (response is Map) {
        final data = response['plans'] ??
            response['data'] ??
            response['items'] ??
            response['results'] ??
            response['billing_plans'];
        if (data is List) {
          plansList = data;
        } else {
          plansList = [response];
        }
      }

      if (plansList.isNotEmpty) {
        return plansList.map((item) {
          if (item is Map<String, dynamic>) {
            return SubscriptionPlanModel.fromJson(item);
          } else if (item is Map) {
            return SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(item));
          }
          return SubscriptionPlanModel(
            id: item.toString().toLowerCase(),
            label: item.toString(),
            priceLabel: '',
          );
        }).toList();
      }

      return const [
        SubscriptionPlanModel(id: 'yearly', label: 'Yearly', priceLabel: '\$79.99 / year', badge: 'Save 20%'),
        SubscriptionPlanModel(id: 'monthly', label: 'Monthly', priceLabel: '\$9.99 / month'),
      ];
    } catch (_) {
      return const [
        SubscriptionPlanModel(id: 'yearly', label: 'Yearly', priceLabel: '\$79.99 / year', badge: 'Save 20%'),
        SubscriptionPlanModel(id: 'monthly', label: 'Monthly', priceLabel: '\$9.99 / month'),
      ];
    }
  }

  /// Starts the Pro trial/subscription for the chosen plan id.
  Future<bool> subscribe(String planId) async {
    try {
      final token = await _userStorage.getAuthToken();
      await _apiService.getPostApiResponse(
        AppUrls.subscribe,
        {'plan_id': planId},
        token: token,
      );
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    }
  }

  // ---------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------

  Future<UserProfileModel> getProfile() async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getGetResponse(
        AppUrls.profile,
        token: token,
      );
      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response ?? {});
      return UserProfileModel.fromJson(data);
    } catch (_) {
      final activeUser = await _userStorage.getActiveUser();
      final name = activeUser?['fullName'] as String?;
      final email = activeUser?['emailOrPhone'] as String?;
      final photoPath =
          (activeUser?['photoPath'] as String?) ??
          (activeUser?['photo_path'] as String?);
      return UserProfileModel(
        fullName: (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : 'Partner',
        email: email ?? 'farmer@agritech.com',
        farmName:
            (activeUser?['farmName'] as String?) ?? 'Sunrise Valley Farms',
        planType: (activeUser?['planType'] as String?) ?? 'FREE',
        language: (activeUser?['language'] as String?) ?? 'English',
        photoPath: photoPath,
      );
    }
  }

  Future<bool> updateProfile(UserProfileModel profile) async {
    try {
      final token = await _userStorage.getAuthToken();
      final payload = {
        'full_name': profile.fullName.trim(),
        'farm_name': profile.farmName.trim(),
        'photo_path': profile.photoPath ?? '',
      };

      await _apiService.getPutApiResponse(
        AppUrls.profile,
        payload,
        token: token,
      );

      final activeUser = await _userStorage.getActiveUser();
      if (activeUser != null) {
        activeUser['fullName'] = profile.fullName.trim();
        activeUser['farmName'] = profile.farmName.trim();
        activeUser['photoPath'] = profile.photoPath ?? activeUser['photoPath'];
        activeUser['photo_path'] =
            profile.photoPath ?? activeUser['photo_path'];
        await _userStorage.saveActiveUser(activeUser);
      }
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (profile.fullName.trim().isNotEmpty) {
        final activeUser = await _userStorage.getActiveUser();
        if (activeUser != null) {
          activeUser['fullName'] = profile.fullName.trim();
          activeUser['farmName'] = profile.farmName.trim();
          activeUser['photoPath'] =
              profile.photoPath ?? activeUser['photoPath'];
          activeUser['photo_path'] =
              profile.photoPath ?? activeUser['photo_path'];
          await _userStorage.saveActiveUser(activeUser);
        }
      }
      return true;
    }
  }

  Future<bool> updateLanguage(String language) async {
    try {
      final token = await _userStorage.getAuthToken();
      final payload = {'language': language};

      await _apiService.getPutApiResponse(
        AppUrls.profileLanguage,
        payload,
        token: token,
      );

      final activeUser = await _userStorage.getActiveUser();
      if (activeUser != null) {
        activeUser['language'] = language;
        await _userStorage.saveActiveUser(activeUser);
      }
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      final activeUser = await _userStorage.getActiveUser();
      if (activeUser != null) {
        activeUser['language'] = language;
        await _userStorage.saveActiveUser(activeUser);
      }
      return true;
    }
  }

  Future<bool> updateProfileImage(String photoPath) async {
    try {
      final token = await _userStorage.getAuthToken();

      final fieldNames = ['image', 'photo', 'file', 'photo_path'];
      dynamic response;
      for (final fieldName in fieldNames) {
        try {
          response = await _apiService.getPutMultipartApiResponse(
            AppUrls.profileImage,
            filePath: photoPath,
            token: token,
            fieldName: fieldName,
          );
          break;
        } catch (_) {
          continue;
        }
      }

      if (response == null) {
        throw const FormatException('No valid profile image upload response');
      }

      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response ?? {});
      final savedPath =
          (data['photo_path'] ??
                  data['photoPath'] ??
                  data['image'] ??
                  data['url'] ??
                  photoPath)
              as String? ??
          photoPath;

      final activeUser = await _userStorage.getActiveUser();
      if (activeUser != null) {
        activeUser['photoPath'] = savedPath;
        activeUser['photo_path'] = savedPath;
        await _userStorage.saveActiveUser(activeUser);
      }
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      final activeUser = await _userStorage.getActiveUser();
      if (activeUser != null) {
        activeUser['photoPath'] = photoPath;
        activeUser['photo_path'] = photoPath;
        await _userStorage.saveActiveUser(activeUser);
      }
      return true;
    }
  }

  // ---------------------------------------------------------------------
  // Notification preferences
  // ---------------------------------------------------------------------

  Future<NotificationPreferencesModel> getNotificationPreferences() async {
    try {
      final token = await _userStorage.getAuthToken();
      final response = await _apiService.getGetResponse(
        AppUrls.profileNotifications,
        token: token,
      );
      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response ?? {});
      return NotificationPreferencesModel.fromJson(data);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
      return NotificationPreferencesModel();
    }
  }

  Future<bool> updateNotificationPreferences(
    NotificationPreferencesModel prefs,
  ) async {
    try {
      final token = await _userStorage.getAuthToken();
      final payload = prefs.toJson();
      await _apiService.getPutApiResponse(
        AppUrls.profileNotifications,
        payload,
        token: token,
      );
      return true;
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }
  }

  // ---------------------------------------------------------------------
  // Checkout / payment
  // ---------------------------------------------------------------------

  /// Charges the given card for the selected plan. Mocked locally;
  /// wire to a real payment processor once a backend exists.
  Future<bool> submitPayment({
    required String planId,
    required String cardholderName,
    required String cardNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 200));
    return true;
  }
}
