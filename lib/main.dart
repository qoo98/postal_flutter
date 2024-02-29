import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_data.dart';
import 'form.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '郵便番号検索',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '郵便番号検索'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                // 履歴表示画面へ移動
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()));
              },
              icon: const Icon(Icons.history),
            )
          ],
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: ZipCodeForm());
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: AddressSearchResult(),
        ),
      ),
    );
  }
}

class AddressSearchResult extends ConsumerWidget {
  const AddressSearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 最新の入力値（Listの最後の値）を取得
    final input = ref.read(addressSearchHistoryProvider).inputHistory.last;
    // 取得した入力値からAPIリクエストの結果を取得
    final addressData = ref.watch(addressDataProvider(input));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('検索結果'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              addressData.when(
                data: (data) => data.formatResult(),
                error: (err, stack) => Text('Error : $err'),
                loading: () => const CircularProgressIndicator(),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('return home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends ConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.read(addressSearchHistoryProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('検索履歴'),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.home),
            )
          ],
        ),
        body: ListView.builder(
            itemCount: history.inputHistory.length,
            itemBuilder: (context, index) {
              // 逆順に参照出来るようにインデックスを変換する
              final reversedIndex = history.inputHistory.length - 1 - index;
              final zipCode = history.inputHistory[reversedIndex];

              return ListTile(
                title: Text(zipCode),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryDetailPage(
                              zipCode: zipCode,
                              item: history.searchResultHistory[zipCode]!)));
                },
              );
            }));
  }
}

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage(
      {super.key, required this.zipCode, required this.item});

  final String zipCode;
  final AddressData item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(zipCode),
        ),
        body: Container(
            padding: const EdgeInsets.all(30),
            child: Center(
                child: Column(
                  children: [
                    item.formatResult(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('return'),
                    ),
                  ],
                ))));
  }
}


