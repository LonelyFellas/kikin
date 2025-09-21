# Git项目管理桌面客户端 - 技术实现方案

## 技术栈选择

### 前端框架
- **Electron**: 跨平台桌面应用框架
- **React**: 用户界面库
- **TypeScript**: 类型安全的JavaScript
- **Ant Design**: 企业级UI组件库

### 状态管理
- **Redux Toolkit**: 状态管理
- **React Query**: 服务器状态管理
- **Zustand**: 轻量级状态管理

### Git操作库
- **simple-git**: 轻量级Git操作库
- **nodegit**: 完整的Git绑定库
- **isomorphic-git**: 纯JavaScript Git实现

### 数据存储
- **SQLite**: 本地数据库
- **Dexie.js**: IndexedDB包装器
- **LowDB**: 轻量级JSON数据库

## 项目结构

```
git-project-manager/
├── src/
│   ├── main/                    # Electron主进程
│   │   ├── main.ts
│   │   ├── menu.ts
│   │   └── window.ts
│   ├── renderer/                # 渲染进程
│   │   ├── components/          # React组件
│   │   │   ├── ProjectList/
│   │   │   ├── ProjectDetail/
│   │   │   ├── GitStatus/
│   │   │   ├── FileChanges/
│   │   │   ├── CommitHistory/
│   │   │   └── DiffViewer/
│   │   ├── hooks/               # 自定义Hooks
│   │   ├── services/            # 服务层
│   │   │   ├── gitService.ts
│   │   │   ├── projectService.ts
│   │   │   └── storageService.ts
│   │   ├── store/               # 状态管理
│   │   │   ├── slices/
│   │   │   └── index.ts
│   │   ├── types/               # TypeScript类型
│   │   ├── utils/               # 工具函数
│   │   └── App.tsx
│   └── shared/                  # 共享代码
│       ├── types/
│       └── constants/
├── public/
├── package.json
├── tsconfig.json
└── webpack.config.js
```

## 核心服务实现

### 1. Git服务 (gitService.ts)

```typescript
import simpleGit, { SimpleGit } from 'simple-git';
import { GitStatus, CommitInfo, BranchInfo } from '../types/git';

export class GitService {
  private git: SimpleGit;

  constructor(repoPath: string) {
    this.git = simpleGit(repoPath);
  }

  // 获取Git状态
  async getStatus(): Promise<GitStatus> {
    const status = await this.git.status();
    return {
      current: status.current,
      tracking: status.tracking,
      ahead: status.ahead,
      behind: status.behind,
      files: status.files.map(file => ({
        path: file.path,
        status: file.working_dir,
        staged: file.index !== ' ',
        changes: file.working_dir
      }))
    };
  }

  // 获取提交历史
  async getCommitHistory(limit: number = 50): Promise<CommitInfo[]> {
    const log = await this.git.log({ maxCount: limit });
    return log.all.map(commit => ({
      hash: commit.hash,
      message: commit.message,
      author: commit.author_name,
      email: commit.author_email,
      date: new Date(commit.date),
      branch: commit.refs
    }));
  }

  // 获取分支列表
  async getBranches(): Promise<BranchInfo[]> {
    const branches = await this.git.branch();
    return branches.all.map(branch => ({
      name: branch,
      current: branch === branches.current,
      remote: branch.includes('origin/')
    }));
  }

  // 执行Git命令
  async executeCommand(command: string, ...args: string[]): Promise<string> {
    return await this.git.raw(command, ...args);
  }
}
```

### 2. 项目服务 (projectService.ts)

