import 'package:flutter/material.dart';
import 'package:lucky_navigation_bar/lucky_navigation_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleScaffold());
  }
}

class ExampleScaffold extends StatefulWidget {
  const ExampleScaffold({super.key});

  @override
  State<ExampleScaffold> createState() => _ExampleScaffoldState();
}

class _ExampleScaffoldState extends State<ExampleScaffold> {
  int _navCount = 3;
  bool _showFab = true;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Bar Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Number of Destinations:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _navCount,
                  items: List.generate(3, (i) => i + 2)
                      .map(
                        (count) => DropdownMenuItem(
                          value: count,
                          child: Text(count.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _navCount = val;
                        if (_selectedIndex >= _navCount) {
                          _selectedIndex = 0;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text('Show FAB:'),
                Switch(
                  value: _showFab,
                  onChanged: (val) {
                    setState(() {
                      _showFab = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  'Selected: Destination ${_selectedIndex + 1}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LuckyNavigationBar(
        selectedIndex: _selectedIndex,
        destinations: List.generate(
          _navCount,
          (i) => NavigationDestination(
            icon: const Icon(Icons.circle),
            label: 'Dest ${i + 1}',
          ),
        ),
        onDestinationSelected: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
        trailing: _showFab
            ? FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
