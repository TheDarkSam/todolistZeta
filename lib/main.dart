import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:requests/model/tarefa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String baseURL = 'https://todos-production-34e1.up.railway.app';
  late Future<List<Tarefa>> listaTarefas = getTarefas();

  var tarefaController = TextEditingController();

  Future<List<Tarefa>> getTarefas() async {
    String url = '$baseURL/tarefas';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> listaTarefas = jsonDecode(response.body);
      return listaTarefas.map((tarefa) => Tarefa.fromJson(tarefa)).toList();
    } else {
      throw Exception('Erro ao recuperar as tarefas');
    }
  }

  Future<void> criarTarefa(String titulo) async {
    String url = '$baseURL/tarefas/';

    final body = jsonEncode({'titulo': titulo, 'concluida': false});

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
    } else {
      throw Exception('Erro ao registrar a tarefa');
    }
  }

  void postTarefa(String tarefa) async {
    await criarTarefa(tarefa);
    listaTarefas = getTarefas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: listaTarefas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Ocorreu o seguinte erro: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            final tarefas = snapshot.data ?? [];
            return ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                return ListTile(
                  title: Text(tarefa.titulo),
                  leading: Icon(
                    tarefa.concluida
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: tarefa.concluida ? Colors.green : Colors.grey,
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tarefaController.text = '';
          showDialog(
            context: context,
            builder: (BuildContext bc) {
              return AlertDialog(
                title: Text('Criar Tarefa'),
                content: TextField(
                  controller: tarefaController,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar"),
                  ),
                  TextButton(onPressed: () async {
                    postTarefa(tarefaController.text);
                    Navigator.pop(context);
                  }, child: Text("Adicionar")),
                ],
              );
            },
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
