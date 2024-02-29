import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat/request.dart';

// 検索結果を返すプロバイダ
final addressDataProvider =
FutureProvider.autoDispose.family<AddressData, String>((ref, input) async {
  try {
    final response = await fetchResult(
        'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$input');
    final data = AddressData.fromJson(jsonDecode(response.body));
    // 検索結果を履歴として保存
    ref
        .read(addressSearchHistoryProvider.notifier)
        .addSearchAddressData(input, data);
    return data;
  } catch (e) {
    throw Exception(e);
  }
});

final addressSearchHistoryProvider =
StateNotifierProvider<AddressSearchHistoryState, AddressSearchHistory>(
        (ref) => AddressSearchHistoryState());

class AddressData {
  final int _status;
  final String? _message;
  final List<ResultsFields>? _results;

  const AddressData({
    required int status,
    required String? message,
    required List<ResultsFields>? results,
  })  : _results = results,
        _message = message,
        _status = status;

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      status: json['status'],
      message: json['message'] as String?,
      results: json['results'] != null
          ? (json['results'] as List<dynamic>)
          .map((item) => ResultsFields.fromJson(item))
          .toList()
          : [],
    );
  }

  Widget formatResult() {
    if (_results!.isEmpty) {
      //存在しない郵便番号を指定した場合ここ（ステータスコード200のみ返る）
      return const Text('存在しない郵便番号です');
    }
    return Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(),
            columns: const [
              DataColumn(label: Text('都道府県名')),
              DataColumn(label: Text('市区町村名')),
              DataColumn(label: Text('町域名'))
            ],
            rows: _results!
                .map((item) => DataRow(cells: <DataCell>[
              DataCell(Text(
                item.address1,
              )),
              DataCell(Text(
                item.address2,
              )),
              DataCell(Text(
                item.address3,
              )),
            ]))
                .toList(),
          ),
        ));
  }
}

class ResultsFields {
  final String zipcode;
  final String prefcode;
  final String address1;
  final String address2;
  final String address3;
  final String kana1;
  final String kana2;
  final String kana3;

  const ResultsFields({
    required this.zipcode,
    required this.prefcode,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.kana1,
    required this.kana2,
    required this.kana3,
  });

  factory ResultsFields.fromJson(Map<String, dynamic> json) {
    return ResultsFields(
      zipcode: json['zipcode'],
      prefcode: json['prefcode'],
      address1: json['address1'],
      address2: json['address2'],
      address3: json['address3'],
      kana1: json['kana1'],
      kana2: json['kana2'],
      kana3: json['kana3'],
    );
  }
}

class AddressSearchHistory {
  AddressSearchHistory();

  List<String> inputHistory = [];
  Map<String, AddressData> searchResultHistory = {};
}

class AddressSearchHistoryState extends StateNotifier<AddressSearchHistory> {
  AddressSearchHistoryState() : super(AddressSearchHistory());

  // 検索履歴末尾にinputZipCodeの値を追加
  void addInputHistory(String inputZipCode) {
    state.inputHistory = [...state.inputHistory, inputZipCode];
    if (state.inputHistory.length > 20) {
      // 削除する履歴の配列を作成し、保存済の検索結果から対応するものを削除する
      final removeKeyList =
      state.inputHistory.sublist(0, state.inputHistory.length - 20);
      _removeSearchCache(removeKeyList);

      // リスト末尾から20を引いたところを始点にしたリスト（最新20件）を作成し、履歴を更新
      state.inputHistory =
          state.inputHistory.sublist(state.inputHistory.length - 20);
    }
  }

  void _removeSearchCache(List<String> removeKey) {
    // 検索履歴から削除された郵便番号に対応する検索結果も削除する
    removeKey.forEach((key) {
      state.searchResultHistory.remove(key);
    });
  }

  // 検索結果を保存
  void addSearchAddressData(String input, AddressData data) {
    state.searchResultHistory[input] = data;
  }
}

