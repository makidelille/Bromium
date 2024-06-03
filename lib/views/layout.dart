import 'package:bromium/core/bussViewWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const DEFAULT_URL = "buss://register.it/index.html";

class Layout extends StatelessWidget {
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
                decoration: const InputDecoration(hintText: DEFAULT_URL),
              ))
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
              child: BussViewWidget(url: Uri.parse(DEFAULT_URL))),
        )
      ]),
    );
  }
}
