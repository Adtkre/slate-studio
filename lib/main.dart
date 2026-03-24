import 'dart:ui';
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
  final double tiltAngle;
  final List<BoxShadow> shadows;
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
    required this.shadows,
    required this.onTap,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final tools = [
      _ToolItem(
        title: 'Image Converter',
        subtitle: 'Change any format',
        cardColor: const Color(0xFF3D1A4A),
        titleColor: const Color(0xFFF3CCDE),
        subtitleColor: const Color(0xFFBA88AE),
        arrowColor: const Color(0xFFF3CCDE),
        arrowBg: Colors.white10,
        tiltAngle: 0.049,
        shadows: const [
          BoxShadow(
            color: Color(0xFF0D070F),
            blurRadius: 40,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0xFF1A0F1F),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageConverterScreen())),
      ),
      _ToolItem(
        title: 'Compress Images',
        subtitle: 'Shrink without loss',
        cardColor: const Color(0xFF6B3D6A),
        titleColor: const Color(0xFFF3CCDE),
        subtitleColor: const Color(0xFFD6A8C4),
        arrowColor: const Color(0xFFF3CCDE),
        arrowBg: Colors.white12,
        tiltAngle: -0.042,
        shadows: const [
          BoxShadow(
            color: Color(0xCC0D070F),
            blurRadius: 44,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0xEE1A0F1F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageCompressorScreen())),
      ),
      _ToolItem(
        title: 'Compress PDF',
        subtitle: 'Reduce file size',
        cardColor: const Color(0xFFBA88AE),
        titleColor: const Color(0xFF1A0F1F),
        subtitleColor: const Color(0xFF3D1F4A),
        arrowColor: const Color(0xFF1A0F1F),
        arrowBg: Colors.black12,
        tiltAngle: 0.031,
        shadows: const [
          BoxShadow(
            color: Color(0xBB0D070F),
            blurRadius: 48,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0xDD1A0F1F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
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
        tiltAngle: -0.021,
        shadows: const [
          BoxShadow(
            color: Color(0xAA0D070F),
            blurRadius: 56,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0xCC1A0F1F),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x26D6A8C4),
            blurRadius: 0,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ImageToPdfScreen())),
      ),
    ];

    final double peekAmount = screenHeight * 0.13;
    final double cardHeight = screenHeight * 0.20;
    final double stackHeight = cardHeight + (tools.length - 1) * peekAmount;

    return Scaffold(
      body: Stack(
        children: [
          // ── GRADIENT BASE ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A0F1F), Color(0xFF2D1A33), Color(0xFF1A0F1F)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── BACKGROUND BLOBS ──
          Positioned(
            top: -40,
            left: -40,
            child: _blob(200, const Color(0xFF5B3765), 0.35),
          ),
          Positioned(
            top: 80,
            right: -60,
            child: _blob(180, const Color(0xFFBA88AE), 0.15),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            child: _blob(220, const Color(0xFF3D1A4A), 0.40),
          ),

          // ── MAIN CONTENT ──
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 36),
                const Text(
                  'Your cute toolbox',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.5,
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
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF3CCDE),
                    letterSpacing: -1,
                  ),
                ),

                const Spacer(),

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
        ],
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
          boxShadow: item.shadows,
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
                      fontWeight: FontWeight.w800,
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