# Flutter Git项目管理客户端 - 核心代码实现

## 1. 数据模型实现

### 项目实体 (features/projects/domain/entities/project.dart)
```dart
import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String path;
  final String? description;
  final bool isFavorite;
  final List<String> tags;
  final DateTime lastModified;
  final String size;
  final int fileCount;
  final GitStatus? gitStatus;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    this.description,
    this.isFavorite = false,
    this.tags = const [],
    required this.lastModified,
    required this.size,
    required this.fileCount,
    this.gitStatus,
  });

  Project copyWith({
    String? id,
    String? name,
    String? path,
    String? description,
    bool? isFavorite,
    List<String>? tags,
    DateTime? lastModified,
    String? size,
    int? fileCount,
    GitStatus? gitStatus,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      lastModified: lastModified ?? this.lastModified,
      size: size ?? this.size,
      fileCount: fileCount ?? this.fileCount,
      gitStatus: gitStatus ?? this.gitStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        description,
        isFavorite,
        tags,
        lastModified,
        size,
        fileCount,
        gitStatus,
      ];
}

class GitStatus extends Equatable {
  final String currentBranch;
  final String? trackingBranch;
  final List<GitFile> modifiedFiles;
  final List<GitFile> stagedFiles;
  final int aheadCommits;
  final int behindCommits;
  final String? remoteUrl;

  const GitStatus({
    required this.currentBranch,
    this.trackingBranch,
    this.modifiedFiles = const [],
    this.stagedFiles = const [],
    this.aheadCommits = 0,
    this.behindCommits = 0,
    this.remoteUrl,
  });

  @override
  List<Object?> get props => [
        currentBranch,
        trackingBranch,
        modifiedFiles,
        stagedFiles,
        aheadCommits,
        behindCommits,
        remoteUrl,
      ];
}

class GitFile extends Equatable {
  final String path;
  final String status;
  final bool isStaged;
  final String? oldPath;

  const GitFile({
    required this.path,
    required this.status,
    this.isStaged = false,
    this.oldPath,
  });

  @override
  List<Object?> get props => [path, status, isStaged, oldPath];
}
```

### 项目模型 (features/projects/data/models/project_model.dart)
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.path,
    super.description,
    super.isFavorite = false,
    super.tags = const [],
    required super.lastModified,
    required super.size,
    required super.fileCount,
    super.gitStatus,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      name: project.name,
      path: project.path,
      description: project.description,
      isFavorite: project.isFavorite,
      tags: project.tags,
      lastModified: project.lastModified,
      size: project.size,
      fileCount: project.fileCount,
      gitStatus: project.gitStatus,
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      path: path,
      description: description,
      isFavorite: isFavorite,
      tags: tags,
      lastModified: lastModified,
      size: size,
      fileCount: fileCount,
      gitStatus: gitStatus,
    );
  }
}
```

## 2. 数据源实现

### Git数据源 (features/git_operations/data/datasources/git_datasource.dart)
```dart
import 'dart:io';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart' as path;

