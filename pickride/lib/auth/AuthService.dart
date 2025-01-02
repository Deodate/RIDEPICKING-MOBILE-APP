import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Stream to listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Login with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('Attempting to sign in with email: $email');
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign in successful for user: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('Error signing in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  // Fetch user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    debugPrint('Fetching profile for user: $userId');
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      debugPrint('Profile fetched successfully: $response');
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    debugPrint('Signing out user');
    await _supabase.auth.signOut();
    debugPrint('Sign out successful');
  }
}