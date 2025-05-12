import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'services/voice_service.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice to API Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Voice Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  String _transcribedText = '';
  String _apiResponse = '';
  bool _isProcessing = false;
  bool _isRecording = false;
  
  late AnimationController _animationController;
  late AnimationController _pulseAnimationController;
  
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        elevation: 0,
      ),
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
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(),
              const Text(
                'Tap the button and speak',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              
              const SizedBox(height: 40),
              
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