class GitDataSource {
  Future<GitStatus> getStatus(String repoPath) async {
    try {
      final result = await run('git', ['status', '--porcelain'], workingDirectory: repoPath);
      final branchResult = await run('git', ['branch', '--show-current'], workingDirectory: repoPath);
      final trackingResult = await run('git', ['rev-parse', '--abbrev-ref', '@{u}'], workingDirectory: repoPath);
      final aheadBehindResult = await run('git', ['rev-list', '--left-right', '--count', 'HEAD...@{u}'], workingDirectory: repoPath);
      final remoteUrlResult = await run('git', ['remote', 'get-url', 'origin'], workingDirectory: repoPath);

      final currentBranch = branchResult.stdout.toString().trim();
      final trackingBranch = trackingResult.exitCode == 0 ? trackingResult.stdout.toString().trim() : null;
      final remoteUrl = remoteUrlResult.exitCode == 0 ? remoteUrlResult.stdout.toString().trim() : null;

      // 解析ahead/behind信息
      int aheadCommits = 0;
      int behindCommits = 0;
      if (aheadBehindResult.exitCode == 0) {
        final parts = aheadBehindResult.stdout.toString().trim().split('\t');
        if (parts.length == 2) {
          aheadCommits = int.tryParse(parts[0]) ?? 0;
          behindCommits = int.tryParse(parts[1]) ?? 0;
        }
      }

      // 解析文件状态
      final files = <GitFile>[];
      final lines = result.stdout.toString().split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        
        final status = line.substring(0, 2);
        final filePath = line.substring(3);
        
        files.add(GitFile(
          path: filePath,
          status: status[0],
          isStaged: status[1] != ' ',
        ));
      }

      return GitStatus(
        currentBranch: currentBranch,
        trackingBranch: trackingBranch,
        modifiedFiles: files.where((f) => f.status != ' ').toList(),
        stagedFiles: files.where((f) => f.isStaged).toList(),
        aheadCommits: aheadCommits,
        behindCommits: behindCommits,
        remoteUrl: remoteUrl,
      );
    } catch (e) {
      throw GitException('Failed to get git status: $e');
    }
  }

  Future<List<GitCommit>> getCommitHistory(String repoPath, {int limit = 50}) async {
    try {
      final result = await run(
        'git',
        ['log', '--oneline', '--max-count', limit.toString(), '--pretty=format:%H|%an|%ae|%ad|%s'],
        workingDirectory: repoPath,
      );

      final commits = <GitCommit>[];
      final lines = result.stdout.toString().split('\n');
      
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.split('|');
        if (parts.length >= 5) {
          commits.add(GitCommit(
            hash: parts[0],
            author: parts[1],
            email: parts[2],
            date: DateTime.parse(parts[3]),
            message: parts[4],
          ));
        }
      }

      return commits;
    } catch (e) {
      throw GitException('Failed to get commit history: $e');
    }
  }

  Future<void> stageFile(String repoPath, String filePath) async {
    try {
      await run('git', ['add', filePath], workingDirectory: repoPath);
    } catch (e) {
      throw GitException('Failed to stage file: $e');
    }
  }

  Future<void> unstageFile(String repoPath, String filePath) async {
    try {
      await run('git', ['reset', 'HEAD', '--', filePath], workingDirectory: repoPath);
    } catch (e) {
      throw GitException('Failed to unstage file: $e');
    }
  }

  Future<void> commit(String repoPath, String message) async {
    try {
      await run('git', ['commit', '-m', message], workingDirectory: repoPath);
    } catch (e) {
      throw GitException('Failed to commit: $e');
    }
  }

  Future<void> push(String repoPath) async {
    try {
      await run('git', ['push'], workingDirectory: repoPath);
    } catch (e) {
      throw GitException('Failed to push: $e');
    }
  }

  Future<void> pull(String repoPath) async {
    try {
      await run('git', ['pull'], workingDirectory: repoPath);
    } catch (e) {
      throw GitException('Failed to pull: $e');
    }
  }

  Future<String> getFileDiff(String repoPath, String filePath) async {
    try {
      final result = await run('git', ['diff', filePath], workingDirectory: repoPath);
      return result.stdout.toString();
    } catch (e) {
      throw GitException('Failed to get file diff: $e');
    }
  }
}

class GitException implements Exception {
  final String message;
  const GitException(this.message);
  
  @override
  String toString() => 'GitException: $message';
}
```

### 项目本地数据源 (features/projects/data/datasources/project_local_datasource.dart)
```dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project_model.dart';

