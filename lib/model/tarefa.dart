class Tarefa {
  final int id;
  final String titulo;
  final bool concluida;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.concluida
  });

  factory Tarefa.fromJson(Map<String, dynamic> json){
    return Tarefa(id: json['id'], 
    titulo: json['titulo'], 
    concluida: json['concluida']
    );
  }
}