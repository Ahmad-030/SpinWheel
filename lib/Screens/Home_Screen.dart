import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/Spin_Entry.dart';
import '../Providers/Theme_provider.dart';
import '../Widgets/Add_entry_dialog.dart';
import '../Widgets/Entry_card.dart';
import 'Spin_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<SpinEntry> entries = [];
  late AnimationController _animationController;
  late AnimationController _lottieController;
  late Animation<double> _fadeAnimation;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _showAddDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AddEntryDialog(
        type: type,
        onAdd: (value) {
          setState(() {
            if (type == 'text') {
              entries.add(SpinEntry.createText(value, entries.length));
            } else {
              entries.add(SpinEntry.createImage(value, entries.length));
            }
          });
        },
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          entries.add(SpinEntry.createImage(image.path, entries.length));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _removeEntry(String id) {
    setState(() {
      entries.removeWhere((entry) => entry.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with theme toggle
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spin Wheel',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    IconButton(
                      onPressed: themeProvider.toggleTheme,
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.yellow : Colors.orange,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Lottie Animation from local asset
              SizedBox(
                height: 200,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glowing background
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.purple.withOpacity(0.4),
                              Colors.pink.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Lottie Animation from asset
                      Lottie.asset(
                        'assets/animations/casino.json',
                        width: 200,
                        height: 200,
                        controller: _lottieController,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          _lottieController.repeat();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Add buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Text',
                        Icons.text_fields,
                        Colors.blue,
                            () => _showAddDialog('text'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Add Image',
                        Icons.image,
                        Colors.green,
                            () => _pickImageFromGallery(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Entries list
              Expanded(
                child: entries.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 80,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add some entries to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return EntryCard(
                      entry: entries[index],
                      onDelete: () => _removeEntry(entries[index].id),
                      index: index,
                    );
                  },
                ),
              ),

              // Start button
              if (entries.length >= 2)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpinScreen(entries: entries),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Start',
                            style: TextStyle(
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
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* SETUP INSTRUCTIONS:

1. ADD DEPENDENCIES to pubspec.yaml:
   dependencies:
     image_picker: ^1.0.0

2. ANDROID PERMISSIONS (android/app/src/main/AndroidManifest.xml):
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

3. iOS PERMISSIONS (ios/Runner/Info.plist):
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photos to add images to the spin wheel</string>

4. SETUP LOTTIE ASSET (pubspec.yaml):
   assets:
     - assets/lottie/spin_wheel.json

5. DOWNLOAD LOTTIE:
   - Go to https://lottiefiles.com/
   - Download a spin/wheel animation
   - Place it in assets/lottie/spin_wheel.json
*/