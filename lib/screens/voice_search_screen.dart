import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../services/voice_service.dart';
import 'product_list_screen.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  String _transcribedText = '';
  String _apiResponse = '';
  bool _isProcessing = false;
  bool _isRecording = false;
  
  late AnimationController _animationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _textAnimationController;
  
  double _amplitudeLevel = 0.0;
  bool _isSilenceDetected = false;
  
  // Add timer variables to track periodic timers
  Timer? _recordingStatusTimer;
  Timer? _amplitudeUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Total duration for all 3 languages
    )..repeat();
    
    // Add a timer to check recording status for auto-stop detection
    _recordingStatusTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isRecording != _voiceService.isRecording) {
        setState(() {
          _isRecording = _voiceService.isRecording;
        });
        
        // If recording stopped automatically due to silence
        if (!_voiceService.isRecording && _isRecording) {
          _handleRecordingStopped();
        }
      }
    });
    
    // Update amplitude level every 200ms for visualization
    _amplitudeUpdateTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_voiceService.isRecording) {
        setState(() {
          _amplitudeLevel = _voiceService.currentAmplitude;
          _isSilenceDetected = _voiceService.isSilenceDetected;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _textAnimationController.dispose();
    _recordingStatusTimer?.cancel();
    _amplitudeUpdateTimer?.cancel();
    _voiceService.dispose();
    super.dispose();
  }
  
  // Handle when recording is stopped either manually or automatically
  Future<void> _handleRecordingStopped() async {
    _animationController.stop();
    
    setState(() {
      _isProcessing = true;
      _isRecording = false;
    });
    
    // Transcribe the audio
    final transcription = await _voiceService.transcribeAudio();
    if (transcription != null) {
      setState(() {
        _transcribedText = transcription;
        Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(searchQuery: _transcribedText),
                ),
              );
      });
      
      // Send transcribed text to second API
      final apiResponse = await _voiceService.sendToSecondApi(transcription);
      if (apiResponse != null) {
        setState(() {
          _apiResponse = apiResponse.toString();
        });
      } else {
        setState(() {
          _apiResponse = 'Failed to get response from API';
        });
      }
    } else {
      setState(() {
        _transcribedText = 'Failed to transcribe audio';
      });
    }
    
    setState(() {
      _isProcessing = false;
    });
  }
  
  Future<void> _handleRecordingPress() async {
    if (_voiceService.isRecording) {
      // Stop recording manually
      await _voiceService.stopRecording();
      await _handleRecordingStopped();
    } else {
      // Start recording
      await _voiceService.startRecording();
      _animationController.repeat();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: const Text('Voice Assistant'),
      //   elevation: 0,
      //   actions: [
      //     ElevatedButton.icon(
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => ProductListScreen(searchQuery: "Plywood"),
      //           ),
      //         );
      //       },
      //       icon: const Icon(Icons.shopping_cart),
      //       label: const Text('Shop'),
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: Colors.transparent,
      //         elevation: 0,
      //       ),
      //     ),
      //   ],
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.inversePrimary.withOpacity(0.3),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(),
              
              // Animated text that cycles through languages
              AnimatedPromptText(
                animation: _textAnimationController,
              ),
              
              const SizedBox(height: 30),
              
              if (_voiceService.isRecording) ...[
                _buildWaveAnimation(),
                const SizedBox(height: 20),
                const Text(
                  'Recording... (Will stop automatically after 3s of silence)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                _buildAmplitudeIndicator(),
              ],
              
              const SizedBox(height: 20),
              
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Processing...', style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                )
              else
                _buildRecordButton(),
              
              const SizedBox(height: 30),

              const Text(
                'Tap the button and speak',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_transcribedText.isNotEmpty) ...[
                        _buildTranscriptionCard(),
                        const SizedBox(height: 16),
                      ],
                      
                      if (_apiResponse.isNotEmpty)
                        _buildApiResponseCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWaveAnimation() {
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(10, (index) {
              final sinValue = math.sin((_animationController.value * math.pi * 2) + index / 5);
              final heightFactor = (sinValue + 1) / 2 * 0.8 + 0.2; // Range 0.2 to 1.0
              
              return Container(
                width: 5,
                height: 80 * heightFactor,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          );
        },
      ),
    );
  }
  
  Widget _buildRecordButton() {
    final isRecording = _voiceService.isRecording;
    final buttonColor = isRecording ? Colors.red : Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        final scale = isRecording 
            ? 1.0 + (_pulseAnimationController.value * 0.1) 
            : 1.0;
        
        return GestureDetector(
          onTap: _handleRecordingPress,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonColor,
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTranscriptionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Transcribed Text',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(_transcribedText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildApiResponseCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'API Response',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              _apiResponse,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build a visual indicator for the amplitude level
  Widget _buildAmplitudeIndicator() {
    // Map dB scale (-60 to 0) to a 0-1 range for the progress indicator
    double normalizedLevel = (_amplitudeLevel + 60) / 60;
    normalizedLevel = normalizedLevel.clamp(0.0, 1.0); // Ensure it's between 0 and 1
    
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Audio Level: '),
            const SizedBox(width: 5),
            Text(
              '${_amplitudeLevel.toStringAsFixed(1)} dB',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isSilenceDetected ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: normalizedLevel,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _isSilenceDetected ? Colors.red : Colors.green,
          ),
        ),
        if (_isSilenceDetected)
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Silence detected',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Widget that animates through "what you are looking for" in English, Hindi, and Kannada
class AnimatedPromptText extends StatelessWidget {
  final Animation<double> animation;
  
  // Text in different languages
  final List<Map<String, String>> _promptTexts = [
    {'language': 'English', 'text': 'what you are looking for'},
    {'language': 'हिंदी (Hindi)', 'text': 'आप क्या ढूंढ रहे हैं'},
    {'language': 'ಕನ್ನಡ (Kannada)', 'text': 'ನೀವು ಹುಡುಕುತ್ತಿರುವುದು'},
  ];

  AnimatedPromptText({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          // Calculate which language to show based on animation value
          final position = (animation.value * 3).floor() % 3;
          final currentLanguage = _promptTexts[position]['language']!;
          final currentText = _promptTexts[position]['text']!;
          
          // Calculate fade in/out
          final cyclePosition = (animation.value * 3) % 1.0;
          double opacity = 1.0;
          
          // Fade in during first 10%, stay solid for 80%, fade out during last 10%
          if (cyclePosition < 0.1) {
            opacity = cyclePosition * 10; // Fade in
          } else if (cyclePosition > 0.9) {
            opacity = (1.0 - cyclePosition) * 10; // Fade out
          }
          
          return Opacity(
            opacity: opacity,
            child: Column(
              children: [
                // Text(
                //   currentLanguage,
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.bold,
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                // ),
                // const SizedBox(height: 4),
                Text(
                  '"$currentText"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 