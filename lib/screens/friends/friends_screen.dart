import 'package:flutter/material.dart';

// GAP-06: Friends (mockup). Tambah teman by username (dummy success/fail) +
// daftar teman statis dengan status online & skor. Backend menyusul.
class _Friend {
  final String username;
  final int score;
  final bool online;
  const _Friend(this.username, this.score, this.online);
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  static const Color _bg = Color(0xFF0F0F1A);
  static const Color _card = Color(0xFF1A1A2E);
  static const Color _indigo = Color(0xFF5C4EE5);

  final _controller = TextEditingController();
  bool _adding = false;

  final List<_Friend> _friends = [
    const _Friend('ARCHITECT', 9840, true),
    const _Friend('ELARA_V', 9420, false),
    const _Friend('LOGIC_M', 9210, true),
    const _Friend('ZenSolver', 9020, false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      _toast('Enter a username');
      return;
    }
    if (_friends.any((f) => f.username.toLowerCase() == name.toLowerCase())) {
      _toast('Already friends with $name');
      return;
    }

    setState(() => _adding = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulasi network
    if (!mounted) return;
    setState(() => _adding = false);

    // Dummy fail rule: username "ghost" dianggap tidak ditemukan.
    if (name.toLowerCase() == 'ghost') {
      _toast('User "$name" not found');
      return;
    }

    setState(() {
      _friends.insert(0, _Friend(name, 0, false));
      _controller.clear();
    });
    _toast('$name added as a friend');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('FRIENDS',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addFriend(),
                    decoration: InputDecoration(
                      hintText: 'Add friend by username',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon:
                          const Icon(Icons.person_add_alt, color: Colors.grey),
                      filled: true,
                      fillColor: _card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _adding ? null : _addFriend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _adding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ADD',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${_friends.length} FRIENDS',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _friendTile(_friends[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendTile(_Friend f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF2A2A4A),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: f.online ? const Color(0xFF22C55E) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: _card, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(f.online ? 'Online' : 'Offline',
                    style: TextStyle(
                        color: f.online
                            ? const Color(0xFF22C55E)
                            : Colors.grey,
                        fontSize: 12)),
              ],
            ),
          ),
          Text(f.score > 0 ? '${f.score} pts' : 'New',
              style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
