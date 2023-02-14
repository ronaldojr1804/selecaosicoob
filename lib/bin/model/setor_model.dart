// To parse this JSON data, do
//
//     final setor = setorFromJson(jsonString);
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:selecaosicoob/bin/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

List<Setor> setorFromJson(String str) =>
    List<Setor>.from(json.decode(str).map((x) => Setor.fromJson(x)));

String setorToJson(List<Setor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setor {
  Setor({
    this.codigoSetor = '',
    this.uidSetor = '',
    required this.descricao,
  });

  String codigoSetor;
  String uidSetor;
  String descricao;

  factory Setor.fromJson(Map<String, dynamic> json) => Setor(
        codigoSetor: json["codigoSetor"],
        uidSetor: json["uidSetor"],
        descricao: json["descricao"],
      );

  Map<String, dynamic> toJson() => {
        "codigoSetor": codigoSetor,
        "uidSetor": uidSetor,
        "descricao": descricao,
      };
}

class SetorController extends ChangeNotifier {
  bool _isLoading = false;
  String _hasError = '';
  final Uuid _uuid = const Uuid();
  List<Setor> _listaSetor = [];

  SetorController({bool loadSetores = false}) {
    if (loadSetores) {
      getSetores();
    }
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError.isNotEmpty;
  bool get hasData => _listaSetor.isNotEmpty;
  String get error => _hasError;
  List<Setor> get listaSetor => _listaSetor;

  _setLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  Future<void> getSetores() async {
    _setLoading();
    FirestoreService firestoreService = FirestoreService('setor');
    _listaSetor = [];
    await firestoreService.getItems().then((snapshot) {
      _listaSetor = snapshot
          .map((e) => Setor.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    });

    notifyListeners();
    _setLoading();
  }

  Future<void> setdata(Setor setor) async {
    // ESSE METODO SERVE TANTO PARA INSERIR QUANTO PARA EDITAR
    _setLoading();
    FirestoreService firestoreService = FirestoreService('setor');

    if (setor.uidSetor.isEmpty) {
      setor.uidSetor = _uuid.v4();
    }

    if (setor.codigoSetor.isEmpty) {
      setor.codigoSetor = setor.uidSetor.split('-').first;
    }

    await firestoreService.setdata(
      item: setor.toJson(),
      id: setor.codigoSetor,
    );
    _setLoading();
  }
}
