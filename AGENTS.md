# Agent Guidelines for OMS Repository

## Build Commands

### Backend (C# .NET 10)
- Run: `cd backend/omsapi && dotnet run`
- Hot reload: `dotnet watch`
- Build: `dotnet build`

### Frontend PC (Vue 3 + TypeScript)
- Dev: `cd frontend && npm run dev`
- Build: `npm run build`
- Preview: `npm run preview`

### BigView (Data Visualization)
- Dev: `cd bigview && npm run dev`
- Build: `npm run build`
- Lint: `npm run lint` / `npm run lint:fix`
- New component: `npm run new`

### Frontend H5 (Mobile)
- Dev: `cd frontend.h5 && npm run dev`
- Build: `npm run build`

## Code Style Guidelines

### Backend (C#)
- Use async/await for all async operations
- Services use [AutoInject(ServiceLifetime.Scoped)] attribute
- Controllers return ApiResponse<T> wrapper
- XML comments on all public APIs
- ImplicitUsings enabled, nullable reference types enabled
- Controller naming: {Entity}Controller, Service: {Entity}Service
- DTO suffix for data transfer objects, Entity suffix for database entities

### Frontend (TypeScript/Vue 3)
- Single quotes, no semicolons, 2-space indentation (Prettier: 120 char width)
- Auto-import Vue APIs (ref, reactive, computed, watch, etc.) via unplugin-auto-import
- Auto-import Ant Design Vue components
- Component naming: PascalCase for files, PascalCase in templates
- Use script setup with lang="ts"
- Pinia stores use defineStore with Composition API
- API functions in src/api/{module}.ts using request utility from utils/request
- Error handling: use message.error() from ant-design-vue for user feedback
- Use @/ alias for src directory imports
- Types defined in src/types/ or alongside files

### Testing
- No test framework configured - verify changes manually

### Git Commits
- Follow conventional commits via commitlint: `type: description`
