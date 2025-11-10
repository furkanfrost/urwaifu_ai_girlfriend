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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pinkAccent.withOpacity(0.05),
                  Colors.purpleAccent.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "Character Designer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
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
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        tooltip: "Add 100 coins",
                        onPressed: () => widget.controller.addCoins(100),
                        icon: const Icon(Icons.monetization_on, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header card
                        Card(
                          elevation: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pinkAccent.withOpacity(0.1),
                                  Colors.purpleAccent.withOpacity(0.1),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pinkAccent.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundImage: AssetImage(_selectedAvatar),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: _name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Waifu Name",
                                          prefixIcon: const Icon(
                                            Icons.favorite,
                                            color: Colors.pinkAccent,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
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
                        const SizedBox(height: 24),

                        // Avatars
                        const _SectionTitle("Choose Avatar"),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, i) {
                              final a = _avatars[i];
                              final sel = a["path"] == _selectedAvatar;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAvatar = a["path"]!),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: sel
                                          ? Colors.pinkAccent
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (sel)
                                        BoxShadow(
                                          color: Colors.pinkAccent.withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage(a["path"]!),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        a["label"] ?? "",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: sel
                                              ? Colors.pinkAccent
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemCount: _avatars.length,
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Personality preview
                        Card(
                          elevation: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pinkAccent.withOpacity(0.1),
                                  Colors.purpleAccent.withOpacity(0.1),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.pinkAccent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.pinkAccent,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Personality",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.pinkAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedPersonality == "tsundere"
                                            ? "She's moody but secretly in love 😳"
                                            : _selectedPersonality == "playful"
                                                ? "Fun, teasing and energetic 😜"
                                                : "Gentle, loving and supportive 💕",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Save
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.pinkAccent,
                                Colors.purpleAccent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _save,
                            icon: const Icon(Icons.save, color: Colors.white, size: 24),
                            label: const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _chip(String key, String label) {
    final sel = _selectedPersonality == key;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        selected: sel,
        label: Text(label),
        labelStyle: TextStyle(
          color: sel ? Colors.white : Colors.pinkAccent,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        selectedColor: Colors.pinkAccent,
        backgroundColor: Colors.pinkAccent.withOpacity(0.12),
        elevation: sel ? 4 : 0,
        shadowColor: Colors.pinkAccent.withOpacity(0.3),
        onSelected: (_) => setState(() => _selectedPersonality = key),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.5,
      ),
    );
  }
}
