import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const JokeGeneratorApp());
}

class JokeGeneratorApp extends StatelessWidget {
  const JokeGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const JokeScreen(),
    );
  }
}

class JokeService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8000/api/v1';

  Future<Map<String, dynamic>> getRandomJoke() async {
    try {
      final response = await _dio.get('$baseUrl/jokes/random');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch joke: $e');
    }
  }

  Future<Map<String, dynamic>> getJokeByCategory(String category) async {
    try {
      final response = await _dio.get('$baseUrl/jokes/category/$category');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch joke: $e');
    }
  }
}

class JokeScreen extends StatefulWidget {
  const JokeScreen({Key? key}) : super(key: key);

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  final JokeService _jokeService = JokeService();
  Map<String, dynamic>? _currentJoke;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Programming', 'Knock-knock'];

  @override
  void initState() {
    super.initState();
    _fetchRandomJoke();
  }

  Future<void> _fetchRandomJoke() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final joke = await _jokeService.getRandomJoke();
      setState(() {
        _currentJoke = joke;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchJokeByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedCategory = category;
    });

    try {
      final joke = await _jokeService.getJokeByCategory(category);
      setState(() {
        _currentJoke = joke;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎭 Joke Generator'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              const Text(
                'Select Category:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      if (selected) {
                        _fetchJokeByCategory(category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Joke Display
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Error: $_error',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                )
              else if (_currentJoke != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentJoke!['setup'] ?? _currentJoke!['joke'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Punchline:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentJoke!['punchline'] ?? _currentJoke!['delivery'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: _fetchRandomJoke,
                icon: const Icon(Icons.refresh),
                label: const Text('Get Random Joke'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (_currentJoke != null) {
                    final jokeText =
                        '${_currentJoke!['setup'] ?? _currentJoke!['joke']}\n\n${_currentJoke!['punchline'] ?? _currentJoke!['delivery']}';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Joke copied: $jokeText')),
                    );
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Joke'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
