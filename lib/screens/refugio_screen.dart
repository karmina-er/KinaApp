import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import 'dashboard_screen.dart';
import 'task_list_screen.dart';

class RefugioScreen extends StatefulWidget {
  const RefugioScreen({super.key});

  @override
  State<RefugioScreen> createState() => _RefugioScreenState();
}

class _RefugioScreenState extends State<RefugioScreen> {
  final AppState _state = AppState();
  final GeminiService _gemini = GeminiService();
  bool _isLoadingPhrase = false;
  final int _currentIndex = 2; // Índice 2 corresponde a 'Ánimo'

  // Asignamos directamente tonos suaves nativos (.shade100) para no depender de métodos de opacidad dinámicos
  final List<Map<String, dynamic>> _moods = [
    {'emoj': '😊', 'name': 'Feliz', 'color': Colors.amber.shade100},
    {'emoj': '😐', 'name': 'Neutral', 'color': Colors.blue.shade100},
    {'emoj': '😮‍💨', 'name': 'Estresado', 'color': Colors.orange.shade100},
    {'emoj': '😢', 'name': 'Triste', 'color': Colors.purple.shade100},
    {'emoj': '😡', 'name': 'Frustrado', 'color': Colors.red.shade100},
  ];

  Future<void> _actualizarEstadoAnimo(String nuevoAnimo) async {
    setState(() {
      _state.currentMood = nuevoAnimo;
      _state.moodHistory.add(nuevoAnimo);
      _isLoadingPhrase = true;
    });
    _state.updater.value++;

    String frase = await _gemini.obtenerFraseRefugio(nuevoAnimo);

    setState(() {
      _state.aiRefugioPhrase = frase;
      _isLoadingPhrase = false;
    });
    _state.updater.value++;
  }

  void _onBottomTabTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Evita que se encimen botones de regreso innecesarios
        title: const Text(
            "El Refugio 🍃",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _state.updater,
        builder: (context, value, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tarjeta de Mensaje de Apoyo de la IA (Estilo Morado Coherente)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 10) // Negro con 5% de opacidad constante
                      ],
                      border: Border.all(color: const Color(0x26673AB7), width: 1) // Morado DeepPurple con 15% de opacidad constante (0x26)
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.psychology, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text("Mensaje de apoyo IA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _isLoadingPhrase
                          ? const CircularProgressIndicator(color: Colors.deepPurple)
                          : Text(
                        _state.aiRefugioPhrase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Selector Horizontal de Estados de Ánimo
                const Text("¿Cómo te sientes en este momento?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 15),
                SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      bool isSelected = _state.currentMood == mood['name'];

                      return GestureDetector(
                        onTap: () => _actualizarEstadoAnimo(mood['name']),
                        child: Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 12, bottom: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : mood['color'],
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: isSelected ? const [BoxShadow(color: Color(0x33673AB7), blurRadius: 6, offset: Offset(0, 3))] : null,
                            border: isSelected ? null : Border.all(color: const Color(0x1A000000)), // Negro al 10%
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(mood['emoj'], style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 5),
                              Text(
                                mood['name'],
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black54
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Historial Seguro de Estados de Ánimo
                const Text("Tu Historial de Ánimo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 12),

                _state.moodHistory.isEmpty
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0x1A000000))
                  ),
                  child: const Center(
                    child: Text(
                      "Aún no has registrado estados de ánimo hoy.\n¡Selecciona uno arriba!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _state.moodHistory.length,
                  itemBuilder: (context, index) {
                    final item = _state.moodHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.circle, size: 10, color: Colors.deepPurple),
                        title: Text(
                            "Te sentías: $item",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)
                        ),
                        trailing: Text(
                            "Registro #${index + 1}",
                            style: const TextStyle(fontSize: 11, color: Colors.grey)
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),

      // Barra de Navegación Fija en la base (Morada e idéntica al Dashboard)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomTabTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            label: 'Animo',
          ),
        ],
      ),
    );
  }
}