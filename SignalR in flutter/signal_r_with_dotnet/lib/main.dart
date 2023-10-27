import 'package:flutter/material.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final hubConnection = HubConnectionBuilder()
      .withUrl('https://localhost:7235/chatHub') // Replace with your SignalR hub URL
      .build();

  TextEditingController userInputController = TextEditingController();
  TextEditingController messageInputController = TextEditingController();
  List<String> messages = [];

  void _sendMessage() {
    String user = userInputController.text;
    String message = messageInputController.text;

    // Send the message to the SignalR hub
    hubConnection.invoke('SendMessage', args: [user, message]);

    // Clear the input fields
    userInputController.clear();
    messageInputController.clear();
  }

  @override
  void initState() {
    super.initState();

    // Connect to the SignalR hub
    _startHubConnection();

    // Define an event handler for receiving messages
    hubConnection.on('ReceiveMessage', _handleReceivedMessage);
  }

  Future<void> _startHubConnection() async {
    try {
      await hubConnection.start();
      print('SignalR connection started.');
    } catch (e) {
      print('Error starting SignalR connection: $e');
    }
  }

  void _handleReceivedMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.length >= 2) {
      String user = arguments[0]?.toString() ?? '';
      String message = arguments[1]?.toString() ?? '';

      setState(() {
        messages.add('$user: $message');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Chat with SignalR'),
        ),
        body: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("User", style: TextStyle(fontSize: 16.0)),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: userInputController,
                      decoration: InputDecoration(hintText: "Enter your name"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Message", style: TextStyle(fontSize: 16.0)),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: messageInputController,
                      decoration: InputDecoration(hintText: "Enter your message"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text("Send Message"),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Divider(),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index], style: TextStyle(fontSize: 16.0)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure that the SignalR connection is closed when the app is disposed
    hubConnection.stop();
    super.dispose();
  }
}