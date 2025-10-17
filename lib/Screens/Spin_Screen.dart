import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:math' as math;

import '../Models/Spin_Entry.dart';
import '../Providers/Theme_provider.dart';

class SpinScreen extends StatefulWidget {
  final List<SpinEntry> entries;

  const SpinScreen({Key? key, required this.entries}) : super(key: key);

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with TickerProviderStateMixin {
  bool isSpinning = false;
  SpinEntry? winner;
  SpinEntry? previousWinner;
  late AnimationController _slotController;
  late AnimationController _winnerController;
  late AnimationController _glowController;
  late Animation<double> _slotAnimation;
  late Animation<double> _winnerScaleAnimation;
  late Animation<double> _glowAnimation;

  double _slotOffset = 0;
  int finalIndex = 0;
  final double itemHeight = 160.0;

  @override
  void initState() {
    super.initState();

    _slotController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    _slotAnimation = CurvedAnimation(
      parent: _slotController,
      curve: Curves.easeOutQuart,
    );

    _winnerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _winnerScaleAnimation = CurvedAnimation(
      parent: _winnerController,
      curve: Curves.elasticOut,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _slotAnimation.addListener(() {
      setState(() {
        _slotOffset = _slotAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _slotController.dispose();
    _winnerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startSpin() async {
    if (isSpinning || widget.entries.isEmpty) return;

    setState(() {
      isSpinning = true;
      winner = null;
    });

    List<SpinEntry> availableEntries = widget.entries
        .where((entry) => entry.id != previousWinner?.id)
        .toList();

    if (availableEntries.isEmpty) {
      availableEntries = widget.entries;
      previousWinner = null;
    }

    final random = math.Random();
    finalIndex = random.nextInt(availableEntries.length);

    _slotController.reset();
    await _slotController.forward();

    setState(() {
      winner = availableEntries[finalIndex];
      previousWinner = winner;
      isSpinning = false;
    });

    _winnerController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    List<SpinEntry> availableEntries = widget.entries
        .where((entry) => entry.id != previousWinner?.id)
        .toList();

    if (availableEntries.isEmpty) {
      availableEntries = widget.entries;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ]
                : [
              const Color(0xFFf5f7fa),
              const Color(0xFFe8ecf1),
              const Color(0xFFf5f7fa),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'SPIN WHEEL',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSlotMachine(isDark, availableEntries),
                        if (winner != null && !isSpinning) ...[
                          const SizedBox(height: 30),
                          _buildWinnerDisplay(isDark),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildSpinButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotMachine(bool isDark, List<SpinEntry> entries) {
    // Corrected the chromeHighlight back to a blueGrey tone for consistency
    final Color chromeColor = isDark ? Colors.blueGrey[800]! : Colors.grey[700]!;
    final Color chromeHighlight = isDark ? Colors.blueGrey[600]! : Colors.grey[500]!;


    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 50,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222222) : Colors.grey[300],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: chromeColor, width: 6),
          ),
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
          child: _buildSlotReel(isDark, entries),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            height: 30,
            constraints: const BoxConstraints(maxWidth: 370),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [chromeColor, chromeHighlight, chromeColor],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: chromeColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            height: 30,
            constraints: const BoxConstraints(maxWidth: 370),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [chromeColor, chromeHighlight, chromeColor],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: chromeColor.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotReel(bool isDark, List<SpinEntry> entries) {
    return Container(
      height: itemHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white, // This is the background of the reel behind the items
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // Corrected reel border to match chrome color if desired, or keep neutral
          color: Colors.white, // Keeping a neutral grey border for the reel
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            _buildAnimatedSlotItems(entries),
            // Row(
            //   children: List.generate(
            //     3,
            //         (index) => Expanded(
            //       child: Container(
            //         margin: index < 2 ? const EdgeInsets.only(right: 1.0) : null,
            //         decoration: BoxDecoration(
            //           border: Border(
            //             right: index < 2
            //                 ? BorderSide(color: Colors.yellow[800]!, width: 2)
            //                 : BorderSide.none,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Changed to match background of reel, not white, for seamless look
                      isDark ? const Color(0xFF0A0A0A).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                      Colors.transparent,
                      Colors.transparent,
                      isDark ? const Color(0xFF0A0A0A).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    height: itemHeight - 20,
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(
                            winner != null ? 0.2 : _glowAnimation.value * 0.1,
                          ),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSlotItems(List<SpinEntry> entries) {
    if (entries.isEmpty) return const SizedBox();

    final extendedEntries = List<SpinEntry>.generate(
      entries.length * 20,
          (index) => entries[index % entries.length],
    );

    final fullSpins = 5;
    final totalDistance = entries.length * fullSpins + finalIndex;
    final maxScrollOffset = totalDistance * itemHeight;

    final currentOffset = -_slotAnimation.value * maxScrollOffset;

    return Transform.translate(
      offset: Offset(0, currentOffset),
      child: Column(
        children: extendedEntries.asMap().entries.map((entry) {
          final item = entry.value;

          return Center(
            child: SizedBox(
              height: itemHeight,
              width: itemHeight,
              // --- CRITICAL CHANGE: Removed Padding here completely ---
              child: _buildReelItem(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReelItem(SpinEntry entry) {
    // Define a consistent inner padding for content (text or image)
    const double innerContentPadding = 0.0; // This will provide internal spacing for content

    return Container(
      // The outer container takes the full itemHeight/itemWidth (160x160)
      // and defines the rounded corners and gradient for the entire slot item.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(entry.gradientStart.replaceAll('#', '0xFF'))),
            Color(int.parse(entry.gradientEnd.replaceAll('#', '0xFF'))),
          ],
        ),
        // --- MODIFIED: Ensure this borderRadius is consistent and defines the visual edge ---
        borderRadius: BorderRadius.circular(10), // A slightly larger radius for the main item
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Use Padding around the actual content (text or image) to create the inner buffer
      child: Padding(
        padding: const EdgeInsets.all(innerContentPadding), // Apply inner padding here
        child: entry.type == 'text'
            ? Center( // Center text explicitly within its padding
          child: Text(
            entry.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
            : ClipRRect(
          // --- MODIFIED: borderRadius should be slightly smaller than the outer container
          //                to account for the `innerContentPadding` and create a consistent inner curve.
          borderRadius: BorderRadius.circular(10 - innerContentPadding * 0.5), // Adjust this value
          child: SizedBox.expand(
            child: Image.file(
              File(entry.value),
              fit: BoxFit.scaleDown, // This centers the image within the available space
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 60,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerDisplay(bool isDark) {
    if (winner == null) return const SizedBox.shrink();

    final Color chromeColor = isDark ? Colors.blueGrey[800]! : Colors.grey[700]!;
    final Color chromeHighlight = isDark ? Colors.blueGrey[600]! : Colors.grey[500]!;

    return ScaleTransition(
      scale: _winnerScaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [chromeColor, chromeHighlight],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: chromeColor.withOpacity(0.8),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Text(
                    '🎉 WINNER! 🎉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.star, color: Colors.white, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(winner!.gradientStart.replaceAll('#', '0xFF'))),
                    Color(int.parse(winner!.gradientEnd.replaceAll('#', '0xFF'))),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Color(int.parse(winner!.gradientStart.replaceAll('#', '0xFF')))
                        .withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: winner!.type == 'text'
                        ? const Center(
                      child: Icon(Icons.text_fields, color: Colors.white, size: 50),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(
                        File(winner!.value),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          winner!.type == 'text' ? 'Text Entry' : 'Image Entry',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          winner!.type == 'text'
                              ? winner!.value
                              : winner!.value.split('/').last,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildSpinButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.7),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isSpinning ? null : _startSpin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[500],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSpinning
                  ? Icons.hourglass_bottom
                  : (winner != null ? Icons.replay : Icons.play_arrow),
              size: 32,
            ),
            const SizedBox(width: 14),
            Text(
              isSpinning
                  ? 'SPINNING...'
                  : (winner != null ? 'SPIN AGAIN' : 'START SPIN'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}