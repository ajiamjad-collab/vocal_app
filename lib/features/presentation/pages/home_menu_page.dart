import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocal_app/features/brands/presentation/bloc/pages/tabs/brand_tab_page.dart';
import 'package:vocal_app/features/profile/presentation/profile_tab_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_menu_cubit.dart';

// Tabs
import 'tabs/home_tab_page.dart';
//import 'tabs/brand_page.dart';
import 'tabs/star_tab_page.dart';
//import 'tabs/profile_tab_page.dart';
import 'tabs/add_tab_page.dart';

/*class HomeMenuPage extends StatefulWidget {
  const HomeMenuPage({super.key});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  late final PageController _pageController;
  final ValueNotifier<double> _page = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _pageController.addListener(() {
      _page.value = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page.dispose();
    super.dispose();
  }

  void _jumpTo(BuildContext context, int index) {
    context.read<HomeMenuCubit>().setIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC);
    //final navBg = isDark ? const Color(0xFF070A0F) : Colors.white;
    final navBg = isDark ? const Color(0xFF05070B) : const Color(0xFFF1F3F7);
    //final navBg = pageBg; // ✅ nav blends with page



    final inactiveIcon =
        isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.55);

    final pages = const [
      HomeTabPage(),
      BrandTabPage(),
      StarTabPage(),
      ProfileTabPage(),
    ];

    return BlocProvider(
      create: (_) => HomeMenuCubit(),
      child: BlocBuilder<HomeMenuCubit, int>(
        builder: (context, index) {
          return Scaffold(
            backgroundColor: pageBg,
            extendBody: true,

            // ================= PAGE VIEW =================
            body: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => context.read<HomeMenuCubit>().setIndex(i),
              itemCount: pages.length,
              itemBuilder: (context, i) {
                final delta = (_page.value - i).abs().clamp(0.0, 1.0);
                final opacity = 1 - (delta * 0.25);
                final scale = 1 - (delta * 0.03);

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: pages[i],
                  ),
                );
              },
            ),

            // ================= FAB =================
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _GradientFab(
              backgroundColor: navBg,
              icon: Icons.add,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddTabPage()),
                );
              },
            ),

            // ================= BOTTOM NAV =================
            bottomNavigationBar: SafeArea(
              top: false,
              child: SizedBox(
                height: 64, // ✅ ENTERPRISE STANDARD HEIGHT
                child: BottomAppBar(
                  color: navBg,
                  elevation: 0,
                  notchMargin: 8,
                  shape: const CircularNotchedRectangle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _NavIcon(
                                icon: Icons.home_outlined,
                                isActive: index == 0,
                                inactiveColor: inactiveIcon,
                                onTap: () => _jumpTo(context, 0),
                              ),
                              _NavIcon(
                                //icon: Icons.grid_view_rounded,
                                icon: Icons.grid_view_outlined,
                                isActive: index == 1,
                                inactiveColor: inactiveIcon,
                                onTap: () => _jumpTo(context, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 64),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _NavIcon(
                                icon: Icons.star_outline_rounded,
                                isActive: index == 2,
                                inactiveColor: inactiveIcon,
                                onTap: () => _jumpTo(context, 2),
                              ),
                              _NavIcon(
                                icon: Icons.person_outline,
                                isActive: index == 3,
                                inactiveColor: inactiveIcon,
                                onTap: () => _jumpTo(context, 3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}*/

class HomeMenuPage extends StatelessWidget {
  const HomeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeMenuCubit(),
      child: const _HomeMenuView(),
    );
  }
}

class _HomeMenuView extends StatefulWidget {
  const _HomeMenuView();

  @override
  State<_HomeMenuView> createState() => _HomeMenuViewState();
}

class _HomeMenuViewState extends State<_HomeMenuView> {
  late final PageController _pageController;
  final ValueNotifier<double> _page = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      _page.value = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page.dispose();
    super.dispose();
  }

  void _jumpTo(BuildContext innerContext, int index) {
    innerContext.read<HomeMenuCubit>().setIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC);
    final navBg = isDark ? const Color(0xFF05070B) : const Color(0xFFF1F3F7);
    final inactiveIcon = isDark ? Colors.white.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.55);

    final pages = const [
      HomeTabPage(),
      BrandTabPage(),
      StarTabPage(),
      ProfileTabPage(),
    ];

    return BlocBuilder<HomeMenuCubit, int>(
      builder: (innerContext, index) {
        return Scaffold(
          backgroundColor: pageBg,
          extendBody: true,
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => innerContext.read<HomeMenuCubit>().setIndex(i),
            itemCount: pages.length,
            itemBuilder: (context, i) {
              final delta = (_page.value - i).abs().clamp(0.0, 1.0);
              final opacity = 1 - (delta * 0.25);
              final scale = 1 - (delta * 0.03);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: pages[i],
                ),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _GradientFab(
            backgroundColor: navBg,
            icon: Icons.add,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddTabPage()),
              );
            },
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: BottomAppBar(
                color: navBg,
                elevation: 0,
                notchMargin: 8,
                shape: const CircularNotchedRectangle(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NavIcon(
                              icon: Icons.home_outlined,
                              isActive: index == 0,
                              inactiveColor: inactiveIcon,
                              onTap: () => _jumpTo(innerContext, 0),
                            ),
                            _NavIcon(
                              icon: Icons.grid_view_outlined,
                              isActive: index == 1,
                              inactiveColor: inactiveIcon,
                              onTap: () => _jumpTo(innerContext, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 64),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NavIcon(
                              icon: Icons.star_outline_rounded,
                              isActive: index == 2,
                              inactiveColor: inactiveIcon,
                              onTap: () => _jumpTo(innerContext, 2),
                            ),
                            _NavIcon(
                              icon: Icons.person_outline,
                              isActive: index == 3,
                              inactiveColor: inactiveIcon,
                              onTap: () => _jumpTo(innerContext, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



// =================================================
// NAV ICON — gradient INSIDE, no shadow, no ripple
// =================================================
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, size: 28, color: inactiveColor);

    if (isActive) {
      iconWidget = ShaderMask(
        shaderCallback: (rect) => AppColors.kGradient.createShader(rect),
        blendMode: BlendMode.srcIn,
        child: Icon(icon, size: 28, color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 40,
        width: 40,
        child: Center(child: iconWidget),
      ),
    );
  }
}

// =================================================
// FAB — enterprise style
// =================================================
class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final IconData icon;

  const _GradientFab({
    required this.onTap,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    const double stroke = 3;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.kGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(stroke),
          child: Material(
            color: backgroundColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: Center(
                child: ShaderMask(
                  shaderCallback: (rect) => AppColors.kGradient.createShader(rect),
                  blendMode: BlendMode.srcIn,
                  child: Icon(icon, size: 30, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
