import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import 'dashboard_screen.dart';
import 'refugio_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final AppState _state = AppState();
  final GeminiService _gemini = GeminiService();
  bool _isLoading = false;
  final int _currentIndex = 1; // Índice 1 corresponde a 'Tareas'

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  Future<void> _seleccionarFecha(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setModalState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _seleccionarHora(BuildContext context, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setModalState(() => _horaSeleccionada = picked);
    }
  }

  void _onBottomTabTapped(int index) {
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RefugioScreen()));
    }
  }

  void _mostrarFormularioNuevaTarea() {
    _tituloController.clear();
    _descripcionController.clear();
    _fechaSeleccionada = null;
    _horaSeleccionada = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25))
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 25, left: 24, right: 24
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nueva Tarea Semanal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 15),
                TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(labelText: "¿Qué tienes que hacer?", filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: "Escribe la descripción completa aquí...", filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple, side: const BorderSide(color: Color(0x33673AB7))),
                        icon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                        label: Text(_fechaSeleccionada == null
                            ? "Elegir Fecha"
                            : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}"),
                        onPressed: () => _seleccionarFecha(context, setModalState),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple, side: const BorderSide(color: Color(0x33673AB7))),
                        icon: const Icon(Icons.access_time, color: Colors.deepPurple),
                        label: Text(_horaSeleccionada == null
                            ? "Elegir Hora"
                            : _horaSeleccionada!.format(context)),
                        onPressed: () => _seleccionarHora(context, setModalState),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: const Text("Guardar Tarea", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_tituloController.text.isNotEmpty) {
                      final fechaFinal = _fechaSeleccionada != null
                          ? "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month} ${_horaSeleccionada?.format(context) ?? ''}"
                          : "Pronto";

                      setState(() {
                        _state.tasks.add(AppTask(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _tituloController.text,
                          description: _descripcionController.text,
                          deadline: fechaFinal,
                          isCompleted: false,
                          isAiGenerated: false,
                          subTasks: [],
                        ));
                      });
                      _state.updater.value++;
                      Navigator.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _optimizarConGemini(AppTask task) async {
    setState(() => _isLoading = true);

    var sugerencias = await _gemini.planificarTarea(
        titulo: task.title,
        fecha: task.deadline,
        avances: "Ninguno",
        requisitos: task.description,
        sentimiento: _state.currentMood
    );

    if (sugerencias.isNotEmpty) {
      setState(() {
        task.isAiGenerated = true;
        task.subTasks = sugerencias;
      });
      _state.updater.value++;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> referenciasSubtareas = [];
    for (var task in _state.tasks) {
      if (task.isAiGenerated) {
        for (var sub in task.subTasks) {
          referenciasSubtareas.add({
            'subtask_object': sub,
            'parent_task': task,
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Previene inconsistencias en el árbol de navegación
        title: Text("Mi Enfoque Semanal (${_state.tasks.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("🔥 Pasos sugeridos por la IA", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(
            flex: 2,
            child: referenciasSubtareas.isEmpty
                ? const Center(child: Text("Presiona 'Necesito ayuda 🤖' en tus tareas\npara desglosar tu descripción en 4 pasos.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: referenciasSubtareas.length,
              itemBuilder: (context, index) {
                final item = referenciasSubtareas[index];
                return _buildMicroAvanceCard(item['subtask_object'], item['parent_task']);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("📅 Tus Tareas de la Semana", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          SizedBox(
            height: 165,
            child: _state.tasks.isEmpty
                ? const Center(child: Text("No hay tareas agregadas", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _state.tasks.length,
              itemBuilder: (context, index) {
                return _buildProyectoCard(_state.tasks[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // Margen para que no obstruya visualmente el menú inferior
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _mostrarFormularioNuevaTarea,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      // Barra de Navegación Fija integrada perfectamente
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomTabTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
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
      ),
    );
  }

  Widget _buildMicroAvanceCard(Map<String, dynamic> subTask, AppTask parentTask) {
    bool isDone = subTask['isCompleted'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.ads_click, color: isDone ? Colors.green : Colors.deepPurple),
        title: Text(
            subTask['actividad'] ?? 'Micro-paso',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : Colors.black87
            )
        ),
        subtitle: Text(
            "📅 ${subTask['fecha']} • [${parentTask.title}]",
            style: const TextStyle(fontSize: 11)
        ),
        trailing: Checkbox(
          value: isDone,
          activeColor: Colors.deepPurple,
          onChanged: (bool? newValue) {
            setState(() {
              subTask['isCompleted'] = newValue ?? false;
              int listas = parentTask.subTasks.where((s) => s['isCompleted'] == true).length;
              if (listas == parentTask.subTasks.length) {
                parentTask.isCompleted = true;
              } else {
                parentTask.isCompleted = false;
              }
            });
            _state.updater.value++;
          },
        ),
      ),
    );
  }

  Widget _buildProyectoCard(AppTask task) {
    double progreso = 0.0;
    if (task.isCompleted) {
      progreso = 1.0;
    } else if (task.isAiGenerated && task.subTasks.isNotEmpty) {
      int checkedCount = task.subTasks.where((sub) => sub['isCompleted'] == true).length;
      progreso = checkedCount / task.subTasks.length;
    }

    return Container(
      width: 190,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    task.isCompleted = !task.isCompleted;
                  });
                  _state.updater.value++;
                },
                child: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.assignment_outlined,
                    color: task.isCompleted ? Colors.green : (task.isAiGenerated ? Colors.deepPurple : Colors.indigo)
                ),
              ),
              Text(task.deadline, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(task.description, style: const TextStyle(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          if (!task.isAiGenerated && !task.isCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                width: double.infinity,
                height: 28,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Colors.deepPurple.shade50),
                  onPressed: () => _optimizarConGemini(task),
                  child: const Text("Necesito ayuda 🤖", style: TextStyle(color: Colors.deepPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${(progreso * 100).toInt()}%", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 2),
                LinearProgressIndicator(value: progreso, backgroundColor: Colors.grey[200], color: Colors.deepPurple),
              ],
            ),
        ],
      ),
    );
  }
}