```typescript
import { GitService } from './gitService';
import { Project, ProjectStatus } from '../types/project';
import { StorageService } from './storageService';

export class ProjectService {
  private storage: StorageService;

  constructor() {
    this.storage = new StorageService();
  }

  // 扫描目录查找Git仓库
  async scanDirectories(paths: string[]): Promise<Project[]> {
    const projects: Project[] = [];
    
    for (const path of paths) {
      const gitRepos = await this.findGitRepos(path);
      for (const repo of gitRepos) {
        const project = await this.createProject(repo);
        projects.push(project);
      }
    }
    
    return projects;
  }

  // 创建项目对象
  private async createProject(repoPath: string): Promise<Project> {
    const git = new GitService(repoPath);
    const status = await git.getStatus();
    
    return {
      id: this.generateId(),
      name: this.extractProjectName(repoPath),
      path: repoPath,
      status: this.determineStatus(status),
      lastActivity: new Date(),
      favorite: false,
      tags: [],
      gitStatus: status
    };
  }

  // 更新项目状态
  async updateProjectStatus(projectId: string): Promise<void> {
    const project = await this.storage.getProject(projectId);
    if (!project) return;

    const git = new GitService(project.path);
    const status = await git.getStatus();
    
    project.gitStatus = status;
    project.status = this.determineStatus(status);
    project.lastActivity = new Date();
    
    await this.storage.updateProject(project);
  }

  // 获取项目详情
  async getProjectDetails(projectId: string): Promise<Project> {
    const project = await this.storage.getProject(projectId);
    if (!project) throw new Error('Project not found');

    await this.updateProjectStatus(projectId);
    return await this.storage.getProject(projectId);
  }
}
```

### 3. 存储服务 (storageService.ts)

```typescript
import Dexie, { Table } from 'dexie';
import { Project, Settings } from '../types';

export class StorageService extends Dexie {
  projects!: Table<Project>;
  settings!: Table<Settings>;

  constructor() {
    super('GitProjectManager');
    this.version(1).stores({
      projects: 'id, name, path, status, lastActivity, favorite',
      settings: 'id, key, value'
    });
  }

  // 项目相关操作
  async getProjects(): Promise<Project[]> {
    return await this.projects.orderBy('lastActivity').reverse().toArray();
  }

  async getProject(id: string): Promise<Project | undefined> {
    return await this.projects.get(id);
  }

  async saveProject(project: Project): Promise<void> {
    await this.projects.put(project);
  }

  async updateProject(project: Project): Promise<void> {
    await this.projects.update(project.id, project);
  }

  async deleteProject(id: string): Promise<void> {
    await this.projects.delete(id);
  }

  // 设置相关操作
  async getSetting(key: string): Promise<any> {
    const setting = await this.settings.get(key);
    return setting?.value;
  }

  async setSetting(key: string, value: any): Promise<void> {
    await this.settings.put({ id: key, key, value });
  }
}
```

## 主要组件实现

### 1. 项目列表组件

```typescript
import React from 'react';
import { List, Card, Badge, Tag, Button } from 'antd';
import { Project } from '../types/project';

interface ProjectListProps {
  projects: Project[];
  onSelectProject: (project: Project) => void;
  onToggleFavorite: (projectId: string) => void;
}

export const ProjectList: React.FC<ProjectListProps> = ({
  projects,
  onSelectProject,
  onToggleFavorite
}) => {
  return (
    <div className="project-list">
      <List
        dataSource={projects}
        renderItem={(project) => (
          <List.Item>
            <Card
              size="small"
              hoverable
              onClick={() => onSelectProject(project)}
              actions={[
                <Button
                  type="text"
                  icon={project.favorite ? 'star-filled' : 'star'}
                  onClick={(e) => {
                    e.stopPropagation();
                    onToggleFavorite(project.id);
                  }}
                />
              ]}
            >
              <Card.Meta
                title={
                  <div className="project-title">
                    <span>{project.name}</span>
                    <Badge
                      status={getStatusColor(project.status)}
                      text={project.status}
                    />
                  </div>
                }
                description={
                  <div>
                    <div className="project-path">{project.path}</div>
                    <div className="project-tags">
                      {project.tags.map(tag => (
                        <Tag key={tag} size="small">{tag}</Tag>
                      ))}
                    </div>
                  </div>
                }
              />
            </Card>
          </List.Item>
        )}
      />
    </div>
  );
};

function getStatusColor(status: string): 'success' | 'warning' | 'error' | 'default' {
  switch (status) {
    case 'clean': return 'success';
    case 'modified': return 'warning';
    case 'conflict': return 'error';
    default: return 'default';
  }
}
```

### 2. Git状态组件

