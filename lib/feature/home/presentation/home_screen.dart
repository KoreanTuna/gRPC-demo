import 'package:flutter/widgets.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';
import 'package:grpc_study/common/presentation/widget/custom_button.dart';
import 'package:grpc_study/core/router/app_router.dart';
import 'package:grpc_study/feature/home/presentation/view_model/home_view_model.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  Widget buildScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [],
        ),

        CustomButton(
          label: 'Logout',
          onPressed: () async {
            await viewModel.logout();
            if (!context.mounted) return;
            const LoginRoute().go(context);
          },
        ),
      ],
    );
  }
}
