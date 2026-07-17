import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../models/volunteer_task.dart';
import '../../../services/volunteer_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<VolunteerTask> _tasks = [];
  bool _isLoading = true;
  String _filter = 'all';
  final List<String> _filters = ['all', 'pending', 'in_progress', 'completed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await VolunteerService.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<VolunteerTask> get _filteredTasks {
    if (_filter == 'all') return _tasks;
    return _tasks.where((t) => t.status == _filter).toList();
  }

  Future<void> _updateTaskStatus(VolunteerTask task, String newStatus) async {
    final result = await VolunteerService.updateTaskStatus(task.id, newStatus);
    if (result['success'] == true) {
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = VolunteerTask(
            id: task.id,
            title: task.title,
            description: task.description,
            assignedDate: task.assignedDate,
            dueDate: task.dueDate,
            location: task.location,
            status: newStatus,
            report: task.report,
            completedAt: newStatus == 'completed' ? DateTime.now() : task.completedAt,
            assignedBy: task.assignedBy,
            assignedBy_name: task.assignedBy_name,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task marked as ${newStatus.replaceAll('_', ' ')}'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _showTaskDetail(VolunteerTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(task.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Description', task.description),
                _buildDetailItem('Location', task.location),
                _buildDetailItem('Assigned By', task.assignedBy_name),
                _buildDetailItem('Assigned Date', _formatDate(task.assignedDate)),
                if (task.dueDate != null)
                  _buildDetailItem('Due Date', _formatDate(task.dueDate!)),
                if (task.report != null)
                  _buildDetailItem('Report', task.report!),
                const SizedBox(height: 20),
                if (task.status != 'completed')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateTaskStatus(task, 'in_progress');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.info,
                          ),
                          child: const Text('Mark In Progress'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showReportDialog(task);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                          ),
                          child: const Text('Complete'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (task.status == 'in_progress')
                  ElevatedButton(
                    onPressed: () => _showReportDialog(task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                    ),
                    child: const Text('Submit Report & Complete'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReportDialog(VolunteerTask task) {
    final reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        title: const Text('Task Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a report for this task:'),
            const SizedBox(height: 12),
            TextField(
              controller: reportController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your report...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _updateTaskStatus(task, 'completed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'in_progress':
        return AppTheme.info;
      case 'completed':
        return AppTheme.success;
      default:
        return AppTheme.gray500;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _filter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filter = filter);
                      },
                      selectedColor: AppTheme.primary.withOpacity(0.2),
                      checkmarkColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primary : AppTheme.gray600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Tasks list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: AppTheme.gray400),
                            SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: TextStyle(fontSize: 18, color: AppTheme.gray500),
                            ),
                            Text(
                              'Tasks assigned to you will appear here',
                              style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return GestureDetector(
                            onTap: () => _showTaskDetail(task),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppTheme.radius),
                                boxShadow: AppTheme.shadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(task.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          task.status.replaceAll('_', ' ').toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _getStatusColor(task.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.gray600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppTheme.gray400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.location,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray400,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppTheme.gray400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(task.assignedDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}