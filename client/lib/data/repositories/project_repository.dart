import '../../features/project/models/project.dart';
import '../sources/remote/project_remote_source.dart';

class ProjectRepository {
  ProjectRepository({ProjectRemoteSource? remote})
    : _remote = remote ?? ProjectRemoteSource();

  final ProjectRemoteSource _remote;

  Future<List<Project>> fetchProjects() => _remote.fetchProjects();

  Future<Project> createProject(Project project) =>
      _remote.createProject(project);

  Future<void> deleteProject(int id) => _remote.deleteProject(id);
}
