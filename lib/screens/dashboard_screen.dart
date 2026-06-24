import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import 'task_list_screen.dart';
import 'refugio_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppState _state = AppState();
  final GeminiService _gemini = GeminiService();
  final int _currentIndex = 0; // Estado inicial del Dashboard

  void _handleMoodSelection(String mood) async {
    _state.currentMood = mood;
    _state.updater.value++; // FIX: Reemplaza notifyListeners() de forma segura

    // Navegación inmediata al Refugio
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RefugioScreen()));

    // Consulta en segundo plano a la IA
    String nuevaFrase = await _gemini.obtenerFraseRefugio(mood);
    _state.aiRefugioPhrase = nuevaFrase;
    _state.updater.value++;
  }

  void _onBottomTabTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RefugioScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("KINA Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _state.updater,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // FIX AQUÍ: Se cambió FontWeight.black por FontWeight.w900
                const Text("¡Hola, Karmina!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87)),
                const SizedBox(height: 4),
                const Text("¿Cómo se encuentra tu enfoque hoy?", style: TextStyle(fontSize: 15, color: Colors.black54)),
                const SizedBox(height: 25),

                // Selector de Estados de Ánimo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _moodButton("🚀", "Motivado"),
                    _moodButton("🥱", "Agotado"),
                    _moodButton("😰", "Estresado"),
                    _moodButton("🛑", "Bloqueado"),
                  ],
                ),
                const SizedBox(height: 35),

                const Text("Vista Rápida de Pendientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),

                // Muestra de subtareas o actividades principales
                Expanded(
                  child: _state.tasks.isEmpty
                      ? const Center(child: Text("Felicidades, no tienes pendientes activos.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                    itemCount: _state.tasks.take(3).length,
                    itemBuilder: (context, index) {
                      final task = _state.tasks[index];
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: const Icon(Icons.circle_outlined, color: Colors.deepPurple, size: 22),
                          title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                          subtitle: Text(task.deadline, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Botón Enlace Completo (Estilo Morado)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade50,
                    foregroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskListScreen()));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Ver mis tareas y detalles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          );
        },
      ),

      // Barra de Navegación Fija en la base (Morada)
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

  Widget _moodButton(String emoji, String moodLabel) {
    return GestureDetector(
      onTap: () => _handleMoodSelection(moodLabel),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2))
                ]
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 6),
          Text(moodLabel, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}