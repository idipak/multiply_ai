import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Added for Timer

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceService {
  final _audioRecorder = AudioRecorder();
  String? _audioPath;
  bool _isRecording = false;
  Timer? _silenceTimer;
  Timer? _amplitudeTimer;
  double _currentAmplitude = 0.0;
  final double _silenceThreshold = -60.0; // Adjusted threshold for better silence detection (in dB)
  static const Duration _silenceTimeout = Duration(seconds: 3);

  // Replace with your actual API keys and endpoints
  final String _chatGptApiKey = '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';
  final String _chatGptEndpoint = 'https://api.openai.com/v1/audio/transcriptions';
  final String _secondApiEndpoint = 'https://your-second-api-endpoint.com';

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    if (await requestPermissions()) {
      final tempDir = await getTemporaryDirectory();
      _audioPath = '${tempDir.path}/audio_recording.m4a';
      
      // Check if recording is already in progress
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      
      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );
      
      _isRecording = true;
      
      // Start monitoring amplitude for silence detection
      _startSilenceDetection();
    }
  }

  void _startSilenceDetection() {
    // Cancel any existing timers
    _silenceTimer?.cancel();
    _amplitudeTimer?.cancel();
    
    // Start checking amplitude at regular intervals
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      try {
        final amplitude = await _audioRecorder.getAmplitude();
        final level = amplitude.current ?? 0.0;
        _currentAmplitude = level; // Store current amplitude
        
        if (level < _silenceThreshold) {
          // Reset or start silence timer when silence is detected
          _silenceTimer ??= Timer(_silenceTimeout, () {
            // Stop recording after silence timeout
            if (_isRecording) {
              debugPrint('Stopping recording due to silence');
              stopRecording();
            }
          });
        } else {
          // Cancel silence timer when voice is detected
          if (_silenceTimer != null) {
            _silenceTimer!.cancel();
            _silenceTimer = null;
          }
        }
      } catch (e) {
        debugPrint('Error checking amplitude: $e');
      }
    });
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      // Cancel all timers
      _silenceTimer?.cancel();
      _silenceTimer = null;
      _amplitudeTimer?.cancel();
      _amplitudeTimer = null;
      
      await _audioRecorder.stop();
      _isRecording = false;
    }
  }

  Future<String?> transcribeAudio() async {
    if (_audioPath == null) return null;

    final file = File(_audioPath!);
    if (!file.existsSync()) return null;

    try {
      // Create the multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_chatGptEndpoint));

      // Add headers including API key
      request.headers.addAll({
        'Authorization': 'Bearer $_chatGptApiKey',
      });

      // Add the audio file
      request.files.add(
        await http.MultipartFile.fromPath('file', _audioPath!),
      );

      // Add model parameter
      request.fields['model'] = 'whisper-1';
      // Force English output regardless of input language
      request.fields['language'] = 'en';
      // Ensure consistent JSON response format
      request.fields['response_format'] = 'json';

      request.fields['prompt'] = _prompt;

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['text'];
      } else {
        debugPrint('Error transcribing audio: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Exception during transcription: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendToSecondApi(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_secondApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error sending to second API: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception sending to second API: $e');
      return null;
    }
  }

  void dispose() {
    _silenceTimer?.cancel();
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
  }

  double get currentAmplitude => _currentAmplitude;
  
  bool get isSilenceDetected => _isRecording && _currentAmplitude < _silenceThreshold;

  bool get isRecording => _isRecording;
} 

const String _prompt = 'Plywood, Plywood, Laminate, Plywood, Hardware, Furniture, Laminate, Adhesive, Waterproof, Interior, Decorative, Premium, Handles, Dining, Edge Finish, Construction, Hardwood, Softwood, MDF, Teak, Aluminum, MDF+Metal, PVC, PVA, Brand: GreenPly, Century, Merino, Kitply, Hafele, Durian, Sunmica, Fevicol, Usage: Bathrooms, Boats, Furniture, Cabinets, Luxury Furniture, Kitchen Cabinets, Dining Room, Wood Bonding';