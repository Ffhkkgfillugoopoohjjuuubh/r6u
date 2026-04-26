import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectsState {
  final List<ProjectModel> projects;
  final bool isLoading;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = true,
  });

  ProjectsState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectService _service;

  ProjectsNotifier(this._service) : super(const ProjectsState()) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await _service.initialize();
    final projects = await _service.loadAllProjects();
    state = state.copyWith(projects: projects, isLoading: false);
  }

  Future<void> refreshProjects() async {
    final projects = await _service.loadAllProjects();
    state = state.copyWith(projects: projects);
  }

  Future<ProjectModel> createProject(String name) async {
    final project = await _service.createProject(name);
    await refreshProjects();
    return project;
  }

  Future<void> deleteProject(String projectId) async {
    await _service.deleteProject(projectId);
    await refreshProjects();
  }

  Future<void> renameProject(String projectId, String newName) async {
    await _service.renameProject(projectId, newName);
    await refreshProjects();
  }

  Future<void> addSessionToProject(String projectId, String sessionId) async {
    await _service.addSessionToProject(projectId, sessionId);
    await refreshProjects();
  }

  Future<void> removeSessionFromProject(String projectId, String sessionId) async {
    await _service.removeSessionFromProject(projectId, sessionId);
    await refreshProjects();
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ProjectService());
});