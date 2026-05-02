import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

/// A customizable navigation bar widget for Flutter applications.
///
/// The [LuckyNavigationBar] displays a row of navigation destinations,
/// allowing users to switch between different sections of the app.
/// It supports an optional trailing widget, such as a button or icon,
/// and highlights the currently selected destination.
///
/// The navigation bar has a fixed height and padding, defined by
/// [height] and [paddingValue] respectively.
///
/// Example usage:
/// ```dart
/// LuckyNavigationBar(
///   destinations: [
///     NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
///     NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
///   ],
///   selectedIndex: 0,
///   onDestinationSelected: (index) {
///     // Handle navigation
///   },
///   trailing: IconButton(
///     icon: Icon(Icons.settings),
///     onPressed: () {},
///   ),
/// )
/// ```
///
/// {@tool snippet}
/// See also:
///  * [NavigationDestination], which defines each destination.
/// {@end-tool}
class LuckyNavigationBar extends StatefulWidget {
  static const paddingValue = 21.0;
  static const minimizedPaddingValue = 28.0;
  static const height = 62.0;
  static const minimizedHeight = 48.0;

  /// The list of navigation destinations to display.
  final List<NavigationDestination> destinations;

  ///Callback triggered when a destination is selected, providing the index.
  final ValueChanged<int> onDestinationSelected;

  ///The index of the currently selected destination. Defaults to 0.
  final int selectedIndex;

  /// An optional widget displayed at the end of the navigation bar.
  final Widget? trailing;

  /// An optional widget displayed between the minimized bar and trailing
  /// widget.
  ///
  /// The accessory fades and expands in when [minimized] is true, matching the
  /// transition of the navigation bar as it collapses.
  final Widget? accessory;

  /// Whether the navigation bar should collapse into the selected icon.
  ///
  /// When minimized, the bar keeps its regular height but animates its width to
  /// a 62x62 circle and only displays the icon of the selected destination.
  final bool minimized;

  /// Callback triggered when the collapsed circle is tapped while [minimized]
  /// is true.
  ///
  /// Typically used to expand the bar back to its full state.
  final VoidCallback? onMinimizedPressed;

  const LuckyNavigationBar({
    required this.destinations,
    required this.onDestinationSelected,
    this.selectedIndex = 0,
    this.trailing,
    this.accessory,
    this.minimized = false,
    this.onMinimizedPressed,
    super.key,
  });

  @override
  State<LuckyNavigationBar> createState() => _LuckyNavigationBarState();
}

