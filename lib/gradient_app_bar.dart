library gradient_app_bar;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _kLeadingWidth = kToolbarHeight;
const double _kMaxTitleTextScaleFactor = 1.34;

// Bottom justify the toolbarHeight child which may overflow the top.
class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout(this.toolbarHeight);

  final double toolbarHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: toolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, toolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) =>
      toolbarHeight != oldDelegate.toolbarHeight;
}

// https://material.io/design/components/app-bars-top.html#specs
// Mobile Landscape: 48dp
// Mobile Portrait: 56dp
// Tablet/Desktop: 64dp

/// A material design app bar.
///
/// An app bar consists of a toolbar and potentially other widgets, such as a
/// [TabBar] and a [FlexibleSpaceBar]. App bars typically expose one or more
/// common [actions] with [IconButton]s which are optionally followed by a
/// [PopupMenuButton] for less common operations (sometimes called the "overflow
/// menu").
///
/// App bars are typically used in the [Scaffold.appBar] property, which places
/// the app bar as a fixed-height widget at the top of the screen. For a scrollable
/// app bar, see [SliverGradientAppBar], which embeds an [GradientAppBar] in a sliver for use in
/// a [CustomScrollView].
///
/// When not used as [Scaffold.appBar], or when wrapped in a [Hero], place the app
/// bar in a [MediaQuery] to take care of the padding around the content of the
/// app bar if needed, as the padding will not be handled by [Scaffold].
///
/// The GradientAppBar displays the toolbar widgets, [leading], [title], and [actions],
/// above the [bottom] (if any). The [bottom] is usually used for a [TabBar]. If
/// a [flexibleSpace] widget is specified then it is stacked behind the toolbar
/// and the bottom widget. The following diagram shows where each of these slots
/// appears in the toolbar when the writing language is left-to-right (e.g.
/// English):
///
/// ![The leading widget is in the top left, the actions are in the top right,
/// the title is between them. The bottom is, naturally, at the bottom, and the
/// flexibleSpace is behind all of them.](https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.png)
///
/// If the [leading] widget is omitted, but the [GradientAppBar] is in a [Scaffold] with
/// a [Drawer], then a button will be inserted to open the drawer. Otherwise, if
/// the nearest [Navigator] has any previous routes, a [BackButton] is inserted
/// instead. This behavior can be turned off by setting the [automaticallyImplyLeading]
/// to false. In that case a null leading widget will result in the middle/title widget
/// stretching to start.
///
/// {@tool snippet --template=stateless_widget_material}
///
/// This sample shows an [GradientAppBar] with two simple actions. The first action
/// opens a [SnackBar], while the second action navigates to a new page.
///
/// ```dart preamble
/// final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
/// final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));
///
/// void openPage(BuildContext context) {
///   Navigator.push(context, MaterialPageRoute(
///     builder: (BuildContext context) {
///       return Scaffold(
///         appBar: GradientAppBar(
///           title: const Text('Next page'),
///         ),
///         body: const Center(
///           child: Text(
///             'This is the next page',
///             style: TextStyle(fontSize: 24),
///           ),
///         ),
///       );
///     },
///   ));
/// }
/// ```
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Scaffold(
///     key: scaffoldKey,
///     appBar: GradientAppBar(
///       title: const Text('GradientAppBar Demo'),
///       actions: <Widget>[
///         IconButton(
///           icon: const Icon(Icons.add_alert),
///           tooltip: 'Show Snackbar',
///           onPressed: () {
///             scaffoldKey.currentState.showSnackBar(snackBar);
///           },
///         ),
///         IconButton(
///           icon: const Icon(Icons.navigate_next),
///           tooltip: 'Next page',
///           onPressed: () {
///             openPage(context);
///           },
///         ),
///       ],
///     ),
///     body: const Center(
///       child: Text(
///         'This is the home page',
///         style: TextStyle(fontSize: 24),
///       ),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Scaffold], which displays the [GradientAppBar] in its [Scaffold.appBar] slot.
///  * [SliverGradientAppBar], which uses [GradientAppBar] to provide a flexible app bar that
///    can be used in a [CustomScrollView].
///  * [TabBar], which is typically placed in the [bottom] slot of the [GradientAppBar]
///    if the screen has multiple pages arranged in tabs.
///  * [IconButton], which is used with [actions] to show buttons on the app bar.
///  * [PopupMenuButton], to show a popup menu on the app bar, via [actions].
///  * [FlexibleSpaceBar], which is used with [flexibleSpace] when the app bar
///    can expand and collapse.
///  * <https://material.io/design/components/app-bars-top.html>
class GradientAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a material design app bar.
  ///
  /// The arguments [primary], [toolbarOpacity], [bottomOpacity]
  /// and [automaticallyImplyLeading] must not be null. Additionally, if
  /// [elevation] is specified, it must be non-negative.
  ///
  /// If [elevation], [brightness], [iconTheme],
  /// [actionsIconTheme], or [textTheme] are null, then their [GradientAppBarTheme]
  /// values will be used. If the corresponding [GradientAppBarTheme] property is null,
  /// then the default specified in the property's documentation will be used.
  ///
  /// Typically used in the [Scaffold.appBar] property.
  GradientAppBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shape,
    this.gradient,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.backwardsCompatibility,
    this.foregroundColor,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.leadingWidth,
    this.systemOverlayStyle,
  })  : assert(elevation == null || elevation >= 0.0),
        preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  /// A widget to display before the [title].
  ///
  /// If this is null and [automaticallyImplyLeading] is set to true, the
  /// [GradientAppBar] will imply an appropriate widget. For example, if the [GradientAppBar] is
  /// in a [Scaffold] that also has a [Drawer], the [Scaffold] will fill this
  /// widget with an [IconButton] that opens the drawer (using [Icons.menu]). If
  /// there's no [Drawer] and the parent [Navigator] can go back, the [GradientAppBar]
  /// will use a [BackButton] that calls [Navigator.maybePop].
  ///
  /// {@tool sample}
  ///
  /// The following code shows how the drawer button could be manually specified
  /// instead of relying on [automaticallyImplyLeading]:
  ///
  /// ```dart
  /// GradientAppBar(
  ///   leading: Builder(
  ///     builder: (BuildContext context) {
  ///       return IconButton(
  ///         icon: const Icon(Icons.menu),
  ///         onPressed: () { Scaffold.of(context).openDrawer(); },
  ///         tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
  ///       );
  ///     },
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// The [Builder] is used in this example to ensure that the `context` refers
  /// to that part of the subtree. That way this code snippet can be used even
  /// inside the very code that is creating the [Scaffold] (in which case,
  /// without the [Builder], the `context` wouldn't be able to see the
  /// [Scaffold], since it would refer to an ancestor of that widget).
  ///
  /// See also:
  ///
  ///  * [Scaffold.appBar], in which an [GradientAppBar] is usually placed.
  ///  * [Scaffold.drawer], in which the [Drawer] is usually placed.
  final Widget? leading;

  /// Controls whether we should try to imply the leading widget if null.
  ///
  /// If true and [leading] is null, automatically try to deduce what the leading
  /// widget should be. If false and [leading] is null, leading space is given to [title].
  /// If leading widget is not null, this parameter has no effect.
  final bool automaticallyImplyLeading;

  /// The primary widget displayed in the appbar.
  ///
  /// Typically a [Text] widget containing a description of the current contents
  /// of the app.
  final Widget? title;

  /// {@template flutter.material.appbar.systemOverlayStyle}
  /// Specifies the style to use for the system overlays that overlap the AppBar.
  ///
  /// If this property is null, then [SystemUiOverlayStyle.light] is used if the
  /// overall theme is dark, [SystemUiOverlayStyle.dark] otherwise. Theme brightness
  /// is defined by [ColorScheme.brightness] for [ThemeData.colorScheme].
  ///
  /// The AppBar's descendants are built within a
  /// `AnnotatedRegion<SystemUiOverlayStyle>` widget, which causes
  /// [SystemChrome.setSystemUIOverlayStyle] to be called
  /// automatically.  Apps should not enclose an AppBar with their
  /// own [AnnotatedRegion].
  /// {@endtemplate}
  //
  /// See also:
  ///  * [SystemChrome.setSystemUIOverlayStyle]
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// {@template flutter.material.appbar.foregroundColor}
  /// The default color for [Text] and [Icon]s within the app bar.
  ///
  /// If null, then [AppBarTheme.foregroundColor] is used. If that
  /// value is also null, then [AppBar] uses the overall theme's
  /// [ColorScheme.onPrimary] if the overall theme's brightness is
  /// [Brightness.light], and [ColorScheme.onSurface] if the overall
  /// theme's [brightness] is [Brightness.dark].
  ///
  /// This color is used to configure [DefaultTextStyle] that contains
  /// the toolbar's children, and the default [IconTheme] widgets that
  /// are created if [iconTheme] and [actionsIconTheme] are null.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [backgroundColor], which specifies the app bar's background color.
  ///  * [Theme.of], which returns the current overall Material theme as
  ///    a [ThemeData].
  ///  * [ThemeData.colorScheme], the thirteen colors that most Material widget
  ///    default colors are based on.
  ///  * [ColorScheme.brightness], which indicates if the overall [Theme]
  ///    is light or dark.
  final Color? foregroundColor;

  /// Overrides the default value for the obsolete [AppBar.toolbarTextStyle]
  /// property in all descendant [AppBar] widgets.
  ///
  /// See also:
  ///
  ///  * [titleTextStyle], which overrides the default of [AppBar.titleTextStyle]
  ///    in all descendant [AppBar] widgets.
  final TextStyle? toolbarTextStyle;

  /// Widgets to display after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the
  /// last action.
  final List<Widget>? actions;

  /// This widget is stacked behind the toolbar and the tab bar. It's height will
  /// be the same as the app bar's overall height.
  ///
  /// A flexible space isn't actually flexible unless the [GradientAppBar]'s container
  /// changes the [GradientAppBar]'s size. A [SliverGradientAppBar] in a [CustomScrollView]
  /// changes the [GradientAppBar]'s height when scrolled.
  ///
  /// Typically a [FlexibleSpaceBar]. See [FlexibleSpaceBar] for details.
  final Widget? flexibleSpace;

  /// This widget appears across the bottom of the app bar.
  ///
  /// Typically a [TabBar]. Only widgets that implement [PreferredSizeWidget] can
  /// be used at the bottom of an app bar.
  ///
  /// See also:
  ///
  ///  * [PreferredSize], which can be used to give an arbitrary widget a preferred size.
  final PreferredSizeWidget? bottom;

  /// The z-coordinate at which to place this app bar relative to its parent.
  ///
  /// This controls the size of the shadow below the app bar.
  ///
  /// The value is non-negative.
  ///
  /// If this property is null, then [ThemeData.appBarTheme.elevation] is used,
  /// if that is also null, the default value is 4, the appropriate elevation
  /// for app bars.
  final double? elevation;

  /// The material's shape as well its shadow.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  final ShapeBorder? shape;

  /// Overrides the default value of [AppBar.backwardsCompatibility]
  /// property in all descendant [AppBar] widgets.
  final bool? backwardsCompatibility;

  /// The color to use for the app bar's material. Typically this should be set
  /// along with [brightness], [iconTheme], [textTheme].
  ///
  /// If this property is null, then [ThemeData.appBarTheme.color] is used,
  /// if that is also null, then [ThemeData.primaryColor] is used.
  final Gradient? gradient;

  /// {@template flutter.material.appbar.leadingWidth}
  /// Defines the width of [leading] widget.
  ///
  /// By default, the value of `leadingWidth` is 56.0.
  /// {@endtemplate}
  final double? leadingWidth;

  /// The gradient displayed at the appbar.
  ///
  /// If this property is null, then [ThemeData.appBarTheme.brightness] is used,
  /// if that is also null, then [ThemeData.primaryColorBrightness] is used.
  final Brightness? brightness;

  /// The color, opacity, and size to use for app bar icons. Typically this
  /// is set along with [backgroundColor], [brightness], [textTheme].
  ///
  /// If this property is null, then [ThemeData.appBarTheme.iconTheme] is used,
  /// if that is also null, then [ThemeData.primaryIconTheme] is used.
  final IconThemeData? iconTheme;

  /// The color, opacity, and size to use for the icons that appear in the app
  /// bar's [actions]. This should only be used when the [actions] should be
  /// themed differently than the icon that appears in the app bar's [leading]
  /// widget.
  ///
  /// If this property is null, then [ThemeData.appBarTheme.actionsIconTheme] is
  /// used, if that is also null, then this falls back to [iconTheme].
  final IconThemeData? actionsIconTheme;

  /// The typographic styles to use for text in the app bar. Typically this is
  /// set along with [brightness] [backgroundColor], [iconTheme].
  ///
  /// If this property is null, then [ThemeData.appBarTheme.textTheme] is used,
  /// if that is also null, then [ThemeData.primaryTextTheme] is used.
  final TextTheme? textTheme;

  /// Whether this app bar is being displayed at the top of the screen.
  ///
  /// If true, the app bar's toolbar elements and [bottom] widget will be
  /// padded on top by the height of the system status bar. The layout
  /// of the [flexibleSpace] is not affected by the [primary] property.
  final bool primary;

  /// Whether the title should be centered.
  ///
  /// Defaults to being adapted to the current [TargetPlatform].
  final bool? centerTitle;

  /// The spacing around [title] content on the horizontal axis. This spacing is
  /// applied even if there is no [leading] content or [actions]. If you want
  /// [title] to take all the space available, set this value to 0.0.
  ///
  /// Defaults to [NavigationToolbar.kMiddleSpacing].
  final double? titleSpacing;

  /// {@template flutter.material.appbar.titleTextStyle}
  /// The default text style for the AppBar's [title] widget.
  ///
  /// If this property is null, then [AppBarTheme.titleTextStyle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default
  /// value is a copy of the overall theme's [TextTheme.headline6]
  /// [TextStyle], with color set to the app bar's [foregroundColor].
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [toolbarTextStyle], which is the default text style for the AppBar's
  ///    [title], [leading], and [actions] widgets, also known as the
  ///    AppBar's "toolbar".
  ///  * [DefaultTextStyle], which overrides the default text style for all of the
  ///    the widgets in a subtree.
  final TextStyle? titleTextStyle;

  /// How opaque the toolbar part of the app bar is.
  ///
  /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
  ///
  /// Typically, this value is not changed from its default value (1.0). It is
  /// used by [SliverGradientAppBar] to animate the opacity of the toolbar when the app
  /// bar is scrolled.
  final double toolbarOpacity;

  /// {@template flutter.material.appbar.toolbarHeight}
  /// Defines the height of the toolbar component of an [AppBar].
  ///
  /// By default, the value of `toolbarHeight` is [kToolbarHeight].
  /// {@endtemplate}
  final double? toolbarHeight;

  /// How opaque the bottom part of the app bar is.
  ///
  /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
  ///
  /// Typically, this value is not changed from its default value (1.0). It is
  /// used by [SliverGradientAppBar] to animate the opacity of the toolbar when the app
  /// bar is scrolled.
  final double bottomOpacity;

  /// A size whose height is the sum of [kToolbarHeight] and the [bottom] widget's
  /// preferred height.
  ///
  /// [Scaffold] uses this this size to set its app bar's height.
  @override
  final Size preferredSize;

  bool _getEffectiveCenterTitle(ThemeData themeData) {
    if (centerTitle != null) return centerTitle!;
    switch (themeData.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.iOS:
        return actions == null || actions!.length < 2;
      case TargetPlatform.linux:
        break;
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.windows:
        break;
    }
    return false;
  }

  @override
  _GradientAppBarState createState() => _GradientAppBarState();
}

