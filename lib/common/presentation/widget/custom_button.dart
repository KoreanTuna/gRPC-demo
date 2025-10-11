import 'package:flutter/material.dart';
import 'package:grpc_study/core/theme/color_style.dart';
import 'package:grpc_study/core/theme/text_style.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.width,
    this.onPressed,
    this.isEnabled = true,
    this.applyBackgroundColor = true,
    this.applyBorderColor = false,
    this.textColor,
  });

  final String label;
  final double? width;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool applyBackgroundColor;
  final bool applyBorderColor;
  final Color? textColor;

  factory CustomButton.border({
    required String label,
    double? width,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? textColor,
    bool applyBackgroundColor = false,
    bool applyBorderColor = true,
  }) {
    return CustomButton(
      label: label,
      width: width,
      onPressed: onPressed,
      isEnabled: isEnabled,
      applyBackgroundColor: applyBackgroundColor,
      applyBorderColor: applyBorderColor,
      textColor: textColor,
    );
  }

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isProcessing = false;

  Future<void> _handleOnPressed() async {
    if (widget.onPressed == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });
    try {
      await Future.sync(widget.onPressed!);
    } finally {
      if (context.mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: widget.applyBackgroundColor
              ? (widget.isEnabled ? ColorStyle.gray700 : ColorStyle.gray200)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: widget.applyBorderColor
              ? Border.all(
                  color: widget.isEnabled
                      ? ColorStyle.gray700
                      : ColorStyle.gray400,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isEnabled ? _handleOnPressed : null,
            child: Align(
              child: Container(
                height: 56,
                width: widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isProcessing
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.textColor ?? ColorStyle.white,
                              ),
                            ),
                          )
                        : Text(
                            key: ValueKey(widget.label),
                            widget.label,
                            style: const TextStyle().button.copyWith(
                              color:
                                  widget.textColor ??
                                  (widget.applyBackgroundColor
                                      ? (widget.isEnabled
                                            ? Colors.white
                                            : ColorStyle.gray400)
                                      : widget.isEnabled
                                      ? ColorStyle.gray700
                                      : ColorStyle.gray400),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