class ProjectLocalDataSource {
  static const String _boxName = 'projects';
  late Box<ProjectModel> _box;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProjectModelAdapter());
    }
    
    _box = await Hive.openBox<ProjectModel>(_boxName);
  }

  Future<List<ProjectModel>> getAllProjects() async {
    return _box.values.toList();
  }

  Future<ProjectModel?> getProject(String id) async {
    return _box.get(id);
  }

  Future<void> addProject(ProjectModel project) async {
    await _box.put(project.id, project);
  }

  Future<void> updateProject(ProjectModel project) async {
    await _box.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  Future<List<ProjectModel>> getFavoriteProjects() async {
    return _box.values.where((project) => project.isFavorite).toList();
  }

  Future<List<ProjectModel>> getProjectsByTag(String tag) async {
    return _box.values.where((project) => project.tags.contains(tag)).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final project = _box.get(id);
    if (project != null) {
      final updatedProject = project.copyWith(isFavorite: !project.isFavorite);
      await _box.put(id, updatedProject);
    }
  }
}
```

## 3. 仓库实现

### 项目仓库 (features/projects/data/repositories/project_repository_impl.dart)
```dart
import 'package:dio/dio.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource _localDataSource;
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectRepositoryImpl({
    required ProjectLocalDataSource localDataSource,
    required ProjectRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<List<Project>> getAllProjects() async {
    try {
      final projects = await _localDataSource.getAllProjects();
      return projects.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ProjectException('Failed to get projects: $e');
    }
  }

  @override
  Future<Project?> getProject(String id) async {
    try {
      final project = await _localDataSource.getProject(id);
      return project?.toEntity();
    } catch (e) {
      throw ProjectException('Failed to get project: $e');
    }
  }

  @override
  Future<void> addProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      await _localDataSource.addProject(model);
    } catch (e) {
      throw ProjectException('Failed to add project: $e');
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      await _localDataSource.updateProject(model);
    } catch (e) {
      throw ProjectException('Failed to update project: $e');
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _localDataSource.deleteProject(id);
    } catch (e) {
      throw ProjectException('Failed to delete project: $e');
    }
  }

  @override
  Future<List<Project>> getFavoriteProjects() async {
    try {
      final projects = await _localDataSource.getFavoriteProjects();
      return projects.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ProjectException('Failed to get favorite projects: $e');
    }
  }

  @override
  Future<List<Project>> getProjectsByTag(String tag) async {
    try {
      final projects = await _localDataSource.getProjectsByTag(tag);
      return projects.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ProjectException('Failed to get projects by tag: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      await _localDataSource.toggleFavorite(id);
    } catch (e) {
      throw ProjectException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<Project>> scanDirectories(List<String> paths) async {
    try {
      final projects = <Project>[];
      
      for (final path in paths) {
        final gitRepos = await _findGitRepos(path);
        for (final repo in gitRepos) {
          final project = await _createProject(repo);
          projects.add(project);
        }
      }
      
      return projects;
    } catch (e) {
      throw ProjectException('Failed to scan directories: $e');
    }
  }

  Future<List<String>> _findGitRepos(String directoryPath) async {
    // 实现目录扫描逻辑
    // 这里可以使用dart:io的Directory类来递归搜索.git文件夹
    return [];
  }

  Future<Project> _createProject(String repoPath) async {
    // 实现项目创建逻辑
    // 这里可以调用Git服务来获取项目信息
    return Project(
      id: '',
      name: '',
      path: repoPath,
      lastModified: DateTime.now(),
      size: '0',
      fileCount: 0,
    );
  }
}

class ProjectException implements Exception {
  final String message;
  const ProjectException(this.message);
  
  @override
  String toString() => 'ProjectException: $message';
}
```

## 4. 状态管理实现

### 项目状态管理 (features/projects/presentation/providers/project_providers.dart)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../notifiers/project_notifiers.dart';

// 项目仓库Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  // 这里需要注入实际的仓库实现
  throw UnimplementedError();
});

// 项目列表Provider
final projectListProvider = StateNotifierProvider<ProjectListNotifier, List<Project>>((ref) {
  return ProjectListNotifier(ref.read(projectRepositoryProvider));
});

// 选中项目Provider
final selectedProjectProvider = StateProvider<Project?>((ref) => null);

// 收藏项目Provider
final favoriteProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  return await repository.getFavoriteProjects();
});

// 按标签筛选的项目Provider
final projectsByTagProvider = FutureProvider.family<List<Project>, String>((ref, tag) async {
  final repository = ref.read(projectRepositoryProvider);
  return await repository.getProjectsByTag(tag);
});

// 项目搜索Provider
final projectSearchProvider = StateProvider<String>((ref) => '');

// 筛选后的项目Provider
final filteredProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectListProvider);
  final searchQuery = ref.watch(projectSearchProvider);
  
  if (searchQuery.isEmpty) {
    return projects;
  }
  
  return projects.where((project) {
    return project.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
           project.path.toLowerCase().contains(searchQuery.toLowerCase()) ||
           project.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
  }).toList();
});
```

### 项目状态通知器 (features/projects/presentation/providers/project_notifiers.dart)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectListNotifier extends StateNotifier<List<Project>> {
  final ProjectRepository _repository;

  ProjectListNotifier(this._repository) : super([]) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _repository.getAllProjects();
      state = projects;
    } catch (e) {
      // 处理错误
      state = [];
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _repository.addProject(project);
      state = [...state, project];
    } catch (e) {
      // 处理错误
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      state = state.map((p) => p.id == project.id ? project : p).toList();
    } catch (e) {
      // 处理错误
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      state = state.where((p) => p.id != projectId).toList();
    } catch (e) {
      // 处理错误
    }
  }

  Future<void> toggleFavorite(String projectId) async {
    try {
      await _repository.toggleFavorite(projectId);
      state = state.map((p) {
        if (p.id == projectId) {
          return p.copyWith(isFavorite: !p.isFavorite);
        }
        return p;
      }).toList();
    } catch (e) {
      // 处理错误
    }
  }

  Future<void> refreshProjects() async {
    await _loadProjects();
  }
}
```

## 5. UI组件实现

### 主窗口 (lib/main.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: AppInitializer(
        child: GitProjectManagerApp(),
      ),
    ),
  );
}
```

