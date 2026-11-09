import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MrPlayPointsApp());
}

class MrPlayPointsApp extends StatelessWidget {
  const MrPlayPointsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr Play Points',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFBBF24),
          secondary: Color(0xFF1E293B),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accounts = prefs.getStringList('accounts') ?? [];
    });
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('accounts', _accounts);
  }

  void _addAccountDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('إضافة حساب', style: TextStyle(color: Color(0xFFFBBF24))),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'الاسم المستعار للحساب',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _accounts.add(controller.text));
                _saveAccounts();
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _openClaimWebView(String accountName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaimWebView(accountName: accountName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mr Play Points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
                        Text('مساعد نقاط Google Play', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الحسابات المسجلة', style: TextStyle(fontSize: 16, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFBBF24)),
                    onPressed: _addAccountDialog,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _accounts.isEmpty
                  ? const Center(
                      child: Text('لا توجد حسابات مسجلة حالياً\nاضغط + لإضافة حساب', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.2),
                              child: Text(_accounts[index][0].toUpperCase(), style: const TextStyle(color: Colors.green)),
                            ),
                            title: Text(_accounts[index], style: const TextStyle(color: Colors.white)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBBF24)),
                                  onPressed: () => _openClaimWebView(_accounts[index]),
                                  child: const Text('فتح', style: TextStyle(color: Colors.black)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() => _accounts.removeAt(index));
                                    _saveAccounts();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClaimWebView extends StatefulWidget {
  final String accountName;
  const ClaimWebView({super.key, required this.accountName});

  @override
  State<ClaimWebView> createState() => _ClaimWebViewState();
}

class _ClaimWebViewState extends State<ClaimWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _autoClaim();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://play.google.com/store/points/perks'));
  }

  void _autoClaim() async {
    // ننتظر 5 ثواني لكي يتم تحميل الصفحة بالكامل (لتجنب الحظر)
    await Future.delayed(const Duration(seconds: 5));
    
    final jsCode = """
      var buttons = document.querySelectorAll('button, [role="button"], span');
      for (var i = 0; i < buttons.length; i++) {
        var text = buttons[i].innerText.trim();
        if (text === 'Claim' || text === 'استلام' || text === 'المطالبة') {
          buttons[i].click();
          return 'Clicked';
        }
      }
      return 'Not Found';
    """;
    
    await _controller.runJavaScriptReturningResult(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حساب: ${widget.accountName}'),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          )
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFBBF24))),
        ],
      ),
    );
  }
}
