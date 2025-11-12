import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'config/ai_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AITestPage(),
    );
  }
}

class AITestPage extends StatefulWidget {
  const AITestPage({super.key});

  @override
  State<AITestPage> createState() => _AITestPageState();
}

class _AITestPageState extends State<AITestPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedModel = 'gemini-pro';

  final List<String> _models = [
    'gemini-pro',
    'gemini-1.5-pro',
    'gemini-1.5-flash',
    'gemini-1.5-pro-latest',
    'gemini-1.5-flash-latest',
  ];

  Future<void> _testModel() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing model: $_selectedModel...\n';
    });

    try {
      final model = GenerativeModel(
        model: _selectedModel,
        apiKey: AIConfig.geminiApiKey,
      );

      final prompt = _controller.text.isEmpty ? 'Say hello in Vietnamese' : _controller.text;
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _result = '✅ SUCCESS!\n\n'
            'Model: $_selectedModel\n'
            'Response:\n${response.text ?? "No response"}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ FAILED!\n\n'
            'Model: $_selectedModel\n'
            'Error: $e\n\n'
            'Try another model from the dropdown.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google AI Model Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AIConfig.geminiApiKey.substring(0, 20)}...',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Model selector
            const Text(
              'Select Model:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedModel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _models.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedModel = value!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Prompt input
            const Text(
              'Test Prompt (optional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter your test prompt (default: "Say hello in Vietnamese")',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Test button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testModel,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Testing...' : 'Test Model'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Result
            const Text(
              'Result:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result.isEmpty ? 'Click "Test Model" to start' : _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
