import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../providers.dart';

// Screen for adding/editing a user / Pantalla para agregar/editar un usuario

class UserFormScreen extends ConsumerStatefulWidget {
    const UserFormScreen({super.key});

    @override
    ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

// State class for UserFormScreen / Clase de estado para UserFormScreen
class _UserFormScreenState extends ConsumerState<UserFormScreen> {
    // Controllers for form fields / Controladores para los campos del formulario
    final _formKey = GlobalKey<FormState>();
    final _firstNameCtrl = TextEditingController();
    final _lastNameCtrl = TextEditingController();
    final _birthDateCtrl = TextEditingController();
    List<Address> _addresses = [];

    // Method to show date picker and set birth date / Método para mostrar el selector de fecha y establecer la fecha de nacimiento
    @override
    void dispose() {
        _firstNameCtrl.dispose();
        _lastNameCtrl.dispose();
        _birthDateCtrl.dispose();
        super.dispose();
    }

    // Main build method for the screen / Método principal de construcción de la pantalla
    Future<void> _pickBirthDate() async {
        final now = DateTime.now();
        final initial = DateTime(now.year - 25, now.month, now.day);
        final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: now,
        );
        if (picked != null) {
            _birthDateCtrl.text = picked.toLocal().toString().split('T')[0];
        }
    }
    // Method to save the user / Método para guardar el usuario
    void _showAddAddressDialog() {
        final countryCtrl = TextEditingController();
        final deptCtrl = TextEditingController();
        final cityCtrl = TextEditingController();
        final streetCtrl = TextEditingController();
        // Show dialog to add a new address / Mostrar diálogo para agregar una nueva dirección
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text('Add Address / Agregar Dirección'),
                content: SingleChildScrollView(
                    child: Column(
                        children: [
                            TextField(
                                key: const Key('addr_country'),
                                controller: countryCtrl,
                                decoration: const InputDecoration(labelText: 'Country / País'),
                            ),
                            TextField(
                                key: const Key('addr_department'),
                                controller: deptCtrl,
                                decoration: const InputDecoration(labelText: 'State / Departamento'),
                            ),
                            TextField(
                                key: const Key('addr_city'),
                                controller: cityCtrl,
                                decoration: const InputDecoration(labelText: 'City / Ciudad'),
                            ),
                            TextField(
                                key: const Key('addr_street'),
                                controller: streetCtrl,
                                decoration: const InputDecoration(labelText: 'Street / Calle'),
                            ),
                        ],
                    ),
                ),
                actions: [
                    TextButton(
                        onPressed: () {
                            Navigator.pop(ctx);
                        },
                        child: const Text('Cancel / Cancelar'),
                    ),
                    ElevatedButton(
                        key: const Key('dialog_add_address_button'),
                        onPressed: () {
                            if (countryCtrl.text.isNotEmpty &&
                                deptCtrl.text.isNotEmpty &&
                                cityCtrl.text.isNotEmpty) {
                                setState(() {
                                    _addresses.add(Address(
                                        country: countryCtrl.text,
                                        department: deptCtrl.text,
                                        city: cityCtrl.text,
                                        street: streetCtrl.text,
                                    ));
                                });
                                Navigator.pop(ctx);
                            }
                        },
                        child: const Text('Add / Agregar'),
                    ),
                ],
            ),
        );
    }

    // Method to save the user / Método para guardar el usuario
    Future<void> _save() async {
        if (!_formKey.currentState!.validate()) return;

        final birthText = _birthDateCtrl.text;
        DateTime birth;
        try {
            birth = DateTime.parse(birthText);
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid birth date format / Formato de fecha de nacimiento inválido')),
            );
            return;
        }

        final user = User(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            birthDate: birth,
            addresses: List.from(_addresses)
        );

        final repo = ref.read(userRepositoryProvider);
        await repo.add(user);
        if (!mounted) return;
        Navigator.pop(context);
    }

    // Main build method for the screen / Método principal de construcción de la pantalla
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Add User / Agregar Usuario')),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: ListView(
                        children: [
                            TextFormField(
                                key: const Key('firstName'),
                                controller: _firstNameCtrl,
                                decoration: const InputDecoration(labelText: 'First Name / Nombre'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required / Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                                key: const Key('lastName'),
                                controller: _lastNameCtrl,
                                decoration: const InputDecoration(labelText: 'Last Name / Apellido'),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required / Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                                key: const Key('birthDate'),
                                controller: _birthDateCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Birth Date (tap) / Fecha de Nacimiento (toque)',
                                    suffixIcon: Icon(Icons.calendar_today),
                                ),
                                onTap: _pickBirthDate,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required / Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    const Text('Addresses / Direcciones', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextButton.icon(
                                        key: const Key('add_address_button'),
                                        onPressed: _showAddAddressDialog,
                                        icon: const Icon(Icons.add_location_alt),
                                        label: const Text('Add / Agregar'),
                                    )
                                ],
                            ),
                            ..._addresses.asMap().entries.map((e) {
                                final idx = e.key;
                                final a = e.value;
                                return ListTile(
                                    key: Key('address_item_$idx'),
                                    title: Text(a.toString()),
                                    trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => setState(() => _addresses.removeAt(idx)),
                                    ),
                                );
                            }),
                            const SizedBox(height: 24),
                            ElevatedButton(
                                key: const Key('save_user_button'),
                                onPressed: _save,
                                child: const Text('Save User / Guardar Usuario'),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}