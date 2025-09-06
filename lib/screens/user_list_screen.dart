import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../providers.dart';
import 'user_form_screen.dart';
import 'user_detail_screen.dart';
import '../widgets/appleish_appbar.dart';

// Screen to display the list of users / Pantalla para mostrar la lista de usuarios
class UserListScreen extends ConsumerWidget {
    const UserListScreen({super.key});
    
    // Main build method for the screen / Método principal de construcción de la pantalla
    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final box = ref.watch(hiveBoxProvider);

        // Scaffold with AppBar, List of Users, and FAB to add new user / Scaffold con AppBar, Lista de Usuarios y FAB para agregar nuevo usuario
        return Scaffold(
            appBar: const AppleishAppBar( title: const Text('User List / Lista de Usuarios')),
            body: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                            Color(0xFFE0E0FF),
                            Color(0xFFFFE0F0),
                            ],
                        ),
                    ),
                    child:ValueListenableBuilder<Box<User>>(
                    valueListenable: box.listenable(),
                    builder: (context, box, _) {
                        final users = box.values.toList();
                        if(users.isEmpty) {
                            return const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                    'No users found. Click + to add / No se encontraron usuarios. Presiona + para agregar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                    ),
                                ),
                            );
                        }
                        return ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            itemCount: users.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                                final user = users[i];
                                return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        child: Container(
                                            color: Colors.white.withOpacity(0.2),
                                            child: ListTile(
                                                key: Key('user_item_${user.id}'),
                                                title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                subtitle: Text(
                                                    'Born on / Nac. en: ${user.birthDate.toLocal().toString().split(' ')[0]}',
                                                    style: const TextStyle(color: Colors.black54),
                                                ),
                                                trailing: const Icon(Icons.chevron_right),
                                                onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) => UserDetailScreen(userId: user.id),
                                                        ),
                                                    );
                                                },
                                            ),
                                        ),
                                    ),
                                );
                            },
                        );
                    },
                ),
            ),
            // Button to add a new user / Botón para agregar un nuevo usuario
            floatingActionButton: FloatingActionButton(
                key: const Key('fab_add_user'),
                tooltip: 'Add User / Agregar Usuario',
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black87,
                child: const Icon(Icons.add),
                onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserFormScreen(),
                        ),
                    );
                },
            ),         
        );
    }
}