class _GradientAppBarState extends State<GradientAppBar> {
  static const double _defaultElevation = 4.0;

  void _handleDrawerButton() {
    Scaffold.of(context).openDrawer();
  }

  void _handleDrawerButtonEnd() {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    final double toolbarHeight = widget.toolbarHeight ?? kToolbarHeight;
    final bool backwardsCompatibility = widget.backwardsCompatibility ??
        appBarTheme.backwardsCompatibility ??
        true;

    final Color foregroundColor = widget.foregroundColor ??
        appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    IconThemeData overallIconTheme = backwardsCompatibility
        ? widget.iconTheme ?? appBarTheme.iconTheme ?? theme.primaryIconTheme
        : widget.iconTheme ??
            appBarTheme.iconTheme ??
            theme.iconTheme.copyWith(color: foregroundColor);

    IconThemeData actionsIconTheme = widget.actionsIconTheme ??
        appBarTheme.actionsIconTheme ??
        overallIconTheme;

    TextStyle? toolbarTextStyle = backwardsCompatibility
        ? widget.textTheme?.bodyText2 ??
            appBarTheme.textTheme?.bodyText2 ??
            theme.primaryTextTheme.bodyText2
        : widget.toolbarTextStyle ??
            appBarTheme.toolbarTextStyle ??
            theme.textTheme.bodyText2?.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = backwardsCompatibility
        ? widget.textTheme?.headline6 ??
            appBarTheme.textTheme?.headline6 ??
            theme.primaryTextTheme.headline6
        : widget.titleTextStyle ??
            appBarTheme.titleTextStyle ??
            theme.textTheme.headline6?.copyWith(color: foregroundColor);

    if (widget.toolbarOpacity != 1.0) {
      final double opacity =
          const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn)
              .transform(widget.toolbarOpacity);
      if (titleTextStyle?.color != null)
        titleTextStyle = titleTextStyle!
            .copyWith(color: titleTextStyle.color!.withOpacity(opacity));
      if (toolbarTextStyle?.color != null)
        toolbarTextStyle = toolbarTextStyle!
            .copyWith(color: toolbarTextStyle.color!.withOpacity(opacity));
      overallIconTheme = overallIconTheme.copyWith(
        opacity: opacity * (overallIconTheme.opacity ?? 1.0),
      );
      actionsIconTheme = actionsIconTheme.copyWith(
        opacity: opacity * (actionsIconTheme.opacity ?? 1.0),
      );
    }

