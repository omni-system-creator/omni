# OMS 离线部署指南 (Release Package)

本目录包含已编译的 OMS 系统文件，无需在服务器上进行源码编译，适合快速部署和更新。

## 1. 目录结构说明

```text
o/
├── backend/            # 后端发布文件 (已包含 Dockerfile)
├── frontend/           # 前端发布文件 (dist 目录 + nginx.conf + Dockerfile)
├── docker-compose.yml  # 容器编排文件
└── DEPLOY.md           # 本说明文件
```

## 2. 部署步骤

### 2.1 上传文件
将整个 `o` 文件夹（或压缩包）上传至服务器，例如 `/www/wwwroot/o`。

### 2.2 启动服务
进入目录并启动 Docker 容器：

```bash
cd /www/wwwroot/o
docker-compose up -d --build
```

> **注意**: 这里的 `--build` 只是将本地的已编译文件打包进 Docker 镜像，速度非常快，不需要下载依赖或编译代码。

### 2.3 验证
- 后端 API: `http://localhost:5016`
- 前端页面: `http://localhost:8080`

## 3. 数据库说明
本发布包默认配置连接宿主机数据库：
- **Host**: `host.docker.internal` (指向宿主机)
- **Database**: `o_jinlan`
- **User**: `o_jinlan`

如需修改，请编辑 `docker-compose.yml` 中的 `ConnectionStrings__DefaultConnection_mysql` 环境变量。

## 4. 如何更新
1. 在本地运行 `build_release.ps1` 生成新的发布包。
2. 将新的 `backend` 和 `frontend` 目录覆盖服务器上的对应目录。
3. 在服务器执行 `docker-compose up -d --build` 重启服务。
