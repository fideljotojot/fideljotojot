import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'ml/bill_classifier.dart';
import 'models/denomination.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue even if Firebase fails - app can work without it
  }

  runApp(const PesoBillsApp());
}

class PesoBillsApp extends StatelessWidget {
  const PesoBillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peso Bills Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
          primary: const Color(0xFF00695C),
          secondary: const Color(0xFF00897B),
          tertiary: const Color(0xFF4DB6AC),
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF5F5F5),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A), size: 24),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
          color: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.08),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF00695C).withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: const WidgetStatePropertyAll(IconThemeData(size: 26)),
          height: 72,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF00695C).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00695C),
            side: const BorderSide(color: Color(0xFF00695C), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25,
            color: Color(0xFF1A1A1A),
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: Color(0xFF1A1A1A),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: Color(0xFF1A1A1A),
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: Color(0xFF1A1A1A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: Color(0xFF424242),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: Color(0xFF424242),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: Color(0xFF757575),
          ),
        ),
      ),
      home: const _RootNavigationShell(),
    );
  }
}

class _RootNavigationShell extends StatefulWidget {
  const _RootNavigationShell();

  @override
  State<_RootNavigationShell> createState() => _RootNavigationShellState();
}

class _RootNavigationShellState extends State<_RootNavigationShell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const BillScannerHomePage(),
    UniversalScanPage(denominations: BillScannerHomePage._denominations),
    const _AnalyticsPage(),
    const _LogsPage(),
  ];

  void changeSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          height: 72,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 26),
              selectedIcon: Icon(Icons.home_rounded, size: 26),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined, size: 26),
              selectedIcon: Icon(Icons.qr_code_scanner_rounded, size: 26),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, size: 26),
              selectedIcon: Icon(Icons.analytics_rounded, size: 26),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, size: 26),
              selectedIcon: Icon(Icons.history_rounded, size: 26),
              label: 'Logs',
            ),
          ],
        ),
      ),
    );
  }
}

class BillScannerHomePage extends StatefulWidget {
  const BillScannerHomePage({super.key});

  static final List<Denomination> _denominations = [
    Denomination(
      value: 20,
      color: const Color(0xFFFFD54F),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Manuel L. Quezon',
        'See-through denomination value',
        'Security fibers and serial numbers',
      ],
    ),
    Denomination(
      value: 50,
      color: const Color(0xFFEF9A9A),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Sergio Osmeña',
        'Embedded security thread',
        'Concealed value when tilted',
      ],
    ),
    Denomination(
      value: 50,
      color: const Color(0xFFEF9A9A),
      material: BillMaterial.polymer,
      securityFeatures: [
        'Transparent polymer window',
        'Holographic foil elements',
        'Enhanced security features',
      ],
    ),
    Denomination(
      value: 100,
      color: const Color(0xFF90CAF9),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Manuel A. Roxas',
        'Holographic patch',
        'Tactile dots for the visually impaired',
      ],
    ),
    Denomination(
      value: 100,
      color: const Color(0xFF90CAF9),
      material: BillMaterial.polymer,
      securityFeatures: [
        'Transparent polymer window',
        'Holographic security features',
        'Advanced anti-counterfeiting elements',
      ],
    ),
    Denomination(
      value: 200,
      color: const Color(0xFFA5D6A7),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Diosdado Macapagal',
        'Color-shifting security thread',
        'Latent image of value',
      ],
    ),
    Denomination(
      value: 500,
      color: const Color(0xFFFFF59D),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Benigno & Corazon Aquino',
        'Optically variable ink',
        'Embossed tactile marks',
      ],
    ),
    Denomination(
      value: 500,
      color: const Color(0xFFFFF59D),
      material: BillMaterial.polymer,
      securityFeatures: [
        'Transparent polymer window with NEDA building',
        'Holographic foil stripes',
        'Dynamic shadow image of Ninoy & Cory',
      ],
    ),
    Denomination(
      value: 1000,
      color: const Color(0xFF80CBC4),
      material: BillMaterial.paper,
      securityFeatures: [
        'Portrait watermark of Philippine heroes',
        'Optically variable device (OVD) patch',
        'Windowed security thread',
      ],
    ),
    Denomination(
      value: 1000,
      color: const Color(0xFF80CBC4),
      material: BillMaterial.polymer,
      securityFeatures: [
        'Transparent polymer window with sampaguita',
        'Color-shifting eagle and south sea pearl',
        'Raised bars for tactile identification',
      ],
    ),
  ];

  @override
  State<BillScannerHomePage> createState() => _BillScannerHomePageState();
}

class _BillScannerHomePageState extends State<BillScannerHomePage> {
  ScrollController? _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  Timer? _snapTimer;
  double _rowHeight = 0;
  bool _isUserScrolling = false;
  bool _isAutoScrolling = false;
  double _lastScrollOffset = 0;
  double _scrollStartOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _snapTimer?.cancel();
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController!.position;
    final currentOffset = _scrollController!.offset;

