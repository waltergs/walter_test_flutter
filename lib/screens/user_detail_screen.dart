import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../providers.dart';

// Screen to show user details and manage addresses / Pantalla para mostrar detalles del usuario y gestionar direcciones
class UserDetailScreen extends ConsumerStatefulWidget {
    // User ID to fetch details / ID del usuario para obtener detalles
    final String userId;
    const UserDetailScreen({super.key, required this.userId});

    // Creating state for the screen / Creando estado para la pantalla
    @override
    ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

// State class for UserDetailScreen / Clase de estado para UserDetailScreen
class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
    // User object to hold user details / Objeto User para mantener detalles del usuario
    User? _user;
    bool _loading = true;

    // Initializing state and loading user details / Inicializando el estado y cargando detalles del usuario
    @override
    void initState() {
        super.initState();
        _loadUser();
    }

    // Method to load user details from repository / Método para cargar detalles del usuario desde el repositorio
    void _loadUser() {
        final repo = ref.read(userRepositoryProvider);
        repo.getById(widget.userId).then((user) {
            setState(() {
                _user = user;
                _loading = false;
            });
        });
    }

    // Method to add a new address / Método para agregar una nueva dirección
    Future<void> _addAddress() async {
        final countryCtrl = TextEditingController();
        final deptCtrl = TextEditingController();
        final cityCtrl = TextEditingController();
        final streetCtrl = TextEditingController();
        final ctx = context;
        
        // Showing dialog to input address details / Mostrando diálogo para ingresar detalles de la dirección
        await showDialog(
            context: ctx,
            builder: (dctx) => AlertDialog(
                title: const Text('Add Address / Agregar Dirección'),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            TextField(
                                key: const Key('addr_country'),
                                controller: countryCtrl,
                                decoration: const InputDecoration(labelText: 'Country / País *'),
                            ),
                            TextField(
                                key: const Key('addr_department'),
                                controller: deptCtrl,
                                decoration: const InputDecoration(labelText: 'Department / Departamento *'),
                            ),
                            TextField(
                                key: const Key('addr_city'),
                                controller: cityCtrl,
                                decoration: const InputDecoration(labelText: 'City / Ciudad *'),
                            ),
                            TextField(
                                key: const Key('addr_street'),
                                controller: streetCtrl,
                                decoration: const InputDecoration(labelText: 'Street (optional) / Calle (opcional)'),
                            ),
                        ],
                    ),                      
                ),
                actions: [
                    TextButton( onPressed: () {
                        Navigator.pop(dctx);
                    }, child: const Text('Cancel / Cancelar')),
                    ElevatedButton(
                        onPressed: () async {
                            if(countryCtrl.text.trim().isEmpty ||
                                deptCtrl.text.trim().isEmpty ||
                                cityCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('Please fill in all required fields / Por favor completa todos los campos obligatorios'))
                                );
                                return;
                            }
                            final a = Address(
                                country: countryCtrl.text.trim(),
                                department: deptCtrl.text.trim(),
                                city: cityCtrl.text.trim(),
                                street: streetCtrl.text.trim(),
                            );
                            final repo = ref.read(userRepositoryProvider);
                            final u = _user;
                            if(u != null) {
                                u.addresses.add(a);
                                await repo.update(u);
                                _loadUser();
                            }
                            Navigator.pop(dctx);
                        },
                        child: const Text('Add / Agregar'),
                    )
                ],
            )
        );
        
    }

    // Method to delete the user / Método para eliminar el usuario
    Future<void> _deleteUser() async {
        final repo = ref.read(userRepositoryProvider);
        await repo.delete(widget.userId);
        if(!mounted) return;
        Navigator.pop(context);
    }

    // Method to delete an address by index / Método para eliminar una dirección por índice
    Future<void> _deleteAddress(int idx) async {
        final repo = ref.read(userRepositoryProvider);
        final u = _user;
        if(u != null) {
            u.addresses.removeAt(idx);
            await repo.update(u);
            _loadUser();
        }
    }

    // Main build method for the screen / Método principal de construcción de la pantalla
    @override
    Widget build(BuildContext context) {
        if (_loading) return Scaffold(
            appBar: AppBar(title: Text('Loading... / Cargando...')),
            body: Center(child: CircularProgressIndicator()),
        );
        if (_user == null) return Scaffold(
            appBar: AppBar(title: const Text('User Not Found / Usuario No Encontrado')),
            body: const Center(child: Text('User not found / Usuario no encontrado')),
        );

        final u = _user!;
        // Scaffold with user details and list of addresses / Scaffold con detalles del usuario y lista de direcciones
        return Scaffold(
            appBar: AppBar(
                title: Text(u.fullName),
                actions: [
                    IconButton(
                        onPressed: _deleteUser,
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete User / Eliminar Usuario'
                    ),                    
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        ListTile(
                            title: Text(u.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            subtitle: Text('Born on / Nac. en: ${u.birthDate.toLocal().toString().split(' ')[0]}'),
                        ),
                        const Divider(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Text('Addresses / Direcciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                TextButton.icon(
                                    key: const Key('add_address_button'),
                                    onPressed: _addAddress,
                                    icon: const Icon(Icons.add_location),
                                    label: const Text('Add / Agregar'),
                                ),
                            ],
                        ),
                        Expanded(
                            child: u.addresses.isEmpty
                                ? const Center(child: Text('No addresses found. Click Add to add / No se encontraron direcciones. Presiona Agregar para añadir'))
                                : ListView.separated(
                                    itemCount: u.addresses.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (_, i) {
                                        final a = u.addresses[i];
                                        return ListTile(
                                            key: Key('address_item_$i'),
                                            title: Text(a.toString()),
                                            trailing: IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                tooltip: 'Delete Address / Eliminar Dirección',
                                                onPressed: () => _deleteAddress(i),
                                            ),
                                        );
                                    },
                                ),
                            
                        ),
                    ],
                ),
            ),
        );
    }
}
