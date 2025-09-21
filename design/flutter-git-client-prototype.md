# Flutter Git项目管理桌面客户端原型设计

## 整体架构设计

### 技术栈选择
- **框架**: Flutter 3.0+ (支持桌面端)
- **状态管理**: Riverpod / Bloc
- **UI组件**: Material Design 3 / Cupertino
- **Git操作**: git2dart / process_run
- **数据存储**: Hive / SQLite (sqflite)
- **网络请求**: Dio / http
- **文件操作**: path_provider / file_picker

### 项目结构
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   └── theme/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── projects/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   ├── git_operations/
│   ├── diff_viewer/
│   ├── commit_history/
│   └── settings/
├── shared/
│   ├── widgets/
│   ├── services/
│   └── models/
└── generated/
```

## 主界面设计

### 1. 主窗口布局
```dart
class MainWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Git项目管理器'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          // 侧边栏 - 项目列表
          Container(
            width: 250,
            child: ProjectSidebar(),
          ),
          // 主内容区域
          Expanded(
            child: ProjectDetailView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 2. 侧边栏设计
```dart
class ProjectSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectListProvider);
    final selectedProject = ref.watch(selectedProjectProvider);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // 搜索框
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索项目...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // 快速操作按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _cloneRepository(context),
                    icon: Icon(Icons.download),
                    label: Text('克隆'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createRepository(context),
                    icon: Icon(Icons.create_new_folder),
                    label: Text('新建'),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // 项目列表
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectListItem(
                  project: project,
                  isSelected: project.id == selectedProject?.id,
                  onTap: () => ref.read(selectedProjectProvider.notifier).selectProject(project),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. 项目详情视图
```dart
class ProjectDetailView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(selectedProjectProvider);
    
    if (selectedProject == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('选择一个项目开始管理', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      );
    }
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 项目概览卡片
          ProjectOverviewCard(project: selectedProject),
          SizedBox(height: 16),
          // Git状态卡片
          GitStatusCard(project: selectedProject),
          SizedBox(height: 16),
          // 文件更改和提交历史
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: FileChangesCard(project: selectedProject),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CommitHistoryCard(project: selectedProject),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 核心组件设计

### 1. 项目概览卡片
```dart
class ProjectOverviewCard extends StatelessWidget {
  final Project project;
  
  const ProjectOverviewCard({Key? key, required this.project}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, size: 32, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        project.path,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(project.isFavorite ? Icons.star : Icons.star_border),
                  onPressed: () => _toggleFavorite(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(Icons.schedule, '最后更新', project.lastModified),
                SizedBox(width: 16),
                _buildInfoChip(Icons.storage, '大小', project.size),
                SizedBox(width: 16),
                _buildInfoChip(Icons.description, '文件数', '${project.fileCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text('$label: $value', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

### 2. Git状态卡片
```dart
class GitStatusCard extends ConsumerWidget {
  final Project project;
  
  const GitStatusCard({Key? key, required this.project}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gitStatus = ref.watch(gitStatusProvider(project.id));
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Git状态', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            // 分支信息
            Row(
              children: [
                Icon(Icons.account_tree, color: Colors.blue),
                SizedBox(width: 8),
                Text('当前分支: '),
                Chip(
                  label: Text(gitStatus.currentBranch),
                  backgroundColor: Colors.blue.shade100,
                ),
                if (gitStatus.trackingBranch != null) ...[
                  Icon(Icons.arrow_forward, size: 16),
                  Chip(
                    label: Text(gitStatus.trackingBranch!),
                    backgroundColor: Colors.green.shade100,
                  ),
                ],
              ],
            ),
            SizedBox(height: 16),
            // 状态统计
            Row(
              children: [
                _buildStatusChip(
                  '修改文件',
                  gitStatus.modifiedFiles.length,
                  Colors.orange,
                ),
                SizedBox(width: 16),
                _buildStatusChip(
                  '已暂存',
                  gitStatus.stagedFiles.length,
                  Colors.blue,
                ),
                SizedBox(width: 16),
                _buildStatusChip(
                  '领先提交',
                  gitStatus.aheadCommits,
                  Colors.green,
                ),
                SizedBox(width: 16),
                _buildStatusChip(
                  '落后提交',
                  gitStatus.behindCommits,
                  Colors.red,
                ),
              ],
            ),
            SizedBox(height: 16),
            // 操作按钮
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: gitStatus.modifiedFiles.isNotEmpty ? _viewDiff : null,
                  icon: Icon(Icons.difference),
                  label: Text('查看差异'),
                ),
                ElevatedButton.icon(
                  onPressed: gitStatus.stagedFiles.isNotEmpty ? _commit : null,
                  icon: Icon(Icons.save),
                  label: Text('提交'),
                ),
                ElevatedButton.icon(
                  onPressed: gitStatus.aheadCommits > 0 ? _push : null,
                  icon: Icon(Icons.upload),
                  label: Text('推送'),
                ),
                ElevatedButton.icon(
                  onPressed: gitStatus.behindCommits > 0 ? _pull : null,
                  icon: Icon(Icons.download),
                  label: Text('拉取'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12)),
          Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

### 3. 文件更改卡片
```dart
class FileChangesCard extends ConsumerWidget {
  final Project project;
  
  const FileChangesCard({Key? key, required this.project}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gitStatus = ref.watch(gitStatusProvider(project.id));
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文件更改 (${gitStatus.modifiedFiles.length})', 
                 style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: gitStatus.modifiedFiles.length,
                itemBuilder: (context, index) {
                  final file = gitStatus.modifiedFiles[index];
                  return FileChangeItem(
                    file: file,
                    onViewDiff: () => _viewFileDiff(file),
                    onStage: () => _stageFile(file),
                    onUnstage: () => _unstageFile(file),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileChangeItem extends StatelessWidget {
  final GitFile file;
  final VoidCallback onViewDiff;
  final VoidCallback onStage;
  final VoidCallback onUnstage;
  
  const FileChangeItem({
    Key? key,
    required this.file,
    required this.onViewDiff,
    required this.onStage,
    required this.onUnstage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 状态图标
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getStatusColor(file.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(file.status),
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _getStatusText(file.status),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // 操作按钮
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 20),
                onPressed: onViewDiff,
                tooltip: '查看差异',
              ),
              IconButton(
                icon: Icon(file.isStaged ? Icons.remove : Icons.add, size: 20),
                onPressed: file.isStaged ? onUnstage : onStage,
                tooltip: file.isStaged ? '取消暂存' : '暂存文件',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'M': return Colors.orange;
      case 'A': return Colors.green;
      case 'D': return Colors.red;
      case 'R': return Colors.blue;
      default: return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'M': return Icons.edit;
      case 'A': return Icons.add;
      case 'D': return Icons.delete;
      case 'R': return Icons.drive_file_rename_outline;
      default: return Icons.help;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'M': return '已修改';
      case 'A': return '新增文件';
      case 'D': return '已删除';
      case 'R': return '已重命名';
      default: return '未知状态';
    }
  }
}
```

## 数据模型设计

### 1. 项目模型
```dart
class Project {
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
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      description: json['description'],
      isFavorite: json['isFavorite'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      lastModified: DateTime.parse(json['lastModified']),
      size: json['size'],
      fileCount: json['fileCount'],
      gitStatus: json['gitStatus'] != null 
          ? GitStatus.fromJson(json['gitStatus']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'description': description,
      'isFavorite': isFavorite,
      'tags': tags,
      'lastModified': lastModified.toIso8601String(),
      'size': size,
      'fileCount': fileCount,
      'gitStatus': gitStatus?.toJson(),
    };
  }
}
```

### 2. Git状态模型
```dart
class GitStatus {
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
  
  factory GitStatus.fromJson(Map<String, dynamic> json) {
    return GitStatus(
      currentBranch: json['currentBranch'],
      trackingBranch: json['trackingBranch'],
      modifiedFiles: (json['modifiedFiles'] as List?)
          ?.map((e) => GitFile.fromJson(e))
          .toList() ?? [],
      stagedFiles: (json['stagedFiles'] as List?)
          ?.map((e) => GitFile.fromJson(e))
          .toList() ?? [],
      aheadCommits: json['aheadCommits'] ?? 0,
      behindCommits: json['behindCommits'] ?? 0,
      remoteUrl: json['remoteUrl'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'currentBranch': currentBranch,
      'trackingBranch': trackingBranch,
      'modifiedFiles': modifiedFiles.map((e) => e.toJson()).toList(),
      'stagedFiles': stagedFiles.map((e) => e.toJson()).toList(),
      'aheadCommits': aheadCommits,
      'behindCommits': behindCommits,
      'remoteUrl': remoteUrl,
    };
  }
}

class GitFile {
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
  
  factory GitFile.fromJson(Map<String, dynamic> json) {
    return GitFile(
      path: json['path'],
      status: json['status'],
      isStaged: json['isStaged'] ?? false,
      oldPath: json['oldPath'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'status': status,
      'isStaged': isStaged,
      'oldPath': oldPath,
    };
  }
}
```

## 状态管理设计

### 1. Riverpod Providers
```dart
// 项目列表Provider
final projectListProvider = StateNotifierProvider<ProjectListNotifier, List<Project>>((ref) {
  return ProjectListNotifier(ref.read(projectRepositoryProvider));
});

// 选中项目Provider
final selectedProjectProvider = StateProvider<Project?>((ref) => null);

// Git状态Provider
final gitStatusProvider = FutureProvider.family<GitStatus, String>((ref, projectId) async {
  final project = ref.read(projectListProvider).firstWhere((p) => p.id == projectId);
  return ref.read(gitServiceProvider).getStatus(project.path);
});

// 项目仓库Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    localDataSource: ref.read(projectLocalDataSourceProvider),
    gitService: ref.read(gitServiceProvider),
  );
});

// Git服务Provider
final gitServiceProvider = Provider<GitService>((ref) {
  return GitServiceImpl();
});
```

### 2. 项目列表状态管理
```dart
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
    final project = state.firstWhere((p) => p.id == projectId);
    final updatedProject = project.copyWith(isFavorite: !project.isFavorite);
    await updateProject(updatedProject);
  }
}
```

这个Flutter版本的设计提供了：
- 现代化的Material Design 3界面
- 响应式布局设计
- 清晰的状态管理架构
- 可扩展的组件结构
- 完整的类型安全支持

需要我继续完善某个特定部分吗？
