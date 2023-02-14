import 'package:flutter/material.dart';

import '../../model/setor_model.dart';
import '../../model/usuario_model.dart';

class UsuarioPageController extends ChangeNotifier {
  final UsuarioController controller;
  UsuarioPageController(this.controller);

  TextEditingController searchQueryController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

  Future<void> setSetores(
    BuildContext context,
    Usuario data,
    List<Setor> setorParam,
  ) async {
    ValueNotifier<List<Setor>> setores = ValueNotifier([]);
    setores.value = setorParam;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
          valueListenable: setores,
          builder: (context, value, child) {
            return AlertDialog(
              title: const Text(
                'Editar Setores do Usuario',
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                  height: 500,
                  width: 500,
                  child: ListView.builder(
                    itemCount: setores.value.length,
                    itemBuilder: (context, index) {
                      Setor setor = setores.value[index];
                      return CheckboxListTile(
                        title: Text(setor.descricao),
                        subtitle: Text(setor.codigo),
                        onChanged: (value) {
                          setores.value[index].checkBox = value!;

                          print('${setor.descricao}||$value');
                        },
                        value: setor.checkBox,
                      );
                    },
                  )),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Salvar'),
                  onPressed: () async {
                    await controller
                        .setdata(data)
                        .then((value) => Navigator.of(context).pop());
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> novo(
    BuildContext context, {
    Usuario? data,
  }) async {
    bool hasData = data == null ? false : true;

    TextEditingController nomeController = TextEditingController(
      text: hasData ? data.nome : '',
    );
    TextEditingController emailController = TextEditingController(
      text: hasData ? data.email : '',
    );

    ValueNotifier<String> tipoUser =
        ValueNotifier(hasData ? data.tipo : 'padrao');

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hasData ? 'Editar Usuario' : 'Novo Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  label: Text('Nome'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder(
                valueListenable: tipoUser,
                builder: (context, value, child) {
                  return DropdownButton<String>(
                    onChanged: (newValue) {
                      tipoUser.value = newValue!;
                    },
                    value: tipoUser.value,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'padrao',
                        child: Text('Padrão'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'agente',
                        child: Text('Agente'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Salvar'),
              onPressed: () async {
                if (hasData) {
                  data.nome = nomeController.text;
                  data.tipo = tipoUser.value;
                  await controller
                      .setdata(data)
                      .then((value) => Navigator.of(context).pop());
                } else {
                  await controller
                      .setdata(Usuario(
                        nome: nomeController.text,
                        email: emailController.text,
                        senha: '',
                        setores: [],
                        tipo: tipoUser.value,
                      ))
                      .then((value) => Navigator.of(context).pop());
                }
              },
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => initialData());
  }

  void initialData() {
    controller.getData();
    notifyListeners();
  }

  void search() {
    controller.getData(filtroDescricao: searchQuery);
    isSearching = true;
    notifyListeners();
  }

  setSearching() {
    isSearching = true;
    notifyListeners();
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;

    if (newQuery.isEmpty) {
      search();
    }
    //notifyListeners();
  }

  void stopSearching() {
    _clearSearchQuery();

    isSearching = false;
    notifyListeners();
  }

  void _clearSearchQuery() {
    searchQueryController.clear();
    updateSearchQuery("");
    notifyListeners();
  }
}