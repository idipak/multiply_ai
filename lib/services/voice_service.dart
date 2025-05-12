import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

/// A demo voice service with ChatGPT integration
/// To use this with real APIs, add your OpenAI API key below
class VoiceService {
  bool _isRecording = false;
  double _currentAmplitude = -60.0;
  bool _isSilenceDetected = false;
  Timer? _amplitudeTimer;
  Timer? _silenceTimer;
  
  // Replace this with your actual OpenAI API key
  final String _openAiApiKey = 'YOUR_OPENAI_API_KEY';  // Add your API key here
  
  // Getters
  bool get isRecording => _isRecording;
  double get currentAmplitude => _currentAmplitude;
  bool get isSilenceDetected => _isSilenceDetected;

  Future<bool> hasPermission() async {
    // This is a demo implementation
    return true;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    
    _isRecording = true;
    _simulateRecording();
    debugPrint('Started recording simulation');
  }
  
  void _simulateRecording() {
    _amplitudeTimer?.cancel();
    _silenceTimer?.cancel();
    
    // Simulate amplitude changes during recording
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      
      // Generate random amplitude between -45 and -10
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      _currentAmplitude = -45 + (random / 100) * 35;
      
      // Simulate silence detection after 5 seconds
      if (timer.tick > 25) {
        _isSilenceDetected = true;
        _currentAmplitude = -55;
      }
    });
    
    // Simulate automatic stop after 8 seconds
    _silenceTimer = Timer(const Duration(seconds: 8), () {
      if (_isRecording) {
        stopRecording();
      }
    });
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    _isRecording = false;
    _amplitudeTimer?.cancel();
    _silenceTimer?.cancel();
    debugPrint('Stopped recording simulation');
  }
  
  Future<String?> transcribeAudio() async {
    try {
      // In a real implementation, this would send audio to OpenAI
      /*
      // Example code to send to OpenAI API:
      final request = http.MultipartRequest('POST', 
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'));
      
      request.headers.addAll({
        'Authorization': 'Bearer $_openAiApiKey',
      });
      
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));
      request.fields['model'] = 'whisper-1';
      request.fields['language'] = 'en';
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      return jsonResponse['text'];
      */
      
      // For demo, just return a simulated response
      await Future.delayed(const Duration(seconds: 1));
      return "I need high-quality plywood for my bathroom renovation. What would you recommend?";
    } catch (e) {
      debugPrint('Exception during transcription: $e');
      return "Error transcribing audio. Please try again.";
    }
  }
  
  Future<dynamic> sendToSecondApi(String text) async {
    try {
      if (_openAiApiKey != 'YOUR_OPENAI_API_KEY') {
        // If you have provided an API key, try using the actual OpenAI API
        try {
          final response = await http.post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_openAiApiKey',
            },
            body: jsonEncode({
              'model': 'gpt-3.5-turbo',
              'messages': [
                {'role': 'system', 'content': 'You are a helpful assistant that specializes in plywood and furniture.'},
                {'role': 'user', 'content': text}
              ],
              'max_tokens': 150,
            }),
          );
          
          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            final content = jsonResponse['choices'][0]['message']['content'];
            return {"response": content};
          }
        } catch (e) {
          debugPrint('API error: $e');
        }
      }
      
      // Return a simulated response for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        "response": "For bathroom renovations, I would recommend BWP Marine Plywood which is specifically designed to be waterproof and suitable for high-moisture environments. The 18mm thickness should be sufficient for most bathroom applications. GreenPly offers a good quality product in this category with both fire and water resistance properties.",
        "note": "This is a simulated response. Add your OpenAI API key to get real responses from ChatGPT."
      };
    } catch (e) {
      debugPrint('Exception sending to second API: $e');
      return {"error": "Failed to get response: $e"};
    }
  }
  
  void dispose() {
    _amplitudeTimer?.cancel();
    _silenceTimer?.cancel();
  }
} 