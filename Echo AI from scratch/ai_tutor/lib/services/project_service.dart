import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  late SharedPreferences _prefs;
  late Directory _documentsDir;
  bool _isInitialized = false;

  static const String _projectsKey = 'echo_projects';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _documentsDir = await getApplicationDocumentsDirectory();

    final projectsDir = Directory('${_documentsDir.path}/echo_projects');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }

    _isInitialized = true;
  }

  String get projectsDirectory => '${_documentsDir.path}/echo_projects';

  Future<Directory> _getDir() async {
    final dir = Directory(projectsDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> saveProject(ProjectModel project) async {
    final dir = await _getDir();
    final file = File('${dir.path}/${project.id}.json');
    await file.writeAsString(jsonEncode(project.toJson()), flush: true);
    
    final projectIds = getProjectIds();
    if (!projectIds.contains(project.id)) {
      projectIds.add(project.id);
      await _prefs.setStringList(_projectsKey, projectIds);
    }
  }

  List<String> getProjectIds() {
    return _prefs.getStringList(_projectsKey) ?? [];
  }

  Future<List<ProjectModel>> loadAllProjects() async {
    final projectIds = getProjectIds();
    final projects = <ProjectModel>[];
    
    for (final id in projectIds) {
      final project = await loadProject(id);
      if (project != null) {
        projects.add(project);
      }
    }

    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  Future<ProjectModel?> loadProject(String projectId) async {
    try {
      final dir = await _getDir();
      final file = File('${dir.path}/$projectId.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return ProjectModel.fromJson(jsonDecode(content));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<ProjectModel> createProject(String name) async {
    final now = DateTime.now();
    final project = ProjectModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      sessionIds: [],
    );

    await saveProject(project);
    return project;
  }

  Future<void> deleteProject(String projectId) async {
    final dir = await _getDir();
    final file = File('${dir.path}/$projectId.json');
    if (await file.exists()) {
      await file.delete();
    }

    final projectIds = getProjectIds();
    projectIds.remove(projectId);
    await _prefs.setStringList(_projectsKey, projectIds);
  }

  Future<void> renameProject(String projectId, String newName) async {
    final project = await loadProject(projectId);
    if (project != null) {
      final updated = project.copyWith(name: newName);
      await saveProject(updated);
    }
  }

  Future<void> addSessionToProject(String projectId, String sessionId) async {
    final project = await loadProject(projectId);
    if (project != null && !project.sessionIds.contains(sessionId)) {
      final updated = project.copyWith(
        sessionIds: [...project.sessionIds, sessionId],
      );
      await saveProject(updated);
    }
  }

  Future<void> removeSessionFromProject(String projectId, String sessionId) async {
    final project = await loadProject(projectId);
    if (project != null) {
      final updated = project.copyWith(
        sessionIds: project.sessionIds.where((id) => id != sessionId).toList(),
      );
      await saveProject(updated);
    }
  }

  Future<void> clearAllProjects() async {
    final dir = await _getDir();
    final files = dir.listSync().where((e) => e is File && e.path.endsWith('.json')).toList();
    for (final entity in files) {
      entity.deleteSync();
    }
    await _prefs.setStringList(_projectsKey, []);
  }

  void dispose() {}
}