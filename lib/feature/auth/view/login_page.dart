import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/auth/view/widgets/code_verification_card.dart';
import 'package:lets_talk/feature/auth/view/widgets/login_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  CountryCode? countryCode;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Color(0xFF2C1F16), // Dark brownish
              Color(0xFF5D4037), // Lighter brown/orange tint
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s.connectFriends,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.s.stayConnected,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthCodeSent) {
                    return CodeVerificationCard(
                      codeController: codeController,
                      onVerifyPressed: () {
                        final code = codeController.text;
                        if (code.isNotEmpty) {
                          context.read<AuthBloc>().add(AuthVerifyCode(code: code));
                        }
                      },
                    );
                  }
                  return LoginCard(
                    phoneController: phoneController,
                    countryCode: countryCode,
                    onCountryCodeChanged: (code) {
                      setState(() {
                        countryCode = code;
                      });
                    },
                    initialCountryCode: View.of(context).platformDispatcher.locale.countryCode,
                    onInit: (code) {
                      if (countryCode == null && code != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              countryCode = code;
                            });
                          }
                        });
                      }
                    },
                    onLoginPressed: () {
                      final code = countryCode?.dialCode;
                      final phone = phoneController.text;

                      if (code != null && phone.isNotEmpty) {
                        context.read<AuthBloc>().add(
                              AuthSendCode(countryCode: code, phoneNumber: phone),
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.s.selectCountryError)),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
