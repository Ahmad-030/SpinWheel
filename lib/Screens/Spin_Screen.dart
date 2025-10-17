import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/Spin_Entry.dart';
import '../Providers/Theme_provider.dart';
import '../Widgets/Spin_reel.dart';

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
  late AnimationController _spinController;
  late AnimationController _winnerController;
  late Animation<double> _winnerAnimation;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _winnerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _winnerAnimation = CurvedAnimation(
      parent: _winnerController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _winnerController.dispose();
    super.dispose();
  }

  void _startSpin() async {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      winner = null;
    });

    // Get available entries (exclude previous winner)
    List<SpinEntry> availableEntries = widget.entries
        .where((entry) => entry.id != previousWinner?.id)
        .toList();

    if (availableEntries.isEmpty) {
      availableEntries = widget.entries;
      previousWinner = null;
    }

    // Spin animation
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(milliseconds: 50 + i * 5));
      setState(() {
        currentIndex = (currentIndex + 1) % availableEntries.length;
      });
    }

    // Select winner
    final winnerIndex = DateTime.now().millisecond % availableEntries.length;
    setState(() {
      winner = availableEntries[winnerIndex];
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
      appBar: AppBar(
        title: const Text('Spin Wheel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Spin Reel
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: Center(
                  child: SpinReel(
                    entry: isSpinning
                        ? availableEntries[currentIndex % availableEntries.length]
                        : (winner ?? availableEntries[0]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Winner display
            if (winner != null && !isSpinning)
              ScaleTransition(
                scale: _winnerAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(winner!.gradientStart.replaceAll('#', '0xFF'))),
                        Color(int.parse(winner!.gradientEnd.replaceAll('#', '0xFF'))),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(int.parse(winner!.gradientStart.replaceAll('#', '0xFF')))
                            .withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎉 Winner! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        winner!.type == 'text' ? winner!.value : 'Image Entry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Spin buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isSpinning ? null : _startSpin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: winner != null ? Colors.orange : Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        winner != null ? Icons.refresh : Icons.play_arrow,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSpinning
                            ? 'Spinning...'
                            : (winner != null ? 'Spin Again' : 'Start Spin'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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