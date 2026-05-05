// Login / sign-up bottom sheet with full auth wiring.
// - Email + password sign-in / sign-up (toggle mode)
// - Apple sign-in + Google sign-in
// - Reset password
// - Verification mail is sent automatically on sign-up

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/LoginSupportBottomSheet.dart';
import 'package:readlock/design_system/RLReveal.dart';
import 'package:readlock/design_system/RLStarfieldButton.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/OnboardingScreen.dart';
import 'package:readlock/screens/VerifyEmailScreen.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/RLTypewriterText.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/auth/DisposableEmailDomains.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

// * Configuration for the login sheet.
//
// Default values reproduce the auth-gate flow used by MainNavigation. Other
// flows (e.g. account deletion re-authentication) supply their own copy and
// flip toggles to hide irrelevant UI.
class LoginSheetConfig {
  // Header copy at the top of the sheet.
  final String title;
  final String subtitle;

  // Hide the sign-up toggle row when the flow only allows signing in
  // (re-authentication can never create a new account).
  final bool allowSignUp;

  // Hide the support / forgot-password link in the secondary row.
  final bool allowSupport;

  // Hide the dev-only bypass row. Always disabled for security-sensitive
  // flows like re-authentication.
  final bool showDevSkip;

  // When true, every sign-in handler routes through the matching Firebase
  // re-authentication API against the currently signed-in user. Successful
  // re-auth refreshes the auth token without changing the active user.
  final bool isReauthMode;

  // Fires after a successful authentication, before the sheet is popped.
  // Replaces the default success path (close + onboarding) so callers can
  // chain follow-up flows (e.g. confirm-then-delete) from a still-mounted
  // ancestor context.
  final void Function(BuildContext context)? onAuthenticated;

  const LoginSheetConfig({
    this.title = RLUIStrings.LOGIN_TITLE,
    this.subtitle = RLUIStrings.LOGIN_SUBTITLE,
    this.allowSignUp = true,
    this.allowSupport = true,
    this.showDevSkip = true,
    this.isReauthMode = false,
    this.onAuthenticated,
  });
}

class LoginBottomSheet {
  // * Dev-only bypass.
  //
  // When true, MainNavigation's auth-state listener will not re-present the
  // login sheet even if the user is unauthenticated. Flipped by the Skip
  // button on the login form. Reset on app restart, never persisted.
  static bool isDevBypassed = false;

  // Tracks whether a login sheet is currently mounted on the navigator so
  // overlapping callers (the auth-listener auto-show + the explicit calls
  // in ProfileScreen / VerifyEmailScreen / AccountBottomSheet) can't
  // present two stacked sheets after a sign-out.
  static bool isCurrentlyVisible = false;

  // Returns the bottom-sheet future so callers can await dismissal (e.g. the
  // main navigation needs to know when it can show the sheet again).
  static Future<void> show(
    BuildContext context, {
    LoginSheetConfig config = const LoginSheetConfig(),
  }) async {
    final bool alreadyOnScreen = isCurrentlyVisible;

    if (alreadyOnScreen) {
      return;
    }

    isCurrentlyVisible = true;

    try {
      await RLBottomSheet.show(
        context,
        child: LoginSheet(config: config),
        isDismissible: config.isReauthMode,
        enableDrag: config.isReauthMode,
        showGrabber: false,
        backgroundColor: RLDS.backgroundLight,
      );
    } finally {
      isCurrentlyVisible = false;
    }
  }
}

// * Social login button sizing — matches the Apple and Google buttons.
const double SOCIAL_LOGIN_BUTTON_HEIGHT = 48.0;

class LoginSheet extends StatefulWidget {
  final LoginSheetConfig config;

  const LoginSheet({super.key, this.config = const LoginSheetConfig()});

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

  LoginSheetConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    emailController.addListener(handleEmailChange);

    // Reauth runs against the current user, so prefilling the email field
    // both speeds up the form and signals which account is being verified.
    if (config.isReauthMode) {
      final String currentEmail = AuthService.currentUserEmail ?? '';
      emailController.text = currentEmail;
    }
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

  // * Email / password submit (handles sign-in, sign-up, and reauth)

