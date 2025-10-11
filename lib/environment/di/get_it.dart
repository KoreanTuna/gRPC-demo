import 'package:get_it/get_it.dart';
import 'package:grpc_study/environment/di/get_it.config.dart';
import 'package:injectable/injectable.dart';

GetIt locator = GetIt.instance;

@injectableInit
Future<void> setUpGetItConfig() async {
  await locator.init();
}
