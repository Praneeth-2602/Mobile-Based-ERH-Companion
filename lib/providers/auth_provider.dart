import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Mock user data for demonstration
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    '1234-asha': {
      'id': 'asha-001',
      'name': 'Priya Sharma',
      'role': 'asha',
      'village': 'Rampur',
      'phoneNumber': '+91 9876543210',
      'pin': '1234',
      'isOnline': true,
    },
    '5678-anm': {
      'id': 'anm-001',
      'name': 'Dr. Meera Patel',
      'role': 'anm',
      'village': 'Rampur Block',
      'phoneNumber': '+91 9876543211',
      'pin': '5678',
      'isOnline': true,
    },
    '9999-phc': {
      'id': 'phc-001',
      'name': 'Dr. Rajesh Kumar',
      'role': 'phc',
      'village': 'District Hospital',
      'phoneNumber': '+91 9876543212',
      'pin': '9999',
      'isOnline': true,
    },
  };

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userRole = prefs.getString('user_role');

      if (userId != null && userRole != null) {
        // Try to restore user session
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
        
        final userKey = '${prefs.getString('user_pin') ?? ''}-$userRole';
        if (_mockUsers.containsKey(userKey)) {
          _user = User.fromJson(_mockUsers[userKey]!);
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String pin, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final userKey = '$pin-${role.name}';
      
      if (_mockUsers.containsKey(userKey)) {
        final userData = Map<String, dynamic>.from(_mockUsers[userKey]!);
        userData['lastSync'] = DateTime.now().toIso8601String();
        
        _user = User.fromJson(userData);
        _isAuthenticated = true;

        // Store login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _user!.id);
        await prefs.setString('user_role', role.name);
        await prefs.setString('user_pin', pin);
        await prefs.setBool('is_authenticated', true);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateConnectivity(bool isOnline) async {
    if (_user != null) {
      _user = _user!.copyWith(isOnline: isOnline);
      notifyListeners();
    }
  }

  Future<void> updateLastSync() async {
    if (_user != null) {
      _user = _user!.copyWith(lastSync: DateTime.now());
      notifyListeners();
    }
  }

  // Helper method to check if PIN and role combination is valid
  static bool isValidCredentials(String pin, UserRole role) {
    final userKey = '$pin-${role.name}';
    return _mockUsers.containsKey(userKey);
  }

  // Get available demo credentials
  static List<Map<String, String>> getDemoCredentials() {
    return [
      {'role': 'ASHA', 'pin': '1234', 'name': 'Priya Sharma'},
      {'role': 'ANM', 'pin': '5678', 'name': 'Dr. Meera Patel'},
      {'role': 'PHC', 'pin': '9999', 'name': 'Dr. Rajesh Kumar'},
    ];
  }
}