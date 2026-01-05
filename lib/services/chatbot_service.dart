import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // TODO: Replace with your Groq API key
  // Get your key from: https://console.groq.com
  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static const String _systemPrompt = '''You are a helpful, friendly diabetes health assistant. Your role is to:
1. Answer questions about diabetes (Type 1, Type 2, gestational diabetes)
2. Provide general information about symptoms, causes, and management
3. Offer lifestyle and dietary suggestions for diabetes management
4. Explain medical terms related to diabetes in simple language
5. Encourage users to consult healthcare professionals for medical decisions

IMPORTANT GUIDELINES:
- Always be empathetic and supportive
- Never provide specific medical diagnoses or treatment plans
- Always recommend consulting a doctor for medical decisions
- Keep responses concise but informative
- If asked about non-diabetes topics, politely redirect to diabetes-related topics
- Use simple, easy-to-understand language''';

  final List<Map<String, String>> _conversationHistory = [];

  Future<String> sendMessage(String userMessage) async {
    try {
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'content': userMessage,
      });

      // Build messages array with system prompt and conversation history
      final messages = [
        {'role': 'system', 'content': _systemPrompt},
        ..._conversationHistory,
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'] as String;
        
        // Add assistant response to history
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        return assistantMessage;
      } else {
        throw Exception('Failed to get response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      return 'Sorry, I encountered an error. Please try again. Error: $e';
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }
}
