import 'package:flutter/material.dart';

class Productlist extends StatefulWidget {
  const Productlist({super.key});

  @override
  State<Productlist> createState() => _ProductlistState();
}

class _ProductlistState extends State<Productlist> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("This is Product List Page"),
    );
  }
}