    // Check if user is actively scrolling (not programmatic)
    if (!_isAutoScrolling && position.isScrollingNotifier.value) {
      if (!_isUserScrolling) {
        _isUserScrolling = true;
        _scrollStartOffset = currentOffset;
        _pauseAutoScroll();
      }
      // Reset the resume timer whenever user scrolls
      _resumeTimer?.cancel();
      _resumeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _isUserScrolling = false;
          _startAutoScroll();
        }
      });

      // Track scroll position for snap detection
      _lastScrollOffset = currentOffset;

      // Cancel any pending snap
      _snapTimer?.cancel();
    }

    // Detect when scrolling stops (position hasn't changed)
    if (!_isAutoScrolling && _isUserScrolling && _rowHeight > 0) {
      _snapTimer?.cancel();
      _snapTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted &&
            !_isAutoScrolling &&
            _scrollController!.hasClients &&
            (_scrollController!.offset - _lastScrollOffset).abs() < 1.0) {
          _snapToNextRow();
        }
      });
    }
  }

  void _snapToNextRow() {
    if (_scrollController == null ||
        !_scrollController!.hasClients ||
        _rowHeight == 0) {
      return;
    }

    final currentScroll = _scrollController!.offset;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final scrollDelta = currentScroll - _scrollStartOffset;

    // Determine scroll direction and move to next/previous row
    double targetScroll;
    if (scrollDelta.abs() < _rowHeight * 0.3) {
      // Small scroll - snap to nearest row
      final rowIndex = (currentScroll / _rowHeight).round();
      targetScroll = (rowIndex * _rowHeight).clamp(0.0, maxScroll);
    } else if (scrollDelta > 0) {
      // Scrolled down - move to next row
      final currentRow = (currentScroll / _rowHeight).floor();
      final nextRow = currentRow + 1;
      targetScroll = (nextRow * _rowHeight).clamp(0.0, maxScroll);
    } else {
      // Scrolled up - move to previous row
      final currentRow = (currentScroll / _rowHeight).ceil();
      final prevRow = currentRow - 1;
      targetScroll = (prevRow * _rowHeight).clamp(0.0, maxScroll);
    }

    // Only snap if we're not already at the target row position
    if ((currentScroll - targetScroll).abs() > 1.0) {
      _isAutoScrolling = true;
      _scrollController!
          .animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            _isAutoScrolling = false;
            _scrollStartOffset = targetScroll;
          });
    }
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_scrollController != null &&
          _scrollController!.hasClients &&
          _rowHeight > 0 &&
          !_isUserScrolling) {
        final maxScroll = _scrollController!.position.maxScrollExtent;
        final currentScroll = _scrollController!.offset;

        // Calculate next scroll position (one row height)
        final nextScroll = currentScroll + _rowHeight;

        _isAutoScrolling = true;
        if (nextScroll > maxScroll) {
          // Scroll back to top
          _scrollController!
              .animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isAutoScrolling = false;
              });
        } else {
          // Scroll to next row
          _scrollController!
              .animateTo(
                nextScroll,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isAutoScrolling = false;
              });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/images/peso_logo.png', height: 24),
          ),
        ),
        title: Text(
          'PESO BILL SCANNER',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Scanner guidelines',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const _ScannerGuidelinesDialog(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: _UniversalScannerCard(
                onTap: () {
                  // Find the parent navigation shell and switch to scan page
                  final navigationShellState = context
                      .findAncestorStateOfType<_RootNavigationShellState>();
                  if (navigationShellState != null) {
                    navigationShellState.changeSelectedIndex(1);
                  } else {
                    // Fallback: navigate if navigation shell not found
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UniversalScanPage(
                          denominations: BillScannerHomePage._denominations,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'BILL ENCYCLOPEDIA',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate card dimensions for 2 columns
              final screenWidth = constraints.maxWidth;
              final horizontalPadding = 20.0 * 2; // left + right padding
              final spacing = 16.0; // crossAxisSpacing
              final cardWidth = (screenWidth - horizontalPadding - spacing) / 2;
              final cardHeight = cardWidth; // aspectRatio is 1.0
              // Height for exactly 2 rows: 2 cards + 1 spacing between rows
              final containerHeight = (cardHeight * 2) + spacing;
              // Height of one row: 1 card + spacing
              _rowHeight = cardHeight + spacing;

              return SizedBox(
                height: containerHeight,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: BillScannerHomePage._denominations.length,
                        itemBuilder: (context, index) {
                          final denomination =
                              BillScannerHomePage._denominations[index];
                          return _DenominationGridCard(
                            denomination: denomination,
                            onTap: () =>
                                _showDenominationDetails(context, denomination),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showDenominationDetails(
    BuildContext context,
    Denomination denomination,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DenominationDetailsSheet(denomination: denomination),
    );
  }
}

String? _getBillImagePath(Denomination denomination) {
  final value = denomination.value;
  final isPolymer = denomination.material == BillMaterial.polymer;

  // Map denomination values to image filenames
  switch (value) {
    case 20:
      return 'assets/images/20pesos-640-1571047972.jpg';
    case 50:
      return isPolymer ? 'assets/images/new-50.jpg' : 'assets/images/50.jpg';
    case 100:
      return isPolymer
          ? 'assets/images/new-100.webp'
          : 'assets/images/100.avif';
    case 200:
      return 'assets/images/200.jpg';
    case 500:
      return isPolymer ? 'assets/images/new-500.webp' : 'assets/images/500.jpg';
    case 1000:
      return isPolymer
          ? 'assets/images/new-1000.jpg'
          : 'assets/images/1000.webp';
    default:
      return null;
  }
}

Widget _buildFallbackBadge(Denomination denomination, ThemeData theme) {
  return Container(
    height: 90,
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFF9F6F0), // Paper-like background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '₱${denomination.value}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A4A4A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E3DC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              denomination.material == BillMaterial.paper ? 'Paper' : 'Polymer',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B5B4A),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DenominationGridCard extends StatelessWidget {
  const _DenominationGridCard({
    required this.denomination,
    required this.onTap,
  });

  final Denomination denomination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = _getBillImagePath(denomination);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              Color.lerp(
                denomination.color,
                Colors.black,
                0.3,
              )?.withValues(alpha: 0.5) ??
              denomination.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(denomination.color, Colors.white, 0.95) ??
                      Colors.white,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image or fallback
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 10,
                      right: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: imagePath != null
                            ? Image.asset(
                                imagePath,
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackBadge(
                                    denomination,
                                    theme,
                                  );
                                },
                              )
                            : _buildFallbackBadge(denomination, theme),
                      ),
                    ),
                  ),
                ),
                // Denomination value + material badge on the same row
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 16,
                    right: 16,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '₱${denomination.value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              denomination.material == BillMaterial.paper
                                  ? Icons.description_outlined
                                  : Icons.polymer_outlined,
                              size: 15,
                              color: denomination.material == BillMaterial.paper
                                  ? const Color(0xFF8B6F47)
                                  : const Color(0xFF1976D2),
                            ),
                            const SizedBox(width: 1),
                            Text(
                              denomination.material == BillMaterial.paper
                                  ? 'Paper'
                                  : 'Polymer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    denomination.material == BillMaterial.paper
                                    ? const Color(0xFF8B6F47)
                                    : const Color(0xFF1976D2),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanBucket {
  const _ScanBucket({this.value, this.material, this.fallbackLabel});

  final int? value;
  final BillMaterial? material;
  final String? fallbackLabel;

  String get label {
    if (value != null) {
      if (material != null) {
        return '₱$value • ${material!.label}';
      }
      return '₱$value';
    }
    return fallbackLabel ?? 'Unknown';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ScanBucket &&
        other.value == value &&
        other.material == material &&
        other.fallbackLabel == fallbackLabel;
  }

  @override
  int get hashCode => Object.hash(value, material, fallbackLabel);
}

BillMaterial? _billMaterialFromLabel(String? label) {
  if (label == null) return null;
  for (final material in BillMaterial.values) {
    if (material.label == label) {
      return material;
    }
  }
  return null;
}

Color _resolveBucketColor(_ScanBucket bucket, ThemeData theme, int index) {
  if (bucket.value != null) {
    Denomination? denomination;
    for (final d in BillScannerHomePage._denominations) {
      if (d.value == bucket.value &&
          (bucket.material == null || d.material == bucket.material)) {
        denomination = d;
        break;
      }
    }
    if (denomination == null) {
      for (final d in BillScannerHomePage._denominations) {
        if (d.value == bucket.value) {
          denomination = d;
          break;
        }
      }
    }

    if (denomination != null) {
      final baseColor = denomination.color;
      if (bucket.material == BillMaterial.polymer) {
        return Color.lerp(baseColor, Colors.white, 0.15) ?? baseColor;
      }
      if (bucket.material == BillMaterial.paper) {
        return Color.lerp(baseColor, Colors.black, 0.05) ?? baseColor;
      }
      return baseColor;
    }
  }

  final fallbackColors = <Color>[
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
    theme.colorScheme.tertiary,
    theme.colorScheme.error,
    Colors.teal,
    Colors.indigo,
    Colors.orange,
  ];

  return fallbackColors[index % fallbackColors.length];
}

class _AnalyticsPage extends StatelessWidget {
  const _AnalyticsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/images/peso_logo.png', height: 24),
          ),
        ),
        title: Text(
          'ANALYTICS',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bill_scans')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load analytics',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Scans Yet',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start scanning bills to see analytics here',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final counts = <_ScanBucket, int>{};
          final dailyCounts = <DateTime, int>{};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final value = data['value'] as int?;
            final materialLabel = data['material'] as String?;
            final material = _billMaterialFromLabel(materialLabel);
            final mlLabel = data['label'] as String?;
            final bucket = _ScanBucket(
              value: value,
              material: material,
              fallbackLabel: value == null ? (mlLabel ?? 'Unknown') : null,
            );
            counts.update(bucket, (current) => current + 1, ifAbsent: () => 1);

            // Group by day for daily frequency chart
            final createdAt = data['createdAt'];
            if (createdAt is Timestamp) {
              final date = createdAt.toDate().toLocal();
              final day = DateTime(date.year, date.month, date.day);
              dailyCounts.update(
                day,
                (current) => current + 1,
                ifAbsent: () => 1,
              );
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _ScanFrequencyGraph(counts: counts),
              const SizedBox(height: 16),
              _DailyScanFrequencyChart(dailyCounts: dailyCounts, allDocs: docs),
            ],
          );
        },
      ),
    );
  }
}

