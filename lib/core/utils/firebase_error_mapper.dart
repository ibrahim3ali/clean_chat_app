class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد';
      case 'wrong-password':
      case 'invalid-credential':
        return 'بيانات تسجيل الدخول غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (يجب أن تكون 6 أحرف على الأقل)';
      default:
        return 'حدث خطأ في المصادقة: $code';
    }
  }
}
