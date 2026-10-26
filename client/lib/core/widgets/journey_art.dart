import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A lightweight landscape that stays crisp at every screen size.
class JourneyArt extends StatelessWidget {
  final double height;
  const JourneyArt({super.key, this.height = 180});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _LandscapePainter()),
    ),
  );
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE6EEDB),
    );
    canvas.drawCircle(
      Offset(w * .76, h * .28),
      h * .14,
      Paint()..color = AppColors.coral,
    );
    final back = Path()
      ..moveTo(0, h * .68)
      ..lineTo(w * .27, h * .18)
      ..lineTo(w * .52, h * .64)
      ..lineTo(w * .7, h * .4)
      ..lineTo(w, h * .78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF9BB9A4));
    final front = Path()
      ..moveTo(0, h * .79)
      ..quadraticBezierTo(w * .25, h * .43, w * .52, h * .8)
      ..quadraticBezierTo(w * .78, h * .48, w, h * .64)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF457A65));
    final river = Path()
      ..moveTo(w * .6, h * .74)
      ..cubicTo(w * .37, h * .86, w * .83, h * .87, w * .48, h)
      ..lineTo(w * .74, h)
      ..cubicTo(w * .99, h * .88, w * .51, h * .83, w * .64, h * .74)
      ..close();
    canvas.drawPath(river, Paint()..color = const Color(0xFFDBE9B6));
    for (final x in [.09, .16, .86, .93]) {
      final y = h * (x < .5 ? .87 : .84);
      canvas.drawLine(
        Offset(w * x, y),
        Offset(w * x, y - h * .16),
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = 3,
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * x - h * .055, y - h * .055)
          ..lineTo(w * x, y - h * .25)
          ..lineTo(w * x + h * .055, y - h * .055)
          ..close(),
        Paint()..color = AppColors.ink,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