    Widget? leading = widget.leading;
    if (leading == null && widget.automaticallyImplyLeading) {
      if (hasDrawer) {
        leading = IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _handleDrawerButton,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (!hasEndDrawer && canPop)
          leading = useCloseButton ? const CloseButton() : const BackButton();
      }
    }
    if (leading != null) {
      leading = ConstrainedBox(
        constraints: BoxConstraints.tightFor(
            width: widget.leadingWidth ?? _kLeadingWidth),
        child: leading,
      );
    }

    Widget? title = widget.title;
    if (title != null) {
      bool? namesRoute;
      switch (theme.platform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          namesRoute = true;
          break;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          break;
      }

      title = _AppBarTitleBox(child: title);
      title = Semantics(
        namesRoute: namesRoute,
        child: title,
        header: true,
      );

      title = DefaultTextStyle(
        style: titleTextStyle!,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );

      // Set maximum text scale factor to [_kMaxTitleTextScaleFactor] for the
      // title to keep the visual hierarchy the same even with larger font
      // sizes. To opt out, wrap the [title] widget in a [MediaQuery] widget
      // with [MediaQueryData.textScaleFactor] set to
      // `MediaQuery.textScaleFactorOf(context)`.
      final MediaQueryData mediaQueryData = MediaQuery.of(context);
      title = MediaQuery(
        data: mediaQueryData.copyWith(
          textScaleFactor: math.min(
            mediaQueryData.textScaleFactor,
            _kMaxTitleTextScaleFactor,
          ),
        ),
        child: title,
      );
    }

