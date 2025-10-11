import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grpc_study/common/presentation/widget/base_screen.dart';
import 'package:grpc_study/common/presentation/widget/custom_app_bar.dart';
import 'package:grpc_study/common/presentation/widget/custom_button.dart';
import 'package:grpc_study/core/router/app_router.dart';
import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';
import 'package:grpc_study/feature/home/presentation/view_model/home_view_model.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  PreferredSizeWidget? renderAppBar(BuildContext context) {
    return const CustomAppBar(title: 'Home');
  }

  @override
  Widget buildScreen(BuildContext context) {
    final TextEditingController messageController = useTextEditingController();
    final messagesSnapshot = useStream<List<ChatMessage>>(
      viewModel.messagesStream,
      initialData: const [],
    );

    useEffect(() {
      final errorSub = viewModel.errorStream.listen((error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      });

      return () {
        errorSub.cancel();
      };
    }, const []);

    useEffect(() {
      return () {
        viewModel.dispose();
      };
    }, const []);

    final messages = messagesSnapshot.data ?? const <ChatMessage>[];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUser = message.sender == ChatSender.user;
              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.blueAccent.withOpacity(0.8)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(
                          color: isUser
                              ? Colors.white70
                              : Colors.black.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                await viewModel.sendMessage(messageController.text);
                messageController.clear();
              },
              child: const Text('Send'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        CustomButton(
          label: 'Logout',
          onPressed: () async {
            final result = await viewModel.logout();
            result.when(
              ok: (_) {
                if (!context.mounted) return;
                const LoginRoute().go(context);
              },
              error: (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.message)),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
