import 'package:bromium/core/network.dart';
import 'package:bromium/core/parser.dart';
import 'package:flutter/material.dart';

class BussViewWidget extends StatefulWidget {
  final Uri url;
  const BussViewWidget({super.key, required this.url});

  @override
  State<BussViewWidget> createState() => _BussViewWidgetState();
}

class _BussViewWidgetState extends State<BussViewWidget> {
  late Future<String> html;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    html = Network.fetch(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Network.fetch(widget.url),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return CircularProgressIndicator(color: Colors.red);

          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('There was an error fetching ${widget.url}');
          }

          return Parser.parseHtml(snapshot.data ?? "No content", context);
        });
  }
}
