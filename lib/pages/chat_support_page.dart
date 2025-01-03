import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'chat_bot_webview.dart';  // Add this import

class ChatSupportPage extends StatelessWidget {
  const ChatSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Support'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSupportButton(
              context,
              'Technical Support',
              Icons.computer,
              () => _handleSupport(context, 'technical'),
            ),
            _buildSupportButton(
              context,
              'Order Issues',
              Icons.shopping_cart,
              () => _handleSupport(context, 'orders'),
            ),
            _buildSupportButton(
              context,
              'Payment Support',
              Icons.payment,
              () => _handleSupport(context, 'payment'),
            ),
            _buildSupportButton(
              context,
              'Other Issues',
              Icons.chat,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatBotWebView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(width: 15),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSupport(BuildContext context, String type) {
    // Navigate to ChatBotWebView with specific support type
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotWebView(),
      ),
    );
  }
}

class ChatBotWebView extends StatefulWidget {
  @override
  _ChatBotWebViewState createState() => _ChatBotWebViewState();
}

class _ChatBotWebViewState extends State<ChatBotWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => isLoading = true),
          onPageFinished: (url) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://ecub-bot2.vercel.app'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bot'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}