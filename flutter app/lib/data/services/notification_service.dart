import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📩 Background message: ${message.notification?.title}');
}

/// Service for handling Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;
  String? _fcmToken;

  /// Get current FCM token
  String? get token => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');
      } else {
        debugPrint('⚠️ Notification permission denied');
        return;
      }

      // Create Android notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'cardly_default_channel',
        'Cardly Notifications',
        description: 'Notifications for card sharing and updates',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Initialize local notifications
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Send new token to backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

      _initialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize notification service: $e');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'cardly_default_channel',
            'Cardly Notifications',
            channelDescription: 'Notifications for card sharing and updates',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['cardId']?.toString(),
      );
    }
  }

  /// Handle notification tap (when app was in background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📩 Notification tapped: ${message.data}');
    // TODO: Navigate to card detail screen
    // final cardId = message.data['cardId'];
    // if (cardId != null) {
    //   // Navigate to card detail
    // }
  }

  /// Handle notification tap (local notification)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📩 Local notification tapped: ${response.payload}');
    // TODO: Navigate to card detail screen
    // final cardId = response.payload;
    // if (cardId != null) {
    //   // Navigate to card detail
    // }
  }

  /// Register token with backend
  Future<void> registerToken(Function(String token) onTokenRegistered) async {
    if (_fcmToken != null) {
      await onTokenRegistered(_fcmToken!);
    }
  }

  /// Refresh token and register with backend
  Future<void> refreshAndRegisterToken(
      Function(String token) onTokenRegistered) async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        debugPrint('🔄 Token refreshed: $_fcmToken');
        await onTokenRegistered(_fcmToken!);
      }
    } catch (e) {
      debugPrint('❌ Failed to refresh token: $e');
    }
  }
}
