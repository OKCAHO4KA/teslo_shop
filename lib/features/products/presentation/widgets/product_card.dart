import 'package:flutter/material.dart';
import 'package:teslo_shop/features/products/domain/domain.dart';

class ProductsCard extends StatelessWidget {
  final Product product;
  const ProductsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ImageViewer(images: product.images),
      Text(product.title, textAlign: TextAlign.center),
      const SizedBox(height: 20)
    ]);
  }
}

class _ImageViewer extends StatelessWidget {
  final List<String> images;
  const _ImageViewer({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset('assets/images/no-image.jpg',
              fit: BoxFit.cover, height: 250));
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: FadeInImage(
            placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
            image: NetworkImage(images.first),
            fit: BoxFit.cover,
            fadeOutDuration: const Duration(milliseconds: 100),
            fadeInDuration: const Duration(milliseconds: 200),
            height: 250));
  }
}
