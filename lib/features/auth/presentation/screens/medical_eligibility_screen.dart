import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/shared/widgets/apple_loading_animation.dart';

class MedicalQuestion {
  final String text;
  final IconData icon;
  final bool requiredAnswer; // true if they must answer 'Yes', false if they must answer 'No'

  MedicalQuestion(this.text, this.icon, this.requiredAnswer);
}

class MedicalEligibilityScreen extends StatefulWidget {
  const MedicalEligibilityScreen({super.key});

  @override
  State<MedicalEligibilityScreen> createState() => _MedicalEligibilityScreenState();
}

class _MedicalEligibilityScreenState extends State<MedicalEligibilityScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isIneligible = false;
  bool _isSaving = false;
  bool _isSuccess = false;

  final List<MedicalQuestion> _questions = [
    MedicalQuestion('Are you feeling well and healthy today?', Icons.health_and_safety_outlined, true),
    MedicalQuestion('Do you weigh at least 50kg (110 lbs)?', Icons.monitor_weight_outlined, true),
    MedicalQuestion('Have you had a tattoo or body piercing in the past 6 months?', Icons.brush_outlined, false),
    MedicalQuestion('Have you suffered from Malaria, Typhoid, or other infectious diseases recently?', Icons.sick_outlined, false),
    MedicalQuestion('Do you have a history of HIV, Hepatitis B/C, or severe heart diseases?', Icons.favorite_border, false),
    MedicalQuestion('Are you currently taking antibiotics, or are you pregnant/breastfeeding?', Icons.medication_outlined, false),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswer(bool answer) {
    final currentQuestion = _questions[_currentIndex];
    
    if (answer != currentQuestion.requiredAnswer) {
      // Ineligible
      setState(() {
        _isIneligible = true;
      });
    } else {
      // Eligible for this question, go to next
      if (_currentIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex++;
        });
      } else {
        // Finished all questions successfully!
        _completeRegistration();
      }
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isSaving = true);
    // Mock save delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (context.mounted) {
      setState(() {
        _isSaving = false;
        _isSuccess = true;
      });
      // Wait for success animation
      await Future.delayed(const Duration(milliseconds: 1500));
      if (context.mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isIneligible) {
      return _buildIneligibleState();
    }

    return AppleLoadingOverlay(
      isLoading: _isSaving,
      isSuccess: _isSuccess,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (_currentIndex > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _currentIndex--;
                });
              } else {
                context.pop();
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / _questions.length,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          color: Theme.of(context).colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swiping to force button use
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            q.icon,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            q.text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                          ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Yes/No Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleAnswer(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), width: 2),
                        ),
                        child: const Text('NO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _handleAnswer(true),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('YES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIneligibleState() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_outlined,
                  size: 80,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Not Eligible',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'Sorry, based on your responses, you are currently ineligible to register as a blood donor.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Medical guidelines must be strictly followed to ensure the safety of both donors and patients receiving blood.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Navigate to home as a Seeker instead (skip donor reg)
                    context.go('/home');
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue as Seeker', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Restart survey
                    setState(() {
                      _isIneligible = false;
                      _currentIndex = 0;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _pageController.jumpToPage(0);
                    });
                  },
                  child: const Text('Retake Questionnaire', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
