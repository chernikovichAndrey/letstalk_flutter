import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_talk/common/service/websocket_service.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/call/domain/bloc/call_bloc.dart';
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
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text('Incoming Call'),
                    content: Text('User ${state.callerId} is calling you.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<CallBloc>()
                              .add(CallRejected(callId: state.callId));
                          Navigator.pop(context);
                        },
                        child: const Text('Decline'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<CallBloc>().add(CallAccepted(
                            callId: state.callId,
                            callerId: state.callerId,
                            offer: state.offer,
                            isVideo: state.callType == 'video',
                          ));
                          context.push(Routes.calls.path);
                        },
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                );
              } else if (state is CallOutgoing) {
                context.push(Routes.calls.path);
              }
            },
          ),
        ],
      child: child,
    );
  }
}