import 'package:flutter/widgets.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';
import 'package:grpc_study/core/router/app_router.dart';

class SplashScreen extends BaseScreen {
  const SplashScreen({super.key});

  Future<void> _checkUserStatus(BuildContext context) async {
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      const LoginRoute().go(context);
    });
  }

  @override
  Widget buildScreen(BuildContext context) {
    return FutureBuilder(
      future: _checkUserStatus(context),
      builder: (context, asyncSnapshot) {
        return const Center(
          child: Text('Splash Screen'),
        );
      },
    );
  }
}
