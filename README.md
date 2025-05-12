# Voice to API Demo

A Flutter application that records voice, sends it to OpenAI's ChatGPT API for transcription, and forwards the result to another API.

## Features

- Voice recording functionality
- Integration with OpenAI's Whisper API for voice-to-text transcription
- Forwarding of transcribed text to a second API
- Modern Material 3 UI with feedback on recording status

## Setup

1. Clone the repository
2. Update the API keys and endpoints in `lib/services/voice_service.dart`:
   - Replace `your-chatgpt-api-key` with your actual OpenAI API key
   - Update `_secondApiEndpoint` with the URL of your second API

## Required Permissions

The app requires the following permissions:
- Microphone access (for recording voice)
- Internet access (for API communication)

## Usage

1. Run the app using `flutter run`
2. Tap the microphone button to start recording
3. Speak your message
4. Tap the stop button to end recording
5. The app will:
   - Send the audio to ChatGPT for transcription
   - Display the transcribed text
   - Send the text to your second API
   - Display the response

## Dependencies

- `record`: For audio recording functionality
- `path_provider`: For managing file paths
- `http`: For API communication
- `permission_handler`: For managing permissions

## Implementation Details

The app follows a clean architecture approach:
- `VoiceService` class handles all voice recording and API communication
- UI is separated from business logic
- Permission requests are handled gracefully

## Customization

You can modify the app to fit your specific needs:
- Change the recording parameters in `startRecording()`
- Modify the API request format in `transcribeAudio()` and `sendToSecondApi()`
- Customize the UI in `MyHomePage`
