import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                decoration: InputDecoration(hintText: "buzz://register.it"),
              ))
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              height: 5000,
              decoration: BoxDecoration(color: Colors.red),
            ),
          ),
        )
      ]),
    );
  }
}
