import 'package:hive/hive.dart';

// Defining class Address and its fields / Definiendo la clase Address y sus campos
class Address {
    String country;
    String department;
    String city;
    String street;

    Address({
        required this.country,
        required this.department,
        required this.city,
        this.street = '',
    });
    
    // Converting Address to Map for Hive storage / Convirtiendo Address a Map para almacenamiento en Hive
    @override
    String toString() => [street, city, department, country].where((item) => item.isNotEmpty).join(', ');
}

// Adapter manual para Hive / Manual adapter for Hive
class AddressAdapter extends TypeAdapter<Address> {
    @override
    final int typeId = 1;

    // Reading Address to binary format for Hive storage / Leyendo Address en formato binario para almacenamiento en Hive
    @override
    Address read(BinaryReader reader) {
        final country = reader.readString();
        final department = reader.readString();
        final city = reader.readString();
        final street = reader.readString();
        return Address(
            country: country,
            department: department,
            city: city,
            street: street,
        );
    }

    // Writing Address to binary format for Hive storage / Escribiendo Address en formato binario para almacenamiento en Hive
    @override
    void write(BinaryWriter writer, Address obj) {
        writer.writeString(obj.country);
        writer.writeString(obj.department);
        writer.writeString(obj.city);
        writer.writeString(obj.street);
    }
}
