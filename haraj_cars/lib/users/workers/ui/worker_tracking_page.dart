import 'package:flutter/material.dart';
import '../data/worker_model.dart';

class WorkerTrackingPage extends StatefulWidget {
  final Worker? worker; // null for all workers, Worker object for specific worker

  const WorkerTrackingPage({
    Key? key,
    this.worker,
  }) : super(key: key);

  @override
  State<WorkerTrackingPage> createState() => _WorkerTrackingPageState();
}

class _WorkerTrackingPageState extends State<WorkerTrackingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<WorkerAction> _actions = [];
  List<Worker> _workers = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading data
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _workers = [
      Worker(
        id: '1',
        name: 'John Smith',
        email: 'john@example.com',
        phone: '+1234567890',
        position: 'Sales Representative',
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
        permissions: ['view_cars', 'add_cars'],
      ),
      Worker(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        phone: '+1234567891',
        position: 'Marketing Specialist',
        joinDate: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
        permissions: ['view_cars', 'add_cars', 'edit_cars'],
      ),
    ];

    _actions = [
      WorkerAction(
        id: '1',
        workerId: '1',
        action: 'car_added',
        description: 'Added new car listing: Toyota Camry 2020',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WorkerAction(
        id: '2',
        workerId: '2',
        action: 'car_edited',
        description: 'Updated car listing: Honda Civic 2019',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      WorkerAction(
        id: '3',
        workerId: '1',
        action: 'user_contacted',
        description: 'Contacted potential buyer for BMW X5',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      WorkerAction(
        id: '4',
        workerId: '2',
        action: 'report_generated',
        description: 'Generated monthly sales report',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<WorkerAction> _getFilteredActions() {
    List<WorkerAction> filtered = _actions;

    if (widget.worker != null) {
      filtered = filtered.where((action) => action.workerId == widget.worker!.id).toList();
    }

    switch (_selectedFilter) {
      case 'Today':
        final today = DateTime.now();
        filtered = filtered.where((action) {
          return action.timestamp.year == today.year &&
              action.timestamp.month == today.month &&
              action.timestamp.day == today.day;
        }).toList();
        break;
      case 'This Week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered.where((action) => action.timestamp.isAfter(weekAgo)).toList();
        break;
      case 'This Month':
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        filtered = filtered.where((action) => action.timestamp.isAfter(monthAgo)).toList();
        break;
    }

    return filtered..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  String _getActionIcon(String action) {
    switch (action) {
      case 'car_added':
        return '🚗';
      case 'car_edited':
        return '✏️';
      case 'car_deleted':
        return '🗑️';
      case 'user_contacted':
        return '📞';
      case 'report_generated':
        return '📊';
      case 'login':
        return '🔐';
      case 'logout':
        return '🚪';
      default:
        return '📝';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'car_added':
        return Colors.green;
      case 'car_edited':
        return Colors.blue;
      case 'car_deleted':
        return Colors.red;
      case 'user_contacted':
        return Colors.orange;
      case 'report_generated':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker != null 
            ? '${widget.worker!.name} - Activity' 
            : 'Worker Activity Tracking'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Activity Feed'),
            Tab(text: 'Statistics'),
            Tab(text: 'Workers'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityFeed(),
            _buildStatistics(),
            _buildWorkersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredActions = _getFilteredActions();

    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter by',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Activity List
        Expanded(
          child: filteredActions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activity found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredActions.length,
                  itemBuilder: (context, index) {
                    final action = filteredActions[index];
                    final worker = _workers.firstWhere(
                      (w) => w.id == action.workerId,
                      orElse: () => Worker(
                        id: action.workerId,
                        name: 'Unknown Worker',
                        email: '',
                        phone: '',
                        position: '',
                        joinDate: DateTime.now(),
                        isActive: false,
                        permissions: [],
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getActionColor(action.action).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getActionIcon(action.action),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        title: Text(
                          action.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${worker.name}'),
                            Text(
                              _formatTimestamp(action.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getActionColor(action.action).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getActionDisplayName(action.action),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getActionColor(action.action),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Actions',
                  '${_actions.length}',
                  Icons.timeline,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Workers',
                  '${_workers.where((w) => w.isActive).length}',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today\'s Actions',
                  '${_getFilteredActions().length}',
                  Icons.today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Avg Actions/Day',
                  '12',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Types Chart (Placeholder)
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Types Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pie_chart,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chart Coming Soon',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search workers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),

          // Workers List
          Expanded(
            child: ListView.builder(
              itemCount: _workers.length,
              itemBuilder: (context, index) {
                final worker = _workers[index];
                final workerActions = _actions.where((a) => a.workerId == worker.id).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: worker.isActive ? Colors.green : Colors.grey,
                      child: Text(
                        worker.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      worker.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker.position),
                        Text(
                          '$workerActions actions performed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: worker.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            worker.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              color: worker.isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WorkerTrackingPage(worker: worker),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          tooltip: 'View Activity',
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _getActionDisplayName(String action) {
    switch (action) {
      case 'car_added':
        return 'Car Added';
      case 'car_edited':
        return 'Car Edited';
      case 'car_deleted':
        return 'Car Deleted';
      case 'user_contacted':
        return 'User Contacted';
      case 'report_generated':
        return 'Report Generated';
      case 'login':
        return 'Login';
      case 'logout':
        return 'Logout';
      default:
        return 'Other';
    }
  }
}
