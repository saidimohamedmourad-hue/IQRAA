import 'package:dio/dio.dart';
import '../datasources/api_client.dart';
import '../models/resume/resume_model.dart';

class ResumeRepository {
  final _client = ApiClient();

  Future<List<ResumeModel>> myResumes() async {
    final res = await _client.dio.get('/resumes');
    final data = res.data as List;
    return data.map((e) => ResumeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ResumeModel> uploadResume(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'resume': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _client.dio.post('/resumes', data: formData);
    return ResumeModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteResume(String id) async {
    await _client.dio.delete('/resumes/$id');
  }
}
