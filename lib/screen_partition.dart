import 'package:flutter/material.dart';
import 'tree.dart';
import 'screen_space.dart';
import 'requests.dart';

class ScreenPartition extends StatefulWidget {
  final String id;
  const ScreenPartition({super.key, required this.id});

  @override
  State<ScreenPartition> createState() => _ScreenPartitionState();
}

class _ScreenPartitionState extends State<ScreenPartition> {
  late Future<Tree> futureTree;

  @override
  void initState() {
    super.initState();
    futureTree = getTree(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(snapshot.data!.root.id),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    // TODO go home page = root
                    ),
                //TODO other actions
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int i) =>
                  _buildRow(snapshot.data!.root.children[i], i),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Area area, int index) {
    assert(area is Partition || area is Space);
    if (area is Partition) {
      return ListTile(
        tileColor:  Theme.of(context).colorScheme.primaryContainer,
        focusColor:  Theme.of(context).colorScheme.secondary,
        hoverColor:  Theme.of(context).colorScheme.secondary,
        title: Text('P ${area.id}'),
        onTap: () => _navigateDownPartition(area.id),
      );
    } else {
      return ListTile(
        tileColor:  Theme.of(context).colorScheme.primary,
        focusColor:  Theme.of(context).colorScheme.secondary,
        hoverColor:  Theme.of(context).colorScheme.secondary,
        title: Text('S ${area.id}'),
        onTap: () => _navigateDownSpace(area.id),
      );
    }
  }

  void _refresh() async {
    futureTree = getTree(widget.id);
    setState(() {});
  }

  void _navigateDownPartition(String childId) {
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
    // but doing _refresh(); without then() after push may also work
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => ScreenPartition(id: childId),
    ))
        .then((var value) {
      _refresh();
    });
  }

  void _navigateDownSpace(String childId) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => ScreenSpace(id: childId),
    ))
        .then((var value) {
      _refresh();
    });
  }
}
