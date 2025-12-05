import 'package:flutter/material.dart';
import 'package:webview_all/webview_all.dart';

// --- Entry Point ---
void main() {
  runApp(const StaffApp());
}

// --- App Configuration ---
class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duoob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Professional Blue
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.comfortable,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

// --- Data Models ---
enum TaskType { administrative, technical }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final String url;
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.date,
  });
}

// --- Mock Data ---
final List<Task> _allTasks = [
  Task(
    id: '1',
    title: 'Update HR Records',
    description: 'Review and update the employee database for Q4.',
    type: TaskType.administrative,
    url: 'https://flutter.dev',
    date: DateTime.now(),
  ),
  Task(
    id: '2',
    title: 'Server Maintenance',
    description: 'Check logs for the main database server.',
    type: TaskType.technical,
    url: 'https://pub.dev',
    date: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Task(
    id: '3',
    title: 'Payroll Approval',
    description: 'Approve pending payroll requests.',
    type: TaskType.administrative,
    url: 'https://google.com',
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Task(
    id: '4',
    title: 'API Integration Check',
    description: 'Verify the payment gateway endpoints.',
    type: TaskType.technical,
    url: 'https://stackoverflow.com',
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// --- Main App Shell (Navigation Layer) ---
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Navigation Rail (Far Left Menu)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          
          // Divider between Rail and Content
          VerticalDivider(thickness: 1, width: 1, color: Theme.of(context).dividerColor),

          // 2. Main Content Area (Switches based on selection)
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                TaskWorkspace(),      // The Task Split-View
                PlaceholderPage(title: 'Reports & Analytics'),
                PlaceholderPage(title: 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Task Workspace (The Split-View Logic) ---
class TaskWorkspace extends StatefulWidget {
  const TaskWorkspace({super.key});

  @override
  State<TaskWorkspace> createState() => _TaskWorkspaceState();
}

class _TaskWorkspaceState extends State<TaskWorkspace> {
  Task? _selectedTask;
  TaskType _selectedFilter = TaskType.administrative;

  List<Task> get _filteredTasks {
    return _allTasks.where((t) => t.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // A. Task List Sidebar (Middle Pane)
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterTabs(),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),

        // B. Detail View (Right Pane)
        Expanded(
          child: _selectedTask == null
              ? _buildEmptyState()
              : _buildTaskDetailView(),
        ),
      ],
    );
  }

  // --- Workspace Components ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      alignment: Alignment.centerLeft,
      child: Text(
        'My Tasks',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<TaskType>(
          segments: const [
            ButtonSegment(
              value: TaskType.administrative,
              label: Text('ERP'),
              icon: Icon(Icons.folder_shared_outlined, size: 16),
            ),
            ButtonSegment(
              value: TaskType.technical,
              label: Text('Employee'),
              icon: Icon(Icons.terminal_outlined, size: 16),
            ),
          ],
          selected: {_selectedFilter},
          onSelectionChanged: (Set<TaskType> newSelection) {
            setState(() {
              _selectedFilter = newSelection.first;
              _selectedTask = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _filteredTasks;
    if (tasks.isEmpty) {
      return Center(
        child: Text('No tasks found.', style: TextStyle(color: Theme.of(context).hintColor)),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = _selectedTask?.id == task.id;

        return ListTile(
          title: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
          subtitle: Text(
            task.date.toString().substring(0, 10),
            style: const TextStyle(fontSize: 12),
          ),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(task.title[0], style: const TextStyle(fontSize: 14)),
          ),
          selected: isSelected,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          onTap: () {
            setState(() {
              _selectedTask = task;
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'Select a task to view details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTask!.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Chip(
                    label: Text(_selectedTask!.type.name.toUpperCase()),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(_selectedTask!.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              SelectableText('Source: ${_selectedTask!.url}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _MockWebView(url: _selectedTask!.url)),
      ],
    );
  }
}

// --- Placeholder for other future pages ---
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Coming Soon'),
        ],
      ),
    );
  }
}

// --- Platform WebView Simulation ---
class _MockWebView extends StatelessWidget {
  final String url;
  const _MockWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Center(
          // Look here!  
          child: Webview(url: "$url")
      ),
          // Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(Icons.public, size: 80, color: Colors.grey),
          //       const SizedBox(height: 20),
          //       const Text('Web Content Area', style: TextStyle(fontSize: 24, color: Colors.black87)),
          //       const SizedBox(height: 10),
          //       Text('Loading: $url', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          //       const SizedBox(height: 30),
          //       FilledButton.icon(
          //         onPressed: () {
          //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening $url...')));
          //         },
          //         icon: const Icon(Icons.open_in_new),
          //         label: const Text('Open in Browser'),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}