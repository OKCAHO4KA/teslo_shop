import 'package:teslo_shop/features/products/domain/entities/product.dart';

abstract class ProductDatasource {
  Future<List<Product>> getProductByPage({int limit = 10, int offset = 0});
  Future<List<Product>> searchProductByTerm(String term);
  Future<Product> getProductById(String id);
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike);
}
