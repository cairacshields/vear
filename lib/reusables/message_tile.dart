import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MessageTile extends StatelessWidget {
  final String name;

  MessageTile(this.name);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 50.0,
      margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFFA5BE00),
        borderRadius: BorderRadius.all(Radius.circular(5.0))
      ),
      child: Container(
        child: Text(name, style: GoogleFonts.ubuntu(
            textStyle: TextStyle(
                fontSize: 15.0, color: Colors.black)),),
      ),
    );
  }
}