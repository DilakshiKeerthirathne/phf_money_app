import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_app/features/transactions/presentation/providers/transaction_providers.dart';

import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepositoryImpl());

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    await repo.seedDefaultCategories();
    return repo.getCategories();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state =
        AsyncData(await ref.read(categoryRepositoryProvider).getCategories());
  }

  Future<void> addCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).createCategory(category);
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
    await refresh();
  }

  Future<void> clearAll() async {
    final repo = ref.read(transactionRepositoryProvider);

    await repo.deleteAll();

    await refresh();
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
        CategoriesNotifier.new);