class _LuckyNavigationBarState extends State<LuckyNavigationBar>
    with SingleTickerProviderStateMixin {
  static const internalPadding = EdgeInsets.symmetric(horizontal: 4);
  static const scalingFactor = 0.016;
  static const itemSpacing = -8.0;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  var _itemSpacing = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.minimized) {
        setState(() => _itemSpacing = itemSpacing);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LuckyNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.minimized != widget.minimized) {
      if (widget.minimized) {
        setState(() => _itemSpacing = 0);
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !widget.minimized) {
            setState(() => _itemSpacing = itemSpacing);
          }
        });
      }
    }
  }

  void _onTapDown(PointerDownEvent details) => _controller.forward();

  void _onPointerUp(PointerEvent details) => _controller.reverse();

  void onTabSelected(int index) => widget.onDestinationSelected(index);

  @override
  Widget build(BuildContext context) {
    final isIOS =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height:
                LuckyNavigationBar.minimizedPaddingValue +
                LuckyNavigationBar.height,
            child: _LuckyNavigationBarBrim(),
          ),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubicEmphasized,
            tween: Tween(end: widget.minimized ? 1 : 0),
            builder: (context, progress, _) {
              final padding = lerpDouble(
                LuckyNavigationBar.paddingValue,
                LuckyNavigationBar.minimizedPaddingValue,
                progress,
              )!;
              final height = lerpDouble(
                LuckyNavigationBar.height,
                LuckyNavigationBar.minimizedHeight,
                progress,
              )!;

              return SafeArea(
                bottom: !isIOS,
                minimum: EdgeInsets.all(padding).copyWith(top: 0),
                child: SizedBox(
                  height: height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      if (widget.accessory != null)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: height + 8,
                          right: widget.trailing == null ? 0 : height + 8,
                          child: _LuckyNavigationBarAccessory(
                            visible: widget.minimized,
                            child: widget.accessory!,
                          ),
                        ),
                      Row(
                        spacing: 8,
                        mainAxisAlignment: widget.trailing != null
                            ? .spaceBetween
                            : widget.minimized && widget.accessory != null
                            ? .start
                            : .center,
                        children: [
                          Flexible(
                            child: Listener(
                              onPointerDown: _onTapDown,
                              onPointerUp: _onPointerUp,
                              child: AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (_, child) => Transform.scale(
                                  scale:
                                      1 + _scaleAnimation.value * scalingFactor,
                                  child: child,
                                ),
                                child: _LuckyNavigationBarSurface(
                                  minimized: widget.minimized,
                                  expandedWidth: resolveWidth,
                                  height: height,
                                  selectedIndex: widget.selectedIndex,
                                  destinations: widget.destinations,
                                  itemSpacing: _itemSpacing,
                                  onTabChanged: onTabSelected,
                                  onMinimizedPressed: widget.onMinimizedPressed,
                                ),
                              ),
                            ),
                          ),
                          ?widget.trailing,
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double get resolveWidth {
    const maxWidth = 512.0;

    if (widget.destinations.length == 2) return 188;

    if (widget.trailing != null) return maxWidth;

    if (widget.destinations.length == 3) return 274;

    return maxWidth;
  }
}

class _LuckyNavigationBarAccessory extends StatelessWidget {
  final Widget child;
  final bool visible;

  const _LuckyNavigationBarAccessory({
    required this.child,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: kThemeAnimationDuration * 2,
      curve: Curves.easeOutCubic,
      tween: Tween(end: visible ? 1.0 : 0.0),
      builder: (context, value, child) {
        final opacity = ((value - .28) / .72).clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: opacity < 1,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, (1 - opacity) * 4),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _LuckyNavigationBarBrim extends StatelessWidget {
  const _LuckyNavigationBarBrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

class _LuckyNavigationBarSurface extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onTabChanged;
  final int selectedIndex;
  final double itemSpacing;
  final bool minimized;
  final double expandedWidth;
  final double height;
  final VoidCallback? onMinimizedPressed;

  const _LuckyNavigationBarSurface({
    required this.destinations,
    required this.onTabChanged,
    required this.selectedIndex,
    required this.itemSpacing,
    required this.minimized,
    required this.expandedWidth,
    required this.height,
    required this.onMinimizedPressed,
  });

  ShapeBorder _shape(BuildContext context) => RoundedSuperellipseBorder(
    borderRadius: BorderRadius.circular(height / 2),
    side: BorderSide(
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4),
      width: 0.5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final selectedDestinationIndex = selectedIndex.clamp(
      0,
      destinations.length - 1,
    );
    final selectedDestination = destinations[selectedDestinationIndex];

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubicEmphasized,
      tween: Tween(end: minimized ? 1 : 0),
      builder: (context, progress, _) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: minimized ? onMinimizedPressed : null,
        child: _LuckyNavigationBarMorphTransition(
          progress: progress,
          expandedWidth: expandedWidth,
          height: height,
          shape: _shape(context),
          selectedDestination: selectedDestination,
          expandedChild: _LuckyNavigationBarView(
            tabIndex: selectedIndex,
            destinations: destinations,
            onTabChanged: onTabChanged,
            child: Padding(
              padding: _LuckyNavigationBarState.internalPadding,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOutCubic,
                tween: Tween(end: itemSpacing),
                builder: (context, spacing, _) => Row(
                  mainAxisAlignment: .spaceEvenly,
                  spacing: spacing,
                  children: List.generate(
                    destinations.length,
                    (index) => Expanded(
                      child: _LuckyNavigationBarItem(
                        destination: destinations[index],
                        selected: selectedIndex == index,
                        onTap: () => onTabChanged(index),
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

class _LuckyNavigationBarMorphTransition extends StatelessWidget {
  final double progress;
  final double expandedWidth;
  final double height;
  final ShapeBorder shape;
  final NavigationDestination selectedDestination;
  final Widget expandedChild;

  const _LuckyNavigationBarMorphTransition({
    required this.progress,
    required this.expandedWidth,
    required this.height,
    required this.shape,
    required this.selectedDestination,
    required this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    final width = lerpDouble(expandedWidth, height, progress);
    final expandedOpacity = (1 - (progress * 1.45)).clamp(0.0, 1.0);
    final selectedIconOpacity = ((progress - .34) / .66).clamp(0.0, 1.0);
    final selectedIconScale = lerpDouble(.74, 1, selectedIconOpacity)!;
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        shape: shape,
        color: theme.colorScheme.surfaceContainer,
        elevation: 1,
        animationDuration: .zero,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (expandedOpacity > 0)
              IgnorePointer(
                ignoring: progress > .05,
                child: Opacity(
                  opacity: expandedOpacity,
                  child: Transform.translate(
                    offset: Offset(0, progress * 5),
                    child: Transform.scale(
                      scale: lerpDouble(1, .96, progress),
                      child: expandedChild,
                    ),
                  ),
                ),
              ),
            if (progress > 0)
              Opacity(
                opacity: selectedIconOpacity,
                child: Transform.scale(
                  scale: selectedIconScale,
                  child: AnimatedSwitcher(
                    duration: kThemeAnimationDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: IconTheme.merge(
                      key: ValueKey(selectedDestination),
                      data: IconThemeData(
                        color: selectedColor,
                        fill: 1,
                        size: 28,
                      ),
                      child:
                          selectedDestination.selectedIcon ??
                          selectedDestination.icon,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LuckyNavigationBarItem extends StatelessWidget {
  final NavigationDestination destination;
  final VoidCallback onTap;
  final bool selected;

  const _LuckyNavigationBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final selectedColor = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constrains) {
        final usePortraitLayout = constrains.maxWidth < 150;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: ColorTween(
                  begin: selected ? selectedColor : unselectedColor,
                  end: selected ? selectedColor : unselectedColor,
                ),
                duration: kThemeAnimationDuration,
                curve: Curves.easeInOutCubic,
                builder: (_, color, _) => Flex(
                  direction: usePortraitLayout ? .vertical : .horizontal,
                  spacing: usePortraitLayout ? 0 : 8,
                  mainAxisSize: .min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: selected ? 1 : 0,
                        end: selected ? 1 : 0,
                      ),
                      duration: kThemeAnimationDuration,
                      curve: Curves.easeInOutCubic,
                      builder: (_, value, _) => IconTheme.merge(
                        data: IconThemeData(
                          color: color,
                          fill: value,
                          size: 28,
                        ),
                        child: destination.icon,
                      ),
                    ),
                    Text(
                      destination.label,
                      style: TextStyle(
                        color: color,
                        fontSize: usePortraitLayout ? 12 : null,
                      ),
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LuckyNavigationBarView extends StatefulWidget {
  final List<NavigationDestination> destinations;
  final int tabIndex;
  final Widget child;
  final ValueChanged<int> onTabChanged;

  const _LuckyNavigationBarView({
    required this.destinations,
    required this.child,
    required this.tabIndex,
    required this.onTabChanged,
  });

  @override
  State<_LuckyNavigationBarView> createState() =>
      _LuckyNavigationBarViewState();
}

class _LuckyNavigationBarViewState extends State<_LuckyNavigationBarView>
    with SingleTickerProviderStateMixin {
  late int tabCount = widget.destinations.length;

  bool _isDown = false;
  bool _isDragging = false;
  bool _skipMotion = false;

  late double xAlign = computeAlignmentForTab(widget.tabIndex);

  double computeAlignmentForTab(int tabIndex) {
    final relativeTabIndex = (tabIndex / (tabCount - 1)).clamp(0.0, 1.0);

    return (relativeTabIndex * 2) - 1; // -1 to 1
  }

  @override
  void didUpdateWidget(covariant _LuckyNavigationBarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabIndex != widget.tabIndex && widget.tabIndex >= 0) {
      final reappearing = oldWidget.tabIndex < 0;
      setState(() {
        xAlign = computeAlignmentForTab(widget.tabIndex);
        if (reappearing) _skipMotion = true;
      });
      if (reappearing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _skipMotion = false);
        });
      }
    }

    if (oldWidget.destinations != widget.destinations) {
      setState(() => tabCount = widget.destinations.length);
    }
  }

  double _getAlignmentFromGlobalPostition(Offset globalPosition) {
    final box = context.findRenderObject()! as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);

    // Calculate the effective draggable range
    // The indicator moves within the tab bar, but has its own width (1/tabCount of total)
    final indicatorWidth = 1.0 / tabCount; // Relative width of indicator
    final draggableRange =
        1.0 - indicatorWidth; // Range the indicator center can move
    final padding = indicatorWidth / 2; // Padding on each side

    // Map the drag position to the draggable range
    final rawRelativeX = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    final normalizedX = (rawRelativeX - padding) / draggableRange;

    // Apply rubber band resistance for overdrag
    final adjustedRelativeX = _applyRubberBandResistance(normalizedX);

    return (adjustedRelativeX * 2) - 1; // Convert to -1:1 range
  }

  void _onDragDown(DragDownDetails details) => setState(() {
    _isDown = true;
    xAlign = _getAlignmentFromGlobalPostition(details.globalPosition);
  });

  void _onDragUpdate(DragUpdateDetails details) => setState(() {
    _isDragging = true;
    xAlign = _getAlignmentFromGlobalPostition(details.globalPosition);
  });

  // Apply rubber band resistance similar to iOS scroll views
  double _applyRubberBandResistance(double value) {
    const resistance = 0.2; // Lower values = more resistance
    const maxOverdrag = 0.3; // Maximum overdrag as fraction of normal range

    // Overdrag to the left
    if (value < 0) {
      final overdrag = -value;
      final resistedOverdrag = overdrag * resistance;

      return -resistedOverdrag.clamp(0.0, maxOverdrag);
    }

    // Overdrag to the right
    if (value > 1) {
      final overdrag = value - 1;
      final resistedOverdrag = overdrag * resistance;

      return 1 + resistedOverdrag.clamp(0.0, maxOverdrag);
    }

    // Normal range, no resistance
    return value;
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isDown = false;
    });

    final currentRelativeX = (xAlign + 1) / 2; // Convert from -1:1 to 0:1

    // Determine target tab based on position.
    // The alignment maps tab indices 0..(tabCount-1) linearly to -1..1, so the
    // inverse is currentRelativeX * (tabCount - 1) to land on a tab index.
    int targetTabIndex;

    if (currentRelativeX < 0) {
      // Overdragged to the left - snap to first tab
      targetTabIndex = 0;
    } else if (currentRelativeX > 1) {
      // Overdragged to the right - snap to last tab
      targetTabIndex = tabCount - 1;
    } else {
      targetTabIndex = (currentRelativeX * (tabCount - 1)).round().clamp(
        0,
        tabCount - 1,
      );
    }
    xAlign = computeAlignmentForTab(targetTabIndex);

    if (targetTabIndex != widget.tabIndex) {
      widget.onTabChanged(targetTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.tabIndex >= 0;
    final targetAlignment = computeAlignmentForTab(
      hasSelection ? widget.tabIndex : 0,
    );

    return GestureDetector(
      onHorizontalDragDown: hasSelection ? _onDragDown : null,
      onHorizontalDragUpdate: hasSelection ? _onDragUpdate : null,
      onHorizontalDragEnd: hasSelection ? _onDragEnd : null,
      onHorizontalDragCancel: hasSelection
          ? () => setState(() {
              _isDragging = false;
              _isDown = false;
            })
          : null,
      child: VelocityMotionBuilder(
        converter: const SingleMotionConverter(),
        value: xAlign,
        motion: _skipMotion
            ? const Motion.linear(Duration.zero)
            : _isDragging
            ? const .interactiveSpring(snapToEnd: true)
            : const .bouncySpring(snapToEnd: true),
        builder: (context, value, velocity, child) {
          final alignment = Alignment(value, 0);

          return SingleMotionBuilder(
            motion: const .snappySpring(
              snapToEnd: true,
              duration: kThemeAnimationDuration,
            ),
            value: _isDown || (alignment.x - targetAlignment).abs() > 0.30
                ? 1.0
                : 0.0,
            builder: (_, thickness, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                child!,
                _LuckyNavigationBarSelectorView(
                  velocity: _skipMotion ? 0 : velocity,
                  alignment: alignment,
                  thickness: thickness,
                  destinationsLength: widget.destinations.length,
                  visible: hasSelection,
                ),
              ],
            ),
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _LuckyNavigationBarSelectorView extends StatelessWidget {
  final int destinationsLength;
  final double velocity;
  final Alignment alignment;
  final double thickness;

  final bool visible;

  const _LuckyNavigationBarSelectorView({
    required this.destinationsLength,
    required this.velocity,
    required this.alignment,
    required this.thickness,
    required this.visible,
  });

  /// Creates a jelly transform matrix based on velocity
  /// for organic squash and stretch effect
  Matrix4 _buildJellyTransform({
    required Offset velocity,
    required double maxDistortion,
    required double velocityScale,
  }) {
    // Calculate the magnitude of velocity to determine distortion intensity
    final speed = velocity.distance;

    // Normalize velocity direction
    final direction = speed > 0 ? velocity / speed : Offset.zero;

    // Apply a scaling factor to make the effect more pronounced
    final distortionFactor =
        (speed / velocityScale).clamp(0.0, 1.0) * maxDistortion;

    if (distortionFactor == 0) {
      return Matrix4.identity();
    }

    // Create squash and stretch effect
    // Squash in the direction of movement, stretch perpendicular to it
    final squashX = 1.0 - (direction.dx.abs() * distortionFactor * 0.5);
    final squashY = 1.0 - (direction.dy.abs() * distortionFactor * 0.5);
    final stretchX = 1.0 + (direction.dy.abs() * distortionFactor * 0.3);
    final stretchY = 1.0 + (direction.dx.abs() * distortionFactor * 0.3);

    // Combine squash and stretch effects
    final scaleX = squashX * stretchX;
    final scaleY = squashY * stretchY;

    return Matrix4.identity()..scaleByDouble(scaleX, scaleY, scaleX, 1);
  }

  double _resolveWidthFactor(double width) =>
      (1 -
          (destinationsLength - 1) *
              (_LuckyNavigationBarState.itemSpacing / width)) /
      destinationsLength;

  @override
  Widget build(BuildContext context) {
    final rect = RelativeRect.lerp(
      RelativeRect.fill,
      const RelativeRect.fromLTRB(-8, -8, -8, -8),
      thickness,
    );

    return Positioned.fill(
      left: 4,
      right: 4,
      top: 4,
      bottom: 4,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: kThemeAnimationDuration,
          curve: Curves.easeOutCubic,
          tween: Tween(end: visible ? 1.0 : 0.0),
          builder: (context, visibility, child) => Opacity(
            opacity: visibility,
            child: child,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => FractionallySizedBox(
              widthFactor: _resolveWidthFactor(constraints.maxWidth),
              alignment: alignment,
              child: TweenAnimationBuilder<double>(
                duration: kThemeAnimationDuration,
                curve: Curves.easeOutCubic,
                tween: Tween(end: visible ? 1.0 : 0.0),
                builder: (context, visibility, child) => Transform.scale(
                  scale: lerpDouble(.6, 1, visibility) ?? 1,
                  child: child,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fromRelativeRect(
                      rect: rect!,
                      child: SingleMotionBuilder(
                  motion: Motion.bouncySpring(
                    duration: kThemeAnimationDuration * 2,
                  ),
                  value: velocity,
                  builder: (context, velocity, child) => Transform(
                    alignment: Alignment.center,
                    transform: _buildJellyTransform(
                      velocity: Offset(velocity, 0),
                      maxDistortion: .8,
                      velocityScale: 10,
                    ),
                    child: child,
                  ),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.16),
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(
                          LuckyNavigationBar.height,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
