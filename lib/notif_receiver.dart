import 'package:flutter/material.dart';
import 'package:health_app_repo/util/functions.dart';

import 'functions_and_shit.dart';

class NotifReceiver extends StatefulWidget {
  final String payload;

  const NotifReceiver({Key? key, required this.payload}) : super(key: key);
  @override
  _NotifReceiverState createState() => _NotifReceiverState();
}

class _NotifReceiverState extends State<NotifReceiver>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🌺 🌺 🌺 🌺 🌺 NotifReceiver: ';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm NotifReceiver: initState started!');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Receiver'),
      ),
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.payload,
                style: Styles.greyLabelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
