import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/github_api_service.dart';

class SettingsController extends GetxController {
  final token = ''.obs;
  final isValidating = false.obs;
  final isValid = false.obs;
  final userName = ''.obs;
  final userAvatar = ''.obs;
  final errorMessage = ''.obs;

  static const _tokenKey = 'github_pat';

  final _apiService = GitHubApiService();

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      _apiService.configure(savedToken);
      await validateToken();
    }
  }

  Future<void> saveToken(String newToken) async {
    token.value = newToken;
    _apiService.configure(newToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    await validateToken();
  }

  Future<void> validateToken() async {
    if (token.value.isEmpty) {
      isValid.value = false;
      return;
    }

    isValidating.value = true;
    errorMessage.value = '';

    try {
      final user = await _apiService.validateToken();
      userName.value = user['login'] as String? ?? '';
      userAvatar.value = user['avatar_url'] as String? ?? '';
      isValid.value = true;
    } catch (e) {
      isValid.value = false;
      errorMessage.value = 'Invalid token: ${e.toString()}';
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> clearToken() async {
    token.value = '';
    isValid.value = false;
    userName.value = '';
    userAvatar.value = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