```typescript
import React from 'react';
import { Card, Statistic, Button, Space, Tag } from 'antd';
import { GitStatus } from '../types/git';

interface GitStatusProps {
  gitStatus: GitStatus;
  onViewDiff: () => void;
  onCommit: () => void;
  onPush: () => void;
  onPull: () => void;
}

export const GitStatusPanel: React.FC<GitStatusProps> = ({
  gitStatus,
  onViewDiff,
  onCommit,
  onPush,
  onPull
}) => {
  const modifiedFiles = gitStatus.files.filter(f => f.status !== ' ');
  const stagedFiles = gitStatus.files.filter(f => f.staged);

  return (
    <Card title="Git状态" size="small">
      <div className="git-status">
        <div className="branch-info">
          <Tag color="blue">{gitStatus.current}</Tag>
          {gitStatus.tracking && (
            <span> → {gitStatus.tracking}</span>
          )}
        </div>
        
        <div className="status-stats">
          <Statistic
            title="修改文件"
            value={modifiedFiles.length}
            valueStyle={{ color: modifiedFiles.length > 0 ? '#cf1322' : '#3f8600' }}
          />
          <Statistic
            title="已暂存"
            value={stagedFiles.length}
            valueStyle={{ color: stagedFiles.length > 0 ? '#1890ff' : '#3f8600' }}
          />
          <Statistic
            title="领先提交"
            value={gitStatus.ahead}
            valueStyle={{ color: gitStatus.ahead > 0 ? '#1890ff' : '#3f8600' }}
          />
          <Statistic
            title="落后提交"
            value={gitStatus.behind}
            valueStyle={{ color: gitStatus.behind > 0 ? '#faad14' : '#3f8600' }}
          />
        </div>

        <div className="git-actions">
          <Space>
            <Button
              type="primary"
              icon="eye"
              onClick={onViewDiff}
              disabled={modifiedFiles.length === 0}
            >
              查看差异
            </Button>
            <Button
              type="default"
              icon="save"
              onClick={onCommit}
              disabled={stagedFiles.length === 0}
            >
              提交
            </Button>
            <Button
              type="default"
              icon="upload"
              onClick={onPush}
              disabled={gitStatus.ahead === 0}
            >
              推送
            </Button>
            <Button
              type="default"
              icon="download"
              onClick={onPull}
              disabled={gitStatus.behind === 0}
            >
              拉取
            </Button>
          </Space>
        </div>
      </div>
    </Card>
  );
};
```

## 开发环境配置

### package.json

```json
{
  "name": "git-project-manager",
  "version": "1.0.0",
  "main": "dist/main/main.js",
  "scripts": {
    "dev": "concurrently \"npm run dev:main\" \"npm run dev:renderer\"",
    "dev:main": "webpack --config webpack.main.config.js --mode development --watch",
    "dev:renderer": "webpack serve --config webpack.renderer.config.js --mode development",
    "build": "npm run build:main && npm run build:renderer",
    "build:main": "webpack --config webpack.main.config.js --mode production",
    "build:renderer": "webpack --config webpack.renderer.config.js --mode production",
    "start": "electron .",
    "pack": "electron-builder",
    "dist": "npm run build && electron-builder"
  },
  "dependencies": {
    "electron": "^22.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "antd": "^5.0.0",
    "simple-git": "^3.15.0",
    "dexie": "^3.2.0",
    "@reduxjs/toolkit": "^1.9.0",
    "react-redux": "^8.0.0",
    "react-query": "^3.39.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@types/node": "^18.0.0",
    "typescript": "^4.9.0",
    "webpack": "^5.75.0",
    "webpack-cli": "^5.0.0",
    "webpack-dev-server": "^4.11.0",
    "concurrently": "^7.6.0",
    "electron-builder": "^23.6.0"
  }
}
```

### TypeScript配置

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": [
    "src"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
```

## 部署和分发

### 构建配置

```json
{
  "build": {
    "appId": "com.yourcompany.git-project-manager",
    "productName": "Git项目管理器",
    "directories": {
      "output": "dist-electron"
    },
    "files": [
      "dist/**/*",
      "node_modules/**/*"
    ],
    "mac": {
      "category": "public.app-category.developer-tools",
      "target": "dmg"
    },
    "win": {
      "target": "nsis"
    },
    "linux": {
      "target": "AppImage"
    }
  }
}
```

这个技术实现方案提供了一个完整的桌面Git项目管理客户端的基础架构，包含了所有必要的服务和组件实现。您可以根据具体需求进行调整和扩展。
