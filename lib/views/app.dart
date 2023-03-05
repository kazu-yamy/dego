import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

final ipAddressProvider = StateProvider((ref) {
  return '000.000.000.000:8000';
});

final dateProvider = StateProvider((ref) {
  return '';
});

final timeProvider = StateProvider((ref) {
  return '';
});

final tempProvider = StateProvider((ref) {
  return 0.00;
});

final imageProvider = StateProvider((ref) {
  return '';
});

final dioProvider = StateProvider<Dio>((ref) {
  return Dio();
});

class AppPage extends ConsumerWidget {
  AppPage({super.key});

  final dataProvider = StreamProvider((ref) async* {
    Dio dio = ref.watch(dioProvider);
    Response<dynamic> sensorRes = await dio.get("/data/item/get");
    final data = await sensorRes.data[1]["item"];
    ref.read(dateProvider.notifier).state = data["date"];
    ref.read(timeProvider.notifier).state = data["time"];
    ref.read(tempProvider.notifier).state = data["temp"];
    ref.read(imageProvider.notifier).state =
        "http://${ref.read(ipAddressProvider)}/files/${data['image_path']}.jpg";
    await Future.delayed(const Duration(minutes: 10));
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);
    final time = ref.watch(timeProvider);
    final temp = ref.watch(tempProvider);
    final image = ref.watch(imageProvider);

    return Scaffold(
      body: Center(
          child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                      margin: const EdgeInsets.all(4),
                      shape: const Border.symmetric(),
                      child: Text("日付$date / 時間$time"),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.all(4),
                      shape: const Border.symmetric(),
                      child: Text("水温$temp"),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      margin: const EdgeInsets.all(4),
                      shape: const Border.symmetric(),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Text("Please set the correct IPAddress "),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ]))),
    );
  }
}

class IpAddressPage extends ConsumerWidget {
  const IpAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String ip = ref.watch(ipAddressProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "ip address",
                  hintText: ip.toString(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  ref.read(ipAddressProvider.notifier).state = value;
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () async {
                  final ipAddress = ref.watch(ipAddressProvider);
                  try {
                    BaseOptions options = BaseOptions(
                        baseUrl: "http://$ipAddress",
                        receiveDataWhenStatusError: true,
                        connectTimeout: const Duration(seconds: 1),
                        receiveTimeout: const Duration(seconds: 1));
                    Dio dio = Dio(options);
                    final sensorRes = await dio.get("/data/item/get");
                    if (sensorRes.statusCode == 200) {
                      final data = await sensorRes.data[1]["item"];
                      ref.read(dateProvider.notifier).state = data["date"];
                      ref.read(timeProvider.notifier).state = data["time"];
                      ref.read(tempProvider.notifier).state = data["temp"];
                      ref.read(imageProvider.notifier).state =
                          "http://$ipAddress/files/${data['image_path']}.jpg";
                    }
                  } catch (e) {
                    await Fluttertoast.showToast(msg: "取得できませんでした.");
                  }
                },
                child: const Text("登録"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