    Widget? actions;
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.actions!,
      );
    } else if (hasEndDrawer) {
      actions = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: _handleDrawerButtonEnd,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    }

    // Allow the trailing actions to have their own theme if necessary.
    if (actions != null) {
      actions = IconTheme.merge(
        data: actionsIconTheme,
        child: actions,
      );
    }

    final Widget toolbar = NavigationToolbar(
      leading: leading,
      middle: title,
      trailing: actions,
      centerMiddle: widget._getEffectiveCenterTitle(theme),
      middleSpacing: widget.titleSpacing ??
          appBarTheme.titleSpacing ??
          NavigationToolbar.kMiddleSpacing,
    );

    // If the toolbar is allocated less than toolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    Widget appBar = ClipRect(
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(toolbarHeight),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: DefaultTextStyle(
            style: toolbarTextStyle!,
            child: toolbar,
          ),
        ),
      ),
    );
    if (widget.bottom != null) {
      appBar = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: toolbarHeight),
              child: appBar,
            ),
          ),
          if (widget.bottomOpacity == 1.0)
            widget.bottom!
          else
            Opacity(
              opacity: const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn)
                  .transform(widget.bottomOpacity),
              child: widget.bottom,
            ),
        ],
      );
    }

    // The padding applies to the toolbar and tabbar, not the flexible space.
    if (widget.primary) {
      appBar = SafeArea(
        bottom: false,
        top: true,
        child: appBar,
      );
    }

    appBar = Align(
      alignment: Alignment.topCenter,
      child: appBar,
    );

    if (widget.flexibleSpace != null) {
      appBar = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Semantics(
            sortKey: const OrdinalSortKey(1.0),
            explicitChildNodes: true,
            child: widget.flexibleSpace,
          ),
          Semantics(
            sortKey: const OrdinalSortKey(0.0),
            explicitChildNodes: true,
            // Creates a material widget to prevent the flexibleSpace from
            // obscuring the ink splashes produced by appBar children.
            child: Material(
              type: MaterialType.transparency,
              child: appBar,
            ),
          ),
        ],
      );
    }

    final Brightness overlayStyleBrightness =
        widget.brightness ?? appBarTheme.brightness ?? colorScheme.brightness;
    final SystemUiOverlayStyle overlayStyle = backwardsCompatibility
        ? (overlayStyleBrightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        : widget.systemOverlayStyle ??
            appBarTheme.systemOverlayStyle ??
            (colorScheme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark);

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: appBarTheme.color ?? theme.primaryColor,
          elevation:
              widget.elevation ?? appBarTheme.elevation ?? _defaultElevation,
          shape: widget.shape,
          child: Container(
            decoration: BoxDecoration(gradient: widget.gradient),
            child: Semantics(
              explicitChildNodes: true,
              child: appBar,
            ),
          ),
        ),
      ),
    );
  }
}

// Layout the AppBar's title with unconstrained height, vertically
// center it within its (NavigationToolbar) parent, and allow the
// parent to constrain the title's actual height.
class _AppBarTitleBox extends SingleChildRenderObjectWidget {
  const _AppBarTitleBox({Key? key, required Widget child})
      : super(key: key, child: child);

  @override
  _RenderAppBarTitleBox createRenderObject(BuildContext context) {
    return _RenderAppBarTitleBox(
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderAppBarTitleBox renderObject) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _RenderAppBarTitleBox extends RenderAligningShiftedBox {
  _RenderAppBarTitleBox({
    RenderBox? child,
    TextDirection? textDirection,
  }) : super(
            child: child,
            alignment: Alignment.center,
            textDirection: textDirection);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints innerConstraints =
        constraints.copyWith(maxHeight: double.infinity);
    final Size childSize = child!.getDryLayout(innerConstraints);
    return constraints.constrain(childSize);
  }

  @override
  void performLayout() {
    final BoxConstraints innerConstraints =
        constraints.copyWith(maxHeight: double.infinity);
    child!.layout(innerConstraints, parentUsesSize: true);
    size = constraints.constrain(child!.size);
    alignChild();
  }
}
