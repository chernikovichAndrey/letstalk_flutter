import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/service/callkit_service.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/incoming_call_banner.dart';
import 'package:lets_talk/feature/chats/domain/chats_bloc/chats_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/shell/domain/navigation_bloc/navigation_bloc.dart';

class ShellHolder extends StatefulWidget {
  const ShellHolder({required this.child, super.key});

  final Widget child;

  @override
  State<ShellHolder> createState() => _ShellHolderState();
}

class _ShellHolderState extends State<ShellHolder> {
  late CallKitService _callKitService;
  StreamSubscription<Map<String, dynamic>>? _acceptSub;
  StreamSubscription<Map<String, dynamic>>? _declineSub;
  StreamSubscription<Map<String, dynamic>>? _initSub;
  Timer? _pendingDeclineTimer;

  @override
  void initState() {
    super.initState();
    _callKitService = getIt<CallKitService>();
    _acceptSub = _callKitService.onAccept.listen((data) {
      _pendingDeclineTimer?.cancel();
      getIt<CallBloc>().add(CallIncomingFromPush(data));
      if (mounted) {
        context.push(Routes.call.path);
      }
    });
    _declineSub = _callKitService.onDecline.listen((data) {
      _pendingDeclineTimer?.cancel();
      _pendingDeclineTimer = Timer(const Duration(milliseconds: 500), () {
        final callId = int.tryParse(data['call_id']?.toString() ?? '');
        if (callId != null) {
          getIt<CallBloc>().add(CallRejected(callId: callId));
        }
      });
    });
    _initSub = _callKitService.onInit.listen((data) {
      final callerId = int.tryParse(data['caller_id']?.toString() ?? '');
      if (callerId != null) {
        getIt<CallBloc>().add(
          CallInitiated(
            targetUserId: callerId,
            fullName: data['caller_name'],
            avatar: data['caller_avatar'],
            isVideo: data['call_type'] == 'video',
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _acceptSub?.cancel();
    _declineSub?.cancel();
    _initSub?.cancel();
    super.dispose();
  }

  void _showIncomingCallBanner(BuildContext context, CallIncoming state) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: context.s.incomingCall,
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return IncomingCallBanner(
          callerName:
          state.callerInfo?.fullName ??
              context.s.userCallerName(state.callerId.toString()),
          callerAvatar: state.callerInfo?.avatar,
          callType: state.callType,
          onDecline: () {
            getIt<CallBloc>().add(CallRejected(callId: state.callId));
          },
          onAccept: () {
            getIt<CallBloc>().add(
              CallAccepted(
                callId: state.callId,
                callerId: state.callerId,
                offer: state.offer,
                isVideo: state.callType == 'video',
              ),
            );
            context.push(Routes.call.path);
          },
        );
      },
      transitionBuilder:
          (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
          Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.status != ProfileStatus.loaded &&
              curr.status == ProfileStatus.loaded,
          listener: (context, state) {
            getIt<ChatsBloc>().add(ChatsLoad());
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.token != null) {
                getIt<WebSocketService>().authenticate(state.token!);
              }
              getIt<ProfileBloc>().add(ProfileLoadEvent());
              getIt<NavigationBloc>().add(NavigationInitEvent());
              context.go(Routes.chats.path);
            } else if (state is AuthUnauthenticated) {
              context.go(Routes.login.path);
            }
          },
        ),
        BlocListener<CallBloc, CallState>(
          listenWhen: (previous, current) =>
              previous.toString() != current.toString(),
          listener: (context, state) {
            if (state is CallIncoming && Platform.isAndroid) {
              _showIncomingCallBanner(context, state);
            } else if (state is CallOutgoing) {
              context.push(Routes.call.path);
            } else if (state is CallEnded) {
              _callKitService.endAllCalls();
              if (context.canPop()) {
                context.pop();
              }
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
