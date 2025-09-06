import 'dart:ui';
import 'package:flutter/material.dart';

/// Un AppBar con estilo minimalista tipo iOS (apple-ish) y algo de Liquid Glass.
class AppleishAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool centerTitle;

  const AppleishAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x99FFFFFF), // semi blanco arriba
            Color(0x66FFFFFF), // más transparente abajo
          ],
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 👈 efecto liquid glass
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent, // transparente porque ya tenemos glass
            foregroundColor: Colors.black87,
            centerTitle: centerTitle,
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}