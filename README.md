# Lucky Navigation Bar

[![Package](https://img.shields.io/pub/v/lucky_navigation_bar.svg?style=for-the-badge)](https://pub.dartlang.org/packages/lucky_navigation_bar)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg?style=for-the-badge)](https://pub.dev/packages/very_good_analysis)
[![Build](https://img.shields.io/github/actions/workflow/status/jesusrp98/lucky_navigation_bar/flutter_package.yml?branch=master&style=for-the-badge)](https://github.com/jesusrp98/lucky_navigation_bar/actions)
[![Patreon](https://img.shields.io/badge/Support-Patreon-orange.svg?style=for-the-badge)](https://www.patreon.com/jesusrp98)
[![License](https://img.shields.io/github/license/jesusrp98/lucky_navigation_bar.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0.en.html)

This Flutter package allows you to use a iOS 26 (codenamed `lucky`) inspired navigation bar. You can even add a widget to the right also.

<p align="center">
  <img src="https://raw.githubusercontent.com/jesusrp98/lucky_navigation_bar/main/screenshots/gif_1.gif" width="600" hspace="4">
</p>

## Features

- Flexible Destinations: Add 2–6 navigation destinations with icons and labels using regular `NavigationDestination` class.
- Custom Trailing Widget: Add widgets (e.g., `FloatingActionButton`) to the end of the navigation bar, to mimick iOS.
- Stateful Selection: Easily manage and update the selected destination.
- Adaptive Layout: Handles different numbers of destinations and orientations gracefully.
- Easy Integration: Drop into any Scaffold as a bottom navigation bar, no complicated setup required.

## Example

Here is an example of a simple use of this package, featuring the `ExpandChild` & `ExpandText` widgets.

If you want to take a deeper look at the example, take a look at the [example](https://github.com/jesusrp98/lucky_navigation_bar/tree/master/example) folder provided with the project.


```
LuckyNavigationBar(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ],
  selectedIndex: selectedIndex,
  onDestinationSelected: (i) => setState(() => selectedIndex = i),
  trailing: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.search),
  ),
)
```

## Getting Started

This project is a starting point for a Dart [package](https://flutter.io/developing-packages/), a library module containing code that can be shared easily across multiple Flutter or Dart projects.

For help getting started with Flutter, view our [online documentation](https://flutter.io/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Built with

- [Flutter](https://flutter.dev/) - Beatiful native apps in record time.
- [Android Studio](https://developer.android.com/studio/index.html/) - Tools for building apps on every type of Android device.
- [Visual Studio Code](https://code.visualstudio.com/) - Code editing. Redefined.

## Authors

- **Jesús Rodríguez** - you can find me on [GitHub](https://github.com/jesusrp98), [Twitter](https://twitter.com/jesusrp98) & [Reddit](https://www.reddit.com/user/jesusrp98).

## License

This project is licensed under the GNU GPL v3 License - see the [LICENSE](LICENSE) file for details.
