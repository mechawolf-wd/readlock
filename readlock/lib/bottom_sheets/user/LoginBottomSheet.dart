// Login / sign-up bottom sheet with full auth wiring.
// - Email + password sign-in / sign-up (toggle mode)
// - Apple sign-in + Google sign-in
// - Reset password
// - Verification mail is sent automatically on sign-up

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/LoginSupportBottomSheet.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLReveal.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/OnboardingScreen.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/auth/UserService.dart';

class LoginBottomSheet {
  // * Dev-only bypass.
  //
  // When true, MainNavigation's auth-state listener will not re-present the
  // login sheet even if the user is unauthenticated. Flipped by the Skip
  // button on the login form. Reset on app restart — never persisted.
  static bool isDevBypassed = false;

  // Returns the bottom-sheet future so callers can await dismissal (e.g. the
  // main navigation needs to know when it can show the sheet again).
  static Future<void> show(BuildContext context) {
    return RLBottomSheet.show(
      context,
      child: const LoginSheet(),
      isDismissible: false,
      enableDrag: false,
      showGrabber: false,
      backgroundColor: RLDS.backgroundLight,
    );
  }
}

// * Social login button sizing — matches the Apple and Google buttons.
const double SOCIAL_LOGIN_BUTTON_HEIGHT = 48.0;

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

  bool isSignUpMode = false;
  bool isAuthenticating = false;

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

  // * Mode toggle

  void toggleMode() {
    setState(() {
      isSignUpMode = !isSignUpMode;
    });
  }

  // * Email / password submit (handles both sign-in and sign-up)

  Future<void> handleEmailPasswordSubmit() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    final bool hasNoEmail = email.isEmpty;
    final bool hasNoPassword = password.isEmpty;

    if (hasNoEmail) {
      RLToast.warning(context, RLUIStrings.LOGIN_EMAIL_REQUIRED);
      return;
    }

    if (hasNoPassword) {
      RLToast.warning(context, RLUIStrings.LOGIN_PASSWORD_REQUIRED);
      return;
    }

    setState(() {
      isAuthenticating = true;
    });

    AuthResult result;

    if (isSignUpMode) {
      result = await AuthService.signUpWithEmailAndPassword(email: email, password: password);
    } else {
      result = await AuthService.signInWithEmailAndPassword(email: email, password: password);
    }

    await finaliseAuthResult(result);
  }

  // * Social sign-in handlers

  Future<void> handleAppleLoginTap() async {
    setState(() {
      isAuthenticating = true;
    });

    final AuthResult result = await AuthService.signInWithApple();

    await finaliseAuthResult(result);
  }

  Future<void> handleGoogleLoginTap() async {
    setState(() {
      isAuthenticating = true;
    });

    final AuthResult result = await AuthService.signInWithGoogle();

    await finaliseAuthResult(result);
  }

  // * Shared result handling — creates the profile doc when needed, then
  // either routes fresh sign-ups through onboarding or just closes the sheet.

  Future<void> finaliseAuthResult(AuthResult result) async {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    if (result.isFailure) {
      setState(() {
        isAuthenticating = false;
      });

      final String? errorMessage = result.errorMessage;
      final bool hasErrorMessage = errorMessage != null;

      if (hasErrorMessage) {
        RLToast.error(context, errorMessage);
      }

      return;
    }

    final user = result.credential?.user;
    final bool hasUser = user != null;

    if (hasUser) {
      await AuthService.createUserProfileIfNeeded(user);
    }

    // Onboarding fires whenever the signed-in profile hasn't completed it
    // yet — covers fresh sign-ups (a brand-new doc starts with the flag
    // false) and any returning user who bailed out of the flow before.
    final bool shouldRunOnboarding = hasUser && await isOnboardingPending();

    // The mounted check must stay inline for the use_build_context_synchronously
    // lint to recognise it as the guard before we touch BuildContext.
    if (!mounted) {
      return;
    }

    if (shouldRunOnboarding) {
      await routeNewUserThroughOnboarding();
      return;
    }

    Navigator.of(context).pop();
  }

  // Reads /users/{id}.hasCompletedOnboarding. Treats a missing profile as
  // "needs onboarding" so any race between profile creation and this read
  // still funnels the user through the flow rather than past it.
  Future<bool> isOnboardingPending() async {
    final UserModel? profile = await UserService.getCurrentUserProfile();
    final bool hasNoProfile = profile == null;

    if (hasNoProfile) {
      return true;
    }

    return !profile.hasCompletedOnboarding;
  }

  // Brand-new accounts go through the onboarding flow before they land on
  // the home screen. We close the login sheet first so onboarding pushes
  // onto the main navigator, not on top of a still-mounted modal sheet —
  // mirrors the LoginSupportPicker pattern. Once onboarding closes, mark
  // the profile complete so we don't replay it on next launch.
  Future<void> routeNewUserThroughOnboarding() async {
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);

    Navigator.of(context).pop();

    await OnboardingScreen.show(rootNavigator.context);

    await UserService.markOnboardingComplete();
  }

  // * Reset password

  Future<void> handleForgotPasswordTap() async {
    if (isAuthenticating) {
      return;
    }

    final String email = emailController.text.trim();
    final bool hasNoEmail = email.isEmpty;

    if (hasNoEmail) {
      RLToast.warning(context, RLUIStrings.RESET_PASSWORD_EMAIL_REQUIRED);
      return;
    }

    setState(() {
      isAuthenticating = true;
    });

    final String? error = await AuthService.sendPasswordResetEmail(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      isAuthenticating = false;
    });

    final bool hasError = error != null;

    if (hasError) {
      RLToast.error(context, error);
      return;
    }

    RLToast.success(context, RLUIStrings.RESET_PASSWORD_SENT_MESSAGE);
  }

  // * Support — opens a dedicated bottom sheet with inputs + buttons for
  // reset password / resend verification / email support. The sheet owns
  // its own state and status line, so this handler is just a launcher.

  void handleSupportTap() {
    if (isAuthenticating) {
      return;
    }

    LoginSupportPicker.show(context, prefillEmail: emailController.text.trim());
  }

  // * Dev bypass — for testing only. Sets the static flag so MainNavigation
  // won't immediately re-present the sheet, then closes it.

  void handleDevSkipTap() {
    LoginBottomSheet.isDevBypassed = true;

    Navigator.of(context).pop();
  }

  // * Dev-only — dismisses the login sheet. Mirrors handleDevSkipTap so
  // tapping the link gets you past the gate without going through real
  // auth. Real onboarding wiring will live in finaliseAuthResult later.
  void handleTriggerOnboardingTap() {
    handleDevSkipTap();
  }

  // * Render

  @override
  Widget build(BuildContext context) {
    return ModalContent();
  }

  Widget ModalContent() {
    // Bottom 24 matches every other bottom sheet in the app.
    return Padding(
      padding: const EdgeInsets.only(bottom: RLDS.spacing24),
      child: Wrap(
        children: [
          Div.column([
            HeaderSection(),

            SocialLoginSection(),

            OrDivider(),

            FormSection(),

            ActionRow(),

            SecondaryLinks(),

            DevSkipButton(),
          ]),
        ],
      ),
    );
  }

  Widget DevSkipButton() {
    final Color devLinkColor = RLDS.glass70(RLDS.textSecondary);

    return Div.row(
      [
        GestureDetector(
          onTap: handleDevSkipTap,
          child: RLTypography.bodySmall(RLUIStrings.DEV_SKIP_LOGIN_LABEL, color: devLinkColor),
        ),

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodySmall(' · ', color: devLinkColor),

        const Spacing.width(RLDS.spacing8),

        GestureDetector(
          onTap: handleTriggerOnboardingTap,
          child: RLTypography.bodySmall(
            RLUIStrings.DEV_TRIGGER_ONBOARDING_LABEL,
            color: devLinkColor,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.only(top: RLDS.spacing20, bottom: RLDS.spacing4),
    );
  }

  String getHeaderTitle() {
    if (isSignUpMode) {
      return RLUIStrings.SIGNUP_TITLE;
    }

    return RLUIStrings.LOGIN_TITLE;
  }

  String getHeaderSubtitle() {
    if (isSignUpMode) {
      return RLUIStrings.SIGNUP_SUBTITLE;
    }

    return RLUIStrings.LOGIN_SUBTITLE;
  }

  VoidCallback? asTapHandler(VoidCallback handler) {
    if (isAuthenticating) {
      return null;
    }

    return handler;
  }

  Widget HeaderSection() {
    final String title = getHeaderTitle();
    final String subtitle = getHeaderSubtitle();

    return Div.column(
      [
        RLTypography.headingLarge(title, textAlign: TextAlign.center),

        const Spacing.height(RLDS.spacing4),

        RLTypography.bodyMedium(
          subtitle,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.fromLTRB(
        RLDS.spacing24,
        RLDS.spacing24,
        RLDS.spacing24,
        RLDS.spacing16,
      ),
    );
  }

  Widget SocialLoginSection() {
    return Div.row([
      Expanded(child: AppleLoginButton()),

      const Spacing.width(RLDS.spacing12),

      Expanded(child: GoogleLoginButton()),
    ], padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24));
  }

  Widget AppleLoginButton() {
    final Icon AppleIcon = const Icon(Icons.apple, color: RLDS.white, size: RLDS.iconMedium);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.black,
      borderRadius: RLDS.borderRadiusSmall,
    );

    return GestureDetector(
      onTap: asTapHandler(handleAppleLoginTap),
      child: Container(
        height: SOCIAL_LOGIN_BUTTON_HEIGHT,
        decoration: buttonDecoration,
        child: Div.row([
          AppleIcon,

          const Spacing.width(RLDS.spacing8),

          RLTypography.bodyMedium(RLUIStrings.APPLE_LOGIN_LABEL, color: RLDS.white),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleLoginButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.black,
      borderRadius: RLDS.borderRadiusSmall,
    );

    return GestureDetector(
      onTap: asTapHandler(handleGoogleLoginTap),
      child: Container(
        height: SOCIAL_LOGIN_BUTTON_HEIGHT,
        decoration: buttonDecoration,
        child: Div.row([
          GoogleIcon(),

          const Spacing.width(RLDS.spacing8),

          RLTypography.bodyMedium(RLUIStrings.GOOGLE_LOGIN_LABEL),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }

  Widget GoogleIcon() {
    return SvgPicture.asset(
      'assets/logo/google.svg',
      height: RLDS.iconSmall,
      width: RLDS.iconSmall,
    );
  }

  Widget OrDivider() {
    final Color dividerColor = RLDS.glass10(RLDS.textPrimary);

    return Div.row(
      [
        Expanded(child: Container(height: 1, color: dividerColor)),

        Div.row([
          RLTypography.bodyMedium(RLUIStrings.OR_DIVIDER_LABEL, color: RLDS.textSecondary),
        ], padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing16)),

        Expanded(child: Container(height: 1, color: dividerColor)),
      ],
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24, vertical: RLDS.spacing20),
    );
  }

  Widget FormSection() {
    return Div.column([
      RLTextField.email(controller: emailController, focusNode: emailFocusNode),

      PasswordFieldAnimated(),
    ], padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24));
  }

  Widget PasswordFieldAnimated() {
    // Reveal the password field only once the email looks like an address —
    // the presence of '@' is the cheapest correctness heuristic and avoids
    // showing the password slot while the user is still typing the local
    // part of their email.
    // AnimatedSize handles the layout expand; RLReveal layers the shared
    // app-wide opacity fade on top so the field fades in with the same
    // timing as every other reveal (continue button, true/false buttons).
    final bool hasAtSymbol = emailController.text.contains('@');
    final Widget passwordContent = RenderIf.condition(hasAtSymbol, PasswordField());

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: RLReveal(visible: hasAtSymbol, child: passwordContent),
    );
  }

  Widget PasswordField() {
    return Div.column([
      const Spacing.height(RLDS.spacing12),

      RLTextField.password(controller: passwordController, focusNode: passwordFocusNode),
    ]);
  }

  // * Primary action row — full-width filled CTA, nothing beside it.

  Widget ActionRow() {
    final String label = getActionButtonLabel();
    final Color actionColor = getActionButtonColor();

    return RLButton.primary(
      label: label,
      color: actionColor,
      margin: const EdgeInsets.fromLTRB(
        RLDS.spacing24,
        RLDS.spacing20,
        RLDS.spacing24,
        RLDS.spacing8,
      ),
      onTap: asTapHandler(handleEmailPasswordSubmit),
    );
  }

  Color getActionButtonColor() {
    if (isSignUpMode) {
      return RLDS.success;
    }

    return RLDS.primary;
  }

  String getActionButtonLabel() {
    if (isAuthenticating) {
      if (isSignUpMode) {
        return RLUIStrings.SIGN_UP_LOADING_LABEL;
      }

      return RLUIStrings.SIGN_IN_LOADING_LABEL;
    }

    if (isSignUpMode) {
      return RLUIStrings.SIGN_UP_BUTTON_LABEL;
    }

    return RLUIStrings.SIGN_IN_BUTTON_LABEL;
  }

  // * Secondary links — mode-switch text + Support clickable text, inline.
  //
  // Both are clickable text (no button chrome), sitting side-by-side with a
  // middle-dot separator. In sign-in mode reads: "New account · Support".

  Widget SecondaryLinks() {
    final String modeSwitchLabel = getModeSwitchLabel();

    return Div.row(
      [
        ClickableTextLink(label: modeSwitchLabel, onTap: toggleMode),

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodyMedium(' · ', color: RLDS.textSecondary),

        const Spacing.width(RLDS.spacing8),

        ClickableTextLink(
          label: RLUIStrings.LOGIN_SUPPORT_LABEL,
          onTap: asTapHandler(handleSupportTap),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
    );
  }

  String getModeSwitchLabel() {
    if (isSignUpMode) {
      return RLUIStrings.SWITCH_TO_SIGN_IN_LABEL;
    }

    return RLUIStrings.SWITCH_TO_SIGN_UP_LABEL;
  }

  Widget ClickableTextLink({required String label, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: RLTypography.bodyMedium(label, color: RLDS.textSecondary),
    );
  }
}
