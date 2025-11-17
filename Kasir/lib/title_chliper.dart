import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double width; // Properti untuk mengatur lebar
  final String title;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.height = kToolbarHeight,
    this.width = double.infinity, // Nilai default untuk lebar penuh
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(width),
      child: Container(
        width: width, // Menggunakan width untuk mengatur lebar Container
        height: preferredSize.height,
        color: Colors.pink,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(
            left: 16.0), // Sesuaikan padding jika diperlukan
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  final double width;

  MyClipper(this.width);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(width - 30, 0);
    path.quadraticBezierTo(width, size.height / 2, width - 30, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
