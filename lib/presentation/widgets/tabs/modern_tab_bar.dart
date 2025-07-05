import 'package:flutter/material.dart';

class ModernTabBar extends StatefulWidget {
  final TabController controller;
  final List<ModernTab> tabs;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const ModernTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<ModernTabBar> createState() => _ModernTabBarState();
}

class _ModernTabBarState extends State<ModernTabBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    widget.controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    _animationController.forward(from: 0.0);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    final borderRadius = widget.borderRadius ?? 12.0;
    final padding = widget.padding ?? const EdgeInsets.all(4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius + 4),
      ),
      child: Stack(
        children: [
          // Animated Background Indicator
          AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.only(
                    left:
                        (MediaQuery.of(context).size.width - 32 - 8) /
                        widget.tabs.length *
                        widget.controller.index,
                  ),
                  width:
                      (MediaQuery.of(context).size.width - 32 - 8) /
                      widget.tabs.length,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: activeColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
          // Tab Buttons
          Row(
            children: List.generate(widget.tabs.length, (index) {
              final tab = widget.tabs[index];
              final isActive = widget.controller.index == index;

              return Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: () => widget.controller.animateTo(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon with animation
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isActive ? tab.activeIcon : tab.icon,
                                key: ValueKey(isActive),
                                color: isActive ? activeColor : inactiveColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Label with animation
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isActive ? activeColor : inactiveColor,
                                fontSize: isActive ? 12 : 11,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                              child: Text(
                                tab.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ModernTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ModernTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// Alternative Modern TabBar with Glassmorphism effect
class GlassmorphismTabBar extends StatefulWidget {
  final TabController controller;
  final List<ModernTab> tabs;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const GlassmorphismTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<GlassmorphismTabBar> createState() => _GlassmorphismTabBarState();
}

class _GlassmorphismTabBarState extends State<GlassmorphismTabBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withOpacity(0.8),
            theme.colorScheme.surface.withOpacity(0.6),
          ],
        ),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Animated indicator
            AnimatedBuilder(
              animation: widget.controller,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.only(
                    left:
                        (MediaQuery.of(context).size.width - 32) /
                        widget.tabs.length *
                        widget.controller.index,
                  ),
                  width:
                      (MediaQuery.of(context).size.width - 32) /
                      widget.tabs.length,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        activeColor.withOpacity(0.2),
                        activeColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
            // Tab buttons
            Row(
              children: List.generate(widget.tabs.length, (index) {
                final tab = widget.tabs[index];
                final isActive = widget.controller.index == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.controller.animateTo(index),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              key: ValueKey(isActive),
                              color: isActive ? activeColor : inactiveColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: isActive ? activeColor : inactiveColor,
                              fontSize: isActive ? 12 : 11,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                            child: Text(
                              tab.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
