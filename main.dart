import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatGPTApp());
}

class ChatGPTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final String openAiKey = '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';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatGPT',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 52, 53, 65),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 52, 53, 65),
              Color.fromARGB(255, 52, 53, 60),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      messages[index]['content'] ?? '',
                      style: TextStyle(
                        color: messages[index]['role'] == 'user' ? Colors.white : Colors.blue,
                      ),
                    ),
                    dense: true,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({
          'role': 'user',
          'content': message,
        });
      });

      try {
        String response = await chatGPTAPI(message);
        setState(() {
          messages.add({
            'role': 'assistant',
            'content': response,
          });
        });
      } catch (e) {
        print('An error occurred: $e');
        setState(() {
          messages.add({
            'role': 'assistant',
            'content': 'An internal error occurred: $e',
          });
        });
      }

      _controller.clear();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo-instruct",
          "prompt": prompt,
          "temperature": 0.7,
          "max_tokens": 150,
          "top_p": 1,
          "frequency_penalty": 0,
          "presence_penalty": 0,
        }),
      );

      if (response.statusCode == 200) {
        String content = jsonDecode(response.body)['choices'][0]['text'];
        return content.trim();
      } else {
        throw Exception('Failed to load response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An internal error occurred: $e');
    }
  }
}



