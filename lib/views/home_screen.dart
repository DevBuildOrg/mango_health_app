// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/controllers.dart';
import 'fruit_result_screen.dart';
import 'product_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUserHealth();
  }

  void _loadUserHealth() {
    final authCtrl = context.read<AuthController>();
    final healthCtrl = context.read<HealthController>();
    if (authCtrl.currentUser != null) {
      healthCtrl.loadHealthProfile(authCtrl.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Mango'),
        backgroundColor: const Color(0xFFFFA000),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'history':
                  Navigator.pushNamed(context, '/history');
                  break;
                case 'logout':
                  await context.read<AuthController>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
              PopupMenuItem<String>(value: 'history', child: Text('History')),
              PopupMenuDivider(),
              PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _selectedTab == 0
          ? const _FruitScanTab()
          : const _ProductScanTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (idx) => setState(() => _selectedTab = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Fruits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2),
            label: 'Products',
          ),
        ],
      ),
    );
  }
}

class _FruitScanTab extends StatelessWidget {
  const _FruitScanTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFA000).withAlpha(30),
            ),
            child: const Icon(Icons.eco, size: 60, color: Color(0xFFFFA000)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Scan a Fruit',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get ripeness & sweetness estimates',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          _ScanButton(
            label: 'Take Photo',
            icon: Icons.camera_alt,
            onPressed: () => _scanFruit(context, ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _ScanButton(
            label: 'Choose from Gallery',
            icon: Icons.photo_library,
            onPressed: () => _scanFruit(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<void> _scanFruit(BuildContext context, ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile == null || !context.mounted) return;

    final bytes = await pickedFile.readAsBytes();
    if (!context.mounted) return;

    final authCtrl = context.read<AuthController>();
    final healthCtrl = context.read<HealthController>();
    final fruitCtrl = context.read<FruitController>();

    if (authCtrl.currentUser == null || healthCtrl.healthProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or health profile not loaded')),
      );
      return;
    }

    final success = await fruitCtrl.analyzeFruitImage(
      bytes,
      authCtrl.currentUser!.uid,
      healthCtrl.healthProfile!,
    );

    if (!context.mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FruitResultScreen(imageBytes: bytes),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${fruitCtrl.error}')),
      );
    }
  }
}

class _ProductScanTab extends StatelessWidget {
  const _ProductScanTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withAlpha(30),
            ),
            child: const Icon(Icons.qr_code_2, size: 60, color: Colors.blue),
          ),
          const SizedBox(height: 24),
          const Text(
            'Scan Products',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get nutrition & health advice',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          _ScanButton(
            label: 'Scan Barcode',
            icon: Icons.qr_code_2,
            onPressed: () => _showBarcodeInput(context),
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _ScanButton(
            label: 'Search Product',
            icon: Icons.search,
            onPressed: () => _showProductSearch(context),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _showBarcodeInput(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Barcode number'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _scanProduct(context, controller.text);
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }

  void _showProductSearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Product'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Product name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement product search results
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanProduct(BuildContext context, String barcode) async {
    final authCtrl = context.read<AuthController>();
    final healthCtrl = context.read<HealthController>();
    final productCtrl = context.read<ProductController>();

    if (authCtrl.currentUser == null || healthCtrl.healthProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or health profile not loaded')),
      );
      return;
    }

    final success = await productCtrl.scanBarcode(
      barcode,
      authCtrl.currentUser!.uid,
      healthCtrl.healthProfile!,
    );

    if (!context.mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductResultScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${productCtrl.error}')),
      );
    }
  }
}

class _ScanButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ScanButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFFFFA000),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
