import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicChatPage extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String clinicId;

  const ClinicChatPage({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.clinicId,
  });

  @override
  _ClinicChatPageState createState() => _ClinicChatPageState();
}

class _ClinicChatPageState extends State<ClinicChatPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    startAutoRefresh(); // Start the timer
  }

  /// Starts auto-refresh every 1 second
  void startAutoRefresh() {
    refreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchMessages();
    });
  }

  /// Fetches chat messages
  Future<void> fetchMessages() async {
    final response = await supabase
        .from('messages')
        .select()
        .or('sender_id.eq.${widget.clinicId},receiver_id.eq.${widget.clinicId}')
        .or('sender_id.eq.${widget.patientId},receiver_id.eq.${widget.patientId}')
        .order('timestamp', ascending: true);

    setState(() {
      messages = List<Map<String, dynamic>>.from(response);
    });
  }

  /// Sends a message
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    try {
      await supabase.from('messages').insert({
        'receiver_id': widget.patientId,
        'sender_id': widget.clinicId,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      messageController.clear();
      fetchMessages(); // Fetch messages after sending
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel(); // Cancel the timer when page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.patientName}")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['sender_id'] == widget.clinicId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message Input Field
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => sendMessage(messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return "${dateTime.hour}:${dateTime.minute}";
  }
}
