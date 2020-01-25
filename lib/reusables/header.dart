import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vear/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Header extends StatelessWidget {
  final dynamic user;
  final FirebaseUser currentuser;

  Header(this.user, this.currentuser);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0, right: 10.0,left: 10.0, bottom: 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "Vear",
              style: GoogleFonts.ubuntu(
                  fontSize: 45.0,
                  textStyle: TextStyle(color: const Color(0xFF679436), fontWeight: FontWeight.bold)),
            ),
          ),
          GestureDetector(
            child: Container(
              height: 70.0,
              width: 70.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: new NetworkImage(
                    user["profile_pic_url"] != null ? user["profile_pic_url"] :
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQMgRbNQhU19ONiJK71H22tB8ItBNqMkqxGyEBM3hyFq1Cqqlqf",
                  ),
                ),
              ),
            ),

            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ProfileScreen(user, currentuser.uid)));
            },
          )
        ],
      ),
    );
  }
}
