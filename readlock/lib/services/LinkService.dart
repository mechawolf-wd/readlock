// Wrapper around url_launcher for opening external URLs.
// All call sites are fire-and-forget: failures are logged but not surfaced.

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkService {
  static Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool canOpen = await canLaunchUrl(uri);

    if (!canOpen) {
      debugPrint('LinkService: cannot open $url');
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
