import 'package:flutter/material.dart';
import 'image_to_pdf_screen.dart';
import 'image_compressor_screen.dart';
import 'pdf_compressor_screen.dart';
import 'image_converter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A0F1F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBA88AE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final Color cardColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color arrowColor;
  final Color arrowBg;
  final double tiltAngle; // in radians
  final VoidCallback onTap;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.cardColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.arrowColor,
    required this.arrowBg,
    required this.tiltAngle,
    required this.onTap,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // index 0 = furthest back (darkest), last = on top (lightest)
    // tiltAngle: positive = right tilt, negative = left tilt
    final tools = [
      _ToolItem(
        title: 'Image Converter',
        subtitle: 'Change any format',
        cardColor: const Color(0xFF5B3765),
        titleColor: const Color(0xFFF3CCDE),
        subtitleColor: const Color(0xFFBA88AE),
        arrowColor: const Color(0xFFF3CCDE),
        arrowBg: Colors.white12,
        tiltAngle: 0.045,   // tilted right
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageConverterScreen())),
      ),
      _ToolItem(
        title: 'Compress Images',
        subtitle: 'Shrink without loss',
        cardColor: const Color(0xFF9E6899),
        titleColor: const Color(0xFF1A0F1F),
        subtitleColor: const Color(0xFF3D1F4A),
        arrowColor: const Color(0xFF1A0F1F),
        arrowBg: Colors.black12,
        tiltAngle: -0.04,  // tilted left
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageCompressorScreen())),
      ),
      _ToolItem(
        title: 'Compress PDF',
        subtitle: 'Reduce file size',
        cardColor: const Color(0xFFBA88AE),
        titleColor: const Color(0xFF1A0F1F),
        subtitleColor: const Color(0xFF5B3765),
        arrowColor: const Color(0xFF1A0F1F),
        arrowBg: Colors.black12,
        tiltAngle: 0.03,   // tilted right (subtle)
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PdfCompressorScreen())),
      ),
      _ToolItem(
        title: 'Images → PDF',
        subtitle: 'Combine & convert',
        cardColor: const Color(0xFFD6A8C4),
        titleColor: const Color(0xFF1A0F1F),
        subtitleColor: const Color(0xFF5B3765),
        arrowColor: const Color(0xFF1A0F1F),
        arrowBg: Colors.black12,
        tiltAngle: -0.02,  // almost straight, tiny left tilt
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageToPdfScreen())),
      ),
    ];

    final double peekAmount = screenHeight * 0.13;
    final double cardHeight = screenHeight * 0.20;
    final double stackHeight = cardHeight + (tools.length - 1) * peekAmount;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0F1F), Color(0xFF2D1A33)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── CENTERED HEADER ──
              const SizedBox(height: 36),
              const Text(
                'Your cute toolbox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 2,
                  color: Color(0xFFBA88AE),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Slate Studio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF3CCDE),
                  letterSpacing: -0.5,
                ),
              ),

              // ── SPACER PUSHES CARDS TO BOTTOM ──
              const Spacer(),

              // ── STACKED TILTED CARDS AT BOTTOM ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SizedBox(
                  height: stackHeight,
                  child: Stack(
                    children: List.generate(tools.length, (i) {
                      return Positioned(
                        top: i * peekAmount,
                        left: 0,
                        right: 0,
                        height: cardHeight,
                        child: Transform.rotate(
                          angle: tools[i].tiltAngle,
                          alignment: Alignment.bottomCenter,
                          child: _StackedCard(item: tools[i]),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackedCard extends StatelessWidget {
  final _ToolItem item;
  const _StackedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: item.cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: item.titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 17,
                      color: item.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.arrowBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: item.arrowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}