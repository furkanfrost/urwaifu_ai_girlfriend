import 'package:flutter/material.dart';
import '../main.dart';
import '../models/app_config.dart';

class StoreScreen extends StatelessWidget {
  final AppController controller;
  const StoreScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = <_StoreItem>[
      _StoreItem(
        sku: "outfit_sakura",
        name: "Sakura Outfit 🌸",
        price: 120,
        image: "assets/images/waifu_cute.png",
        description: "A cute sakura themed outfit that brightens her mood.",
      ),
      _StoreItem(
        sku: "theme_sakura",
        name: "Theme: Sakura",
        price: 80,
        image: "assets/images/waifu_soft.png",
        description: "Soft pink tones for a dreamy experience.",
      ),
      _StoreItem(
        sku: "voice_soft",
        name: "Voice Pack 🎤",
        price: 150,
        image: "assets/images/waifu_default.png",
        description: "A gentle soothing voice for bedtime talks.",
      ),
    ];

    return ValueListenableBuilder<AppConfig>(
      valueListenable: controller.config,
      builder: (context, cfg, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Store 🛍️"),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: const TextStyle(
              color: Colors.pinkAccent, fontWeight: FontWeight.w600, fontSize: 20),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text("${cfg.coins}"),
                  avatar: const Icon(Icons.monetization_on, color: Colors.amber),
                  backgroundColor: Colors.amber.withOpacity(0.15),
                ),
              )
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .8),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              final owned = cfg.ownedSkus.contains(it.sku);
              return GestureDetector(
                onTap: () => _showItemSheet(context, it, owned),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(it.image, fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(it.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            owned
                                ? const Text("Owned",
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : Text("${it.price} coins",
                                    style: const TextStyle(color: Colors.pinkAccent)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showItemSheet(BuildContext context, _StoreItem it, bool owned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 4, width: 40, decoration: BoxDecoration(
                color: Colors.grey[400], borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 14),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(it.image, height: 72, width: 72, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(it.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  if (!owned)
                    Chip(
                      label: Text("${it.price}"),
                      avatar: const Icon(Icons.monetization_on, color: Colors.amber),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(it.description, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.pinkAccent.withOpacity(.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: owned ? Colors.green : Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: owned
                          ? null
                          : () {
                              // satın al
                              Navigator.of(context).pop();
                              controller.purchase(it.sku, it.price);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${it.name} purchased 💖"),
                                  backgroundColor: Colors.pinkAccent,
                                ),
                              );
                            },
                      child: Text(owned ? "Owned" : "Buy"),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _StoreItem {
  final String sku;
  final String name;
  final int price;
  final String image;
  final String description;

  _StoreItem({
    required this.sku,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });
}
