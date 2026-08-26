import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lista de Tarefas Persistente',
      home: const TelaLista(),
        );
  }
}

class Tarefa{
  String titulo;
  bool concluida;

  Tarefa({required this.titulo, this.concluida = false});
  Map<String,dynamic> paraMapa() => {'titulo': titulo, 'concluida': concluida};

  factory Tarefa.deMapa(Map<String,dynamic> mapa) => Tarefa(
    titulo: mapa['titulo'],
    concluida: mapa['concluida'],
  );
}

class TelaLista extends StatefulWidget{
  const TelaLista({super.key});
  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista>{
  List<Tarefa> tarefas = [];
  final tituloController = TextEditingController();

  @override
  void initState(){
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('tarefas');
    if (dados != null){
      final lista = jsonDecode(dados) as List;
      setState(() {
        tarefas = lista.map((item) => Tarefa.deMapa(item)).toList();
      });
    }
  }

  Future<void> salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = jsonEncode(tarefas.map((t) => t.paraMapa()).toList());
    await prefs.setString('tarefas', dados);
  }

  void adicionarTarefa() {
    if (tituloController.text.isEmpty) return;
    setState(() {
      tarefas.add(Tarefa(titulo: tituloController.text));
      tituloController.clear();
    });
    salvarTarefas();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas Persistente')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tituloController,
                      decoration: InputDecoration(labelText: 'Nova Tarefa'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: adicionarTarefa,
                  )
                ],
              )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tarefas.length,
              itemBuilder: (context,indice){
                final tarefa = tarefas[indice];
                return ListTile(
                  leading: Checkbox(
                    value: tarefa.concluida,
                    onChanged: (valor) {
                      setState(() {
                        tarefa.concluida = valor!;
                      });
                      salvarTarefas();
                    }
                  ),
                  title: Text(
                    tarefa.titulo,
                    style: TextStyle(
                      decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        tarefas.removeAt(indice);
                      });
                      salvarTarefas();
                    },
                  )
                );
              }
            )
          )
        ]
      )
    );
  }
}

