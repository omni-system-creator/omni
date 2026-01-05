# 综合信息管理系统 (OmniSystem)

综合信息管理系统是一款为企业提供一体化业务数据管理解决方案的平台，旨在实现合同、财务、项目、客户、供应商等核心业务流程的数字化管理与协同。系统采用模块化松耦合设计，各模块既可独立运行，又能通过标准接口实现数据深度互通。

国内仓库地址：<a href="https://gitee.com/kinglan_gitee/omni" target="_blank">https://gitee.com/kinglan_gitee/omni</a>

演示地址：<a href="https://os.jinlan.info" target="_blank">https://os.jinlan.info</a>

## 📚 文档资源

- [📄 系统功能规划 (功能.md)](./documents/功能.md)
- [📖 关于项目 (About.md)](./documents/About.md)

## 🌟 核心功能

综合信息管理系统不仅仅是一个业务系统，更是一个强大的低代码/零代码开发与运行平台，具备以下核心能力：

- **🛡️ 权限管控能力**：基于 RBAC 的动态权限控制体系，支持颗粒度精细到字段级、数据行级的安全管控，确保数据安全。
- **📊 数据管理能力**：强大的数据建模与管理引擎，支持复杂业务数据的存储、检索、关联与流转，构建企业数据资产。
- **🔌 接口编排能力**：可视化接口编排与逻辑设计，支持通过拖拽配置实现复杂的业务逻辑与 API 服务，降低开发门槛。
- **🔗 数据集成能力**：强大的多源数据集成能力，轻松打破信息孤岛，实现异构系统间的数据互联互通与实时同步。
- **🎨 界面自定义能力**：灵活的表单设计器与页面布局工具，支持拖拽式 UI 设计，满足企业个性化的界面交互需求。
- **📱 形态多样性**：全终端形态支持，一次配置，多端运行。完美适配 **PC 浏览器**、**桌面客户端**、**移动端 H5**、**APP** 及 **嵌入式设备**。
- **🚀 快速部署能力**：支持容器化部署与自动化运维，开箱即用，快速响应业务变化，大幅缩短交付周期。

## 💡 应用场景

基于强大的平台能力，系统内置并支持构建多种复杂的业务应用场景：

### 1. 合同全生命周期管理
- **模板管理**：支持基于历史合同快速生成标准模板，支持复杂格式及动态表格。
- **在线签署**：集成电子签章，支持移动端手写签字与防篡改保护。
- **执行跟踪**：关键节点自动提醒，变更记录全程留痕，履约异常预警。
- **归档检索**：支持全文检索与权限分级访问控制。

### 2. 项目管理
- **统筹管理**：提供看板、甘特图等多视图，支持资源分配与冲突检测。
- **文档协同**：项目文档集中存储，支持版本控制与外部安全分享。
- **成本控制**：预算与实际支出实时对比，成本超支预警。

### 3. 财务管理
- **应收应付**：自动关联合同款项，生成收付款计划与账龄分析。
- **发票管理**：支持发票OCR识别、验真及红冲作废流程。
- **报表分析**：多维度收支统计，自动生成利润趋势及部门业绩报表。

### 4. 客户与供应商管理 (CRM & SRM)
- **客户360°视图**：聚合基础信息、联系人关系及合作历史，支持信用评估与分级。
- **供应商管理**：履约能力评分，采购价格对比及合作风险预警。

### 其他模块
- **库存管理**：出入库管理、库存追踪、盘点分析。
- **BI数据分析**：销售、财务、采购等多维度数据可视化驾驶舱。
- **个人中心**：待办事项、网盘、消息通知、日程管理。

## 🛠️ 技术栈

### 后端
- **框架**: .NET 10
- **数据库**: MySQL 8.0+
- **ORM**: Entity Framework Core
- **API 文档**: Swagger / OpenAPI
- **日志**: Serilog

### 前端
- **框架**: Vue 3 + TypeScript
- **构建工具**: Vite
- **UI 组件库**: Ant Design Vue
- **状态管理**: Pinia
- **图表库**: ECharts
- **路由管理**: Vue Router

## 📂 目录结构

```
OMS/
├── backend/             # 后端项目源码
│   ├── omsapi/          # Web API 项目
│   └── ...
├── frontend/            # 前端 PC 端项目源码 (Vue 3 + Ant Design Vue)
│   ├── src/
│   │   ├── components/  # 公共组件
│   │   ├── layouts/     # 布局组件
│   │   ├── router/      # 路由配置
│   │   ├── stores/      # Pinia 状态管理
│   │   ├── views/       # 页面视图
│   │   └── ...
│   └── ...
├── frontend.h5/         # 前端移动端项目源码 (Vue 3 + Vant 4)
│   ├── src/
│   │   └── ...
│   └── ...
├── bigview/             # 数据大屏项目源码
│   └── ...
├── documents/           # 项目文档
│   ├── 功能.md          # 系统功能需求规划方案
│   └── About.md         # 项目介绍
└── README.md            # 项目说明文档
```

## 🚀 快速开始

### 后端启动

1. 进入后端目录：
   ```bash
   cd backend/omsapi
   ```

2. 配置数据库连接：
   修改 `appsettings.json` 中的 `ConnectionStrings:DefaultConnection` 为你的 MySQL 连接字符串。

3. 运行项目：
   ```bash
   dotnet run
   ```
   
   或者使用热重载模式：
   ```bash
   dotnet watch
   ```

### 前端 PC 端启动

1. 进入前端目录：
   ```bash
   cd frontend
   ```

2. 安装依赖：
   ```bash
   npm install
   # 或
   yarn install
   ```

3. 启动开发服务器：
   ```bash
   npm run dev
   # 或
   yarn dev
   ```

### 前端移动端启动

1. 进入移动端目录：
   ```bash
   cd frontend.h5
   ```

2. 安装依赖：
   ```bash
   npm install
   ```

3. 启动开发服务器：
   ```bash
   npm run dev
   ```

4. 构建生产版本：
   ```bash
   npm run build
   ```

5. 构建 Android App：
   ```bash
   # 1. 构建移动端资源
   npm run build:app

   # 2. 同步资源到 Android 项目
   npx cap sync

   # 3. 打开 Android Studio 进行打包
   npx cap open android
   ```

## 🤝 支持与联系

如果您觉得本项目对您有帮助，欢迎请作者喝杯咖啡 ☕

| 微信支付 | 支付宝 | 联系作者 |
| :---: | :---: | :---: |
| ![微信支付](./documents/捐赠收款-微信.png) | ![支付宝](./documents/捐赠收款-支付宝.jpg) | ![联系作者](./documents/作者微信.png) |

## 🙏 特别鸣谢

本项目核心 Canvas 渲染引擎基于 [Leafer UI](https://www.leaferjs.com/) 开发。

感谢 [LeaferJS](https://github.com/leaferjs/ui) 团队提供如此优秀、高性能且易用的 Canvas 2D 渲染库。

- **Leafer UI 官网**: [https://www.leaferjs.com/](https://www.leaferjs.com/)
- **GitHub 仓库**: [https://github.com/leaferjs/ui](https://github.com/leaferjs/ui)

## 📄 许可证

MIT License
