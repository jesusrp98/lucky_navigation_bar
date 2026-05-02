import 'package:flutter/material.dart';
import 'package:lucky_navigation_bar/lucky_navigation_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExampleScaffold(),
      theme: ThemeData.light().copyWith(
        iconTheme: const IconThemeData(opticalSize: 24),
      ),
      debugShowCheckedModeBanner: false,
    );
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
  bool _minimized = false;
  bool _showAccessory = true;
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
          SwitchListTile(
            title: const Text('Minimized'),
            value: _minimized,
            onChanged: (val) {
              setState(() {
                _minimized = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Accessory'),
            value: _showAccessory,
            onChanged: (val) {
              setState(() {
                _showAccessory = val;
              });
            },
          ),
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
        minimized: _minimized,
        destinations: List.generate(
          _navCount,
          (i) => NavigationDestination(
            icon: Icon(switch (i) {
              1 => Symbols.king_bed_rounded,
              2 => Symbols.play_circle_rounded,
              _ => Symbols.home_rounded,
            }),
            label: 'Tab ${i + 1}',
          ),
        ),
        onDestinationSelected: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
        onMinimizedPressed: () {
          setState(() {
            _minimized = false;
          });
        },
        accessory: _showAccessory ? _Accessory() : null,
        trailing: _showFab
            ? AspectRatio(
                aspectRatio: 1,
                child: FloatingActionButton(
                  onPressed: () {},
                  elevation: 1,
                  highlightElevation: 1,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.search, size: 28),
                ),
              )
            : null,
      ),
    );
  }
}

class _Accessory extends StatelessWidget {
  const _Accessory();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: LuckyNavigationBar.minimizedHeight,
      child: Material(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(LuckyNavigationBar.height / 2),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: .4),
            width: 0.5,
          ),
        ),
        color: colorScheme.surfaceContainer,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: .spaceAround,
            children: const [Text('Years'), Text('Months')],
          ),
        ),
      ),
    );
  }
}
