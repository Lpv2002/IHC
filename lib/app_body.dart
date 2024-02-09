import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

class AppBody extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const AppBody({
    Key? key,
    this.messages = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = messages[messages.length - 1 - i];
        Message message = obj['message'];
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageContainer(
              message: message,
              isUserMessage: isUserMessage,
            ),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: messages.length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;

  const _MessageContainer({
    Key? key,
    required this.message,
    this.isUserMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200),
      child: LayoutBuilder(
        builder: (context, constrains) {
          switch (message.type) {            
            case MessageType.text:
            default:
              return Container(
                decoration: BoxDecoration(
                  color: isUserMessage
                      ? Color.fromARGB(157, 2, 61, 109)
                      : const Color.fromARGB(255, 54, 52, 48),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: !isUserMessage
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.all(10),
                child: Text(
                  message.text?.text?[0] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
