import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Tu API Key definida correctamente a nivel de clase
  static const String _apiKey = String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: 'TU_API_KEY_AQUI' // Reemplaza aquí si la pegas directamente
  );

  /// 1. MÉTODO PARA PLANIFICAR TAREAS (Desglose)
  Future<List<Map<String, dynamic>>> planificarTarea({
    required String titulo,
    required String fecha,
    required String avances,
    required String requisitos,
    required String sentimiento,
  }) async {
    try {
      final url = Uri.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey");

      final prompt = """
      Actúa como un tutor de organización académica inteligente para estudiantes universitarios.
      Tengo una tarea principal llamada: '$titulo' con fecha límite '$fecha'.
      Descripción/Requisitos de la tarea: '$requisitos'.
      Mi estado de ánimo actual es: '$sentimiento'.
      Desglosa esta tarea compleja en exactamente 4 micro-pasos o actividades realistas y progresivas.
      Debes responder ÚNICAMENTE con un arreglo JSON válido, sin bloques de código markdown (no uses ```json), sin texto extra antes ni después.
      Cada objeto del arreglo debe tener exactamente estas dos llaves estructuradas en español:
        'actividad': (descripción corta del micro-paso)
        'fecha': (una sugerencia de cuándo completarlo, ej: 'Hoy', 'Mañana', 'En 2 días')
      """;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String textResponse = data['candidates'][0]['content']['parts'][0]['text'];

        String jsonLimpio = textResponse
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();

        List<dynamic> listaDecodificada = jsonDecode(jsonLimpio);
        return listaDecodificada.map((item) {
          return {
            'actividad': item['actividad'] ?? 'Micro-paso sugerido',
            'fecha': item['fecha'] ?? 'Pronto',
            'isCompleted': false,
          };
        }).toList();
      }
    } catch (e) {
      print("Error en planificarTarea: $e");
    }

    // LISTA DE RESPALDO (Mantenida intacta con tus 4 pasos académicos)
    return [
      {"fecha": "⚠️ Paso 1", "actividad": "Inicia con la introducción para: $titulo.", "isCompleted": false},
      {"fecha": "⚠️ Paso 2", "actividad": "Desarrollo del cuerpo del trabajo y contenido principal.", "isCompleted": false},
      {"fecha": "⚠️ Paso 3", "actividad": "Redacción de las conclusiones y puntos finales.", "isCompleted": false},
      {"fecha": "⚠️ Paso 4", "actividad": "Revisa detalles, formato y ortografía. (Verifica tu API Key/Internet)", "isCompleted": false},
    ];
  } // Aquí cierra correctamente el método planificarTarea

  /// 2. MÉTODO PARA EL REFUGIO (CORREGIDO Y DENTRO DE LA CLASE)
  Future<String> obtenerFraseRefugio(String sentimiento) async {
    final url = Uri.parse("[https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey](https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey)");

    final prompt = "Genera una frase corta y empática de apoyo emocional para un estudiante estresado por la escuela. Su estado actual es: '$sentimiento'. No uses markdown ni textos largos, máximo 2 líneas.";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? "Mantén tu enfoque hoy.";
      } else {
        print("Error de API: ${response.statusCode} - ${response.body}");
        return "Sigue adelante, tu enfoque es tu fuerza.";
      }
    } catch (e) {
      print("❌ ERROR EN obtenerFraseRefugio: $e");
      return "Mantén la calma, estamos conectando con tu espacio seguro.";
    }
  } // Aquí cierra el método obtenerFraseRefugio

} // <--- ESTA LLAVE CIERRA TODA LA CLASE AL FINAL DEL ARCHIVO