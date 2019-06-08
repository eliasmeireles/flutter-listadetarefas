import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/service/tarefas_service.dart';

class HomePage extends StatefulWidget {
  final String title = 'Lista de tarefas';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tarefaService = TarefasService();
  final tarefaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    tarefaService.readData().then((data) {
      setState(() {
        tarefaService.fullTarefas(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() => Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: <Widget>[
                _tarefaInput(),
                _raisedButton(),
              ],
            ),
          ),
          _listTarefas(),
        ],
      );

  Widget _listTarefas() => Expanded(
        child: RefreshIndicator(child: _listViewBuilder(), onRefresh: refresh),
      );

  Future<Null> refresh() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      tarefaService.sortList();
    });
    return null;
  }

  ListView _listViewBuilder() {
    return ListView.builder(
      itemCount: tarefaService.length(),
      padding: EdgeInsets.only(top: 16.0),
      itemBuilder: (context, index) {
        return _listTile(context, index);
      },
    );
  }

  Widget _listTile(BuildContext context, int index) => Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: _checkboxListTile(index),
        onDismissed: (direction) {
          removeTarefaFromLista(context, index);
        },
      );

  void removeTarefaFromLista(BuildContext context, int index) {
    setState(() {
      tarefaService.lastRemoved = Map.from(tarefaService.tarefas[index]);
      tarefaService.removeTarefaAt(index);

      Scaffold.of(context).removeCurrentSnackBar();
      showSnackBarUndoDeletation(context);
    });
  }

  void showSnackBarUndoDeletation(
    BuildContext context,
  ) {
    final snackBar = SnackBar(
      content:
          Text("Tarefa ${tarefaService.lastRemoved[tarefaTitle]} removida!"),
      action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              tarefaService.undoDeletation();
            });
          }),
      duration: Duration(seconds: 30),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _checkboxListTile(int index) {
    return CheckboxListTile(
      title: Text(tarefaService.tarefas[index][tarefaTitle]),
      value: tarefaService.tarefas[index][tarefaStatus],
      secondary: CircleAvatar(
        child: Icon(tarefaService.tarefas[index][tarefaStatus]
            ? Icons.check
            : Icons.error),
      ),
      onChanged: (k) {
        setState(() {
          tarefaService.tarefas[index][tarefaStatus] = k;
          tarefaService.saveData();
        });
      },
    );
  }

  Widget _raisedButton() => RaisedButton(
        child: Icon(Icons.add, color: Colors.white),
        color: Colors.teal,
        onPressed: () {
          addTarefa();
        },
      );

  void addTarefa() {
    setState(() {
      tarefaService.addTarefa(tarefaController.text);
      tarefaController.text = "";
    });
  }

  Widget _tarefaInput() => Expanded(
        child: TextField(
          controller: tarefaController,
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(fontSize: 16.0, color: Colors.teal)),
        ),
      );

  Widget _buildAppBar() => AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.teal,
      );
}
