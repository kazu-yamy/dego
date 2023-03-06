import 'package:dego/views/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final baseTabViewProvider = StateProvider((ref) => ViewType.ipAddress);

enum ViewType { ipAddress, home, list }

class BaseTabView extends ConsumerWidget {
  BaseTabView({super.key});

  final widgets = [
    const IpAddressPage(),
    AppPage(),
  ];

  Widget buttomNav(BuildContext context, WidgetRef ref) {
    final view = ref.watch(baseTabViewProvider);
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: const Text("IP"),
            label: 'ipAddress',
            backgroundColor: Colors.deepPurpleAccent.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white),
        BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home',
            backgroundColor: Colors.deepPurpleAccent.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white),
      ],
      currentIndex: view.index,
      onTap: (int index) =>
          ref.read(baseTabViewProvider.notifier).state = ViewType.values[index],
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.deepPurpleAccent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(baseTabViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dego")),
      body: widgets[view.index],
      bottomNavigationBar: buttomNav(context, ref),
    );
  }
}
