import 'role.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String? token;
  final String? refreshToken;
  final String? guestId;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
    this.refreshToken,
    this.guestId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, {String? token, String? refreshToken}) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? json['email']?.toString() ?? 'Пользователь',
      role: Role.fromString(json['role']?.toString()),
      token: token ?? json['token']?.toString(),
      refreshToken: refreshToken ?? json['refreshToken']?.toString(),
      guestId: json['guestId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.name,
    'token': token,
    'refreshToken': refreshToken,
    'guestId': guestId,
  };
}
