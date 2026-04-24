import 'package:flutter/material.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSend;
  final Function(bool) onOcrSelected;
  final bool isLoading;
  final TextEditingController controller;

  const ChatInputWidget({
    super.key,
    required this.onSend,
    required this.onOcrSelected,
    required this.isLoading,
    required this.controller,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _showOcrOptions = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showOcrOptions)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showOcrOptions = false);
                      widget.onOcrSelected(true);
                    },
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Camera'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showOcrOptions = false);
                      widget.onOcrSelected(false);
                    },
                    icon: const Icon(Icons.photo_library, size: 20),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _showOcrOptions ? Icons.close : Icons.add_circle_outline,
                  color: const Color(0xFF2196F3),
                ),
                onPressed: () {
                  setState(() => _showOcrOptions = !_showOcrOptions);
                },
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onSend(value);
                      widget.controller.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
                child: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final text = widget.controller.text.trim();
                          if (text.isNotEmpty) {
                            widget.onSend(text);
                            widget.controller.clear();
                          }
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}