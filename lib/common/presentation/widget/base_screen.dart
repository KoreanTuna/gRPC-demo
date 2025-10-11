import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

abstract class BaseScreen extends HookWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: baseBackgroundColor,
      child: Stack(
        children: [
          SafeArea(
            top: setTopSafeArea,
            bottom: setBottomSafeArea,
            left: setLeftSafeArea,
            right: setRightSafeArea,
            child: PopScope(
              canPop: canPop,
              child: Scaffold(
                appBar: renderAppBar(context),
                backgroundColor: baseBackgroundColor,
                resizeToAvoidBottomInset: baseResizeToAvoidBottomInset,
                body: Padding(
                  padding: applyBodyPadding
                      ? const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        )
                      : EdgeInsets.zero,
                  child: buildScreen(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @protected
  PreferredSizeWidget? renderAppBar(BuildContext context) => null;

  @protected
  bool get applyBodyPadding => true;

  @protected
  Widget buildScreen(BuildContext context);

  @protected
  Color? get baseBackgroundColor => Colors.white;

  @protected
  LinearGradient? get backgroundGradient => null;

  @protected
  bool get setBottomSafeArea => true;

  @protected
  bool get setTopSafeArea => true;

  @protected
  bool get setLeftSafeArea => false;

  @protected
  bool get setRightSafeArea => false;

  @protected
  bool get canPop => false;

  @protected
  bool get baseResizeToAvoidBottomInset => true;
}
