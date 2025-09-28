import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool showArrow;

  const CustomButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isEnabled = true,
    this.showArrow = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) {
        setState(() {
          _isPressed = true;
        });
        _animationController.forward();
      } : null,
      onTapUp: widget.isEnabled ? (_) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      } : null,
      onTapCancel: widget.isEnabled ? () {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      } : null,
      onTap: widget.isEnabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.isEnabled ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceColor,
                    widget.color.withOpacity(0.02),
                  ],
                ) : null,
                color: widget.isEnabled ? null : AppTheme.neutralGray.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isEnabled 
                      ? (_isPressed ? widget.color : widget.color.withOpacity(0.2))
                      : AppTheme.neutralGray.withOpacity(0.2),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: widget.isEnabled ? [
                  if (_isPressed)
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ...AppTheme.softShadow,
                ] : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: widget.isEnabled ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.8),
                          ],
                        ) : null,
                        color: widget.isEnabled ? null : AppTheme.neutralGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: widget.isEnabled ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.isEnabled ? Colors.white : AppTheme.neutralGray,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.isEnabled 
                                  ? AppTheme.primaryBlue
                                  : AppTheme.neutralGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: widget.isEnabled
                                  ? AppTheme.neutralGray
                                  : AppTheme.neutralGray.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow icon
                    if (widget.showArrow)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isEnabled
                              ? widget.color.withOpacity(0.1)
                              : AppTheme.neutralGray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: widget.isEnabled
                              ? widget.color
                              : AppTheme.neutralGray.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}