import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/common/extension/build_context_style_ext.dart';
import 'package:lets_talk/common/widget/glass_button.dart';

class CreateContactPage extends StatefulWidget {
  const CreateContactPage({super.key});

  @override
  State<CreateContactPage> createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  CountryCode? _countryCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Using colors closer to the screenshot
    final backgroundColor = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1);
    final hintStyle = context.text.bodyLarge?.copyWith(
      color: isDark ? Colors.white38 : Colors.black38,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GlassButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            context.s.newContact,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: GlassButton(
                icon: Icons.check,
                onTap: () {
                  // TODO: Implement save
                  Navigator.pop(context);
                },
              ),
            ),
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name Fields Group
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      style: context.text.bodyLarge,
                      decoration: InputDecoration(
                        hintText: context.s.firstName,
                        hintStyle: hintStyle,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(height: 1, indent: 16, color: dividerColor),
                    TextField(
                      controller: _lastNameController,
                      style: context.text.bodyLarge,
                      decoration: InputDecoration(
                        hintText: context.s.lastName,
                        hintStyle: hintStyle,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Phone Fields Group
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Country Selector Row
                    CountryCodePicker(
                      onChanged: (code) {
                        setState(() {
                          _countryCode = code;
                        });
                      },
                      onInit: (code) {
                        if (_countryCode == null && code != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _countryCode = code;
                              });
                            }
                          });
                        }
                      },
                      initialSelection: View.of(context).platformDispatcher.locale.countryCode,
                      favorite: const ['RU', 'BY', 'KZ'],
                      showCountryOnly: true,
                      showOnlyCountryWhenClosed: true,
                      alignLeft: true,
                      padding: EdgeInsets.zero,
                      builder: (CountryCode? code) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          leading: code != null ? Image.asset(
                            code.flagUri!,
                            package: 'country_code_picker',
                            width: 24,
                          ) : null,
                          title: Text(
                            code?.name ?? '',
                            style: context.text.bodyLarge,
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 16, color: dividerColor),
                    // Phone Input Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          if (_countryCode != null)
                            Text(
                              _countryCode!.dialCode ?? '',
                              style: context.text.bodyLarge,
                            ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 24,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: context.text.bodyLarge,
                              decoration: InputDecoration(
                                hintText: '00 000 0000',
                                hintStyle: hintStyle,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
