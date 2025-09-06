import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

// Abstract class for UserRepository to define the contract / Clase abstracta para UserRepository para definir el contrato
abstract class UserRepository {
    // Methods to be implemented / Métodos a implementar
    Future<List<User>> getAll();
    ValueListenable<Box<User>> watchAll();
    Future<void> add(User user);
    Future<void> update(User user);
    Future<void> delete(String id);
    Future<User?> getById(String id);
}

// Implementation of UserRepository using Hive / Implementación de UserRepository usando Hive
class HiveUserRepository implements UserRepository {
    // Hive box to store User objects / Caja de Hive para almacenar objetos User
    final Box<User> _box;
    
    HiveUserRepository(this._box);

    // Adding a new user to the Hive box / Añadiendo un nuevo usuario al Hive box
    @override
    Future<void> add(User user) async {
        await _box.put(user.id, user);
    }

    // Deleting a user by id from the Hive box / Borrando un usuario por id del Hive box
    @override
    Future<void> delete(String id) async {
        await _box.delete(id);
    }

    // Retrieving all users from the Hive box / Recuperando todos los usuarios del Hive box
    @override
    Future<List<User>> getAll() async {
        return _box.values.toList();
    }

    // Watching changes in the Hive box / Observando cambios en el Hive box
    @override
    ValueListenable<Box<User>> watchAll() => _box.listenable();

    // Getting a user by id from the Hive box / Obteniendo un usuario por id del Hive box
    @override
    Future<User?> getById(String id) async {
        return _box.get(id);
    }

    // Updating an existing user in the Hive box / Actualizando un usuario existente en el Hive box
    @override
    Future<void> update(User user) async {
        await _box.put(user.id, user);
    }
}
