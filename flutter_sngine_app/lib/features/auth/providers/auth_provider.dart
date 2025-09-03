import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/dio_provider.dart';

// Auth State
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    String? accessToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SharedPreferences _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AuthNotifier(this._apiService, this._prefs) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken != null) {
        // Verify token with server
        final response = await _apiService.refreshSession(accessToken);
        if (response.isSuccess && response.data != null) {
          state = state.copyWith(
            isAuthenticated: true,
            user: response.data,
            accessToken: accessToken,
            isLoading: false,
          );
          return;
        }
      }
    } catch (e) {
      // Token invalid or expired
      await logout();
    }
    
    state = state.copyWith(isLoading: false);
  }

  Future<bool> login(String usernameEmail, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.login(usernameEmail, password);
      
      if (response.isSuccess && response.data != null) {
        // Store credentials securely
        await _secureStorage.write(key: 'access_token', value: 'generated_token'); // You'll need to modify Sngine to return tokens
        await _prefs.setString('user_data', response.data!.toJson().toString());
        
        state = state.copyWith(
          isAuthenticated: true,
          user: response.data,
          accessToken: 'generated_token',
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.register(
        firstName,
        lastName,
        username,
        email,
        password,
      );
      
      if (response.isSuccess && response.data != null) {
        // Auto-login after successful registration
        return await login(email, password);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    // Clear stored credentials
    await _secureStorage.delete(key: 'access_token');
    await _prefs.remove('user_data');
    
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(apiService, prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});