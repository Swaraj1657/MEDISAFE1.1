import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroqLLMButton extends StatefulWidget {
  final String apiKey;
  final String modelName;

  const GroqLLMButton({
    super.key,
    required this.apiKey,
    this.modelName = 'llama3-8b-8192',
  });

  @override
  State<GroqLLMButton> createState() => _GroqLLMButtonState();
}

class _GroqLLMButtonState extends State<GroqLLMButton> {
  final TextEditingController _promptController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _promptController.text = ''; // Ensure controller is initialized
  }

  Future<void> _getGroqResponse(
    String prompt,
    StateSetter dialogSetState,
  ) async {
    // Use dialogSetState to update dialog UI
    dialogSetState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.apiKey}',
        },
        body: jsonEncode({
          'model': widget.modelName,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      // Update state only if widget is still mounted
      if (mounted) {
        dialogSetState(() {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _response = data['choices'][0]['message']['content'];
          } else {
            _response = 'Error: ${response.statusCode}\n${response.body}';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // Update state only if widget is still mounted
      if (mounted) {
        dialogSetState(() {
          _response = 'Exception: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _showGroqDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to maintain dialog state
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 600,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Groq LLM Chat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your prompt here...',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => _getGroqResponse(
                                _promptController.text,
                                dialogSetState,
                              ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Send to Groq'),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _response.isEmpty
                                ? 'LLM response will appear here...'
                                : _response,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.chat),
      label: const Text('Chat with Groq LLM'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: _showGroqDialog,
    );
  }
}
