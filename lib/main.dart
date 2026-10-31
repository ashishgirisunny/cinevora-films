import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

// ULTRA PREMIUM OTT THEME PALETTE
const Color kCrimson = Color(0xFFE50914);
const Color kDarkCanvas = Color(0xFF07090E);
const Color kSurfaceCard = Color(0xFF131722);
const Color kDeepBorder = Color(0xFF1F2637);
const Color kGoldAccent = Color(0xFFFFB800);
const String kBaseApi = 'http://cinevorafilms.in/api/index.php';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const CineVoraMasterApp());
}

class CineVoraMasterApp extends StatelessWidget {
  const CineVoraMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinevora Films Ott',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkCanvas,
        primaryColor: kCrimson,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0E15), elevation: 0),
        colorScheme: const ColorScheme.dark(primary: kCrimson, surface: kSurfaceCard),
        fontFamily: 'sans-serif',
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= CLOUD API GATEWAY =================
class ApiService {
  static Future> fetchFeed(int userId) async {
    try {
      final res = await http.get(Uri.parse('$kBaseApi?action=get_feed&user_id=$userId')).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {'status': 'error'};
  }

  static Future> login(String email, String pass) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseApi?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': pass}),
      );
      return jsonDecode(res.body);
    } catch (_) {}
    return {'status': 'error', 'message': 'Network connect nahi hua!'};
  }

  static Future> signup(String name, String email, String pass) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseApi?action=signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': pass}),
      );
      return jsonDecode(res.body);
    } catch (_) {}
    return {'status': 'error', 'message': 'Registration fail hua!'};
  }

  static Future<void> trackWatch(int mid, int uid) async {
    try {
      await http.post(
        Uri.parse('$kBaseApi?action=track_watch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'movie_id': mid, 'user_id': uid}),
      );
    } catch (_) {}
  }

  static Future<void> trackDownload(int mid, int uid) async {
    try {
      await http.post(
        Uri.parse('$kBaseApi?action=track_download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'movie_id': mid, 'user_id': uid}),
      );
    } catch (_) {}
  }

  static Future> verifyPayment(int uid, int planId, double amount, String txId) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseApi?action=verify_payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': uid,
          'plan_id': planId,
          'amount': amount,
          'payment_id': txId,
        }),
      );
      return jsonDecode(res.body);
    } catch (_) {}
    return {'status': 'error'};
  }
}

// ================= SPLASH =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('uid') ?? 0;
    if (!mounted) return;
    if (uid > 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePickerScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cinevora Films Ott', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            SizedBox(height: 8),
            Text('Your Stories. Beautifully Streamed.', style: TextStyle(fontSize: 12, color: Colors.white54, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ================= WHO IS WATCHING (MULTI-PROFILE) =================
class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Cinevora Films Ott', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 40),
              const Text('Who is watching?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileTile(context, name: 'Sunny', color: const Color(0xFF1B4D3E), letter: 'S', isKids: false),
                  const SizedBox(width: 24),
                  _buildProfileTile(context, name: 'Kids', color: const Color(0xFF262C4B), letter: 'K', isKids: true),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add, size: 36, color: Colors.white60),
              ),
              const SizedBox(height: 10),
              const Text('Add profile', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())),
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: const Text('Manage profiles', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, {required String name, required Color color, required String letter, required bool isKids}) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: Text(letter, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              if (isKids)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: kCrimson, borderRadius: BorderRadius.circular(6)),
                  child: const Text('KIDS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

// ================= AUTH SCREENS =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final res = await ApiService.login(_email.text.trim(), _pass.text.trim());
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      final u = res['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('uid', u['id']);
      await prefs.setString('name', u['name'] ?? 'Sunny');
      await prefs.setString('email', u['email'] ?? '');
      await prefs.setInt('is_vip', u['is_premium'] ?? 0);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePickerScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Login failed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Text('Cinevora Films Ott', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1724),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF3B253E)),
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Sign in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'name@example.com',
                            filled: true,
                            fillColor: const Color(0xFF14131D),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Email address daalo' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: _hide,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _hide = !_hide)),
                            filled: true,
                            fillColor: const Color(0xFF14131D),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kCrimson,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New here? ', style: TextStyle(color: Colors.white60, fontSize: 13)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                              child: const Text('Create account', style: TextStyle(color: kCrimson, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    final res = await ApiService.signup(_name.text.trim().isEmpty ? 'Sunny' : _name.text.trim(), _email.text.trim(), _pass.text.trim());
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      final u = res['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('uid', u['id']);
      await prefs.setString('name', u['name'] ?? 'Sunny');
      await prefs.setString('email', u['email'] ?? '');
      await prefs.setInt('is_vip', u['is_premium'] ?? 0);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePickerScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: const Color(0xFF1E1724), borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create your account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: Color(0xFF14131D))),
              const SizedBox(height: 12),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Color(0xFF14131D))),
              const SizedBox(height: 12),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Color(0xFF14131D))),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kCrimson, minimumSize: const Size.fromHeight(48)),
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MAIN NAVIGATION SHELL =================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final List<Widget> _tabs = const [
    HomeScreen(),
    BrowseCatalogScreen(),
    WishlistScreen(),
    AccountProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        backgroundColor: const Color(0xFF0F121B),
        selectedItemColor: kCrimson,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
        ],
      ),
    );
  }
}

