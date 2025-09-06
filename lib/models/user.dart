import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'address.dart';

// Defining class User and its fields / Definiendo la clase User y sus campos
class User {
    String id;
    String firstName;
    String lastName;
    DateTime birthDate;
    List<Address> addresses;

    // Constructor with optional id and addresses / Constructor con id y addresses opcionales
    User({
        String? id,
        required this.firstName,
        required this.lastName,
        required this.birthDate,
        List<Address>? addresses,
    }) : 
        id = id ?? const Uuid().v4(),
        addresses = addresses ?? [];
    
    String get fullName => '$firstName $lastName';
}

// Adapter manual para Hive / Manual adapter for Hive
class UserAdapter extends TypeAdapter<User> {
    @override
    final int typeId = 0;

    // Reading User to binary format for Hive storage / Leyendo User en formato binario para almacenamiento en Hive
    @override
    User read(BinaryReader reader) {
        final id = reader.readString();
        final firstName = reader.readString();
        final lastName = reader.readString();
        final millis = reader.readInt();
        final addressesCount = reader.readInt();
        final addresses = <Address>[];
        for (var i = 0; i < addressesCount; i++) {
            addresses.add(reader.read() as Address);
        }
        return User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            birthDate: DateTime.fromMillisecondsSinceEpoch(millis),
            addresses: addresses,
        );
    }

    // Writing User to binary format for Hive storage / Escribiendo User en formato binario para almacenamiento en Hive
    @override
    void write(BinaryWriter writer, User obj) {
        writer.writeString(obj.id);
        writer.writeString(obj.firstName);
        writer.writeString(obj.lastName);
        writer.writeInt(obj.birthDate.millisecondsSinceEpoch);
        writer.writeInt(obj.addresses.length);
        for (var address in obj.addresses) {
            writer.write(address);
        }
    }
}