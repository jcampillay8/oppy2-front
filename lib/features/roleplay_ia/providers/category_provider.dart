// lib/features/roleplay_ia/providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiClient = ref.read(apiClientProvider); 
  
  // CORRECCIÓN: Accedemos a .dio.get() porque 'dio' es la propiedad que tiene el método
  final response = await apiClient.dio.get('/avatars/categories');
  
  final List<dynamic> data = response.data is List 
      ? response.data 
      : (response.data['data'] ?? []);

  List<String> flattenNames(List<dynamic> tree) {
    List<String> names = [];
    for (var node in tree) {
      if (node['name'] != null) {
        names.add(node['name'] as String);
      }
      if (node['children'] != null && node['children'] is List) {
        names.addAll(flattenNames(node['children'] as List<dynamic>));
      }
    }
    return names;
  }

  final flattenedList = flattenNames(data);
  return flattenedList.toSet().toList()..sort();
});