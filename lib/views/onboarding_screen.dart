// lib/views/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../models/models.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(HealthProfile) onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        children: [
          _buildWelcomePage(),
          _buildHealthConditionsPage(),
          _buildAllergyPage(),
          _buildCompletePage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFA000).withAlpha(30),
            ),
            child: const Icon(Icons.eco, size: 50, color: Color(0xFFFFA000)),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Health Mango',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan fruits and products to get personalized nutrition advice based on your health conditions.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFA000),
              ),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConditionsPage() {
    final conditions = HealthCondition.values.where((c) => c != HealthCondition.none).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Do you have any of these health conditions?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select all that apply. We'll give personalized advice.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ...conditions.map((condition) {
              return _ConditionCard(condition: condition);
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFFA000),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyPage() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Any food allergies?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const _AllergyInputSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFFA000),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePage() {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withAlpha(30),
            ),
            child: const Icon(Icons.check, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 32),
          const Text(
            'All set!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your health profile is ready. Start scanning fruits and products for personalized nutrition advice.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onComplete(HealthProfile.empty(''));
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFA000),
              ),
              child: const Text('Start Using App'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionCard extends StatefulWidget {
  final HealthCondition condition;

  const _ConditionCard({required this.condition});

  @override
  State<_ConditionCard> createState() => _ConditionCardState();
}

class _ConditionCardState extends State<_ConditionCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isSelected = !_isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isSelected ? const Color(0xFFFFA000) : Colors.grey[300]!,
            width: _isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _isSelected ? const Color(0xFFFFF8E1) : Colors.white,
        ),
        child: Row(
          children: [
            Checkbox(
              value: _isSelected,
              onChanged: (_) => setState(() => _isSelected = !_isSelected),
              activeColor: const Color(0xFFFFA000),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.condition.display,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  Text(
                    widget.condition.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergyInputSection extends StatefulWidget {
  const _AllergyInputSection();

  @override
  State<_AllergyInputSection> createState() => _AllergyInputSectionState();
}

class _AllergyInputSectionState extends State<_AllergyInputSection> {
  final List<String> _allergies = [];
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._allergies.map((allergy) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000).withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(allergy, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _allergies.remove(allergy)),
                  child: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
          );
        }),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Type an allergy and press Add',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  _allergies.add(_controller.text);
                  _controller.clear();
                });
              }
            },
            child: const Text('Add Allergy'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
