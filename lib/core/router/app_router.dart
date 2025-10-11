import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:grpc_study/environment/di/get_it.dart';
import 'package:grpc_study/feature/home/presentation/home_screen.dart';
import 'package:grpc_study/feature/login/presentation/login_screen.dart';
import 'package:grpc_study/feature/login/presentation/view_model/login_view_model.dart';
import 'package:grpc_study/feature/splash/presentation/splash_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@TypedGoRoute<SplashRoute>(
  path: '/splash',
  name: 'splash',
)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

@TypedGoRoute<LoginRoute>(
  path: '/login',
  name: 'login',
)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return LoginScreen(
      viewModel: locator<LoginViewModel>(),
    );
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  name: 'home',
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}
