import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/users_cubit.dart';

class NewChatBottomSheet extends StatefulWidget {
  final UserEntity currentUser;
  const NewChatBottomSheet({super.key, required this.currentUser});

  static Future<void> show(BuildContext context, UserEntity currentUser) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => NewChatBottomSheet(currentUser: currentUser),
    );
  }

  @override
  State<NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<NewChatBottomSheet> {
  final _emailController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchAndStartChat() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = context.tr('invalidEmail'));
      return;
    }
    if (email.toLowerCase() == widget.currentUser.email.toLowerCase()) {
      setState(() => _errorMessage = context.tr('cannotChatWithSelf'));
      return;
    }
    setState(() { _isSearching = true; _errorMessage = null; });

    try {
      final user = await context.read<UsersCubit>().searchUserByEmail(email);
      if (!mounted) return;
      if (user != null) {
        context.pop();
        context.push(AppRoutes.chat, extra: ChatRouteExtra(currentUser: widget.currentUser, otherUser: user));
      } else {
        setState(() { _isSearching = false; _errorMessage = context.tr('userNotFound'); });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _isSearching = false; _errorMessage = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('startNewChat'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close_rounded), color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.tr('enterEmailPrompt'), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchAndStartChat(),
            decoration: InputDecoration(
              labelText: context.tr('email'),
              hintText: 'example@gmail.com',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSearching ? null : _searchAndStartChat,
            child: _isSearching
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(context.tr('searchAndStart'), style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
