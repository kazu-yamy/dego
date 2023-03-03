import 'package:dego/views/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final baseTabViewProvider = StateProvider((ref) => ViewType.ipAddress);

enum ViewType { ipAddress, home, list }

class BaseTabView extends ConsumerWidget {
  BaseTabView({super.key});

  final widgets = [
    const IpAddressPage(),
    const AppPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(baseTabViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dego")),
      body: widgets[view.index],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Text("IP"), label: 'ipAddress'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home')
        ],
        currentIndex: view.index,
        onTap: (int index) => ref.read(baseTabViewProvider.notifier).state =
            ViewType.values[index],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
