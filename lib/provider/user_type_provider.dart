import 'package:flutter/material.dart';

enum UserType {
  customer,
  mechanic,
}

class UserTypeProvider extends ChangeNotifier {
  UserType _userType = UserType.customer;

  UserType get userType => _userType;

  void setUserType(UserType type) {
    _userType = type;
    notifyListeners();
  }
}
