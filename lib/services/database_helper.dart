import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static SharedPreferences? _prefs;

  DatabaseHelper._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get all users from storage
  Future<List<User>> _getUsers() async {
    final prefs = await this.prefs;
    final usersJson = prefs.getString('users') ?? '[]';
    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList.map((u) => User.fromMap(u)).toList();
  }

  // Save users to storage
  Future<void> _saveUsers(List<User> users) async {
    final prefs = await this.prefs;
    final usersJson = jsonEncode(users.map((u) => u.toMap()).toList());
    await prefs.setString('users', usersJson);
  }

  // Create a new user
  Future<int> createUser(User user) async {
    final users = await _getUsers();
    final newId = users.isEmpty ? 1 : users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    
    final hashedUser = User(
      id: newId,
      name: user.name,
      email: user.email,
      password: _hashPassword(user.password),
      createdAt: user.createdAt,
    );
    
    users.add(hashedUser);
    await _saveUsers(users);
    return newId;
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final users = await _getUsers();
    return users.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }

  // Authenticate user
  Future<User?> authenticateUser(String email, String password) async {
    final users = await _getUsers();
    final hashedPassword = _hashPassword(password);
    
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == hashedPassword,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final users = await _getUsers();
    try {
      return users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
