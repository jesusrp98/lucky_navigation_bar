import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky_navigation_bar/src/lucky_navigation_bar.dart';

void main() {
  group('LuckyNavigationBar', () {
    testWidgets('renders correct number of destinations', (tester) async {
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LuckyNavigationBar(
            destinations: destinations,
            selectedIndex: selected,
            onDestinationSelected: (i) => selected = i,
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(
        find.byType(NavigationDestination),
        findsNothing,
      ); // Custom rendering

      expect(find.byType(Text), findsNWidgets(3));
    });

    testWidgets('calls onDestinationSelected when tapped', (tester) async {
      var selected = 0;
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: LuckyNavigationBar(
            destinations: destinations,
            selectedIndex: selected,
            onDestinationSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('shows trailing widget if provided', (tester) async {
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: LuckyNavigationBar(
            destinations: destinations,
            onDestinationSelected: (_) {},
            trailing: const Text('Trailing'),
          ),
        ),
      );
      expect(find.text('Trailing'), findsOneWidget);
    });

    testWidgets('shows accessory while minimized', (tester) async {
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: LuckyNavigationBar(
            destinations: destinations,
            minimized: true,
            accessory: const SizedBox(
              height: 80,
              child: Text('Years Months All'),
            ),
            trailing: const Text('Trailing'),
            onDestinationSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final accessoryOpacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.text('Years Months All'),
          matching: find.byType(Opacity),
        ),
      );
      final accessorySize = tester.getSize(
        find.ancestor(
          of: find.text('Years Months All'),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == 80,
          ),
        ),
      );

      expect(accessoryOpacity.opacity, 1);
      expect(accessorySize.height, 80);
      expect(find.text('Trailing'), findsOneWidget);
    });

    testWidgets('minimizes to selected destination icon', (tester) async {
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: LuckyNavigationBar(
            destinations: destinations,
            selectedIndex: 1,
            minimized: true,
            onDestinationSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final minimizedSurface = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == LuckyNavigationBar.height &&
            widget.height == LuckyNavigationBar.height,
      );

      expect(minimizedSurface, findsOneWidget);
      expect(
        find.descendant(
          of: minimizedSurface,
          matching: find.byIcon(Icons.search),
        ),
        findsOneWidget,
      );
    });

    testWidgets('updates selectedIndex visually', (tester) async {
      var selected = 0;
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => LuckyNavigationBar(
              destinations: destinations,
              selectedIndex: selected,
              onDestinationSelected: (i) => setState(() => selected = i),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      // The second item should now be selected visually
      final selectedText = tester.widget<Text>(find.text('Search'));
      expect(selectedText.style?.color, isNotNull);
    });

    testWidgets('handles 2, 3, and >3 destinations', (tester) async {
      for (final count in [2, 3, 4, 5]) {
        final destinations = List.generate(
          count,
          (i) => NavigationDestination(
            icon: const Icon(Icons.circle),
            label: 'Dest $i',
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: LuckyNavigationBar(
              destinations: destinations,
              onDestinationSelected: (_) {},
            ),
          ),
        );
        expect(find.byType(Text), findsNWidgets(count));
      }
    });
  });
}