// ================= 1. HOME SCREEN (FULL ADVANCED FEED) =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> feed = {};
  bool loading = true;
  int uid = 0;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getInt('uid') ?? 0;
    final res = await ApiService.fetchFeed(uid);
    if (mounted) {
      setState(() {
        feed = res;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kCrimson)));

    final featured = feed['featured'];
    final trending = (feed['trending'] as List?) ?? [];
    final bhojpuri = (feed['bhojpuri'] as List?) ?? [];
    final series = (feed['series'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinevora Films Ott', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF1B4D3E),
            child: const Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with Gradient
              if (featured != null)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaDetailScreen(item: featured, uid: uid))),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      CachedNetworkImage(
                        imageUrl: featured['poster'] ?? '',
                        height: 380,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(height: 380, color: kSurfaceCard),
                      ),
                      Container(
                        height: 380,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, kDarkCanvas.withOpacity(0.95)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(featured['title'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('${featured['year'] ?? '2026'} • ${featured['category'] ?? 'Blockbuster'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: kCrimson),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaDetailScreen(item: featured, uid: uid))),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Now'),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

              // Categories Quick Slider
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text('Videos Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _categoryBubble('Action', const Color(0xFF9E1B32)),
                    _categoryBubble('Drama', const Color(0xFF4A148C)),
                    _categoryBubble('Bhojpuri', const Color(0xFFC2185B)),
                    _categoryBubble('Comedy', const Color(0xFF00695C)),
                  ],
                ),
              ),

              // Trending Movies
              if (trending.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text('🔥 Trending Movies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: trending.length,
                    itemBuilder: (context, i) => _mediaCard(trending[i]),
                  ),
                ),
              ],

              // Bhojpuri Blockbusters Section
              if (bhojpuri.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text('🌟 Bhojpuri Hits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: bhojpuri.length,
                    itemBuilder: (context, i) => _mediaCard(bhojpuri[i]),
                  ),
                ),
              ],

              // Web Series
              if (series.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Text('🥞 Web Series & Originals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: series.length,
                    itemBuilder: (context, i) => _seriesCard(series[i]),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryBubble(String name, Color col) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
      ),
      alignment: Alignment.center,
      child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _mediaCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaDetailScreen(item: item, uid: uid))),
      child: Container(
        width: 125,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: item['poster'] ?? '', height: 155, width: 125, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 155, color: kSurfaceCard)),
            ),
            const SizedBox(height: 4),
            Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _seriesCard(Map<String, dynamic> item) {
    return Container(
      width: 125,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(imageUrl: item['thumbnail'] ?? '', height: 155, width: 125, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 155, color: kSurfaceCard)),
          ),
          const SizedBox(height: 4),
          Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ================= 2. BROWSE SCREEN =================
