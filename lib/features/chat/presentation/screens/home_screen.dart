import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/language_toggle_button.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_profile_banner.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/new_chat_bottom_sheet.dart';
import '../widgets/user_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final uid = authState.user.uid;
      context.read<UsersCubit>().loadConversations(currentUserId: uid);
      ServiceLocator.notificationService.saveTokenToFirestore(uid);
      ServiceLocator.inAppNotificationWatcher.startWatching(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          ServiceLocator.inAppNotificationWatcher.stopWatching();
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('homeTitle')),
          actions: [
            const LanguageToggleButton(),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: context.tr('logout'),
              onPressed: () => LogoutDialog.show(context, onConfirm: () => context.read<AuthCubit>().logout()),
            ),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) return const Center(child: CircularProgressIndicator());
            final currentUser = authState.user;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeProfileBanner(user: currentUser),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Text(
                    context.tr('recentChats'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<UsersCubit, UsersState>(
                    builder: (context, state) {
                      if (state is UsersLoading) return const Center(child: CircularProgressIndicator());
                      if (state is UsersError) return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                      if (state is UsersLoaded) {
                        if (state.conversations.isEmpty) {
                          return HomeEmptyState(onStartChat: () => NewChatBottomSheet.show(context, currentUser));
                        }
                        return ListView.builder(
                          itemCount: state.conversations.length,
                          itemBuilder: (context, index) {
                            final conv = state.conversations[index];
                            return UserListTile(
                              conversation: conv,
                              currentUserId: currentUser.uid,
                              onTap: () => context.push(
                                AppRoutes.chat,
                                extra: ChatRouteExtra(currentUser: currentUser, otherUser: conv.toUserEntity()),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              onPressed: () => NewChatBottomSheet.show(context, state.user),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: Text(context.tr('startNewChat'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }
}
