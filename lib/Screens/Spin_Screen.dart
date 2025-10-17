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

    // Get available entries
    List<SpinEntry> availableEntries = widget.entries
        .where((entry) => entry.id != previousWinner?.id)
        .toList();

    if (availableEntries.isEmpty) {
      availableEntries = widget.entries;
      previousWinner = null;
    }

    // Select winner index
    final random = math.Random();
    finalIndex = random.nextInt(availableEntries.length);

    // Calculate total rotation: multiple full spins + final position
    final fullSpins = 5;
    final totalItems = availableEntries.length * fullSpins + finalIndex;

    // Reset and start animation
    _slotController.reset();
    await _slotController.forward();

    // Set winner after animation
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
              // Header
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

              // Slot Machine and Winner Display - Scrollable
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

              // Spin Button - Fixed at bottom
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top decoration
        Container(
          height: 12,
          width: MediaQuery.of(context).size.width - 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber[700]!,
                Colors.yellow[400]!,
                Colors.amber[700]!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
        ),

        // Main slot container
        Container(
          width: MediaQuery.of(context).size.width - 70,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF0F0F1E)]
                  : [Colors.white, Colors.grey[100]!],
            ),
            border: Border(
              left: BorderSide(color: Colors.amber[600]!, width: 4),
              right: BorderSide(color: Colors.amber[600]!, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: _buildSlotReel(isDark, entries),
        ),

        // Bottom decoration
        Container(
          height: 12,
          width: MediaQuery.of(context).size.width - 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber[700]!,
                Colors.yellow[400]!,
                Colors.amber[700]!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlotReel(bool isDark, List<SpinEntry> entries) {
    return Container(
      height: itemHeight,
      decoration: BoxDecoration(
        color: isDark ? Colors.black45 : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber[400]!,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Gradient overlays for depth
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Slot items
            _buildAnimatedSlotItems(entries),

            // Center highlight
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    height: itemHeight - 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber[300]!.withValues(
                          alpha: winner != null ? 1.0 : _glowAnimation.value,
                        ),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(
                            alpha: winner != null ? 0.9 : _glowAnimation.value * 0.6,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
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

    // Create extended list for smooth infinite scrolling
    final extendedEntries = List<SpinEntry>.generate(
      entries.length * 10,
          (index) => entries[index % entries.length],
    );

    // Calculate scroll offset
    final fullSpins = 5;
    final totalDistance = entries.length * fullSpins + finalIndex;
    final currentOffset = -_slotOffset * totalDistance * itemHeight;

    return Transform.translate(
      offset: Offset(0, currentOffset),
      child: Column(
        children: extendedEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return SizedBox(
            height: itemHeight,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _buildReelItem(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReelItem(SpinEntry entry) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(entry.gradientStart.replaceAll('#', '0xFF'))),
            Color(int.parse(entry.gradientEnd.replaceAll('#', '0xFF'))),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: entry.type == 'text'
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            entry.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(
          File(entry.value),
          fit: BoxFit.cover,
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
    );
  }

  Widget _buildWinnerDisplay(bool isDark) {
    if (winner == null) return const SizedBox.shrink();

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
                  colors: [Colors.amber[700]!, Colors.yellow[400]!],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.8),
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
                        .withValues(alpha: 0.6),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
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
                        fit: BoxFit.cover,
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
            color: Colors.green.withValues(alpha: 0.7),
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