class BrowseCatalogScreen extends StatelessWidget {
  const BrowseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories & Genres')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Languages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _langCard('Tamil', 'தமிழ்', Colors.red.shade900),
                const SizedBox(width: 12),
                _langCard('Hindi', 'हिन्दी', Colors.orange.shade900),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _langCard('Bhojpuri', 'भोजपुरी', Colors.purple.shade900),
                const SizedBox(width: 12),
                _langCard('English', 'English', Colors.green.shade900),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Audio Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _langCard('Pop', 'Pop Tracks', Colors.blueGrey.shade800),
                const SizedBox(width: 12),
                _langCard('Hip-Hop', 'Rap Beats', Colors.blueGrey.shade900),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _langCard(String title, String sub, Color col) {
    return Expanded(
      child: Container(
        height: 85,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ================= 3. WISHLIST & WATCH HISTORY =================
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My library')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => tab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tab == 0 ? kCrimson : Colors.transparent, width: 2))),
                    alignment: Alignment.center,
                    child: Text('Wishlist', style: TextStyle(color: tab == 0 ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => tab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tab == 1 ? kCrimson : Colors.transparent, width: 2))),
                    alignment: Alignment.center,
                    child: Text('Recently watched', style: TextStyle(color: tab == 1 ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tab == 0 ? Icons.bookmark_border : Icons.history, size: 64, color: Colors.white24),
                  const SizedBox(height: 14),
                  Text(tab == 0 ? 'Your wishlist is empty' : 'No watch history yet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Save titles you want to watch later', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= 4. ACCOUNT & SUBSCRIPTION CONSOLE =================
class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  String name = 'Sunny';
  String email = 'cinedesix27@gmail.com';
  int isVip = 0;
  List plans = [];
  String upiId = 'cinevora@upi';
  int curTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final res = await ApiService.fetchFeed(0);
    setState(() {
      name = prefs.getString('name') ?? 'Sunny';
      email = prefs.getString('email') ?? 'cinedesix27@gmail.com';
      isVip = prefs.getInt('is_vip') ?? 0;
      plans = res['subscription_plans'] ?? [];
      upiId = res['payment_gateways']?['upi_id'] ?? 'cinevora@upi';
    });
  }

  Future<void> _payUpi(Map<String, dynamic> p) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('uid') ?? 0;
    final price = double.tryParse(p['price'].toString()) ?? 199.0;
    final planId = int.tryParse(p['id'].toString()) ?? 1;

    final upiUri = Uri.parse('upi://pay?pa=$upiId&pn=CineVoraFilms&am=$price&cu=INR&tn=VIP_Subscription');
    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    final tx = 'UPI_${DateTime.now().millisecondsSinceEpoch}';
    final act = await ApiService.verifyPayment(uid, planId, price, tx);
    if (act['status'] == 'success') {
      await prefs.setInt('is_vip', 1);
      setState(() => isVip = 1);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 VIP Subscription Activated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _navBtn('Profile', 0),
                const SizedBox(width: 8),
                _navBtn('Subscription', 1),
                const SizedBox(width: 8),
                _navBtn('Watch history', 2),
              ],
            ),
            const SizedBox(height: 20),

            if (curTab == 0) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF161A26), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(radius: 28, backgroundColor: Color(0xFF1B4D3E), child: Text('S', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(email, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: isVip == 1 ? Colors.amber.withOpacity(0.2) : Colors.white12, borderRadius: BorderRadius.circular(6)),
                              child: Text(isVip == 1 ? '● VIP ACTIVE' : '● No active plan', style: TextStyle(color: isVip == 1 ? Colors.amber : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit profile', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePickerScreen())),
                            icon: const Icon(Icons.grid_view, size: 14),
                            label: const Text('Switch profile', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), minimumSize: const Size.fromHeight(40)),
                      onPressed: () async {
                        final p = await SharedPreferences.getInstance();
                        await p.clear();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      icon: const Icon(Icons.logout, size: 14),
                      label: const Text('Sign out', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
              ),
            ] else if (curTab == 1) ...[
              const Text('Active Subscription Plans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...plans.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: kSurfaceCard, border: Border.all(color: kDeepBorder), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text(p['plan_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGoldAccent)),
                            Text('₹${p['price']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${p['duration_days']} Days Validity • ${p['quality']} • ${p['device_limit']} Screens', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kCrimson, minimumSize: const Size.fromHeight(44)),
                          onPressed: () => _payUpi(p),
                          child: const Text('Subscribe & Pay via UPI (GPay / PhonePe)', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )),
            ] else ...[
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No watch records yet', style: TextStyle(color: Colors.white54)))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navBtn(String label, int idx) {
    final active = curTab == idx;
    return GestureDetector(
      onTap: () => setState(() => curTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: active ? const Color(0xFF262C3D) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

// ================= MEDIA DETAIL & STREAM PLAYER =================
class MediaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final int uid;
  const MediaDetailScreen({super.key, required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    final vUrl = item['video_url'] ?? '';
    final mid = int.tryParse(item['id'].toString()) ?? 0;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(imageUrl: item['poster'] ?? '', height: 260, width: double.infinity, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 260, color: kSurfaceCard)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${item['year'] ?? '2026'} • ${item['duration'] ?? '2h'} • ${item['category'] ?? 'Cinema'}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: kCrimson),
                        onPressed: () async {
                          ApiService.trackWatch(mid, uid);
                          final uri = Uri.parse(vUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Stream'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                        onPressed: () {
                          ApiService.trackDownload(mid, uid);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading started in background...')));
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item['description'] ?? 'No storyline details available.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