class _ScanHistoryList extends StatelessWidget {
  const _ScanHistoryList({required this.docs});

  final List<QueryDocumentSnapshot> docs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text('Scan History', style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final value = data['value'] as int?;
              final material = data['material'] as String?;
              final confidence = (data['confidence'] as num?)?.toDouble();
              final createdAt = data['createdAt'];
              String createdAtText = '';
              if (createdAt is Timestamp) {
                final date = createdAt.toDate().toLocal();
                createdAtText =
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      value != null
                          ? '₱$value'
                          : (data['label'] as String? ?? 'Unknown bill'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (material != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    material,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          if (confidence != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(confidence * 100).toStringAsFixed(1)}% confidence',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (createdAtText.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  createdAtText,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LogsPage extends StatelessWidget {
  const _LogsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/images/peso_logo.png', height: 24),
          ),
        ),
        title: Text(
          'LOGS',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bill_scans')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load logs',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Logs Yet',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your scan history will appear here once you start scanning bills.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: _ScanHistoryList(docs: docs),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanFrequencyGraph extends StatefulWidget {
  const _ScanFrequencyGraph({required this.counts});

  final Map<_ScanBucket, int> counts;

  @override
  State<_ScanFrequencyGraph> createState() => _ScanFrequencyGraphState();
}

class _ScanFrequencyGraphState extends State<_ScanFrequencyGraph> {
  _ScanBucket? _selectedBucket;

  @override
  Widget build(BuildContext context) {
    if (widget.counts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final entries = widget.counts.entries.toList()
      ..sort((a, b) => a.key.label.compareTo(b.key.label));
    final total = entries.fold<int>(
      0,
      (accumulator, e) => accumulator + e.value,
    );
    final selectedBucket =
        _selectedBucket ?? (entries.isNotEmpty ? entries.first.key : null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pie_chart_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Scan Frequency', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          final local = details.localPosition;
                          final size = constraints.biggest;
                          final tappedBucket = _hitTestSlice(
                            local,
                            size,
                            entries,
                            total,
                          );
                          if (tappedBucket != null) {
                            setState(() {
                              _selectedBucket = tappedBucket;
                            });
                          }
                        },
                        child: CustomPaint(
                          painter: _ScanFrequencyPiePainter(
                            entries: entries,
                            total: total,
                            selectedBucket: selectedBucket,
                            theme: theme,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            if (selectedBucket != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getDistinctPieChartColor(
                          selectedBucket,
                          entries.indexWhere((e) => e.key == selectedBucket),
                          theme,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedBucket.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.counts[selectedBucket]} scans',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  _ScanBucket? _hitTestSlice(
    Offset localPosition,
    Size size,
    List<MapEntry<_ScanBucket, int>> entries,
    int total,
  ) {
    if (total == 0) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final radius = (size.shortestSide / 2) * 0.9;

    if (distance > radius || distance == 0) {
      return null;
    }

    double angle = math.atan2(dy, dx);
    if (angle < 0) angle += 2 * math.pi;

    double startAngle = -math.pi / 2;
    for (final entry in entries) {
      final sweepAngle = 2 * math.pi * (entry.value / total);
      final endAngle = startAngle + sweepAngle;

      double normStart = startAngle;
      double normEnd = endAngle;
      if (normStart < 0) {
        normStart += 2 * math.pi;
      }
      if (normEnd < 0) {
        normEnd += 2 * math.pi;
      }

      bool inSlice;
      if (normStart <= normEnd) {
        inSlice = angle >= normStart && angle < normEnd;
      } else {
        inSlice = angle >= normStart || angle < normEnd;
      }

      if (inSlice) {
        return entry.key;
      }

      startAngle = endAngle;
    }

    return null;
  }
}

Color _getDistinctPieChartColor(
  _ScanBucket bucket,
  int index,
  ThemeData theme,
) {
  // Use yellow-orange for 20 bills on the pie chart
  if (bucket.value == 20) {
    if (bucket.material == BillMaterial.polymer) {
      // Lighter yellow-orange for polymer 20 bills
      return const Color(0xFFFFB74D); // Light yellow-orange
    } else {
      // Yellow-orange for paper (cotton) 20 bills
      return const Color(0xFFFF9800); // Yellow-orange
    }
  }

  // Use violet shades for 100 bills on the pie chart
  if (bucket.value == 100) {
    if (bucket.material == BillMaterial.polymer) {
      // Lighter violet for polymer 100 bills
      return const Color(0xFFCE93D8); // Light violet
    } else {
      // Deeper violet for paper 100 bills
      return const Color(0xFFBA68C8); // Medium violet
    }
  }

  // Use blue for 1000 bills on the pie chart
  if (bucket.value == 1000) {
    if (bucket.material == BillMaterial.polymer) {
      // Lighter blue for polymer 1000 bills
      return const Color(0xFF90CAF9); // Very light blue
    } else {
      // Deeper blue for paper (cotton) 1000 bills
      return const Color(0xFF42A5F5); // Medium blue
    }
  }

  // Use yellow for 500 bills on the pie chart
  if (bucket.value == 500) {
    if (bucket.material == BillMaterial.polymer) {
      // Lighter yellow for polymer 500 bills
      return const Color(0xFFFFF59D); // Light yellow
    } else {
      // Very yellow for paper (cotton) 500 bills
      return const Color(0xFFFFEB3B); // Very yellow
    }
  }

  // Use the bill denomination colors as the base for other bills
  final baseColor = _resolveBucketColor(bucket, theme, index);

  // For same denomination but different materials, add more distinction
  // by slightly adjusting the color
  if (bucket.material == BillMaterial.polymer) {
    // Make polymer bills slightly lighter/more saturated to distinguish from paper
    final hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.1).clamp(0.0, 1.0))
        .toColor();
  }

  return baseColor;
}

class _ScanFrequencyPiePainter extends CustomPainter {
  _ScanFrequencyPiePainter({
    required this.entries,
    required this.total,
    required this.selectedBucket,
    required this.theme,
  });

  final List<MapEntry<_ScanBucket, int>> entries;
  final int total;
  final _ScanBucket? selectedBucket;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || entries.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.shortestSide / 2) * 0.7;

    double startAngle = -math.pi / 2;

    // Create a border paint for separating slices
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sweepAngle = 2 * math.pi * (entry.value / total);
      final isSelected = selectedBucket != null && entry.key == selectedBucket;

      // Use bill denomination colors as the base, with variations for materials
      final color = _getDistinctPieChartColor(entry.key, i, theme);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = color;

      final radius = isSelected ? baseRadius + 8 : baseRadius;
      final sliceRect = Rect.fromCircle(center: center, radius: radius);

      canvas.drawArc(sliceRect, startAngle, sweepAngle, true, paint);

      // Draw white border between slices
      canvas.drawArc(sliceRect, startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }

    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = theme.colorScheme.onSurface.withValues(alpha: .1);

    canvas.drawCircle(center, baseRadius + 8, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanFrequencyPiePainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.total != total ||
        oldDelegate.selectedBucket != selectedBucket;
  }
}

class _DailyScanFrequencyChart extends StatefulWidget {
  const _DailyScanFrequencyChart({
    required this.dailyCounts,
    required this.allDocs,
  });

  final Map<DateTime, int> dailyCounts;
  final List<QueryDocumentSnapshot> allDocs;

  @override
  State<_DailyScanFrequencyChart> createState() =>
      _DailyScanFrequencyChartState();
}

class _DailyScanFrequencyChartState extends State<_DailyScanFrequencyChart> {
  DateTime? _selectedWeekStart;

  void _showScansForDay(DateTime selectedDay) {
    // Filter documents for the selected day
    final dayStart = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    final scansForDay = widget.allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['createdAt'];
      if (createdAt is! Timestamp) return false;
      final date = createdAt.toDate().toLocal();
      final day = DateTime(date.year, date.month, date.day);
      return day.year == dayStart.year &&
          day.month == dayStart.month &&
          day.day == dayStart.day;
    }).toList();

    if (scansForDay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No scans found for ${_formatDate(selectedDay)}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _DayScansBottomSheet(selectedDate: selectedDay, scans: scansForDay),
    );
  }

  Future<void> _selectWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeekStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select week start date',
    );
    if (picked != null) {
      setState(() {
        _selectedWeekStart = picked;
      });
    }
  }

