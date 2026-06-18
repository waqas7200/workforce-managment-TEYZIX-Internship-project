import 'package:flutter/material.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? trailingIcon;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: Responsive.ah(50),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surface, // Keep it dark so yellow loader pops
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.aw(28)),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: Responsive.aw(24),
                height: Responsive.aw(24),
                child: const CircularProgressIndicator(
                  color: AppColors.primary, // Yellow theme color
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.asp(16),
                        ),
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: Responsive.aw(8)),
                    trailingIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
