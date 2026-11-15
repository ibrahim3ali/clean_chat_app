import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core.dart';
import '../../data.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    SupabaseClient? supabaseClient,
  }) : supabaseClient = supabaseClient ?? Supabase.instance.client;

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
      if (user == null) {
        throw const AuthException('فشل في العثور على بيانات المستخدم');
      }

      final userName =
          user.displayName ?? email.trim().split('@').first;

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: userName,
        isOnline: true,
      );

      // مزامنة حالة المستخدم وبروفايله مع Supabase
      try {
        await supabaseClient.from('profiles').upsert({
          'id': user.uid,
          'name': userModel.name,
          'email': userModel.email,
          'is_online': true,
        });
      } catch (_) {}

      // مزامنة احتياطية مع Firestore
      try {
        await firestore.collection('users').doc(user.uid).set(
          userModel.toMap(),
          SetOptions(merge: true),
        );
      } catch (_) {}

      return userModel;
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

      // حفظ بروفايل المستخدم في Supabase فوراً
      try {
        await supabaseClient.from('profiles').upsert({
          'id': user.uid,
          'name': userModel.name,
          'email': userModel.email,
          'is_online': true,
        });
      } catch (_) {}

      // حفظ احتياطي في Firestore
      try {
        await firestore.collection('users').doc(user.uid).set(userModel.toMap());
      } catch (_) {}

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
        try {
          await supabaseClient
              .from('profiles')
              .update({'is_online': false})
              .eq('id', currentUid);
        } catch (_) {}

        try {
          await firestore.collection('users').doc(currentUid).update({
            'isOnline': false,
          });
        } catch (_) {}
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
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
      isOnline: true,
    );
  }
}
