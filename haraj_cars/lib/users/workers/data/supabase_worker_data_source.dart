import 'package:supabase_flutter/supabase_flutter.dart';
import 'worker_data_source.dart';
import 'worker_model.dart';

class SupabaseWorkerDataSource implements WorkerDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<List<Worker>> getAllWorkers() async {
    try {
      final response = await _supabase
          .from('workers_list')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Worker.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching workers: $e');
      return [];
    }
  }

  @override
  Future<Worker?> getWorkerById(int id) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .select()
          .eq('id', id)
          .single();

      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching worker by ID: $e');
      return null;
    }
  }

  @override
  Future<Worker?> getWorkerByPhone(String phone) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_phone', phone)
          .single();

      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching worker by phone: $e');
      return null;
    }
  }

  @override
  Future<Worker?> getWorkerByName(String name) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_name', name)
          .single();

      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching worker by name: $e');
      return null;
    }
  }

  @override
  Future<Worker?> createWorker(Worker worker) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .insert(worker.toCreateJson())
          .select()
          .single();

      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating worker: $e');
      return null;
    }
  }

  @override
  Future<Worker?> updateWorker(Worker worker) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .update(worker.toUpdateJson())
          .eq('id', worker.id)
          .select()
          .single();

      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating worker: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteWorker(int id) async {
    try {
      await _supabase
          .from('workers_list')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting worker: $e');
      return false;
    }
  }

  @override
  Future<Worker?> authenticateWorker(String phone, String password) async {
    try {
      print('🔐 Attempting to authenticate worker with phone: $phone');
      
      // First, let's check if any worker exists with this phone
      final phoneCheck = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_phone', phone);
      
      print('📱 Found ${phoneCheck.length} workers with phone: $phone');
      
      if (phoneCheck.isEmpty) {
        print('❌ No worker found with phone: $phone');
        return null;
      }
      
      // Now try to authenticate with phone and password
      final response = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_phone', phone)
          .eq('worker_password', password)
          .single();

      print('✅ Worker authenticated successfully');
      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error authenticating worker: $e');
      print('💡 Make sure the worker exists and password is correct');
      return null;
    }
  }

  @override
  Future<Worker?> authenticateWorkerByName(String name, String password) async {
    try {
      print('🔐 Attempting to authenticate worker with name: $name');
      
      // First, let's check if any worker exists with this name
      final nameCheck = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_name', name);
      
      print('👤 Found ${nameCheck.length} workers with name: $name');
      
      if (nameCheck.isEmpty) {
        print('❌ No worker found with name: $name');
        return null;
      }
      
      // Now try to authenticate with name and password
      final response = await _supabase
          .from('workers_list')
          .select()
          .eq('worker_name', name)
          .eq('worker_password', password)
          .single();

      print('✅ Worker authenticated successfully by name');
      return Worker.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error authenticating worker by name: $e');
      print('💡 Make sure the worker exists and password is correct');
      return null;
    }
  }

  @override
  Future<bool> updateLastLogin(int workerId) async {
    try {
      await _supabase
          .from('workers_list')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', workerId);

      return true;
    } catch (e) {
      print('Error updating last login: $e');
      return false;
    }
  }

  @override
  Future<List<Worker>> searchWorkers(String query) async {
    try {
      final response = await _supabase
          .from('workers_list')
          .select()
          .or('worker_name.ilike.%$query%,worker_phone.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Worker.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching workers: $e');
      return [];
    }
  }
}
