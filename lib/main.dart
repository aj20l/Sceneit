import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sceneit/widgets/bottom_nav.dart';
import 'User.dart';
import 'package:sceneit/utils/session.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await APIHelper.fetchGenres();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SceneIt",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "sans-serif",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool hide = true;

  late AnimationController anim;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    fade = CurvedAnimation(curve: Curves.easeOutBack, parent: anim);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _background(
        child: FadeTransition(
          opacity: fade,
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.movie_filter_rounded,
                  size: 95,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  "SceneIt 🎬",
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 35),
                _input(username, "Username", Icons.person),
                const SizedBox(height: 14),
                _input(password, "Password", Icons.lock, isPass: true),

                const SizedBox(height: 28),
                _mainBtn("Login", () => _login()),
                const SizedBox(height: 10),
                _outlineBtn("Continue as guest", () {
                  Session.currentUser = null;
                  go(const BottomNav());
                }),

                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => go(const RegisterPage()),
                  child: const Text(
                    "Create New Account",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    String user = username.text.trim();
    String pass = password.text.trim();
    if (user.isEmpty || pass.isEmpty) return message("Fill all fields");

    if (user == "admin" && pass == "1234") {
      Session.currentUser = User(
        id: 0,
        username: "admin",
        email: "admin@mail.com",
        password: pass,
      );
      return go(const BottomNav());
    }

    final model = UserModel();
    final found = await model.getUserByCredentials(user, pass);

    found == null ? message("Invalid login") : go(const BottomNav());
  }

  Widget _background({required Widget child}) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(child: child),
  );

  Widget _glassCard({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withOpacity(.09),
          border: Border.all(color: Colors.white24),
        ),
        child: child,
      ),
    ),
  );

  Widget _input(
    TextEditingController c,
    String text,
    IconData icon, {
    bool isPass = false,
  }) {
    return TextField(
      controller: c,
      obscureText: isPass ? hide : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                  hide ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => hide = !hide),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(.07),
        border: _border(),
        enabledBorder: _border(op: .4),
        focusedBorder: _border(width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border({double op = 1, double width = .9}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(op),
          width: width,
        ),
      );

  Widget _mainBtn(String t, Function onTap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: Colors.white,
      ),
      onPressed: () => onTap(),
      child: Text(t, style: const TextStyle(fontSize: 18, color: Colors.white)),
    ),
  );

  Widget _outlineBtn(String text, Function tap) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () => tap(),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    ),
  );

  void go(Widget p) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => p));

  void message(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController user = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _bg,
        child: Center(
          child: _glass(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),

                _field(user, "Username", Icons.person),
                const SizedBox(height: 13),
                _field(email, "Email", Icons.email),
                const SizedBox(height: 13),
                _field(pass, "Password", Icons.key, passField: true),

                const SizedBox(height: 25),
                _btn("Register", register),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> register() async {
    if (user.text.isEmpty || email.text.isEmpty || pass.text.isEmpty) {
      msg("Fill all fields");
      return;
    }

    final model = UserModel();
    final id = await model.insertUser(
      User(username: user.text, email: email.text, password: pass.text),
    );

    Session.currentUser = User(
      id: id,
      username: user.text,
      email: email.text,
      password: pass.text,
    );

    go(const BottomNav());
  }

  Widget _field(
    TextEditingController c,
    String l,
    IconData ic, {
    bool passField = false,
  }) {
    return TextField(
      controller: c,
      obscureText: passField ? !show : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: l,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(ic, color: Colors.white70),
        suffixIcon: passField
            ? IconButton(
                icon: Icon(
                  show ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () => setState(() => show = !show),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(.07),
        border: _b(),
        enabledBorder: _b(opacity: .4),
        focusedBorder: _b(width: 1.5),
      ),
    );
  }

  OutlineInputBorder _b({double opacity = 1, double width = .9}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(opacity),
          width: width,
        ),
      );

  Widget _btn(String t, Function tap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: Colors.white,
      ),
      onPressed: () => tap(),
      child: const Text(
        "Register",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _glass({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.white.withOpacity(.09),
          border: Border.all(color: Colors.white24),
        ),
        child: child,
      ),
    ),
  );

  final _bg = const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  void go(Widget p) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => p));
  void msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
}
