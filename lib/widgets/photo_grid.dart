import 'dart:io';
import 'package:flutter/material.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> fotos;
  const PhotoGrid({super.key, required this.fotos});

  @override
  Widget build(BuildContext context) {
    if (fotos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Aún no hay fotos de evidencia'),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true, // para vivir dentro de un scroll
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => Dialog(child: Image.file(File(fotos[i]))),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(fotos[i]),
            fit: BoxFit.cover,
            cacheWidth: 300, // miniatura: gasta menos memoria
          ),
        ),
      ),
    );
  }
}