import 'package:flutter/widgets.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';
import 'package:grpc_study/core/router/app_router.dart';
import 'package:grpc_study/feature/splash/presentation/view_model/splash_view_model.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({
    super.key,
    required this.viewModel,
  });

  final SplashViewModel viewModel;

  Future<void> _bootstrap(BuildContext context) async {
    final SplashNavigationTarget target = await viewModel
        .determineStartDestination();

    if (!context.mounted) return;

    switch (target) {
      case SplashNavigationTarget.login:
        const LoginRoute().go(context);
        break;
      case SplashNavigationTarget.home:
        const HomeRoute().go(context);
        break;
    }
  }

  @override
  Widget buildScreen(BuildContext context) {
    return FutureBuilder(
      future: _bootstrap(context),
      builder: (context, asyncSnapshot) {
        return const Center(
          child: Text('Splash Screen'),
        );
      },
    );
  }
}
