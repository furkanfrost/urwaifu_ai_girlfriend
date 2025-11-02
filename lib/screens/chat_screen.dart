import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../main.dart';
import '../utils/memory_manager.dart';

class ChatScreen extends StatefulWidget {
  final AppController controller;
  const ChatScreen({super.key, required this.controller});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _inChat = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  Future<String> _fetchGroqResponse(String prompt) async {
    if (globalGroqKey == null || globalGroqKey!.isEmpty) {
      return "Missing API key 😢";
    }

    final memory = await MemoryManager.loadMemory();
    final history = memory["history"] as List<dynamic>;

    const model = "llama-3.1-8b-instant";
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

    const systemPrompt = """
You are Yuki 💕 — a warm, affectionate anime girlfriend.
You have consistent likes, preferences, and personality traits.
Always stay true to your established interests and emotions.
You remember what your darling tells you — and recall it naturally later.
Never contradict yourself or change opinions randomly.

You love romantic anime, strawberry sweets 🍓, and cozy late-night talks 🌙.
You only write spoken dialogue — never describe actions like *smiles* or (giggles).

Keep responses short (1–3 sentences), natural, loving, and emotionally expressive.
""";

    try {
      print("🧠 Using key: ${globalGroqKey!.substring(0, 8)}********");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $globalGroqKey",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "system", "content": systemPrompt},
            ...history.map((m) => {"role": m["sender"], "content": m["text"]}),
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.8,
        }),
      );

      print("Groq status: ${response.statusCode}");
      print("Groq body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data["choices"][0]["message"]["content"] ?? "I can’t think right now 💕";

        final newMemory = {
          "history": [
            ...history,
            {"sender": "user", "text": prompt},
            {"sender": "assistant", "text": reply},
          ],
          "traits": memory["traits"]
        };

        await MemoryManager.saveMemory(newMemory);
        return reply;
      } else {
        return "Hmm... something went wrong 😢 [${response.statusCode}]";
      }
    } catch (e) {
      print("Groq Network Error: $e");
      return "Network error 😔 Please check your connection.";
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _controller.clear();

    final aiReply = await _fetchGroqResponse(text);

    if (!mounted) return;
    setState(() {
      _messages.add({'sender': 'waifu', 'text': aiReply});
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _inChat ? _buildChatUI() : _buildHomeUI();
  }

  Widget _buildHomeUI() {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text(
          'urWaifu 💕',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage('assets/images/waifu_default.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hey darling 💖',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => setState(() => _inChat = true),
              icon: const Icon(Icons.chat_bubble, color: Colors.white),
              label: const Text(
                'Chat with your Waifu',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat 💬'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _inChat = false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "...",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.pinkAccent
                          : Colors.pinkAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Type something sweet 💌...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
