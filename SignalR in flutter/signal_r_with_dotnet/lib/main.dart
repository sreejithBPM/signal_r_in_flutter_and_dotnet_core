import 'package:flutter/material.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String typingStatus = "";
  List<String> messages = [];
  String user = "";

  final hubConnection = HubConnectionBuilder()
      .withUrl('https://localhost:7235/chatHub') // Replace with your SignalR hub URL
      .build();

  @override
  void initState() {
    super.initState();

    // Start the SignalR connection
    hubConnection.start();

    // Listen for received messages
    hubConnection.on('ReceiveMessage', (arguments) {
      String sendingUser = arguments?[0] as String? ?? '';
      String message = arguments?[1] as String? ?? '';
      print('$sendingUser');

      setState(() {
        messages.add('$sendingUser saysflutter: $message');
      });
    });
    _messageController.addListener(() {
      bool isTyping = _messageController.text.isNotEmpty;
      print('Before invoking SendTypingStatus: user=$user, isTyping=$isTyping');
hubConnection.invoke('SendTypingStatus', args: [user, isTyping]);
print('After invoking SendTypingStatus');
    });

    // Listen for typing status updates
    hubConnection.on('ReceiveTypingStatus', (arguments) {
      String typingUser = arguments?[0] as String? ?? '';
      bool isTyping = arguments?[1] as bool? ?? false;

      setState(() {
        if (isTyping) {
          typingStatus = '$typingUser is typing...';
        } else {
          typingStatus = '';
        }
      });
    });
  }

  void sendMessage() {
    final message = _messageController.text;

    if (message.isNotEmpty) {
      hubConnection.invoke('SendMessage', args: [user, message]);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: <Widget>[
          // User input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'User'),
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
          ),

          // Typing status
          Text(
            typingStatus,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.blue,
            ),
          ),

          // Message list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),

          // Send button
          ElevatedButton(
            onPressed: sendMessage,
            child: Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    hubConnection.stop();
    super.dispose();
  }
}
