// Login bottom sheet with blurred background
// Apple-style progressive form: email first, then password appears

import 'dart:ui';

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

class LoginBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return const LoginSheet();
      },
    );
  }
}

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => LoginSheetState();
}

class LoginSheetState extends State<LoginSheet> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    emailController.addListener(handleEmailChange);
  }

  @override
  void dispose() {
    emailController.removeListener(handleEmailChange);
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  void handleEmailChange() {
    setState(() {});
  }

  void handleSignInTap() {
    Navigator.of(context).pop();
  }

  void handleForgotPasswordTap() {
    // TODO: Navigate to forgot password flow
  }

  void handleSignUpTap() {
    // TODO: Navigate to sign up flow
  }

  void handleAppleLoginTap() {
    // TODO: Implement Apple Sign In
    Navigator.of(context).pop();
  }

  void handleGoogleLoginTap() {
    // TODO: Implement Google Sign In
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: SheetContainer(
        backgroundColor: RLDS.backgroundLight,
        child: ModalContent(),
      ),
    );
  }

  Widget ModalContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        children: [
          Div.column([
            // Header section
            HeaderSection(),

            // Social login buttons
            SocialLoginSection(),

            // Divider
            OrDivider(),

            // Form section
            FormSection(),

            // Action button
            ActionButton(),

            // Secondary links (Reset password & Sign up)
            SecondaryLinks(),
          ]),
        ],
      ),
    );
  }

  Widget HeaderSection() {
    return Div.column([
      const Spacing.height(16),

      // Title
      RLTypography.headingLarge(RLUIStrings.LOGIN_TITLE),

      const Spacing.height(4),

      // Subtitle
      RLTypography.bodyMedium(RLUIStrings.LOGIN_SUBTITLE, color: RLDS.textSecondary),
    ], padding: const EdgeInsets.all(24));
  }

  Widget SocialLoginSection() {
    return Div.row([
      // Apple login button (left)
      Expanded(child: AppleLoginButton()),

      const Spacing.width(12),

      // Google login button (right)
      Expanded(child: GoogleLoginButton()),
    ], padding: const EdgeInsets.symmetric(horizontal: 24));
  }

  Widget AppleLoginButton() {
    final Icon AppleIcon = Icon(Icons.apple, color: RLDS.white, size: 20);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.black,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleAppleLoginTap,
      child: Container(
        height: 48.0,
        decoration: buttonDecoration,
        child: Div.row([
          AppleIcon,

          const Spacing.width(8),

          RLTypography.bodyMedium(RLUIStrings.APPLE_LOGIN_LABEL, color: RLDS.white),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleLoginButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.backgroundDark,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLDS.textPrimary.withValues(alpha: 0.1)),
    );

    return GestureDetector(
      onTap: handleGoogleLoginTap,
      child: Container(
        height: 48.0,
        decoration: buttonDecoration,
        child: Div.row([
          GoogleIcon(),

          const Spacing.width(8),

          RLTypography.bodyMedium(RLUIStrings.GOOGLE_LOGIN_LABEL),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleIcon() {
    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLDS.white,
      borderRadius: BorderRadius.circular(4),
    );

    return Container(
      width: 20,
      height: 20,
      decoration: iconDecoration,
      child: Center(child: RLTypography.bodyLarge('G', color: Colors.red)),
    );
  }

  Widget OrDivider() {
    final Color dividerColor = RLDS.textPrimary.withValues(alpha: 0.1);

    return Div.row([
      Expanded(child: Container(height: 1, color: dividerColor)),

      Div.row([
        RLTypography.bodyMedium(RLUIStrings.OR_DIVIDER_LABEL, color: RLDS.textSecondary),
      ], padding: const EdgeInsets.symmetric(horizontal: 16)),

      Expanded(child: Container(height: 1, color: dividerColor)),
    ], padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20));
  }

  Widget FormSection() {
    return Div.column([
      // Email field
      RLTextField.email(controller: emailController, focusNode: emailFocusNode),

      // Password field (animated)
      PasswordFieldAnimated(),
    ], padding: const EdgeInsets.symmetric(horizontal: 24));
  }

  Widget PasswordFieldAnimated() {
    final bool hasEmail = emailController.text.isNotEmpty;

    final Widget passwordContent = RenderIf.condition(hasEmail, PasswordField());

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: passwordContent,
    );
  }

  Widget PasswordField() {
    return Div.column([
      const Spacing.height(12),

      RLTextField.password(controller: passwordController, focusNode: passwordFocusNode),
    ]);
  }

  Widget ActionButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleSignInTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [RLTypography.bodyLarge(RLUIStrings.SIGN_IN_BUTTON_LABEL)],
        ),
      ),
    );
  }

  Widget SecondaryLinks() {
    return Div.row(
      [
        GestureDetector(
          onTap: handleForgotPasswordTap,
          child: RLTypography.bodyMedium(RLUIStrings.FORGOT_PASSWORD_LABEL, color: RLDS.textSecondary),
        ),

        RLTypography.bodyMedium(' · ', color: RLDS.textSecondary),

        GestureDetector(
          onTap: handleSignUpTap,
          child: RLTypography.bodyMedium(RLUIStrings.SIGN_UP_LABEL, color: RLDS.textSecondary),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
    );
  }
}
