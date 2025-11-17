import 'package:flutter/material.dart';

class CustomBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final double width;
  final String title;
  final IconData iconData;
  final VoidCallback? onPressed;
  final bool showBackButton;

  const CustomBar({
    Key? key,
    required this.title,
    required this.iconData,
    this.height = kToolbarHeight,
    this.width = double.infinity,
    this.onPressed,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(width),
      child: Container(
        width: width,
        height: preferredSize.height,
        color: Colors.pink,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Stack(
  children: [
    // Judul dinamis
    Align(
      alignment: showBackButton ? Alignment.center : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: showBackButton ? 0 : 8.0,
        ),
        child: Text(
          title,
          textAlign: showBackButton ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),

    // Tombol kembali di kiri (jika aktif)
    if (showBackButton)
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

    // Tombol aksi kanan
    Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(
          iconData,
          color: Colors.black,
        ),
        onPressed: onPressed,
      ),
    ),
  ],
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
