import 'package:flutter/material.dart';

class GreenPaint extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
   // Get full screen width and height
   final width = size.width;
   final height = size.height;

   //Paint it used to set colors, etc.
   Paint paint = Paint();

   //Path tells you where to draw
   Path mainBackground = Path();

   //This particular path covers the entire screen
   mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));

   //Set active paint color
   paint.color = const Color(0xFFA5BE00);

   //Draw the path to the screen using the paint
   canvas.drawPath(mainBackground, paint);


   //Create a new path to start a new drawing
   Path ovalPath = Path();

   //By default, paint will always begin at the top left corner of the screen
   //Think of X as width, Y as height
   ovalPath.moveTo(0, height * 0.2);

   //Now we will begin painting curves
    //Start by painting a curve from our current position to the middle of the screen

   //x1 and y1 are the control points (they pull our straight line out), x2 and y2 is where we are going with the curve
   ovalPath.quadraticBezierTo(width * 0.45, height * 0.25, width * 0.51, height * 0.5);

   //Paint another curve from current position to bottom left of the screen
   ovalPath.quadraticBezierTo(width * 0.58, height * 0.8, width * 0.1, height);

   //Finish off the oval by drawing a line to the end of the screen
   ovalPath.lineTo(0, height);

   //Close the path and reset it to our original points above
   ovalPath.close();

   //Set active paint color
   paint.color = const Color(0xFFEEF5DB);

   //Draw the path to the screen using the paint
   canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // only rebuild if we change the paint
    return oldDelegate != this;
  }

}