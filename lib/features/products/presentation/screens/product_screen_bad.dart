import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/products/presentation/providers/providers.dart';

//con error -
//Bad state: Tried to use ProductNotifier after 'dispose' was called
// provider disposed y luego usamos.
class ProductScreenBad extends ConsumerStatefulWidget {
  final String productId;
  const ProductScreenBad({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductScreenBad> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreenBad> {
  @override
  void initState() {
    super.initState();
    ref.read(productProvider(widget.productId).notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Producto')),
      body: Center(
        child: Text(widget.productId),
      ),
    );
  }
}
