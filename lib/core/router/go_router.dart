import 'package:go_router/go_router.dart';
import 'package:grpc_study/core/router/app_router.dart';
import 'package:injectable/injectable.dart';

@module
abstract class GoRouterModule {
  @singleton
  GoRouter router() => GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: const SplashRoute().location,
    routes: $appRoutes,
  );
}
