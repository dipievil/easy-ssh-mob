import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities for adaptive UI
class ResponsiveBreakpoints {
  // Breakpoint definitions following Material Design guidelines
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
  static const double largeDesktop = 1920;

  /// Check if current screen is mobile size
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if current screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if current screen is desktop size
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Check if current screen is large desktop size
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktop;

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return ScreenSize.mobile;
    if (width < desktop) return ScreenSize.tablet;
    if (width < largeDesktop) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  /// Get appropriate number of columns for grid layouts
  static int getGridColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileColumns;
      case ScreenSize.tablet:
        return tabletColumns;
      case ScreenSize.desktop:
        return desktopColumns;
      case ScreenSize.largeDesktop:
        return largeDesktopColumns;
    }
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getScreenPadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return tablet ?? const EdgeInsets.all(24);
    } else {
      return desktop ?? const EdgeInsets.all(32);
    }
  }

  /// Get appropriate spacing based on screen size
  static double getSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get appropriate icon size based on screen size
  static double getIconSize(
    BuildContext context, {
    double mobile = 20.0,
    double tablet = 24.0,
    double desktop = 28.0,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get maximum width for content containers
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 800;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.largeDesktop:
        return 1400;
    }
  }
}

enum ScreenSize { mobile, tablet, desktop, largeDesktop }

/// Responsive widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// Responsive layout with adaptive padding and constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool applyPadding;
  final bool constrainWidth;
  final EdgeInsets? customPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.applyPadding = true,
    this.constrainWidth = true,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply width constraints
    if (constrainWidth) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveBreakpoints.getMaxContentWidth(context),
        ),
        child: content,
      );
    }

    // Apply responsive padding
    if (applyPadding) {
      content = Padding(
        padding:
            customPadding ?? ResponsiveBreakpoints.getScreenPadding(context),
        child: content,
      );
    }

    return Center(child: content);
  }
}

/// Adaptive grid that changes column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveBreakpoints.getGridColumns(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

/// Responsive list that switches between list and grid based on screen size
class AdaptiveList extends StatelessWidget {
  final List<Widget> children;
  final bool useGridOnTablet;
  final bool useGridOnDesktop;
  final double gridSpacing;
  final double listSpacing;

  const AdaptiveList({
    super.key,
    required this.children,
    this.useGridOnTablet = true,
    this.useGridOnDesktop = true,
    this.gridSpacing = 16.0,
    this.listSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final shouldUseGrid =
        (ResponsiveBreakpoints.isTablet(context) && useGridOnTablet) ||
            (ResponsiveBreakpoints.isDesktop(context) && useGridOnDesktop);

    if (shouldUseGrid) {
      return ResponsiveGrid(
        spacing: gridSpacing,
        runSpacing: gridSpacing,
        children: children,
      );
    } else {
      return ListView.separated(
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(height: listSpacing),
        itemBuilder: (context, index) => children[index],
      );
    }
  }
}

/// Responsive text that adjusts font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final double mobileScale;
  final double tabletScale;
  final double desktopScale;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.mobileScale = 1.0,
    this.tabletScale = 1.1,
    this.desktopScale = 1.2,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    double scale = mobileScale;
    if (ResponsiveBreakpoints.isTablet(context)) {
      scale = tabletScale;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      scale = desktopScale;
    }

    final theme = Theme.of(context);
    final effectiveStyle = (baseStyle ?? theme.textTheme.bodyMedium!).copyWith(
      fontSize: (baseStyle?.fontSize ?? theme.textTheme.bodyMedium!.fontSize!) *
          scale,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double mobile;
  final double tablet;
  final double desktop;
  final Axis direction;

  const ResponsiveSpacing({
    super.key,
    this.mobile = 8.0,
    this.tablet = 12.0,
    this.desktop = 16.0,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveBreakpoints.getSpacing(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    return SizedBox(
      width: direction == Axis.horizontal ? spacing : null,
      height: direction == Axis.vertical ? spacing : null,
    );
  }
}

/// Helper extension for responsive values
extension ResponsiveValue<T> on BuildContext {
  R responsive<R>({required R mobile, R? tablet, R? desktop}) {
    if (ResponsiveBreakpoints.isDesktop(this)) {
      return desktop ?? tablet ?? mobile;
    } else if (ResponsiveBreakpoints.isTablet(this)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}
