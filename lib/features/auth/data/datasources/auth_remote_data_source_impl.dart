import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core.dart';
import '../../data.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null)
        throw const AuthException('فشل في العثور على بيانات المستخدم');

      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        await firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
        });
        return UserModel.fromMap(doc.data()!, user.uid);
      }
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? email.split('@').first,
        isOnline: true,
      );
      await firestore.collection('users').doc(user.uid).set(newUser.toMap());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(FirebaseErrorMapper.mapAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('فشل في إنشاء الحساب');

      await user.updateDisplayName(name.trim());
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim().toLowerCase(),
        name: name.trim(),
        isOnline: true,
      );
      await firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(FirebaseErrorMapper.mapAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentUid = firebaseAuth.currentUser?.uid;
      if (currentUid != null) {
        await firestore.collection('users').doc(currentUid).update({
          'isOnline': false,
        });
      }
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      isOnline: true,
    );
  }
}
