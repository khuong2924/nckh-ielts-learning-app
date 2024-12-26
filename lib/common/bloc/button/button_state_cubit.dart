import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'button_state.dart';

class ButtonStateCubit extends Cubit<ButtonState> {
  ButtonStateCubit() : super(ButtonInitialState());

  // Firebase instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Method to log in using Firebase Authentication
  void login(String email, String password) async {
    emit(ButtonLoadingState()); // Emit loading state

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(ButtonSuccessState()); // Login successful
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      String errorMessage = _handleFirebaseAuthError(e.code);
      emit(ButtonFailureState(errorMessage: errorMessage));
    } catch (e) {
      emit(ButtonFailureState(errorMessage: "An unexpected error occurred."));
    }
  }

  // Handle Firebase error codes
  String _handleFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return "No user found for this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'invalid-email':
        return "Invalid email format.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}
