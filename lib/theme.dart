import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// Function to build the app theme / Función para construir el tema de la aplicación
ThemeData buildAppTheme() {
    // Using Material 3 with a custom color scheme and Google Fonts / Usando Material 3 con un esquema de color personalizado y Google Fonts
    return ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7C4DFF),
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        // Styling Elevated Buttons / Estilizando los Elevated Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
    );
}