import '../datasources/api_client.dart';
import '../models/training/training_model.dart';

class TrainingRepository {
  final _client = ApiClient();

  Future<List<TrainingSessionModel>> getSessions({String? search, String? category}) async {
    final res = await _client.dio.get('/training-sessions', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    });
    final data = res.data['data'] as List;
    return data.map((e) => TrainingSessionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TrainingSessionModel> getSession(String id) async {
    final res = await _client.dio.get('/training-sessions/$id');
    return TrainingSessionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> applySession(String sessionId, {String? resumeId}) async {
    await _client.dio.post('/training-sessions/$sessionId/apply', data: {
      if (resumeId != null) 'resume_id': resumeId,
    });
  }

  Future<List<TrainingApplicationModel>> myApplications() async {
    final res = await _client.dio.get('/my/training-applications');
    final data = res.data['data'] as List;
    return data.map((e) => TrainingApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TrainingCategoryModel>> getTrainingCategories() async {
    final res = await _client.dio.get('/training-categories');
    final data = res.data['data'] as List;
    return data.map((e) => TrainingCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // School-owner
  Future<List<TrainingSessionModel>> schoolSessions() async {
    final res = await _client.dio.get('/school/training-sessions');
    final data = res.data['data'] as List;
    return data.map((e) => TrainingSessionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TrainingSessionModel> createSession(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/school/training-sessions', data: data);
    return TrainingSessionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TrainingSessionModel> updateSession(String id, Map<String, dynamic> data) async {
    final res = await _client.dio.put('/school/training-sessions/$id', data: data);
    return TrainingSessionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteSession(String id) async {
    await _client.dio.delete('/school/training-sessions/$id');
  }

  Future<List<TrainingApplicationModel>> sessionApplicants(String sessionId) async {
    final res = await _client.dio.get('/school/training-sessions/$sessionId/applicants');
    final data = res.data['data'] as List;
    return data.map((e) => TrainingApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _client.dio.put('/school/training-applications/$applicationId/status', data: {'status': status});
  }
}
