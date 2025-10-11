import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grpc_study/environment/app_builder.dart';
import 'package:grpc_study/environment/di/get_it.dart';

void main() async {
  await AppInitiator.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: locator<GoRouter>(),
    );
  }
}
