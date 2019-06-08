import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

const tarefaTitle = "title";
const tarefaStatus = "ok";

class TarefasService {
  List tarefas = [];
  Map<String, dynamic> lastRemoved = Map();
  int lastRemovedIndex;

  int length() => tarefas.length;

  void addTarefa(String tarefa) {
    Map<String, dynamic> newToDo = Map();
    newToDo[tarefaTitle] = tarefa;
    newToDo[tarefaStatus] = false;
    tarefas.add(newToDo);
    saveData();
  }

  Future<File> getFile() async {
    final diretory = await getApplicationDocumentsDirectory();
    return File("${diretory.path}/data.json");
  }

  Future<File> saveData() async {
    String data = json.encode(tarefas);
    final file = await getFile();
    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await getFile();
      return file.readAsString();
    } catch (e) {
      print(e);
      return null;
    }
  }

  void fullTarefas(String data) {
    tarefas = json.decode(data);
  }

  void removeTarefaAt(int index) {
    lastRemovedIndex = index;
    tarefas.removeAt(index);
    saveData();
  }

  void undoDeletation() {
    tarefas.insert(lastRemovedIndex, lastRemoved);
    saveData();
  }

  void sortList() {
    tarefas.sort((first, second) {
      if (first[tarefaStatus] && !second[tarefaStatus])
        return 1;
      else if (!first[tarefaStatus] && second[tarefaStatus])
        return -1;
      else
        return 0;
    });
    saveData();
  }
}
