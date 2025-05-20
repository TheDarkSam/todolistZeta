import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:requests/model/tarefa.dart';

class TarefaService {
  final String baseURL = 'https://todos-production-34e1.up.railway.app';

  

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

  Future<void> postTarefa(String titulo) async {
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

  Future<void> deleteTarefa(String id) async {
    String url = '$baseURL/tarefas/$id';

    final response = await http.delete(Uri.parse(url));
  }

  Future<void> putTarefa(String id, String titulo, bool concluida) async {
    String url = '$baseURL/tarefas/$id';

    final body = jsonEncode({'titulo': titulo, 'concluida': concluida});

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-type': 'application/json'},
      body: body,
    );
  }

}