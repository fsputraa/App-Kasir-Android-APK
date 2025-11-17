import 'package:flutter/material.dart';

class CustomCurvedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomCurvedAppBar({super.key});

  @override
  Size get preferredSize =>
      const Size.fromHeight(60); // Atur ketinggian AppBar sesuai kebutuhan

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppBarClipper(),
      child: Container(
        color: Colors.pink, // Warna latar belakang AppBar
        child: const Center(
          child: Text('' // Teks yang ingin ditampilkan

              ),
        ),
      ),
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
