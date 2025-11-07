import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pokemon_service.dart';
import 'dart:math';

class PokemonBattleScreen extends StatefulWidget {
  const PokemonBattleScreen({super.key});

  @override
  State<PokemonBattleScreen> createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  String result = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBattle();
  }

  Future<void> _loadBattle() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    final cards = await PokemonService.fetchCards();

    if (cards.length < 2) return;

    final random = Random();
    final index1 = random.nextInt(cards.length);
    int index2 = random.nextInt(cards.length);
    while (index1 == index2) {
      index2 = random.nextInt(cards.length);
    }

    setState(() {
      card1 = cards[index1];
      card2 = cards[index2];
      _determineWinner();
      isLoading = false;
    });
  }

  void _determineWinner() {
    final hp1 = int.tryParse(card1?['hp'] ?? '0') ?? 0;
    final hp2 = int.tryParse(card2?['hp'] ?? '0') ?? 0;

    if (hp1 > hp2) {
      result = '${card1?['name']} Wins! 🎉';
    } else if (hp2 > hp1) {
      result = '${card2?['name']} Wins! 🎉';
    } else {
      result = "It's a tie! ⚔️";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar('Pokémon Battle'),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 10),
                    Text("Loading Pokémon battle..."),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (card1 != null && card2 != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPokemonCard(card1!, Colors.greenAccent),
                        const Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                        _buildPokemonCard(card2!, Colors.amberAccent),
                      ],
                    ),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      result,
                      key: ValueKey<String>(result),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _loadBattle,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Battle Again",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> card, Color color) {
    final name = card['name'] ?? 'Unknown';
    final imageUrl = card['images']['small'];
    final hp = card['hp'] ?? '0';

    return Column(
      children: [
        Container(
          width: 140,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(strokeWidth: 2),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, size: 50),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "HP: $hp",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildGradientAppBar(String title) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
