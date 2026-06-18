import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tryzx_workfoce_mangment/common/controllers/onboarding_controller.dart';
import 'package:tryzx_workfoce_mangment/core/theme.dart';
import 'package:tryzx_workfoce_mangment/core/utils/responsive.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.aw(24.0)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.ah(20)),
                    SizedBox(
                      height: Responsive.ah(400),
                      width: double.infinity,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: Responsive.aw(250),
                              height: Responsive.aw(250),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                              ),
                            ),
                            Container(
                              width: Responsive.aw(150),
                              height: Responsive.aw(150),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                              ),
                            ),
                            Positioned(
                              top: Responsive.ah(10),
                              left: 0,
                              child: _buildFloatingCard('Development', 'Joined Members', Icons.developer_mode),
                            ),
                            Positioned(
                              top: Responsive.ah(80),
                              right: 0,
                              child: _buildFloatingCard('Portfolio', 'Joined Members', Icons.work),
                            ),
                            Positioned(
                              bottom: Responsive.ah(20),
                              left: Responsive.aw(20),
                              child: _buildFloatingCard('Discovery', 'Joined Members', Icons.explore),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.ah(20)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: Responsive.asp(32),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Your '),
                                    TextSpan(
                                      text: 'Daily\n',
                                      style: TextStyle(color: AppColors.primary),
                                    ),
                                    TextSpan(text: 'Productivity\nStarts Here'),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.star,
                              color: AppColors.primary,
                              size: Responsive.aw(32),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.ah(16)),
                        Text(
                          'Plan tasks, stay focused, and achieve your goals with simple daily organization.',
                          style: TextStyle(
                            fontSize: Responsive.asp(14),
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: Responsive.ah(40)),
                        SwipeToStartButton(onSwipeComplete: controller.getStarted),
                        SizedBox(height: Responsive.ah(20)),
                      ],
                    ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(Responsive.aw(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(Responsive.aw(16)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: Responsive.aw(10),
            offset: Offset(0, Responsive.ah(5)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: Responsive.aw(20)),
          SizedBox(height: Responsive.ah(8)),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.asp(12)),
          ),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.asp(10)),
          ),
        ],
      ),
    );
  }
}

class SwipeToStartButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  
  const SwipeToStartButton({super.key, required this.onSwipeComplete});

  @override
  State<SwipeToStartButton> createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<SwipeToStartButton> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = Responsive.ah(44);
    final double padding = Responsive.ah(8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDragDistance = constraints.maxWidth - buttonWidth - (padding * 2);

        return Container(
          width: double.infinity,
          height: Responsive.ah(60),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Responsive.ah(30)),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(left: Responsive.aw(24.0) + _dragPosition * 0.5),
                  child: Opacity(
                    opacity: (1.0 - (_dragPosition / maxDragDistance)).clamp(0.0, 1.0),
                    child: Text(
                      'Swipe to Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.asp(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: padding + _dragPosition,
                top: padding,
                bottom: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isCompleted) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDragDistance) {
                        _dragPosition = maxDragDistance;
                        _isCompleted = true;
                        widget.onSwipeComplete();
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (!_isCompleted) {
                      setState(() {
                        _dragPosition = 0; // Snap back if not completed
                      });
                    }
                  },
                  child: Container(
                    width: buttonWidth,
                    height: buttonWidth,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: Responsive.aw(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
