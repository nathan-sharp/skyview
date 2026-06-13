import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bluesky/bluesky.dart' as bsky;
import 'package:atproto/atproto.dart' as atp;

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bsky.Bluesky? session;
  final bool isLoading;
  final String? error;

  AuthState({this.session, this.isLoading = false, this.error});

  AuthState copyWith({
    bsky.Bluesky? session,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadSession();
    return AuthState();
  }

  Future<void> _loadSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final handle = prefs.getString('bsky_handle');
      final password = prefs.getString('bsky_password');

      if (handle != null && password != null) {
        await login(handle, password);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> login(String handle, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await atp.createSession(
        identifier: handle,
        password: password,
      );

      final bluesky = bsky.Bluesky.fromSession(session.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bsky_handle', handle);
      await prefs.setString('bsky_password', password);

      state = AuthState(session: bluesky, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bsky_handle');
    await prefs.remove('bsky_password');
    state = AuthState();
  }
}
