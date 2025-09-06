import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'data/user_repository.dart';
import 'models/user.dart';

// Provider for Hive Box of User / Proveedor para el Hive Box del User

final hiveBoxProvider = Provider<Box<User>>((ref) {
    return Hive.box<User>('users_box');
});

// Provider for UserRepository / Proveedor para UserRepository

final userRepositoryProvider = Provider<UserRepository>((ref) {
    final box = ref.watch(hiveBoxProvider);
    return HiveUserRepository(box);
});