import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final bool isOnline;
  final String? fcmToken;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.isOnline = false,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [uid, email, name, isOnline, fcmToken];
}
