import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class CompassService with ChangeNotifier
{
  PermissionStatus get permissionStatus => _permissionStatus;

  bool get hasPermission => _permissionStatus == PermissionStatus.granted;

  Future<void> init() async
  {
    _permissionStatus = await Permission.locationWhenInUse.status;
    if (
      permissionStatus != PermissionStatus.granted
      && permissionStatus != PermissionStatus.permanentlyDenied
    ) {
      _permissionStatus = await Permission.locationWhenInUse.request();
    }
    notifyListeners();
  }

  Future<void> requestPermission() async
  {
    final permissionStatus = await Permission.locationWhenInUse.request();
    if (permissionStatus != _permissionStatus) {
      _permissionStatus = permissionStatus;
      notifyListeners();
    }
  }

  late PermissionStatus _permissionStatus;
}
