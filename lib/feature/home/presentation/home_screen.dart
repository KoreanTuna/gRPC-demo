import 'package:flutter/widgets.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  Widget buildScreen(BuildContext context) {
    return const Center(
      child: Text('Home Screen'),
    );
  }
}