  List<DateTime> _getWeekDates() {
    if (_selectedWeekStart == null || widget.dailyCounts.isEmpty) {
      return [];
    }

    // Calculate the Sunday of the selected week
    final selectedDate = DateTime(
      _selectedWeekStart!.year,
      _selectedWeekStart!.month,
      _selectedWeekStart!.day,
    );
    // Get the Sunday (weekday 7) of the week containing the selected date
    // weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    final daysFromSunday = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;
    final weekStart = selectedDate.subtract(Duration(days: daysFromSunday));

    // Generate all 7 days of the week (Sunday to Saturday)
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Sort dates and get the last 14 days (or all if less than 14)
    final sortedDates = widget.dailyCounts.keys.toList()..sort();
    final recentDates = sortedDates.length > 14
        ? sortedDates.sublist(sortedDates.length - 14)
        : sortedDates;

    if (recentDates.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = widget.dailyCounts.values.reduce(math.max);
    final minDate = recentDates.first;
    final maxDate = recentDates.last;
    final weekDates = _getWeekDates();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daily Scan Frequency',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                // Minimal custom week controls beside the icon
                if (_selectedWeekStart != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _selectWeek,
                          child: Text(
                            weekDates.isNotEmpty
                                ? '${_formatDate(weekDates.first)} - ${_formatDate(weekDates.last)}'
                                : _formatDate(_selectedWeekStart!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedWeekStart = null),
                          child: const Icon(Icons.close_rounded, size: 14),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TextButton.icon(
                    onPressed: _selectWeek,
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(
                      '${_formatDate(minDate)} - ${_formatDate(maxDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Show week chart if selected, otherwise show daily chart
            if (_selectedWeekStart != null) ...[
              _buildWeekChart(theme, weekDates),
            ] else ...[
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: recentDates.map((date) {
                    final count = widget.dailyCounts[date] ?? 0;
                    final height = maxCount > 0 ? (count / maxCount) : 0.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Tooltip(
                              message:
                                  '$count scan${count != 1 ? 's' : ''}\n${_formatDate(date)}',
                              child: GestureDetector(
                                onTap: () => _showScansForDay(date),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                  height: height * 130,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDay(date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Period: ${_formatDate(minDate)} - ${_formatDate(maxDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Total: ${widget.dailyCounts.values.reduce((a, b) => a + b)} scans',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekChart(ThemeData theme, List<DateTime> weekDates) {
    if (weekDates.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No scans for selected week',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Calculate max count for the week (including days with 0 scans)
    final weekCounts = weekDates
        .map((date) => widget.dailyCounts[date] ?? 0)
        .toList();
    final maxCount = weekCounts.isNotEmpty ? weekCounts.reduce(math.max) : 1;
    final weekStart = weekDates.first; // Sunday
    final weekEnd = weekDates.last; // Saturday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekDates.map((date) {
              final count = widget.dailyCounts[date] ?? 0;
              final height = maxCount > 0 ? (count / maxCount) : 0.0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message:
                            '$count scan${count != 1 ? 's' : ''}\n${_formatDate(date)}',
                        child: GestureDetector(
                          onTap: () => _showScansForDay(date),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            height: height * 130,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDay(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Total: ${weekCounts.fold<int>(0, (a, b) => a + b)} scans',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDay(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _DayScansBottomSheet extends StatelessWidget {
  const _DayScansBottomSheet({required this.selectedDate, required this.scans});

  final DateTime selectedDate;
  final List<QueryDocumentSnapshot> scans;

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(selectedDate),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${scans.length} scan${scans.length != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scans list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: scans.length,
                itemBuilder: (context, index) {
                  final doc = scans[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final value = data['value'] as int?;
                  final material = data['material'] as String?;
                  final confidence = (data['confidence'] as num?)?.toDouble();
                  final createdAt = data['createdAt'];
                  String createdAtText = '';
                  if (createdAt is Timestamp) {
                    final date = createdAt.toDate().toLocal();
                    createdAtText =
                        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          value != null
                              ? '₱$value'
                              : (data['label'] as String? ?? 'Unknown bill'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (material != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        material,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              if (confidence != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${(confidence * 100).toStringAsFixed(1)}% confidence',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (createdAtText.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      createdAtText,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CustomWeekFrequencyChart extends StatefulWidget {
  const _CustomWeekFrequencyChart({required this.dailyCounts});

  final Map<DateTime, int> dailyCounts;

  @override
  State<_CustomWeekFrequencyChart> createState() =>
      _CustomWeekFrequencyChartState();
}

class _CustomWeekFrequencyChartState extends State<_CustomWeekFrequencyChart> {
  DateTime? _selectedWeekStart;

  Future<void> _selectWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedWeekStart ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select week start date',
    );
    if (picked != null) {
      setState(() {
        _selectedWeekStart = picked;
      });
    }
  }

  List<DateTime> _getWeekDates() {
    if (_selectedWeekStart == null || widget.dailyCounts.isEmpty) {
      return [];
    }

    final weekStart = DateTime(
      _selectedWeekStart!.year,
      _selectedWeekStart!.month,
      _selectedWeekStart!.day,
    );
    final weekEnd = weekStart.add(const Duration(days: 6));

    final sortedDates = widget.dailyCounts.keys.toList()..sort();
    return sortedDates
        .where(
          (date) =>
              date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              date.isBefore(weekEnd.add(const Duration(days: 1))),
        )
        .toList();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDay(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final weekDates = _getWeekDates();

    if (_selectedWeekStart == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Custom Week Frequency',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _selectWeek,
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: const Text('Select Week'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (weekDates.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Custom Week Frequency',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => setState(() => _selectedWeekStart = null),
                    tooltip: 'Clear selection',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No scans for selected week',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxCount = weekDates
        .map((date) => widget.dailyCounts[date] ?? 0)
        .reduce(math.max);
    final weekStart = _selectedWeekStart!;
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Generate all 7 days of the week, even if some have no scans
    final allWeekDays = List.generate(7, (index) {
      return weekStart.add(Duration(days: index));
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Custom Week Frequency',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectWeek,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Change'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => setState(() => _selectedWeekStart = null),
                  tooltip: 'Clear selection',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: allWeekDays.map((date) {
                  final count = widget.dailyCounts[date] ?? 0;
                  final height = maxCount > 0 ? (count / maxCount) : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message:
                                '$count scan${count != 1 ? 's' : ''}\n${_formatDate(date)}',
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    theme.colorScheme.tertiary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              height: height * 130,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDay(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Week: ${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Total: ${weekDates.map((d) => widget.dailyCounts[d] ?? 0).fold<int>(0, (a, b) => a + b)} scans',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UniversalScanPage extends StatefulWidget {
  const UniversalScanPage({super.key, required this.denominations});

  final List<Denomination> denominations;

  @override
  State<UniversalScanPage> createState() => _UniversalScanPageState();
}

class _UniversalScanPageState extends State<UniversalScanPage> {
  final BillClassifier _classifier = BillClassifier();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _encyclopediaScrollController = ScrollController();
  Timer? _encyclopediaAutoScrollTimer;

  bool _isScanning = false;
  String? _errorMessage;

  bool _isUserScrollingEncyclopedia = false;
  bool _isAutoScrollingEncyclopedia = false;
  double _lastEncyclopediaScrollOffset = 0;
  Timer? _encyclopediaSnapTimer;

  @override
  void initState() {
    super.initState();
    _encyclopediaScrollController.addListener(_onEncyclopediaScroll);
    _startEncyclopediaAutoScroll();
  }

  @override
  void dispose() {
    _classifier.close();
    _encyclopediaAutoScrollTimer?.cancel();
    _encyclopediaSnapTimer?.cancel();
    _encyclopediaScrollController.removeListener(_onEncyclopediaScroll);
    _encyclopediaScrollController.dispose();
    super.dispose();
  }

  void _onEncyclopediaScroll() {
    final currentOffset = _encyclopediaScrollController.offset;

    // Check if user is actively scrolling (not programmatic)
    if (!_isAutoScrollingEncyclopedia &&
        _encyclopediaScrollController.position.isScrollingNotifier.value) {
      if (!_isUserScrollingEncyclopedia) {
        _isUserScrollingEncyclopedia = true;
        _pauseEncyclopediaAutoScroll();
      }
      _lastEncyclopediaScrollOffset = currentOffset;
      _encyclopediaSnapTimer?.cancel();
    }

    // Detect when scrolling stops and snap to nearest card
    if (!_isAutoScrollingEncyclopedia && _isUserScrollingEncyclopedia) {
      _encyclopediaSnapTimer?.cancel();
      _encyclopediaSnapTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted &&
            !_isAutoScrollingEncyclopedia &&
            _encyclopediaScrollController.hasClients &&
            (_encyclopediaScrollController.offset -
                        _lastEncyclopediaScrollOffset)
                    .abs() <
                1.0) {
          _snapToNearestCard();
        }
      });
    }
  }

  void _snapToNearestCard() {
    if (!_encyclopediaScrollController.hasClients) return;

    const cardWidth = 152.0; // 140px card + 12px margin
    final currentScroll = _encyclopediaScrollController.offset;
    final maxScroll = _encyclopediaScrollController.position.maxScrollExtent;

    // Calculate which card we're closest to
    final cardIndex = (currentScroll / cardWidth).round();
    final targetScroll = (cardIndex * cardWidth).clamp(0.0, maxScroll);

    // Only snap if we're not already at a card position
    if ((currentScroll - targetScroll).abs() > 1.0) {
      _isAutoScrollingEncyclopedia = true;
      _encyclopediaScrollController
          .animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            _isAutoScrollingEncyclopedia = false;
            _isUserScrollingEncyclopedia = false;
            _startEncyclopediaAutoScroll();
          });
    } else {
      _isUserScrollingEncyclopedia = false;
      _startEncyclopediaAutoScroll();
    }
  }

  void _pauseEncyclopediaAutoScroll() {
    _encyclopediaAutoScrollTimer?.cancel();
    _encyclopediaAutoScrollTimer = null;
  }

  void _startEncyclopediaAutoScroll() {
    _encyclopediaAutoScrollTimer?.cancel();
    _encyclopediaAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
      if (mounted &&
          _encyclopediaScrollController.hasClients &&
          !_isUserScrollingEncyclopedia) {
        final maxScroll =
            _encyclopediaScrollController.position.maxScrollExtent;
        final currentScroll = _encyclopediaScrollController.offset;

        // Card width is 140 + 12 margin = 152 pixels per card
        const cardWidth = 152.0;

        final nextScroll = currentScroll + cardWidth;

        _isAutoScrollingEncyclopedia = true;
        if (nextScroll > maxScroll) {
          // Scroll back to start
          _encyclopediaScrollController
              .animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isAutoScrollingEncyclopedia = false;
              });
        } else {
          // Scroll to next card
          _encyclopediaScrollController
              .animateTo(
                nextScroll,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isAutoScrollingEncyclopedia = false;
              });
        }
      }
    });
  }

  void _showDenominationDetails(
    BuildContext context,
    Denomination denomination,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DenominationDetailsSheet(denomination: denomination),
    );
  }

  Future<void> _scanFromSource(ImageSource source) async {
    if (_isScanning) return;
    final capture = await _picker.pickImage(source: source, imageQuality: 95);
    if (capture == null) {
      return;
    }

    final imageFile = File(capture.path);

    // Set loading state immediately after image is selected
    // This ensures the UI shows loading state right away
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    // Yield to allow Flutter to update the UI before heavy processing
    await Future.microtask(() {});

    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    try {
      final prediction = await _classifier.classify(imageFile);

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      final matchedDenomination = _matchDenomination(prediction);

      if (prediction != null && matchedDenomination != null) {
        try {
          await FirebaseFirestore.instance.collection('bill_scans').add({
            'label': prediction.label,
            'confidence': prediction.confidence,
            'value': matchedDenomination.value,
            'material': matchedDenomination.material.label,
            'createdAt': Timestamp.now(),
          });
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isScanning = false;
        });

        // Always show feedback to the user, even on failure
        if (prediction == null) {
          // Show error dialog when prediction fails
          _showErrorDialog(
            'Unable to Identify Bill',
            'The model could not identify this bill. This might be due to:\n\n'
                '• Poor lighting or image quality\n'
                '• Bill not fully visible in frame\n'
                '• Blurry or out-of-focus image\n'
                '• Confidence below threshold\n\n'
                'Please try again with better lighting and ensure the entire bill is visible.',
          );
        } else if (matchedDenomination == null) {
          // Show error dialog when prediction doesn't match any denomination
          final displayLabel = prediction.displayLabel;
          _showErrorDialog(
            'Bill Not Recognized',
            'The model identified this as "$displayLabel" but it doesn\'t match any configured denomination.\n\n'
                'Confidence: ${(prediction.confidence * 100).toStringAsFixed(1)}%\n\n'
                'Please ensure:\n'
                '• The entire bill is clearly visible\n'
                '• Good lighting conditions\n'
                '• Bill is not damaged or obscured',
          );
        } else {
          // Success - show confidence dialog
          _showConfidenceDialog(prediction, matchedDenomination);
        }
      }
    } on BillClassifierException catch (error) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showErrorDialog('Scanning Error', error.message);
      }
    } catch (error, stackTrace) {
      // Log the full error for debugging
      debugPrint('Scanning error: $error');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showErrorDialog(
          'Scanning Failed',
          'An unexpected error occurred while scanning.\n\n'
              'Error: ${error.toString()}\n\n'
              'Please try again. If the problem persists, ensure:\n'
              '• Your device has sufficient memory\n'
              '• The image file is not corrupted\n'
              '• You have a stable internet connection (if using cloud features)',
        );
      }
    }
  }

  Future<void> _startScan() async {
    await _scanFromSource(ImageSource.camera);
  }

  Future<void> _pickFromGallery() async {
    await _scanFromSource(ImageSource.gallery);
  }

  Denomination? _matchDenomination(BillPrediction? prediction) {
    if (prediction == null) return null;
    final value = prediction.valueMatch;
    if (value == null) return null;

    for (final denomination in widget.denominations) {
      final matchesValue = denomination.value == value;
      if (!matchesValue) continue;
      if (prediction.indicatesPolymer &&
          denomination.material != BillMaterial.polymer) {
        continue;
      }
      if (prediction.indicatesPaper &&
          denomination.material != BillMaterial.paper) {
        continue;
      }
      return denomination;
    }
    return null;
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(message, style: theme.textTheme.bodyMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHowToScanDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('How to scan'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InstructionStep(
                  icon: Icons.camera_enhance_rounded,
                  title: 'Align the bill',
                  description:
                      'Place the bill on a flat surface with good lighting. Align all edges inside the guide overlay.',
                ),
                SizedBox(height: 12),
                _InstructionStep(
                  icon: Icons.texture_rounded,
                  title: 'Capture security zones',
                  description:
                      'Slowly hover over the holographic patch, transparent window (polymer), and watermark areas.',
                ),
                SizedBox(height: 12),
                _InstructionStep(
                  icon: Icons.fact_check_rounded,
                  title: 'Confirm markers',
                  description:
                      'Follow on-screen prompts to validate tactile marks, serial numbers, and color shifts.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showConfidenceDialog(
    BillPrediction prediction,
    Denomination? matchedDenomination,
  ) {
    if (!mounted) return;

    final confidence = prediction.confidence;
    final confidencePct = (confidence * 100).toStringAsFixed(1);
    final displayLabel = prediction.displayLabel;

    String confidenceLevel;
    Color? confidenceColor;

    if (confidence >= 0.8) {
      confidenceLevel = 'High confidence';
      confidenceColor = Colors.green.shade600;
    } else if (confidence >= 0.6) {
      confidenceLevel = 'Medium confidence';
      confidenceColor = Colors.orange.shade700;
    } else {
      confidenceLevel = 'Low confidence';
      confidenceColor = Colors.red.shade700;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Scan result'),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (matchedDenomination != null) ...[
                    Text(
                      'Detected bill',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${matchedDenomination.value} • ${matchedDenomination.material.label}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text(
                      'Detected label',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Model confidence',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: confidence.clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              confidenceColor ?? theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$confidencePct%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: confidenceColor ?? theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          confidenceLevel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (prediction.scores.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'All class confidences',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...() {
                      final entries = prediction.scores.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      // Palette of distinct colors to give each class its own
                      // visual identity in the confidence list.
                      final palette = <Color>[
                        Colors.teal,
                        Colors.indigo,
                        Colors.orange,
                        Colors.purple,
                        Colors.blueGrey,
                        Colors.pink,
                        Colors.cyan,
                        Colors.amber,
                      ];

                      return List.generate(entries.length, (index) {
                        final entry = entries[index];
                        final classColor = palette[index % palette.length];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.key.replaceFirst(
                                    RegExp(r'^\d+\s*'),
                                    '',
                                  ),
                                  style: theme.textTheme.bodySmall,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: entry.value.clamp(0, 1),
                                    minHeight: 6,
                                    backgroundColor: classColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      classColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  '${(entry.value * 100).toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    }(),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/images/peso_logo.png', height: 24),
          ),
        ),
        title: Text(
          'BILL SCAN',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'How to scan',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showHowToScanDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always show the initial \"Ready to Scan\" hero so the
                  // Universal Scan UI does not change after a scan.
                  const _ScanReadyHero(),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: _isScanning
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner_rounded, size: 22),
                    label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isScanning ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_rounded, size: 22),
                    label: const Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Card(
                      color: theme.colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: theme.colorScheme.onErrorContainer,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Bill Encyclopedia horizontal scroll
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'BILL ENCYCLOPEDIA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    controller: _encyclopediaScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    itemCount: widget.denominations.length,
                    itemBuilder: (context, index) {
                      final denomination = widget.denominations[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        child: _DenominationGridCard(
                          denomination: denomination,
                          onTap: () =>
                              _showDenominationDetails(context, denomination),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHeroSection extends StatelessWidget {
  const _ScanHeroSection({required this.denomination});

  final Denomination denomination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = denomination.color;
    final imagePath = _getBillImagePath(denomination);

    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.15),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: imagePath != null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(0, 186, 4, 4),
                  color.withValues(alpha: 0.7),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, Colors.white, 0.3) ?? color],
              ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Row(
            children: [
              Text(
                '₱${denomination.value}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontSize: 42,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    denomination.material == BillMaterial.polymer
                        ? Icons.polymer_rounded
                        : Icons.description_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    denomination.material == BillMaterial.polymer
                        ? 'Polymer'
                        : 'Paper',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerGuidelinesDialog extends StatelessWidget {
  const _ScannerGuidelinesDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Scanning Guidelines',
              // To adjust size, change fontSize value below (try: 12, 14, 16, 18, 20, 22)
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 19, // Change this number to find your preferred size
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuidelineItem(
            icon: Icons.light_mode_rounded,
            text: 'Use diffused white light to avoid glare.',
          ),
          const SizedBox(height: 12),
          _GuidelineItem(
            icon: Icons.cleaning_services_rounded,
            text: 'Clean the camera lens before scanning.',
          ),
          const SizedBox(height: 12),
          _GuidelineItem(
            icon: Icons.flip_camera_ios_rounded,
            text: 'Capture both sides of polymer bills for window checks.',
          ),
          const SizedBox(height: 12),
          _GuidelineItem(
            icon: Icons.refresh_rounded,
            text:
                'Re-scan if the app detects motion blur or inconsistent focus.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  const _GuidelineItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

class _UniversalScannerCard extends StatelessWidget {
  const _UniversalScannerCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Scan a Peso Bill',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Detect paper and polymer bills instantly',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DenominationDetailsSheet extends StatelessWidget {
  const _DenominationDetailsSheet({required this.denomination});

  final Denomination denomination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScanHeroSection(denomination: denomination),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Security Checklist',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...denomination.securityFeatures.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.1,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanReadyHero extends StatelessWidget {
  const _ScanReadyHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ready to Scan',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap "Start Scan" and align the bill inside the camera frame. '
            'We will automatically identify the denomination and material.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
