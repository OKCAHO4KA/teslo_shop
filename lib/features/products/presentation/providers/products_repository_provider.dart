import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/presentation/providers/auth_provider.dart';
import 'package:teslo_shop/features/products/domain/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/products/domain/repositories/product_repository.dart';

final productsRepositoryProvider = Provider<ProductRepository>((ref) {
// en riverpod se puede hablar entre providers
  final accessToken = ref.watch(authProvider).user?.token ?? '';

  final productsRepository =
      ProductRepositoryImpl(ProductDatasourceImpl(accessToken: accessToken));
//accessToken lo tenemos en otro provider
  return productsRepository;
});
