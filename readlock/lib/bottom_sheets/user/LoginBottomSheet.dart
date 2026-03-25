// Login bottom sheet with blurred background
// Apple-style progressive form: email first, then password appears

import 'dart:ui';

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLConstants.dart';

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
      filter: ImageFilter.blur(sigmaX: BLUR_SIGMA, sigmaY: BLUR_SIGMA),
      child: Container(
        color: RLTheme.white,
        child: SafeArea(top: false, child: ModalContent()),
      ),
    );
  }

  Widget ModalContent() {
    const BoxDecoration modalDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(LOGIN_MODAL_BORDER_RADIUS),
        topRight: Radius.circular(LOGIN_MODAL_BORDER_RADIUS),
      ),
    );

    return Container(
      decoration: modalDecoration,
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
      // Drag handle
      const BottomSheetGrabber(),

      const Spacing.height(16),

      // Title
      RLTypography.headingLarge(LOGIN_TITLE),

      const Spacing.height(4),

      // Subtitle
      RLTypography.bodyMedium(LOGIN_SUBTITLE, color: RLTheme.textSecondary),
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
    const Icon AppleIcon = Icon(Icons.apple, color: RLTheme.white, size: 20);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleAppleLoginTap,
      child: Container(
        height: SOCIAL_BUTTON_HEIGHT,
        decoration: buttonDecoration,
        child: Div.row([
          AppleIcon,

          const Spacing.width(8),

          RLTypography.bodyMedium(APPLE_LOGIN_LABEL, color: RLTheme.white),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleLoginButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLTheme.textPrimary.withValues(alpha: 0.1)),
    );

    return GestureDetector(
      onTap: handleGoogleLoginTap,
      child: Container(
        height: SOCIAL_BUTTON_HEIGHT,
        decoration: buttonDecoration,
        child: Div.row([
          GoogleIcon(),

          const Spacing.width(8),

          RLTypography.bodyMedium(GOOGLE_LOGIN_LABEL),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleIcon() {
    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLTheme.white,
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
    final Color dividerColor = RLTheme.textPrimary.withValues(alpha: 0.1);

    return Div.row([
      Expanded(child: Container(height: 1, color: dividerColor)),

      Div.row([
        RLTypography.bodyMedium(OR_DIVIDER_LABEL, color: RLTheme.textSecondary),
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
    return RLDS.BlockButton(
      children: [RLTypography.bodyLarge(SIGN_IN_BUTTON_LABEL, color: RLTheme.white)],
      backgroundColor: RLTheme.primaryGreen,
      onTap: handleSignInTap,
    );
  }

  Widget SecondaryLinks() {
    return Div.row(
      [
        GestureDetector(
          onTap: handleForgotPasswordTap,
          child: RLTypography.bodyMedium(FORGOT_PASSWORD_LABEL, color: RLTheme.textSecondary),
        ),

        RLTypography.bodyMedium(' · ', color: RLTheme.textSecondary),

        GestureDetector(
          onTap: handleSignUpTap,
          child: RLTypography.bodyMedium(SIGN_UP_LABEL, color: RLTheme.textSecondary),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
    );
  }
}