  Future<void> handleEmailPasswordSubmit() async {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

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

    // Disposable / temp-mail filter on sign-up only. Sign-in and reauth
    // run against accounts that already passed the filter, so the same
    // domain is allowed there. Block before flipping the loading state
    // so the form stays responsive.
    final bool isFreshSignUp = isSignUpMode && !config.isReauthMode;
    final bool isDisposable = isFreshSignUp && isDisposableEmail(email);

    if (isDisposable) {
      RLToast.warning(context, RLUIStrings.ERROR_DISPOSABLE_EMAIL);
      return;
    }

    setState(() {
      isAuthenticating = true;
    });

    if (config.isReauthMode) {
      final bool reauthSucceeded = await AuthService.reauthenticateWithEmailAndPassword(
        email: email,
        password: password,
      );

      await finaliseReauthResult(reauthSucceeded);
      return;
    }

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
    SoundService.playRandomTextClick();

    setState(() {
      isAuthenticating = true;
    });

    if (config.isReauthMode) {
      final bool reauthSucceeded = await AuthService.reauthenticateWithApple();

      await finaliseReauthResult(reauthSucceeded);
      return;
    }

    final AuthResult result = await AuthService.signInWithApple();

    await finaliseAuthResult(result);
  }

  Future<void> handleGoogleLoginTap() async {
    SoundService.playRandomTextClick();

    setState(() {
      isAuthenticating = true;
    });

    if (config.isReauthMode) {
      final bool reauthSucceeded = await AuthService.reauthenticateWithGoogle();

      await finaliseReauthResult(reauthSucceeded);
      return;
    }

    final AuthResult result = await AuthService.signInWithGoogle();

    await finaliseAuthResult(result);
  }

  // * Reauth result handling. Reauth keeps the existing user, so there's no
  // onboarding branch and no profile creation. On success we close the
  // sheet first, then fire the caller-supplied follow-up so the next dialog
  // pushes onto the original presenting context.

  Future<void> finaliseReauthResult(bool succeeded) async {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    if (!succeeded) {
      setState(() {
        isAuthenticating = false;
      });

      RLToast.error(context, RLUIStrings.ERROR_INVALID_CREDENTIALS);
      return;
    }

    final NavigatorState navigator = Navigator.of(context);
    final void Function(BuildContext context)? followUp = config.onAuthenticated;
    final BuildContext callerContext = navigator.context;

    navigator.pop();

    if (followUp != null) {
      followUp(callerContext);
    }
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
    // yet. Covers fresh sign-ups (a brand-new doc starts with the flag
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

    // Returning sign-in. Close the sheet first so the verify gate (if
    // needed) lands on the main navigator instead of a stacked modal.
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    Navigator.of(context).pop();

    if (!rootContext.mounted) {
      return;
    }

    await routeThroughEmailVerificationGate(rootNavigator, rootContext);
  }

