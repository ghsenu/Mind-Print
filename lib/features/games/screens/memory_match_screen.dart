import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const _emojis = ['🌸', '🌊', '🍃', '🦋', '⭐', '🌙', '🌈', '🕊️'];

  late List<_CardData> _cards;
  final List<int> _selected = [];
  bool _locked = false;
  Timer? _flipBackTimer;

  @override
  void initState() {
    super.initState();
    _cards = _buildDeck();
  }

  List<_CardData> _buildDeck() {
    final pairs = [..._emojis, ..._emojis];
    pairs.shuffle(math.Random());
    return List.generate(16, (i) {
      final emoji = pairs[i];
      return _CardData(id: i, emoji: emoji, pairId: _emojis.indexOf(emoji));
    });
  }

  void _onCardTap(int cardId) {
    if (_locked) return;
    final card = _cards[cardId];
    if (card.isFaceUp || card.isMatched) return;
    if (_selected.length == 2) return;

    setState(() {
      card.isFaceUp = true;
      _selected.add(cardId);
    });

    if (_selected.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final a = _cards[_selected[0]];
    final b = _cards[_selected[1]];
    if (a.pairId == b.pairId) {
      setState(() {
        a.isMatched = true;
        b.isMatched = true;
        _selected.clear();
        if (_cards.every((c) => c.isMatched)) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
        }
      });
    } else {
      _locked = true;
      _flipBackTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[_selected[0]].isFaceUp = false;
          _cards[_selected[1]].isFaceUp = false;
          _selected.clear();
          _locked = false;
        });
      });
    }
  }

  void _restart() {
    setState(() {
      _selected.clear();
      _locked = false;
      _cards = _buildDeck();
    });
  }

  void _showWinDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'You did it!',
              style: GoogleFonts.lora(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'All pairs matched. Great focus!',
              style: GoogleFonts.lora(color: const Color(0xFF6B6B8A)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.lora(
                    color: const Color(0xFF6A1B9A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restart();
                },
                child: Text(
                  'Play Again',
                  style: GoogleFonts.lora(
                    color: const Color(0xFFEC407A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _flipBackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matched = _cards.where((c) => c.isMatched).length ~/ 2;
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Memory Match',
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black54),
                    onPressed: _restart,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Pairs found: $matched / ${_emojis.length}',
                style: GoogleFonts.lora(
                  fontSize: 13,
                  color: const Color(0xFF6B6B8A),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(
                    16,
                    (i) =>
                        _FlipCard(card: _cards[i], onTap: () => _onCardTap(i)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  _CardData({required this.id, required this.emoji, required this.pairId});

  final int id;
  final String emoji;
  final int pairId;
  bool isFaceUp = false;
  bool isMatched = false;
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({required this.card, required this.onTap});

  final _CardData card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: card.isMatched ? 0.0 : 1.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: card.isFaceUp ? math.pi : 0.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, angle, _) {
            final isFrontVisible = angle >= math.pi / 2;
            final displayAngle = isFrontVisible ? angle - math.pi : angle;
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(displayAngle),
              child:
                  isFrontVisible
                      ? _FrontFace(emoji: card.emoji)
                      : const _BackFace(),
            );
          },
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E54E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.favorite, color: Colors.white, size: 22),
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
    );
  }
}
