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
      appBar: AppBar(title: const Text('Lucky Navigation Bar')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Number of Destinations'),
            trailing: DropdownButton<int>(
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
          ),
          SwitchListTile(
            title: const Text('Show FAB'),
            value: _showFab,
            onChanged: (val) {
              setState(() {
                _showFab = val;
              });
            },
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
      bottomNavigationBar: LuckyNavigationBar(
        selectedIndex: _selectedIndex,
        destinations: List.generate(
          _navCount,
          (i) => NavigationDestination(
            icon: const Icon(Icons.circle),
            label: 'Tab ${i + 1}',
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
                elevation: 1,
                highlightElevation: 1,
                shape: const CircleBorder(),
                child: const Icon(Icons.search, size: 28),
              )
            : null,
      ),
    );
  }
}