  // Pushes the verify-email screen on the root navigator if the signed-in
  // user's email is still unconfirmed. Social providers (Google) flag the
  // user verified on first sign-in, so this no-ops for them.
  Future<void> routeThroughEmailVerificationGate(
    NavigatorState rootNavigator,
    BuildContext rootContext,
  ) async {
    final bool isVerified = await AuthService.isEmailVerified();

    if (isVerified) {
      return;
    }

    if (!rootContext.mounted) {
      return;
    }

    await VerifyEmailScreen.show(rootContext);
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
  // onto the main navigator, not on top of a still-mounted modal sheet,
  // mirroring the LoginSupportPicker pattern. Once onboarding closes,
  // mark the profile complete and route through the verify-email gate so
  // the reader can't reach the bookshelf with an unconfirmed address.
  Future<void> routeNewUserThroughOnboarding() async {
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    Navigator.of(context).pop();

    await OnboardingScreen.show(rootContext);

    await UserService.markOnboardingComplete();

    if (!rootContext.mounted) {
      return;
    }

    await routeThroughEmailVerificationGate(rootNavigator, rootContext);
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
    // Stack with Clip.none lets the perched sparrow overflow above the
    // sheet's rounded top edge so the bird visually sits ON the sheet
    // rather than inside it. Re-auth flows (account deletion) hide the
    // mascot entirely — the moment is destructive, not friendly.
    final bool showPerchedSparrow = !config.isReauthMode;

    final List<Widget> stackChildren = [ModalContent()];

    if (showPerchedSparrow) {
      stackChildren.add(PerchedSparrow());
    }

    return Stack(clipBehavior: Clip.none, children: stackChildren);
  }

  // * Sparrow perched fully above the sheet's top rim — body sits above
  // the rounded edge with a small gap so the bird reads as standing on
  // top of the sheet rather than crashing into it. Hardcoded to
  // BIRD_OPTIONS first entry (Sparrow) so the login screen always shows
  // the same mascot regardless of the reader's saved bird choice.
  // IgnorePointer keeps it decorative — taps pass through to the scrim.
  //
  // The Stack origin is the SheetContainer's child slot, which itself
  // sits RLDS.spacing12 below the sheet's actual top edge (the no-grabber
  // lead-in inside RLBottomSheet). Offsetting the bird by perchSize plus
  // that lead-in plus a small visual gap puts the bird's bottom just
  // above the sheet's rounded corner.
  Widget PerchedSparrow() {
    const double perchSize = 72.0;
    const double sheetTopGap = RLDS.spacing4;
    const double topOffset = -(perchSize + RLDS.spacing12 + sheetTopGap);

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: BirdAnimationSprite(bird: BIRD_OPTIONS.first, previewSize: perchSize),
        ),
      ),
    );
  }

  Widget ModalContent() {
    final bool showDevSkipRow = config.showDevSkip;
    final Widget devSkipSection = RenderIf.condition(showDevSkipRow, DevSkipButton());

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

            devSkipSection,
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

    return config.title;
  }

  String getHeaderSubtitle() {
    if (isSignUpMode) {
      return RLUIStrings.SIGNUP_SUBTITLE;
    }

    return config.subtitle;
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

    // Keying the typewriter on the title text remounts it whenever the
    // sign-in / sign-up toggle flips the heading, so each new heading
    // re-runs the character-by-character reveal — same pattern as the
    // bottom-nav screen titles (CoursesScreen, MyBookshelfScreen).
    return Div.column(
      [
        RLTypewriterText(
          key: ValueKey<String>(title),
          text: title,
          style: RLTypography.headingLargeStyle,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(RLDS.sheetHeadingToSubheadingSpacing),

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
        RLDS.sheetSubheadingToContentSpacing,
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
    final VoidCallback? actionTap = asTapHandler(handleEmailPasswordSubmit);

    const EdgeInsets actionMargin = EdgeInsets.fromLTRB(
      RLDS.spacing24,
      RLDS.spacing20,
      RLDS.spacing24,
      RLDS.spacing8,
    );

    return Padding(
      padding: actionMargin,
      child: RLStarfieldButton(
        color: actionColor,
        onTap: actionTap,
        child: RLTypography.bodyLarge(label, color: RLDS.white),
      ),
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
    final bool showModeSwitch = config.allowSignUp;
    final bool showSupport = config.allowSupport;
    final bool showSeparator = showModeSwitch && showSupport;
    final bool hasNoLinks = !showModeSwitch && !showSupport;

    if (hasNoLinks) {
      return const Spacing.height(RLDS.spacing12);
    }

    final String modeSwitchLabel = getModeSwitchLabel();

    final List<Widget> links = [];

    if (showModeSwitch) {
      links.add(ClickableTextLink(label: modeSwitchLabel, onTap: toggleMode));
    }

    if (showSeparator) {
      links.add(const Spacing.width(RLDS.spacing8));
      links.add(RLTypography.bodyMedium(' · ', color: RLDS.textSecondary));
      links.add(const Spacing.width(RLDS.spacing8));
    }

    if (showSupport) {
      links.add(
        ClickableTextLink(
          label: RLUIStrings.LOGIN_SUPPORT_LABEL,
          onTap: asTapHandler(handleSupportTap),
        ),
      );
    }

    return Div.row(
      links,
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
    final VoidCallback? wrappedTap = onTap == null
        ? null
        : () {
            SoundService.playRandomTextClick();
            onTap();
          };

    return GestureDetector(
      onTap: wrappedTap,
      child: RLTypography.bodyMedium(label, color: RLDS.textSecondary),
    );
  }
}

