import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'application.dart';
import 'global.dart';


Future<void> main() async
{
  await prepare();
  Global.init();
  await run();
}


Future<void> prepare() async
{
  WidgetsFlutterBinding.ensureInitialized();
}


Future<void> run() async
{
  await Global.images.init();
  runApp(const MyApp());
}
