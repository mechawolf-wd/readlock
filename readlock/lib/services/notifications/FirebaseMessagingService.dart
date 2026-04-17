import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/services/LoggingService.dart';
import 'package:readlock/services/auth/UserService.dart';

// * Background message handler (must be a top-level function)

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  ServiceLogger.forService('FirebaseMessagingService').info(
    'backgroundHandler',
    'messageId=${message.messageId}',
  );
}

// * Firebase messaging service

class FirebaseMessagingService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static bool isInitialized = false;
  static String? currentToken;

  static final ServiceLogger logger = ServiceLogger.forService('FirebaseMessagingService');

  // * Initialization

  static Future<void> initialize() async {
    if (isInitialized) {
      logger.info('initialize', 'Already initialized');
      return;
    }

    logger.info('initialize', 'Starting initialization');

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);

      final RemoteMessage? initialMessage = await messaging.getInitialMessage();
      final bool hasInitialMessage = initialMessage != null;

      if (hasInitialMessage) {
        handleNotificationTap(initialMessage);
      }

      await getToken();

      messaging.onTokenRefresh.listen(handleTokenRefresh);

      isInitialized = true;

      logger.success('initialize');
    } on Exception catch (error) {
      logger.failure('initialize', '$error');
    }
  }

  // * Request notification permissions

  static Future<bool> requestPermission() async {
    logger.info('requestPermission', 'Requesting permissions');

    try {
      final NotificationSettings settings = await messaging.requestPermission();
      final AuthorizationStatus status = settings.authorizationStatus;

      final bool isAuthorized = status == AuthorizationStatus.authorized;
      final bool isProvisional = status == AuthorizationStatus.provisional;
      final bool hasPermission = isAuthorized || isProvisional;

      logger.info('requestPermission', 'status=$status, hasPermission=$hasPermission');

      return hasPermission;
    } on Exception catch (error) {
      logger.failure('requestPermission', '$error');
      return false;
    }
  }

  // * Get FCM token

  static Future<String?> getToken() async {
    try {
      final String? token = await messaging.getToken();
      final bool hasToken = token != null;

      if (hasToken) {
        currentToken = token;

        final String truncatedToken = token.substring(0, 20);

        logger.success('getToken', 'token=$truncatedToken...');

        UserService.updateFcmToken(token);
      } else {
        logger.info('getToken', 'No token available');
      }

      return token;
    } on Exception catch (error) {
      logger.failure('getToken', '$error');
      return null;
    }
  }

  // * Handle token refresh

  static void handleTokenRefresh(String token) {
    final String truncatedToken = token.substring(0, 20);

    logger.info('handleTokenRefresh', 'token=$truncatedToken...');

    currentToken = token;

    UserService.updateFcmToken(token);
  }

  // * Handle foreground message

  static void handleForegroundMessage(RemoteMessage message) {
    logger.info('handleForegroundMessage', 'messageId=${message.messageId}');

    final RemoteNotification? notification = message.notification;
    final bool hasNotification = notification != null;

    if (!hasNotification) {
      return;
    }

    final String title = notification.title ?? '';
    final String body = notification.body ?? '';

    logger.info('handleForegroundMessage', 'title="$title", body="$body"');
  }

  // * Handle notification tap

  static void handleNotificationTap(RemoteMessage message) {
    logger.info('handleNotificationTap', 'messageId=${message.messageId}');

    final JSONMap data = message.data;

    logger.info('handleNotificationTap', 'data=$data');
  }

  // * Subscribe to topic

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);

      logger.success('subscribeToTopic', 'topic=$topic');
    } on Exception catch (error) {
      logger.failure('subscribeToTopic', '$error');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);

      logger.success('unsubscribeFromTopic', 'topic=$topic');
    } on Exception catch (error) {
      logger.failure('unsubscribeFromTopic', '$error');
    }
  }

  // * Save token after login

  static Future<void> saveTokenAfterLogin() async {
    final bool hasToken = currentToken != null;

    if (hasToken) {
      logger.info('saveTokenAfterLogin', 'Saving cached token to Firestore');

      UserService.updateFcmToken(currentToken!);
    } else {
      logger.info('saveTokenAfterLogin', 'No cached token, fetching new one');

      await getToken();
    }
  }

  // * Delete token (for sign out)

  static Future<void> deleteToken() async {
    try {
      await messaging.deleteToken();

      currentToken = null;

      logger.success('deleteToken');
    } on Exception catch (error) {
      logger.failure('deleteToken', '$error');
    }
  }
}
