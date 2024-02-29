import 'package:chat/address_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';

class ZipCodeForm extends ConsumerWidget {
  ZipCodeForm({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(22),
            child: TextFormField(
              controller: _controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '値を入力してください';
                } else if (int.tryParse(value) == null) {
                  return '数値を入力してください';
                } else if (value.length != 7) {
                  return '郵便番号はハイフンなし7桁で入力してください';
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // 入力履歴を追加
                  ref
                      .read(addressSearchHistoryProvider.notifier)
                      .addInputHistory(_controller.text);

                  // 画面遷移
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddressSearchResult()));
                }
              },
              child: const Text('Submit')),
        ],
      ),
    );
  }
}

