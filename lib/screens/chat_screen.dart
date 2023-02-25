import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firestore = FirebaseFirestore.instance;
var loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  String messageText = '';
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }


  void getCurrentUser() async{
    try {
      final user = await _auth.currentUser;
      if (user !=null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }
  void messageStream (){
    FirebaseFirestore.instance.collection('messages').snapshots().listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      // Handle each snapshot here
      snapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> message) {
        // Process each document in the snapshot
        //print('Document data: ${message.data()}');
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          /************************  Logout Button   **************************/
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            messagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /**************  Message Text Field  *******************/
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  /*************  Send Message Button   *************/
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class messagesStream extends StatelessWidget {
  const messagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        List<Widget> messageWidgets = [];
        //messageWidgets.reversed;

        if (snapshot.hasData) {
          final messages = snapshot.data?.docs.reversed; //.reversed

          if (messages != null) {
            for (var message in messages){
              final messageText = (message.data() as Map<String, dynamic>)['text']; // cast to Map<String, dynamic>
              final messageSender = (message.data() as Map<String, dynamic>)['sender']; // cast to Map<String, dynamic>
              final currentUser = loggedInUser.email;

              /*************** changing logedin user message bubble style **********************/

              final messageWidget = messageBubble(
                text: messageText,
                sender: messageSender,
                isMe: currentUser == messageSender,
              );
              messageWidgets.add(messageWidget);
            }
          }
        }
        return Expanded(
          child: ListView(
            reverse: false,
            scrollDirection: Axis.vertical,

            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}



class messageBubble extends StatelessWidget {
  const messageBubble({
    this.sender,
    this.text,
    this.isMe,
  });

  final String ? sender;
  final String ? text;
  final bool ? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children:[
          Text(
            sender!,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: isMe! ? BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)) :
            BorderRadius.only(topRight: Radius.circular(30.0), bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe! ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ], //children
      ),
    );;
  }
}