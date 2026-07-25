import 'package:flutter/material.dart';

/// App-wide navigator key so background services (like the SMS listener)
/// can reach the widget tree — read Providers, show a SnackBar — from code
/// that isn't itself a widget. Attached to MaterialApp in main.dart.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
