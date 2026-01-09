import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/auth/view/widgets/login_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final text = phoneController.text;
    if (countryCode == null && text.startsWith('+')) {
      // Find the best matching country code
      // We look for the longest dial code that matches the start of the text
      CountryCode? bestMatch;
      for (final code in countryPicker.countryCodes) {
        if (text.startsWith(code.dialCode)) {
          if (bestMatch == null ||
              code.dialCode.length > bestMatch.dialCode.length) {
            bestMatch = code;
          }
        }
      }

      if (bestMatch != null) {
        setState(() {
          countryCode = bestMatch;
          phoneController.text = text.substring(bestMatch!.dialCode.length);
        });
      }
    }
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
              LoginCard(
                phoneController: phoneController,
                countryCode: countryCode,
                onCountryCodeChanged: (code) {
                  setState(() {
                    countryCode = code;
                  });
                },
                onLoginPressed: () {
                  final code = countryCode?.dialCode;
                  final phone = phoneController.text;

                  if (code != null && phone.isNotEmpty) {
                    context.read<AuthBloc>().add(
                          AuthLogin(countryCode: code, phoneNumber: phone),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.s.selectCountryError)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
