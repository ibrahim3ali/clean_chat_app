import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  static final Map<String, Map<String, String>> _values = {
    'ar': {
      'appTitle': 'Clean Chat',
      'loginTitle': 'مرحباً بك مجدداً',
      'loginSubtitle': 'سجل الدخول للمتابعة والتواصل مع أصدقائك',
      'registerTitle': 'إنشاء حساب جديد',
      'registerSubtitle': 'ابدأ المحادثة مع الأصدقاء الآن بسهولة',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم الكامل',
      'loginButton': 'تسجيل الدخول',
      'registerButton': 'إنشاء الحساب',
      'dontHaveAccount': 'ليس لديك حساب؟ إنشاء حساب',
      'haveAccount': 'لديك حساب بالفعل؟ تسجيل الدخول',
      'homeTitle': 'المحادثات',
      'recentChats': 'المحادثات الأخيرة',
      'noChatsYet': 'لا توجد محادثات حتى الآن',
      'noChatsDesc': 'لن تظهر هنا إلا جهات الاتصال التي قمت بمراسلتها فقط.\nاضغط على الزر بالأسفل لبدء محادثة جديدة عبر البريد الإلكتروني.',
      'startNewChat': 'محادثة جديدة',
      'enterEmailPrompt': 'أدخل البريد الإلكتروني للشخص الذي ترغب في مراسلته:',
      'searchAndStart': 'بحث وبدء المحادثة',
      'logout': 'تسجيل الخروج',
      'logoutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'confirm': 'تأكيد',
      'cancel': 'إلغاء',
      'online': 'متصل الآن',
      'offline': 'غير متصل',
      'typing': 'يكتب الآن...',
      'typeMessage': 'اكتب رسالتك هنا...',
      'you': 'أنت',
      'noMessagesYet': 'لا توجد رسائل سابقة. ابدأ المحادثة الآن!',
      'cannotChatWithSelf': 'لا يمكنك بدء محادثة مع نفسك!',
      'userNotFound': 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني',
      'invalidEmail': 'يرجى إدخال بريد إلكتروني صالح',
      'passwordTooShort': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
      'nameRequired': 'يرجى إدخال الاسم',
      'noMessagesTap': 'لا توجد رسائل بعد - اضغط للبدء',
      'changeLanguage': 'تغيير اللغة',
      'darkMode': 'الوضع الليلي',
      'lightMode': 'الوضع النهاري',
      'toggleTheme': 'تبديل المظهر',
      'themeTitle': 'مظهر التطبيق',
      'systemMode': 'تلقائي (حسب وضع الهاتف)',
      'systemModeDesc': 'يتغير تلقائياً مع إعدادات هاتفك',
      'lightModeDesc': 'المظهر الفاتح الكلاسيكي',
      'darkModeDesc': 'المظهر الداكن المريح للعين',
      'takePhoto': 'التقاط صورة',
      'recordVideo': 'تسجيل فيديو',
      'photoGallery': 'معرض الصور',
      'videoGallery': 'معرض الفيديو',
      'camera': 'الكاميرا',
      'deleteMessage': 'حذف الرسالة',
      'deleteMessageConfirm': 'هل ترغب في حذف هذه الرسالة؟',
      'deleteForMe': 'الحذف لدي فقط',
      'deleteForEveryone': 'الحذف لدى الجميع',
      'clearChat': 'مسح المحادثة',
      'clearChatConfirm': 'هل أنت متأكد من مسح جميع الرسائل في هذه المحادثة؟',
      'clearForMe': 'مسح المحادثة لدي فقط',
      'clearForEveryone': 'مسح المحادثة للطرفين',
      'messageDeleted': 'تم حذف الرسالة',
      'chatCleared': 'تم مسح المحادثة',
    },
    'en': {
      'appTitle': 'Clean Chat',
      'loginTitle': 'Welcome Back',
      'loginSubtitle': 'Sign in to continue chatting with your friends',
      'registerTitle': 'Create Account',
      'registerSubtitle': 'Start chatting with friends easily now',
      'email': 'Email Address',
      'password': 'Password',
      'name': 'Full Name',
      'loginButton': 'Sign In',
      'registerButton': 'Sign Up',
      'dontHaveAccount': "Don't have an account? Sign Up",
      'haveAccount': 'Already have an account? Sign In',
      'homeTitle': 'Conversations',
      'recentChats': 'Recent Chats',
      'noChatsYet': 'No conversations yet',
      'noChatsDesc': 'Only contacts you have messaged will appear here.\nTap the button below to start a new chat by email.',
      'startNewChat': 'New Chat',
      'enterEmailPrompt':
          'Enter the email address of the person you want to chat with:',
      'searchAndStart': 'Search & Start Chat',
      'logout': 'Sign Out',
      'logoutConfirm': 'Are you sure you want to sign out?',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'online': 'Online',
      'offline': 'Offline',
      'typing': 'Typing...',
      'typeMessage': 'Type a message...',
      'you': 'You',
      'noMessagesYet': 'No messages yet. Start the conversation!',
      'cannotChatWithSelf': 'You cannot start a chat with yourself!',
      'userNotFound': 'No user found with this email address',
      'invalidEmail': 'Please enter a valid email address',
      'passwordTooShort': 'Password must be at least 6 characters',
      'nameRequired': 'Please enter your name',
      'noMessagesTap': 'No messages yet - tap to start',
      'changeLanguage': 'Change Language',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'toggleTheme': 'Toggle Theme',
      'themeTitle': 'App Appearance',
      'systemMode': 'System (Follow Phone)',
      'systemModeDesc': 'Follows your phone system appearance',
      'lightModeDesc': 'Classic bright appearance',
      'darkModeDesc': 'Dark appearance easy on the eyes',
      'takePhoto': 'Take Photo',
      'recordVideo': 'Record Video',
      'photoGallery': 'Photo Gallery',
      'videoGallery': 'Video Gallery',
      'camera': 'Camera',
      'deleteMessage': 'Delete Message',
      'deleteMessageConfirm': 'Do you want to delete this message?',
      'deleteForMe': 'Delete for me',
      'deleteForEveryone': 'Delete for everyone',
      'clearChat': 'Clear Chat',
      'clearChatConfirm': 'Are you sure you want to clear all messages in this chat?',
      'clearForMe': 'Clear for me',
      'clearForEveryone': 'Clear for everyone',
      'messageDeleted': 'Message deleted',
      'chatCleared': 'Chat cleared',
    },
  };

  String translate(String key) {
    return _values[locale.languageCode]?[key] ?? _values['ar']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
