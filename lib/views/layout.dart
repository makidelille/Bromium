import 'package:bromium/core/bussViewWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const DEFAULT_URL = "buss://register.it/index.html";

class Layout extends StatefulWidget {
  Uri uri = Uri.parse(DEFAULT_URL);

  Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  TextEditingController ctlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 50.0,
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: ctlr,
                onFieldSubmitted: (value) {
                  Uri newUri = Uri.parse(value);
                  if (newUri.host == "") {
                    newUri = newUri.replace(host: newUri.path, path: "");
                  }

                  if (!newUri.hasScheme || newUri.scheme == "") {
                    newUri = newUri.replace(scheme: "buss");
                  }

                  if (newUri.hasEmptyPath || newUri.pathSegments.isEmpty) {
                    newUri = newUri.replace(path: "/index.html");
                  }

                  if (newUri.scheme == "buss") {
                    setState(() {
                      widget.uri = newUri;
                      ctlr.clear();
                    });
                    return;
                  }
                },
                decoration: InputDecoration(hintText: widget.uri.toString()),
              ))
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(child: BussViewWidget(url: widget.uri)),
        )
      ]),
    );
  }
}
