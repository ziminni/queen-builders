import '../../../core/network/api_config.dart';
import '../../../core/services/api_service.dart';
import '../../../features/project/models/project.dart';

class ProjectRemoteSource {
  ProjectRemoteSource({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Project>> fetchProjects() async {
    final r = await _api.dio.get(ApiConfig.projectProjects);
    final list = r.data as List<dynamic>;
    return list
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Project> createProject(Project project) async {
    final r = await _api.dio.post(
      ApiConfig.projectProjects,
      data: project.toJson(),
    );
    return Project.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  Future<void> deleteProject(int id) async {
    await _api.dio.delete(ApiConfig.projectDetail(id));
  }
}
