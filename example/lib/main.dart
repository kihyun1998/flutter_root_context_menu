import 'package:flutter/material.dart';
import 'package:flutter_root_context_menu/flutter_root_context_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Root Context Menu Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _lastAction = 'No action yet';

  void _incrementCounter() {
    setState(() {
      _counter++;
      _lastAction = 'Incremented counter';
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _lastAction = 'Reset counter';
    });
  }

  void _copyCounter() {
    setState(() {
      _lastAction = 'Copied: $_counter';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Context Menu Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Right-click on the areas below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Example 1: Counter with context menu
            ContextMenuArea(
              child: GestureDetector(
                onSecondaryTapDown: (details) {
                  showContextMenu(
                    context: context,
                    position: details.globalPosition,
                    items: [
                      ContextMenuItem(
                        label: 'Copy Counter',
                        icon: Icons.copy,
                        onTap: _copyCounter,
                      ),
                      ContextMenuItem(
                        label: 'Reset Counter',
                        icon: Icons.refresh,
                        onTap: _resetCounter,
                      ),
                      ContextMenuItem.divider(),
                      ContextMenuItem(
                        label: 'Delete',
                        icon: Icons.delete,
                        textColor: Colors.red,
                        onTap: () {
                          setState(() {
                            _lastAction = 'Delete clicked';
                          });
                        },
                      ),
                    ],
                  );
                },
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Counter Value:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Example 2: Text with different context menu
            ContextMenuArea(
              child: GestureDetector(
                onSecondaryTapDown: (details) {
                  showContextMenu(
                    context: context,
                    position: details.globalPosition,
                    items: [
                      ContextMenuItem(
                        label: 'Edit',
                        icon: Icons.edit,
                        onTap: () {
                          setState(() {
                            _lastAction = 'Edit clicked';
                          });
                        },
                      ),
                      ContextMenuItem(
                        label: 'Share',
                        icon: Icons.share,
                        onTap: () {
                          setState(() {
                            _lastAction = 'Share clicked';
                          });
                        },
                      ),
                      ContextMenuItem(
                        label: 'Print',
                        icon: Icons.print,
                        onTap: () {
                          setState(() {
                            _lastAction = 'Print clicked';
                          });
                        },
                      ),
                    ],
                    config: const ContextMenuConfig(
                      backgroundColor: Color(0xFF2C2C2C),
                      hoverColor: Color(0xFF404040),
                      textStyle: TextStyle(color: Colors.white, fontSize: 14),
                      elevation: 12.0,
                    ),
                  );
                },
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    'Right-click me for dark menu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Last action: $_lastAction',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
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
