import 'package:grpc_study/environment/di/get_it.dart';

abstract class AppInitiator {
  AppInitiator._();

  static Future<void> init() async {
    await setUpGetItConfig();
  }
}
