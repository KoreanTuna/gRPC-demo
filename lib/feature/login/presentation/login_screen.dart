import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';
import 'package:grpc_study/common/presentation/widget/custom_app_bar.dart';
import 'package:grpc_study/common/presentation/widget/custom_button.dart';
import 'package:grpc_study/core/router/app_router.dart';
import 'package:grpc_study/feature/login/presentation/view_model/login_view_model.dart';

class LoginScreen extends BaseScreen {
  const LoginScreen({
    super.key,
    required this.viewModel,
  });

  final LoginViewModel viewModel;

  @override
  PreferredSizeWidget? renderAppBar(BuildContext context) {
    return const CustomAppBar(title: 'Login');
  }

  @override
  Widget buildScreen(BuildContext context) {
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        CustomButton(
          label: 'Login',
          onPressed: () async {
            final loginResult = await viewModel.login(
              emailController.text,
              passwordController.text,
            );
            loginResult.when(
              ok: (_) {
                const HomeRoute().go(context);
              },
              error: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('로그인 실패: $error')),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
