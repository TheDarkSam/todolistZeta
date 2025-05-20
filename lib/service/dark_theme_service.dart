import 'package:flutter/material.dart';

class DarkThemeService extends ChangeNotifier {
  bool _ativo = false;

  bool get darkTheme => _ativo;

  set darkTheme(bool value) {
    _ativo = value;
    notifyListeners();
  }
}
