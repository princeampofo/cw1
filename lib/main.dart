import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleImage() {
    _animationController.reverse().then((_) {
      setState(() {
        _isFirstImage = !_isFirstImage;
      });
      _animationController.forward();
    });
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
                      ? 'https://picsum.photos/200/200?random=1'
                      : 'https://picsum.photos/200/200?random=2',
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
            
            const SizedBox(height: 40),
            
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