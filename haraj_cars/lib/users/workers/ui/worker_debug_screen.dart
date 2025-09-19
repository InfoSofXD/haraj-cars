import 'package:flutter/material.dart';
import '../data/worker_debug_helper.dart';
import '../data/worker_service.dart';

class WorkerDebugScreen extends StatefulWidget {
  const WorkerDebugScreen({Key? key}) : super(key: key);

  @override
  State<WorkerDebugScreen> createState() => _WorkerDebugScreenState();
}

class _WorkerDebugScreenState extends State<WorkerDebugScreen> {
  final WorkerService _workerService = WorkerService();
  List<String> _logs = [];
  bool _isLoading = false;
  
  // Form controllers for creating workers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _createWorker() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _addLog('❌ Please fill in all required fields (Name, Phone, Password)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _addLog('Creating worker: ${_nameController.text}...');
    final worker = await WorkerDebugHelper.createWorker(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? '' : _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    
    if (worker != null) {
      _addLog('✅ Worker created successfully!');
      _addLog('📱 Phone: ${worker.workerPhone}');
      _addLog('🔑 Password: ${_passwordController.text}');
      _addLog('👤 Name: ${worker.workerName}');
      
      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
    } else {
      _addLog('❌ Failed to create worker');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testAuth() async {
    if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
      _addLog('❌ Please enter name and password to test authentication');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _addLog('Testing worker authentication by name...');
    await WorkerDebugHelper.testWorkerAuthByName(_nameController.text.trim(), _passwordController.text.trim());

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _listWorkers() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('Fetching all workers...');
    final workers = await _workerService.getAllWorkers();
    
    if (workers.isEmpty) {
      _addLog('📭 No workers found in database');
    } else {
      _addLog('👥 Found ${workers.length} workers:');
      for (final worker in workers) {
        _addLog('  - ${worker.workerName} (${worker.workerPhone})');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }


  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Debug Helper'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Worker Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Worker Creation Form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create New Worker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Worker Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createWorker,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Create Worker'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _listWorkers,
                      icon: const Icon(Icons.list),
                      label: const Text('List Workers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testAuth,
                      icon: const Icon(Icons.login),
                      label: const Text('Test Auth'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          
          // Logs
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Logs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _logs.isEmpty
                          ? Center(
                              child: Text(
                                'No logs yet. Use the buttons above to perform actions.',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                final log = _logs[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    log,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                top: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Fill in the form above to create a new worker\n'
                  '2. Click "List Workers" to see all workers in the database\n'
                  '3. Click "Test Auth" to verify authentication works\n'
                  '4. Use the worker credentials to login in the app',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
