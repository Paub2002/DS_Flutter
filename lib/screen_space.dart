import 'package:flutter/material.dart';
import 'tree.dart';
import 'requests.dart';
import 'screen_partition.dart';

class ScreenSpace extends StatefulWidget {
  final String id;
  const ScreenSpace({super.key, required this.id});

  @override
  State<ScreenSpace> createState() => _ScreenSpaceState();
}

class _ScreenSpaceState extends State<ScreenSpace> {
  late Future<Tree> futureTree;

  @override
  void initState() {
    super.initState();
    futureTree = getTree(widget.id);
  }

  void _refresh() async {
    futureTree = getTree(widget.id);
    setState(() {});
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Text(snapshot.data!.root.id),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
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

  Widget _buildRow(Door door, int index) {
    return ListTile(
      leading:door.closed ?  IconButton(
        icon : Icon(Icons.door_front_door),
        onPressed: () async {
          await openDoor(door)
              .then((var value ) {
            _refresh();
          });
        }
      ):
      IconButton(
          icon : Icon(Icons.meeting_room),
          onPressed: () async {
            await closeDoor(door)
                .then((var value ) {
              _refresh();
            });
          }
      ),
      title: Text('${door.id}'),

      trailing: door.state == 'locked'
          ? TextButton(
              onPressed: () async {
                await unlockDoor(door)
                .then((var value ) {
                  _refresh();
                });
              },
              child: Text('Unlock'),
            )
          : TextButton(
              onPressed: () async {
                await lockDoor(door)
                    .then((var value ) {
                  _refresh();
                });
              },
              child: Text('Lock'),
            ),
    );
  }
}
