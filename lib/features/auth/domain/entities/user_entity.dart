import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final bool isOnline;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [uid, email, name, isOnline];
}
