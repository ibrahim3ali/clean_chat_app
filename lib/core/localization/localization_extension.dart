import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
