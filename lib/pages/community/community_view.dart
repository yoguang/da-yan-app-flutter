import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin {
  late String _name = 'Hello World';

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: [
            Text(_name),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = 'Hello Flutter';
                });
              },
              child: const Text('Change Name'),
            ),
            Expanded(
                child: ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(title: Text(index.toString()));
              },
              separatorBuilder: (context, index) =>
                  index.isOdd ? Divider(height: 10) : SizedBox(),
              itemCount: 20,
            ))
          ],
        ),
      ),
    );
  }
}
