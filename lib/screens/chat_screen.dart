import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../main.dart';
import '../utils/memory_manager.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_bubble.dart';
import '../widgets/avatar.dart';
import '../models/app_config.dart';



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
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
    _scrollToBottom();

    final aiReply = await _fetchGroqResponse(text);

    if (!mounted) return;
    setState(() {
      _messages.add({'sender': 'waifu', 'text': aiReply});
      _isTyping = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return _inChat ? _buildChatUI() : _buildHomeUI();
  }

  Widget _buildHomeUI() {
    return ValueListenableBuilder<AppConfig>(
      valueListenable: widget.controller.config,
      builder: (context, config, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pinkAccent.withOpacity(0.1),
                  Colors.purpleAccent.withOpacity(0.1),
                  Colors.blueAccent.withOpacity(0.05),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: AssetImage(config.avatarPath),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Hey ${config.waifuName} 💖',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ready to chat?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.pinkAccent,
                              Colors.purpleAccent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => setState(() => _inChat = true),
                          icon: const Icon(Icons.chat_bubble, 
                              color: Colors.white, size: 28),
                          label: const Text(
                            'Start Chatting',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatUI() {
    return ValueListenableBuilder<AppConfig>(
      valueListenable: widget.controller.config,
      builder: (context, config, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar(path: config.avatarPath, radius: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.waifuName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _isTyping ? 'typing...' : 'online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: _isTyping 
                            ? Colors.white.withOpacity(0.8)
                            : Colors.green.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() => _inChat = false),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.purpleAccent,
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.pinkAccent.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Avatar(path: config.avatarPath, radius: 50),
                              const SizedBox(height: 20),
                              Text(
                                'Start chatting with ${config.waifuName} 💕',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: false,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isTyping && index == _messages.length) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 50, top: 8, bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Avatar(path: config.avatarPath, radius: 16),
                                    const SizedBox(width: 8),
                                    const TypingBubble(),
                                  ],
                                ),
                              );
                            }

                            final msg = _messages[index];
                            final isUser = msg['sender'] == 'user';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isUser) ...[
                                    Avatar(path: config.avatarPath, radius: 16),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: MessageBubble(
                                      text: msg['text']!,
                                      isUser: isUser,
                                    ),
                                  ),
                                  if (isUser) ...[
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.pinkAccent,
                                      child: const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: "Type something sweet 💌...",
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.pinkAccent,
                                Colors.purpleAccent,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _sendMessage,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
