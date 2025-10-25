import 'package:flutter/material.dart';
import '../main.dart';
import '../models/app_config.dart';

class CharacterScreen extends StatefulWidget {
  final AppController controller;
  const CharacterScreen({super.key, required this.controller});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  late TextEditingController _name;
  late String _selectedAvatar;
  late String _selectedPersonality;

  final List<Map<String, String>> _avatars = const [
    {"path": "assets/images/waifu_default.png", "label": "Classic 💕"},
    {"path": "assets/images/waifu_cool.png",    "label": "Cool 😎"},
    {"path": "assets/images/waifu_cute.png",    "label": "Cute 🩷"},
    {"path": "assets/images/waifu_soft.png",    "label": "Soft 🌸"},
  ];

  @override
  void initState() {
    super.initState();
    final cfg = widget.controller.config.value;
    _name = TextEditingController(text: cfg.waifuName);
    _selectedAvatar = cfg.avatarPath;
    _selectedPersonality = cfg.personality;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final cfg = widget.controller.config.value;
    final updated = cfg.copyWith(
      waifuName: _name.text.trim().isEmpty ? cfg.waifuName : _name.text.trim(),
      avatarPath: _selectedAvatar,
      personality: _selectedPersonality,
    );
    widget.controller.updateConfig(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text("${updated.waifuName} updated successfully 💕"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppConfig>(
      valueListenable: widget.controller.config,
      builder: (context, cfg, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Character Designer"),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: const TextStyle(
              color: Colors.pinkAccent, fontWeight: FontWeight.w600, fontSize: 20),
            actions: [
              IconButton(
                tooltip: "Add 100 coins",
                onPressed: () => widget.controller.addCoins(100),
                icon: const Icon(Icons.attach_money, color: Colors.pinkAccent),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: AssetImage(_selectedAvatar),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _name,
                              decoration: InputDecoration(
                                labelText: "Waifu name",
                                prefixIcon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                _chip("sweet", "Sweet 💕"),
                                _chip("tsundere", "Tsundere 😳"),
                                _chip("playful", "Playful 😜"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Avatars
              const _SectionTitle("Choose Avatar"),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) {
                    final a = _avatars[i];
                    final sel = a["path"] == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = a["path"]!),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: sel ? Colors.pinkAccent : Colors.transparent, width: 3),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (sel)
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.25),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 34,
                              backgroundImage: AssetImage(a["path"]!),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(a["label"] ?? "", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _avatars.length,
                ),
              ),

              const SizedBox(height: 18),
              // Personality preview
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.pinkAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedPersonality == "tsundere"
                              ? "She’s moody but secretly in love 😳"
                              : _selectedPersonality == "playful"
                                  ? "Fun, teasing and energetic 😜"
                                  : "Gentle, loving and supportive 💕",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),
              // Save
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _save,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String key, String label) {
    final sel = _selectedPersonality == key;
    return ChoiceChip(
      selected: sel,
      label: Text(label),
      labelStyle: TextStyle(
        color: sel ? Colors.white : Colors.pinkAccent,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: Colors.pinkAccent,
      backgroundColor: Colors.pinkAccent.withOpacity(0.12),
      onSelected: (_) => setState(() => _selectedPersonality = key),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
  }
}
