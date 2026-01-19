import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
import 'package:lets_talk/feature/call/view/widgets/incoming_call_banner.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';
import 'package:lets_talk/app/router/routes.dart';

class ShellHolder extends StatelessWidget {
  const ShellHolder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                if (state.token != null) {
                  WebSocketService().authenticate(state.token!);
                }
                context.read<ProfileBloc>().add(ProfileLoadEvent());
                context.go(Routes.contacts.path);
              } else if (state is AuthUnauthenticated) {
                context.go(Routes.login.path);
              }
            },
          ),
          BlocListener<CallBloc, CallState>(
            listener: (context, state) {
              if (state is CallIncoming) {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierLabel: 'Incoming Call',
                  barrierColor: Colors.black54,
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return IncomingCallBanner(
                      callerName: 'User ${state.callerId}',
                      callType: state.callType,
                      onDecline: () {
                        context
                            .read<CallBloc>()
                            .add(CallRejected(callId: state.callId));
                        context.pop();
                      },
                      onAccept: () {
                        context.pop();
                        context.read<CallBloc>().add(CallAccepted(
                          callId: state.callId,
                          callerId: state.callerId,
                          offer: state.offer,
                          isVideo: state.callType == 'video',
                        ));
                        context.push(Routes.calls.path);
                      },
                    );
                  },
                  transitionBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              } else if (state is CallOutgoing) {
                final currentPath = GoRouterState.of(context).uri.path;
                if (currentPath != Routes.calls.path) {
                  context.push(Routes.calls.path);
                }
              } else if (state is CallEnded) {
                if (context.canPop()) {
                   context.pop();
                }
              }
            },
          ),
        ],
      child: child,
    );
  }
}
