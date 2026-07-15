import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> seedDefaultCategories();
}
