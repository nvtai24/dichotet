import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../auth/login_screen.dart';
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _loadingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Kiểm tra session hiện tại → route sang Main hoặc Login
    final authVM = context.read<AuthViewModel>();
    await authVM.checkCurrentUser();
    if (!mounted) return;

    final destination = authVM.isLoggedIn
        ? const MainScreen()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const _LogoWidget(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: const _TitleWidget(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _loadingController.view,
              child: const _LoadingSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
          // Main circle
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2.5),
            ),
            child: const Icon(
              Icons.shopping_basket_rounded,
              color: AppColors.gold,
              size: 60,
            ),
          ),
          // Decorative ✦ symbols around the ring
          ..._decorations.map(
            (d) => Positioned(
              left: d.dx,
              top: d.dy,
              child: const Text(
                '✦',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _decorations = [
    Offset(6, 76), // left
    Offset(148, 76), // right
    Offset(76, 4), // top
    Offset(76, 148), // bottom
    Offset(28, 26), // top-left
    Offset(124, 26), // top-right
    Offset(28, 124), // bottom-left
    Offset(124, 124), // bottom-right
  ];
}

class _TitleWidget extends StatelessWidget {
  const _TitleWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'MUA SẮM TẾT',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Chúc Mừng Năm Mới',
          style: TextStyle(
            color: AppColors.goldLight.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ĐANG TẢI DỮ LIỆU...',
            style: TextStyle(
              color: AppColors.goldLight.withValues(alpha: 0.7),
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}