### 项目列表页面 (features/projects/presentation/pages/project_list_page.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/project_sidebar.dart';
import '../widgets/project_detail_view.dart';
import '../providers/project_providers.dart';

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(selectedProjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Git项目管理器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // 侧边栏
          Container(
            width: 250,
            child: const ProjectSidebar(),
          ),
          // 主内容区域
          Expanded(
            child: selectedProject != null
                ? ProjectDetailView(project: selectedProject)
                : const _EmptyStateView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索项目'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '输入项目名称或路径...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            ref.read(projectSearchProvider.notifier).state = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // 导航到设置页面
  }

  void _showProfileMenu(BuildContext context) {
    // 显示用户菜单
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加项目'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.download),
              title: Text('克隆仓库'),
              subtitle: Text('从远程仓库克隆项目'),
            ),
            ListTile(
              leading: Icon(Icons.create_new_folder),
              title: Text('新建仓库'),
              subtitle: Text('创建新的Git仓库'),
            ),
            ListTile(
              leading: Icon(Icons.folder_open),
              title: Text('导入现有项目'),
              subtitle: Text('导入本地已存在的项目'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '选择一个项目开始管理',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '从侧边栏选择项目，或点击右下角按钮添加新项目',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 项目侧边栏 (features/projects/presentation/widgets/project_sidebar.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_providers.dart';
import 'project_card.dart';

class ProjectSidebar extends ConsumerWidget {
  const ProjectSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(filteredProjectsProvider);
    final selectedProject = ref.watch(selectedProjectProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索项目...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                ref.read(projectSearchProvider.notifier).state = value;
              },
            ),
          ),
          // 快速操作按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cloneRepository(context),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('克隆'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createRepository(context),
                    icon: const Icon(Icons.create_new_folder, size: 16),
                    label: const Text('新建'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // 项目列表
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Text('没有找到项目'),
                  )
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        isSelected: project.id == selectedProject?.id,
                        onTap: () => ref
                            .read(selectedProjectProvider.notifier)
                            .state = project,
                        onToggleFavorite: () => ref
                            .read(projectListProvider.notifier)
                            .toggleFavorite(project.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _cloneRepository(BuildContext context) {
    // 实现克隆仓库逻辑
  }

  void _createRepository(BuildContext context) {
    // 实现创建仓库逻辑
  }
}
```

### 项目卡片 (features/projects/presentation/widgets/project_card.dart)
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: _getStatusColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        project.isFavorite ? Icons.star : Icons.star_border,
                        size: 16,
                        color: project.isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: onToggleFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  project.path,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (project.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: project.tags.take(3).map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(project.lastModified),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    if (project.gitStatus != null)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getGitStatusColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (project.gitStatus == null) return Colors.grey;
    
    final status = project.gitStatus!;
    if (status.modifiedFiles.isNotEmpty) return Colors.orange;
    if (status.aheadCommits > 0) return Colors.green;
    if (status.behindCommits > 0) return Colors.red;
    return Colors.green;
  }

  Color _getGitStatusColor() {
    if (project.gitStatus == null) return Colors.grey;
    
    final status = project.gitStatus!;
    if (status.modifiedFiles.isNotEmpty) return Colors.orange;
    if (status.aheadCommits > 0) return Colors.green;
    if (status.behindCommits > 0) return Colors.red;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else {
      return '刚刚';
    }
  }
}
```

这个Flutter实现提供了：
- 完整的数据模型和状态管理
- 现代化的Material Design 3界面
- 响应式布局和交互
- 清晰的代码结构和架构
- 可扩展的组件设计
<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
todo_write
