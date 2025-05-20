import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:requests/model/tarefa.dart';
import 'package:requests/service/dark_theme_service.dart';
import 'package:requests/service/tarefa_service.dart';
import 'package:requests/viewModel/home_viewModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkThemeService>(
          create: (_) => DarkThemeService(),
        ),
        ChangeNotifierProvider<HomeViewmodel>(create: (_) => HomeViewmodel()),
      ],
      child: Consumer<DarkThemeService>(
        builder: (_, darkThemeService, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme:
                darkThemeService.darkTheme
                    ? ThemeData.dark()
                    : ThemeData.light(),
            home: const MyHomePage(title: 'Lista de Tarefas'),
          );
        },
      ),
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
  final _tarefaService = TarefaService();

  late Future<List<Tarefa>> listaTarefas = _tarefaService.getTarefas();

  var tarefaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // final darkTheme = Provider.of<DarkThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Consumer<DarkThemeService>(
            builder: (_, darkThemeService, widget) {
              return Switch(
                value: darkThemeService.darkTheme,
                onChanged: (value) {
                  darkThemeService.darkTheme = !darkThemeService.darkTheme;
                },
              );
            },
          ),
        ],
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
                String id = tarefa.id.toString();
                final parentContext = context;
                bool concluida;
                return Slidable(
                  startActionPane: ActionPane(
                    motion: DrawerMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 2,
                        onPressed: (context) {
                          _tarefaService.deleteTarefa(id);
                          listaTarefas = _tarefaService.getTarefas();
                          setState(() {});
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Deletar',
                      ),
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 2,
                        onPressed: (context) {
                          tarefaController.text = tarefa.titulo;
                          showDialog(
                            context: context,
                            builder: (BuildContext bc) {
                              return AlertDialog(
                                title: Text('Editar Tarefa'),
                                content: TextField(
                                  controller: tarefaController,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(parentContext);
                                    },
                                    child: Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(parentContext);
                                      await _tarefaService.putTarefa(
                                        id,
                                        tarefaController.text,
                                        tarefa.concluida,
                                      );
                                      listaTarefas =
                                          _tarefaService.getTarefas();
                                      setState(() {});
                                    },
                                    child: Text("Editar"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Editar',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: StretchMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 2,
                        onPressed: (context) {},
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        icon: Icons.star,
                        label: 'Favoritar',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(tarefa.titulo),
                    leading: InkWell(
                      onTap: () async {
                        concluida = !tarefa.concluida;
                        await _tarefaService.putTarefa(
                          id,
                          tarefa.titulo,
                          concluida,
                        );
                        listaTarefas = _tarefaService.getTarefas();
                        setState(() {});
                      },
                      child: Icon(
                        tarefa.concluida
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: tarefa.concluida ? Colors.green : Colors.grey,
                      ),
                    ),
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
                content: TextField(controller: tarefaController),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _tarefaService.postTarefa(tarefaController.text);
                      listaTarefas = _tarefaService.getTarefas();
                      setState(() {});
                    },
                    child: Text("Adicionar"),
                  ),
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
