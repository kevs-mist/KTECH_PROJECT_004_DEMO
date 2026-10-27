import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthFormState {
  final String email;

  const AuthFormState({this.email = ''});

  AuthFormState copyWith({String? email}) {
    return AuthFormState(
      email: email ?? this.email,
    );
  }
}

class AuthFormStateNotifier extends StateNotifier<AuthFormState> {
  AuthFormStateNotifier() : super(const AuthFormState());

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void clear() {
    state = const AuthFormState();
  }
}

final authFormStateProvider =
    StateNotifierProvider<AuthFormStateNotifier, AuthFormState>((ref) {
  return AuthFormStateNotifier();
});
