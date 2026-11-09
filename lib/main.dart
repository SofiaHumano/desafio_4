import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class Tarea {
  final String titulo;
  final bool completada;
  final String prioridad;

  const Tarea({
    required this.titulo,
    this.completada = false,
    this.prioridad = 'Media',
  });

  Tarea copyWith({bool? completada}) {
    return Tarea(
      titulo: titulo,
      completada: completada ?? this.completada,
      prioridad: prioridad,
    );
  }
}

class TasksState {
  final List<Tarea> tareas;

  const TasksState({this.tareas = const []});

  int get pendientes => tareas.where((t) => !t.completada).length;
  int get completadas => tareas.length - pendientes;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(const TasksState());

  void agregar(String titulo, String prioridad) {
    state = TasksState(
      tareas: [
        ...state.tareas,
        Tarea(titulo: titulo, prioridad: prioridad),
      ],
    );
  }

  void eliminar(int indice) {
    final nuevas = [...state.tareas];
    nuevas.removeAt(indice);
    state = TasksState(tareas: nuevas);
  }

  void toggleCompletada(int indice) {
    final nuevas = [...state.tareas];
    nuevas[indice] = nuevas[indice].copyWith(
      completada: !nuevas[indice].completada,
    );
    state = TasksState(tareas: nuevas);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>(
      (ref) => TasksNotifier(),
);

Color colorPrioridad(String prioridad, ColorScheme cs) {
  switch (prioridad) {
    case 'Alta':
      return cs.error;
    case 'Media':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _seccion = 0;

  final List<String> _titulos = ['Inicio', 'Tareas', 'Perfil'];

  final List<Widget> _pantallas = const [
    InicioScreen(),
    TareasScreen(),
    PerfilScreen(),
  ];

  void _irA(int i) {
    setState(() => _seccion = i);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pendientes = ref.watch(tasksProvider).pendientes;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_seccion]),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cs.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/200'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sofia Humano',
                    style: TextStyle(color: cs.onPrimary, fontSize: 16),
                  ),
                  Text(
                    'sofiahack387@gmail.com',
                    style: TextStyle(color: cs.onPrimary, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _seccion == 0,
              onTap: () {
                Navigator.pop(context);
                _irA(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text('Mis Tareas'),
              selected: _seccion == 1,
              onTap: () {
                Navigator.pop(context);
                _irA(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              selected: _seccion == 2,
              onTap: () {
                Navigator.pop(context);
                _irA(2);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Mis Tareas',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),

      body: _pantallas[_seccion],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: _irA,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$pendientes'),
              isLabelVisible: pendientes > 0,
              child: const Icon(Icons.task_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$pendientes'),
              isLabelVisible: pendientes > 0,
              child: const Icon(Icons.task_alt),
            ),
            label: 'Tareas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tasksProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Tareas pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${state.pendientes}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Estadistica(
                  numero: '${state.tareas.length}',
                  texto: 'Total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Estadistica(
                  numero: '${state.completadas}',
                  texto: 'Completadas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Estadistica extends StatelessWidget {
  final String numero;
  final String texto;

  const Estadistica({super.key, required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numero,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cs.onSecondaryContainer,
            ),
          ),
          Text(texto, style: TextStyle(color: cs.onSecondaryContainer)),
        ],
      ),
    );
  }
}

class TareasScreen extends ConsumerStatefulWidget {
  const TareasScreen({super.key});

  @override
  ConsumerState<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends ConsumerState<TareasScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _prioridad = 'Media';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _agregar() {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    ref.read(tasksProvider.notifier).agregar(texto, _prioridad);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tasksProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _agregar(),
                  decoration: InputDecoration(
                    labelText: 'Nueva tarea',
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _agregar,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'Alta', label: Text('Alta')),
              ButtonSegment<String>(value: 'Media', label: Text('Media')),
              ButtonSegment<String>(value: 'Baja', label: Text('Baja')),
            ],
            selected: {_prioridad},
            onSelectionChanged: (Set<String> seleccion) {
              setState(() => _prioridad = seleccion.first);
            },
          ),
        ),

        Expanded(
          child: state.tareas.isEmpty
              ? const Center(child: Text('Todavía no hay tareas'))
              : ListView.builder(
            itemCount: state.tareas.length,
            itemBuilder: (context, i) {
              final tarea = state.tareas[i];
              final color = colorPrioridad(tarea.prioridad, cs);

              return ListTile(
                leading: Checkbox(
                  value: tarea.completada,
                  activeColor: color,
                  onChanged: (_) {
                    ref.read(tasksProvider.notifier).toggleCompletada(i);
                  },
                ),
                title: Text(
                  tarea.titulo,
                  style: TextStyle(
                    decoration: tarea.completada
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  'Prioridad ${tarea.prioridad}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: cs.error),
                  onPressed: () {
                    ref.read(tasksProvider.notifier).eliminar(i);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tasksProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sofia Humano',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.pendientes} pendientes · ${state.completadas} completadas',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
