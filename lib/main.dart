import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        onThemeChange: changeTheme,
        currentTheme: _themeMode,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key, 
    required this.title,
    required this.onThemeChange,
    required this.currentTheme,
  });

  final String title;
  final Function(ThemeMode) onThemeChange;
  final ThemeMode currentTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
    with TickerProviderStateMixin {
  int _counter = 0;
  bool _isFirstImage = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // SharedPreferences keys
  static const String _counterKey = 'counter_value';
  static const String _imageStateKey = 'image_state';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    _loadState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt(_counterKey) ?? 0;
      _isFirstImage = prefs.getBool(_imageStateKey) ?? true;
    });
  }

  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, _counter);
  }

  Future<void> _saveImageState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_imageStateKey, _isFirstImage);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter(); 
  }

  void _toggleImage() {
    _animationController.reverse().then((_) {
      setState(() {
        _isFirstImage = !_isFirstImage;
      });
      _saveImageState();
      _animationController.forward();
    });
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to reset the application? This will clear the counter and reset the image to its initial state.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _resetApplication();
    }
  }

  
  Future<void> _resetApplication() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_counterKey);
    await prefs.remove(_imageStateKey);
    
    await _animationController.reverse();
    
    setState(() {
      _counter = 0;
      _isFirstImage = true;
    });
    

    await _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              widget.onThemeChange(
                widget.currentTheme == ThemeMode.light 
                  ? ThemeMode.dark 
                  : ThemeMode.light
              );
            },
            icon: Icon(
              widget.currentTheme == ThemeMode.dark
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image Section with Animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _isFirstImage 
                      ? 'https://fastly.picsum.photos/id/1005/200/200.jpg?hmac=TlSxs8p2lqA8VkV-Kpg7DKnp8BkwK9UDBHrU2UegLzI'
                      : 'https://fastly.picsum.photos/id/916/200/200.jpg?hmac=hEUrLG-ayFdIoyHKUwazT8SMEsVxWH9xGz4tx-e0cN0',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _toggleImage,
              child: const Text('Toggle Image'),
            ),
            
            const SizedBox(height: 20),
            
            // Theme Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onThemeChange(ThemeMode.light),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.currentTheme == ThemeMode.light 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                    foregroundColor: widget.currentTheme == ThemeMode.light
                        ? Colors.black
                        : Colors.white,
                  ),
                  child: const Text('Light Mode'),
                ),
                ElevatedButton(
                  onPressed: () => widget.onThemeChange(ThemeMode.dark),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.currentTheme == ThemeMode.dark 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                    foregroundColor: widget.currentTheme == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: const Text('Dark Mode'),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Reset Button with distinct styling
            ElevatedButton(
              onPressed: _showResetDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18),
                  SizedBox(width: 8),
                  Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Counter Section
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}