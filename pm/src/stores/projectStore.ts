import { defineStore } from 'pinia'
import type { Phase, Swimlane, Task, ViewSettings, Attachment, TaskPort, TaskDependency, ProjectInfo } from '../types'
import { io, Socket } from 'socket.io-client'

let saveTimeout: any = null;

interface User {
  id?: number
  username: string
  name: string
  role: string
  color?: string
}

// Helper to generate consistent user color
const getUserColor = (str: string) => {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    const c = (hash & 0x00ffffff).toString(16).toUpperCase();
    return '#' + '00000'.substring(0, 6 - c.length) + c;
}

export const useProjectStore = defineStore('project', {
  state: () => ({
    // Auth
    currentUser: null as User | null,
    users: [] as User[],
    isAuthenticated: false,
    currentView: 'login' as 'login' | 'projectList' | 'projectDetail',
    projectList: [] as ProjectInfo[],
    
    // Project
    lastUpdate: 0,
    showProjectProperties: false,
    // State for remote user selections
    remoteSelections: {} as Record<string, { clientId: string, taskId: string, user: User }>,
    projectInfo: {
      code: 'PRJ-2024-001',
      name: '地铁车辆设计项目',
      type: '车辆工程',
      description: '地铁车辆全生命周期设计项目',
      manager: '张三',
      plannedStartDate: '2024-01-01',
      plannedEndDate: '2024-12-31'
    } as ProjectInfo,
    phases: [
      { id: 'p1', name: '概念设计阶段', color: '#E3F2FD' },
      { id: 'p2', name: '方案设计阶段', color: '#E8F5E9' },
      { id: 'p3', name: '详细设计阶段', color: '#FFF3E0' },
      { id: 'p4', name: '设计验证阶段', color: '#F3E5F5' },
    ] as Phase[],
    swimlanes: [
      { id: 'sl1', name: '项目管理', color: '#F5F5F5' },
      { id: 'sl2', name: '机械设计专业', color: '#E1F5FE' },
      { id: 'sl3', name: '电气设计专业', color: '#FFF3E0' },
      { id: 'sl4', name: '软件与控制专业', color: '#E8F5E9' },
      { id: 'sl5', name: '工业设计专业', color: '#F3E5F5' },
      { id: 'sl6', name: '系统集成与验证', color: '#EFEBE9' },
      { id: 'sl7', name: '质量管理', color: '#FFEBEE' },
    ] as Swimlane[],
    tasks: [
      // 概念设计阶段
      { 
        id: 't1_1', 
        name: '项目启动与需求分析', 
        phaseId: 'p1', 
        swimlaneId: 'sl1', 
        status: 'completed', 
        progress: 100, 
        owner: '项目经理', 
        startDate: '2024-01-01', 
        endDate: '2024-01-10', 
        dependencies: [], 
        type: 'task',
        attachments: [
          { id: 'a1', name: '项目章程.pdf', url: '#', type: 'pdf', uploadDate: '2024-01-02', uploader: '张三', size: '2.5MB' },
          { id: 'a2', name: '需求规格说明书_v1.0.docx', url: '#', type: 'doc', uploadDate: '2024-01-05', uploader: '李四', size: '1.2MB' }
        ],
        description: '项目启动与需求分析'
      },
      { 
        id: 't1_2', 
        name: '总体方案设计', 
        phaseId: 'p1', 
        swimlaneId: 'sl6', 
        status: 'completed', 
        progress: 100, 
        owner: '总工', 
        startDate: '2024-01-11', 
        endDate: '2024-01-25', 
        dependencies: ['t1_1'], 
        type: 'task',
        attachments: [
          { id: 'a3', name: '总体方案汇报.pptx', url: '#', type: 'ppt', uploadDate: '2024-01-20', uploader: '王五', size: '5.8MB' }
        ],
        description: '总体方案设计'
      },
      { id: 't1_3', name: '概念评审与冻结', phaseId: 'p1', swimlaneId: 'sl1', status: 'completed', progress: 100, owner: '项目经理', startDate: '2024-01-26', endDate: '2024-01-26', dependencies: ['t1_2'], type: 'milestone' },

      // 方案设计阶段 - 机械
      { id: 't2_1', name: '车体方案设计', phaseId: 'p2', swimlaneId: 'sl2', status: 'completed', progress: 100, owner: '张工', startDate: '2024-02-01', endDate: '2024-02-20', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_2', name: '转向架方案', phaseId: 'p2', swimlaneId: 'sl2', status: 'completed', progress: 100, owner: '陈工', startDate: '2024-02-01', endDate: '2024-02-25', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_3', name: '连接装置设计', phaseId: 'p2', swimlaneId: 'sl2', status: 'completed', progress: 100, owner: '王工', startDate: '2024-02-05', endDate: '2024-02-20', dependencies: ['t1_3'], type: 'task' },
      
      // 方案设计阶段 - 电气
      { id: 't2_4', name: '牵引系统方案', phaseId: 'p2', swimlaneId: 'sl3', status: 'in_progress', progress: 80, owner: '李工', startDate: '2024-02-01', endDate: '2024-02-28', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_5', name: '辅助供电系统', phaseId: 'p2', swimlaneId: 'sl3', status: 'in_progress', progress: 70, owner: '周工', startDate: '2024-02-05', endDate: '2024-02-25', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_6', name: '车载电气布置', phaseId: 'p2', swimlaneId: 'sl3', status: 'pending', progress: 0, owner: '吴工', startDate: '2024-02-10', endDate: '2024-03-01', dependencies: ['t1_3'], type: 'task' },

      // 方案设计阶段 - 软件
      { id: 't2_7', name: '网络控制系统方案', phaseId: 'p2', swimlaneId: 'sl4', status: 'in_progress', progress: 50, owner: '赵工', startDate: '2024-02-01', endDate: '2024-02-28', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_8', name: '车载软件框架', phaseId: 'p2', swimlaneId: 'sl4', status: 'pending', progress: 0, owner: '钱工', startDate: '2024-02-10', endDate: '2024-03-05', dependencies: ['t1_3'], type: 'task' },

      // 方案设计阶段 - 工业设计
      { id: 't2_9', name: '外观造型设计', phaseId: 'p2', swimlaneId: 'sl5', status: 'completed', progress: 100, owner: '孙工', startDate: '2024-02-01', endDate: '2024-02-20', dependencies: ['t1_3'], type: 'task' },
      { id: 't2_10', name: '内饰方案设计', phaseId: 'p2', swimlaneId: 'sl5', status: 'in_progress', progress: 60, owner: '郑工', startDate: '2024-02-15', endDate: '2024-03-10', dependencies: ['t1_3'], type: 'task' },

      // 详细设计阶段 - 机械
      { id: 't3_1', name: '车体详细设计', phaseId: 'p3', swimlaneId: 'sl2', status: 'pending', progress: 0, owner: '张工', startDate: '2024-03-01', endDate: '2024-04-30', dependencies: ['t2_1'], type: 'task' },
      { id: 't3_2', name: '转向架详细设计', phaseId: 'p3', swimlaneId: 'sl2', status: 'pending', progress: 0, owner: '陈工', startDate: '2024-03-01', endDate: '2024-05-15', dependencies: ['t2_2'], type: 'task' },
      { id: 't3_3', name: '内装详细设计', phaseId: 'p3', swimlaneId: 'sl2', status: 'pending', progress: 0, owner: '郑工', startDate: '2024-03-15', endDate: '2024-05-01', dependencies: ['t2_10'], type: 'task' },

      // 详细设计阶段 - 电气
      { id: 't3_4', name: '电气原理设计', phaseId: 'p3', swimlaneId: 'sl3', status: 'pending', progress: 0, owner: '李工', startDate: '2024-03-01', endDate: '2024-04-15', dependencies: ['t2_4'], type: 'task' },
      { id: 't3_5', name: '线束设计', phaseId: 'p3', swimlaneId: 'sl3', status: 'pending', progress: 0, owner: '吴工', startDate: '2024-03-15', endDate: '2024-05-01', dependencies: ['t2_6'], type: 'task' },
      { id: 't3_6', name: '电气柜详细设计', phaseId: 'p3', swimlaneId: 'sl3', status: 'pending', progress: 0, owner: '周工', startDate: '2024-03-10', endDate: '2024-04-30', dependencies: ['t2_6'], type: 'task' },

      // 详细设计阶段 - 软件
      { id: 't3_7', name: '软件模块设计', phaseId: 'p3', swimlaneId: 'sl4', status: 'pending', progress: 0, owner: '钱工', startDate: '2024-03-10', endDate: '2024-05-20', dependencies: ['t2_8'], type: 'task' },
      { id: 't3_8', name: 'HMI界面设计', phaseId: 'p3', swimlaneId: 'sl4', status: 'pending', progress: 0, owner: '孙工', startDate: '2024-03-15', endDate: '2024-05-01', dependencies: ['t2_8'], type: 'task' },
      { id: 't3_9', name: '通信协议实现', phaseId: 'p3', swimlaneId: 'sl4', status: 'pending', progress: 0, owner: '赵工', startDate: '2024-03-05', endDate: '2024-04-20', dependencies: ['t2_7'], type: 'task' },

      // 详细设计阶段 - 系统集成
      { id: 't3_10', name: '机电接口设计', phaseId: 'p3', swimlaneId: 'sl6', status: 'pending', progress: 0, owner: '总工', startDate: '2024-03-01', endDate: '2024-04-01', dependencies: ['t2_1', 't2_4'], type: 'task' },
      { id: 't3_11', name: 'BOM清单编制', phaseId: 'p3', swimlaneId: 'sl6', status: 'pending', progress: 0, owner: '管理员', startDate: '2024-05-01', endDate: '2024-05-30', dependencies: ['t3_1', 't3_4'], type: 'task' },

      // 设计验证阶段
      { id: 't4_1', name: '仿真分析验证', phaseId: 'p4', swimlaneId: 'sl6', status: 'pending', progress: 0, owner: '仿真组', startDate: '2024-06-01', endDate: '2024-07-01', dependencies: ['t3_1', 't3_4'], type: 'task' },
      { id: 't4_2', name: '设计评审', phaseId: 'p4', swimlaneId: 'sl7', status: 'pending', progress: 0, owner: '质量部', startDate: '2024-07-05', endDate: '2024-07-10', dependencies: ['t4_1'], type: 'task' },
      { id: 't4_3', name: '试验大纲编制', phaseId: 'p4', swimlaneId: 'sl6', status: 'pending', progress: 0, owner: '测试组', startDate: '2024-06-15', endDate: '2024-06-30', dependencies: ['t4_1'], type: 'task' },
      { id: 't4_4', name: '原型车试验', phaseId: 'p4', swimlaneId: 'sl6', status: 'pending', progress: 0, owner: '测试组', startDate: '2024-07-15', endDate: '2024-08-30', dependencies: ['t4_3'], type: 'task' },
      { id: 't4_5', name: '问题整改', phaseId: 'p4', swimlaneId: 'sl7', status: 'pending', progress: 0, owner: '各专业', startDate: '2024-09-01', endDate: '2024-09-15', dependencies: ['t4_4'], type: 'task' },
      { id: 't4_6', name: '设计冻结', phaseId: 'p4', swimlaneId: 'sl1', status: 'pending', progress: 0, owner: '项目经理', startDate: '2024-09-20', endDate: '2024-09-20', dependencies: ['t4_5'], type: 'milestone' },
    ] as Task[],
    socket: null as Socket | null,
    viewSettings: {
      zoomLevel: 1,
      showDependencies: true,
      filterOwner: '',
      filterStatuses: [],
      filterPhases: [],
      filterSwimlanes: [],
      resetViewTrigger: 0,
      fitViewTrigger: 0,
    } as ViewSettings,
    selectedElement: null as { type: 'task' | 'phase' | 'swimlane' | 'dependency' | 'port', id: string, taskId?: string } | null,
    exportImageHandler: null as null | (() => Promise<void> | void),
    copyImageHandler: null as (() => void) | null,
    saveStatus: 'saved' as 'saved' | 'saving' | 'error' | 'synced',
    lastSaveTime: null as Date | null,
    lastSyncTime: null as Date | null,
    lastSyncUser: null as string | null,
    collaborators: {} as Record<string, { x: number, y: number, name: string, color: string, lastActive: number }>,
    clientId: Math.random().toString(36).substring(2, 15), // Unique ID for this browser tab/window
  }),
  actions: {
    updateCollaboratorCursor(clientId: string, x: number, y: number, user: any) {
        // Use provided color or generate one
        const color = user.color || getUserColor(user.username || 'anon');

        this.collaborators[clientId] = {
            x,
            y,
            name: user.name || user.username,
            color,
            lastActive: Date.now()
        };
    },
    removeInactiveCollaborators() {
        const now = Date.now();
        const timeout = 10000; // 10 seconds
        for (const [id, collaborator] of Object.entries(this.collaborators)) {
            if (now - collaborator.lastActive > timeout) {
                delete this.collaborators[id];
            }
        }
    },
    emitCursorMove(x: number, y: number) {
        if (this.socket && this.projectInfo.code) {
             // Throttling could be handled here or in the component. 
             // Component side is better for performance (requestAnimationFrame).
             // But let's just emit here.
             this.socket.emit('cursor_move', {
                 projectId: this.projectInfo.code,
                 x, 
                 y,
                 user: this.currentUser,
                 clientId: this.clientId
             });
        }
    },
    setExportImageHandler(handler: () => Promise<void> | void) {
      this.exportImageHandler = handler
    },
    setCopyImageHandler(handler: () => void) {
      this.copyImageHandler = handler
    },
    resetView() {
      this.viewSettings.zoomLevel = 1
      this.viewSettings.resetViewTrigger = (this.viewSettings.resetViewTrigger || 0) + 1
    },
    fitView() {
      this.viewSettings.fitViewTrigger = (this.viewSettings.fitViewTrigger || 0) + 1
    },
    newProject() {
      this.projectInfo = {
        code: 'NEW-PROJECT',
        name: '新项目',
        type: '通用',
        description: '',
        manager: '',
        plannedStartDate: new Date().toISOString().split('T')[0],
        plannedEndDate: ''
      }
      this.phases = [
        { id: 'p1', name: '阶段1', color: '#E3F2FD' }
      ]
      this.swimlanes = [
        { id: 'sl1', name: '专业1', color: '#F5F5F5' }
      ]
      this.tasks = []
      this.selectedElement = null
      this.viewSettings.zoomLevel = 1
      this.viewSettings.filterStatuses = []
      this.viewSettings.filterPhases = []
      this.viewSettings.filterSwimlanes = []
      this.resetView()
    },
    updateProjectInfo(info: Partial<ProjectInfo>, emitEvent = true) {
      Object.assign(this.projectInfo, info)
      this.triggerAutoSave()
      if (emitEvent && this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'update_project_info',
          payload: info,
          user: this.currentUser
        })
      }
    },
    addPhase(phase: Phase, emitEvent = true) {
      this.phases.push(phase)
      this.triggerAutoSave()
      if (emitEvent && this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'add_phase',
          payload: phase,
          user: this.currentUser
        })
      }
    },
    updatePhase(phase: Phase, emitEvent = true) {
      const index = this.phases.findIndex(p => p.id === phase.id)
      if (index !== -1) {
        this.phases[index] = phase
        this.triggerAutoSave()
        if (emitEvent && this.socket && this.projectInfo.code) {
          this.socket.emit('project_action', {
            projectId: this.projectInfo.code,
            action: 'update_phase',
            payload: phase,
            user: this.currentUser
          })
        }
      }
    },
    deletePhase(id: string, emitEvent = true) {
      this.phases = this.phases.filter(p => p.id !== id)
      // Also delete tasks in this phase?
      this.tasks = this.tasks.filter(t => t.phaseId !== id)
      this.triggerAutoSave()
      if (emitEvent && this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'delete_phase',
          payload: { id },
          user: this.currentUser
        })
      }
    },

    addSwimlane(swimlane: Swimlane, emitEvent = true) {
      this.swimlanes.push(swimlane)
      this.triggerAutoSave()
      if (emitEvent && this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'add_swimlane',
          payload: swimlane,
          user: this.currentUser
        })
      }
    },
    updateSwimlane(swimlane: Swimlane, emitEvent = true) {
      const index = this.swimlanes.findIndex(s => s.id === swimlane.id)
      if (index !== -1) {
        this.swimlanes[index] = swimlane
        this.triggerAutoSave()
        if (emitEvent && this.socket && this.projectInfo.code) {
          this.socket.emit('project_action', {
            projectId: this.projectInfo.code,
            action: 'update_swimlane',
            payload: swimlane,
            user: this.currentUser
          })
        }
      }
    },
    deleteSwimlane(id: string, emitEvent = true) {
      this.swimlanes = this.swimlanes.filter(s => s.id !== id)
      this.tasks = this.tasks.filter(t => t.swimlaneId !== id)
      this.triggerAutoSave()
      if (emitEvent && this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'delete_swimlane',
          payload: { id },
          user: this.currentUser
        })
      }
    },

    triggerUpdate() {
      this.lastUpdate = Date.now()
    },

    triggerAutoSave() {
      if (!this.projectInfo.code) return;
      this.saveStatus = 'saving';
      if (saveTimeout) clearTimeout(saveTimeout);
      saveTimeout = setTimeout(() => {
        this.saveProjectToServer(this.projectInfo.code);
      }, 1000);
    },

    addTask(task: Task) {
      this.tasks.push(task)
      this.triggerUpdate()
      this.triggerAutoSave()
      if (this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'add_task',
          payload: task,
          user: this.currentUser
        })
      }
    },
    updateTask(id: string, updates: Partial<Task>, emitEvent = true) {
      const task = this.tasks.find(t => t.id === id)
      if (task) {
        console.log(`Updating task ${id} with`, updates);
        Object.assign(task, updates)
        this.triggerUpdate()
        this.triggerAutoSave()
        if (emitEvent && this.socket && this.projectInfo.code) {
          this.socket.emit('project_action', {
            projectId: this.projectInfo.code,
            action: 'update_task',
            payload: task,
            user: this.currentUser
          })
        }
      }
    },


    updateDependencyControlPoints(taskId: string, depTaskId: string, controlPoints: { x: number, y: number }[], controlPointCount?: number, type?: 'straight' | 'polyline' | 'curve', sourcePort?: string, targetPort?: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const depIndex = task.dependencies.findIndex(d => 
          (typeof d === 'string' ? d : d.taskId) === depTaskId
        )
        
        if (depIndex !== -1) {
          const currentDep = task.dependencies[depIndex]
          let newDep: TaskDependency;
          
          if (typeof currentDep === 'string') {
             newDep = {
               taskId: depTaskId,
               controlPoints,
               controlPointCount,
               type: type || 'polyline',
               sourcePort,
               targetPort
             }
          } else {
             const depObj = currentDep as TaskDependency
             newDep = {
               ...depObj,
               controlPoints,
               controlPointCount,
               type: type || depObj.type || 'polyline'
             };
             if (sourcePort) newDep.sourcePort = sourcePort;
             if (targetPort) newDep.targetPort = targetPort;
          }
          
          const newDeps = [...task.dependencies];
          newDeps[depIndex] = newDep;
          this.updateTask(taskId, { dependencies: newDeps });
        }
      }
    },
    batchUpdateTaskPositions(updates: {id: string, x: number, y: number, autoPositioned?: boolean}[], emitEvent: boolean = true) {
        updates.forEach(update => {
            const task = this.tasks.find(t => t.id === update.id)
            if (task) {
                task.x = update.x
                task.y = update.y
                if (update.autoPositioned !== undefined) {
                  task.autoPositioned = update.autoPositioned
                }
            }
        })
        this.triggerUpdate()
        this.triggerAutoSave()
        if (emitEvent && this.socket && this.projectInfo.code) {
          this.socket.emit('project_action', {
            projectId: this.projectInfo.code,
            action: 'batch_update_task_positions',
            payload: updates,
            user: this.currentUser
          })
        }
    },

    exportProjectData() {
      const data = {
        projectInfo: this.projectInfo,
        phases: this.phases,
        swimlanes: this.swimlanes,
        tasks: this.tasks
      }
      return JSON.stringify(data, null, 2)
    },

    importProjectData(jsonStr: string) {
      try {
        const data = JSON.parse(jsonStr)
        if (data.projectInfo && data.phases && data.swimlanes && data.tasks) {
          // Keep the current project ID if it exists (user is inside a project)
          const currentCode = this.projectInfo.code;

          this.projectInfo = data.projectInfo
          this.phases = data.phases
          this.swimlanes = data.swimlanes
          this.tasks = data.tasks
          
          // Restore the project ID if we were already in a project
          if (currentCode) {
              this.projectInfo.code = currentCode;
          }
          
          // Reset selection to avoid issues with missing IDs
          this.selectedElement = null
          
          return true
        }
        return false
      } catch (e) {
        console.error('Failed to parse project data', e)
        return false
      }
    },

    deleteTask(id: string) {
      this.tasks = this.tasks.filter(t => t.id !== id)
      this.triggerAutoSave()
      if (this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'delete_task',
          payload: { id },
          user: this.currentUser
        })
      }
    },
    moveTask(taskId: string, phaseId: string, swimlaneId: string) {
      this.updateTask(taskId, { phaseId, swimlaneId })
    },
    reorderTask(taskId: string, _newIndex: number, phaseId: string, swimlaneId: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (!task) return

      // Remove task from list
      const otherTasks = this.tasks.filter(t => t.id !== taskId)
      
      // Update task info
      task.phaseId = phaseId
      task.swimlaneId = swimlaneId
      
      // Insert at new index
      // Filter tasks in target cell to find insertion point
      // This logic is complex for global list, simplified:
      // Just put it at the end for now or implement complex reordering if needed
      this.tasks = [...otherTasks, task]
      
      this.triggerAutoSave()
      if (this.socket && this.projectInfo.code) {
        this.socket.emit('project_action', {
          projectId: this.projectInfo.code,
          action: 'update_task',
          payload: task,
          user: this.currentUser
        })
      }
    },

    addDependency(sourceId: string, targetId: string, sourcePort?: string, targetPort?: string) {
      const targetTask = this.tasks.find(t => t.id === targetId)
      if (targetTask) {
        // Check if dependency already exists
        const existingDep = targetTask.dependencies.find(dep => {
            const depId = typeof dep === 'string' ? dep : dep.taskId;
            return depId === sourceId;
        });

        if (!existingDep && sourceId !== targetId) {
            // Prevent cycles (simple check)
            if (!this.checkCycle(sourceId, targetId)) {
               const newDeps = [...targetTask.dependencies];
               if (sourcePort || targetPort) {
                   newDeps.push({
                       taskId: sourceId,
                       type: 'curve',
                       sourcePort,
                       targetPort
                   });
               } else {
                   newDeps.push(sourceId);
               }
               this.updateTask(targetId, { dependencies: newDeps });
            } else {
               throw new Error('无法创建依赖：会导致循环依赖')
            }
        }
      }
    },

    removeDependency(sourceId: string, targetId: string) {
      const targetTask = this.tasks.find(t => t.id === targetId)
      if (targetTask) {
        const newDeps = targetTask.dependencies.filter(dep => {
            const depId = typeof dep === 'string' ? dep : dep.taskId
            return depId !== sourceId
        })
        this.updateTask(targetId, { dependencies: newDeps })
      }
    },
    
    checkCycle(sourceId: string, targetId: string): boolean {
       // Check if adding source->target creates a cycle
       // Meaning: Is there already a path from target to source?
       const visited = new Set<string>()
       const stack = [sourceId]
       
       while (stack.length > 0) {
         const current = stack.pop()!
         if (current === targetId) return true
         if (visited.has(current)) continue
         visited.add(current)
         
         const task = this.tasks.find(t => t.id === current)
         if (task) {
           // Find tasks that depend on 'current' (reverse dependency)
           // Actually, 'task.dependencies' are parents. 
           // We are looking for children.
           // If we add source->target, we have path source->target.
           // Cycle exists if path target->...->source exists.
           // So we trace dependencies of 'source' to see if 'target' is one of them (ancestor).
         }
       }
       
       // Correct logic:
       // We want to add Dependency: Target depends on Source (Source -> Target).
       // Cycle happens if Source already depends on Target (Target -> ... -> Source).
       // So we check if Target is an ancestor of Source.
       
       return this.isAncestor(targetId, sourceId)
    },
    
    isAncestor(ancestorId: string, taskId: string): boolean {
       const task = this.tasks.find(t => t.id === taskId)
       if (!task) return false
       
       const depIds = task.dependencies.map(d => typeof d === 'string' ? d : d.taskId)
       if (depIds.includes(ancestorId)) return true
       
       for (const depId of depIds) {
         if (this.isAncestor(ancestorId, depId)) return true
       }
       
       return false
    },

    selectElement(type: 'task' | 'phase' | 'swimlane' | 'dependency' | 'port', id: string, taskId?: string) {
      this.selectedElement = { type, id, taskId }
      if (type === 'task' && this.socket && this.projectInfo.code) {
          console.log(`Emitting element_selected: ${id} (${type})`);
          this.socket.emit('element_selected', {
              projectId: this.projectInfo.code,
              clientId: this.clientId,
              type,
              id,
              user: this.currentUser
          });
      }
    },
    removeTaskPort(taskId: string, portId: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task && task.ports) {
        // 1. Remove port from task
        task.ports = task.ports.filter(p => p.id !== portId)
        
        // 2. Cleanup dependencies where this task is the TARGET (incoming lines)
        // We need to clear 'targetPort' if it matches portId
        task.dependencies = task.dependencies.map(dep => {
            if (typeof dep === 'string') return dep
            if (dep.targetPort === portId) {
                const { targetPort, ...rest } = dep
                return rest as TaskDependency
            }
            return dep
        })

        // 3. Cleanup dependencies where this task is the SOURCE (outgoing lines)
        this.tasks.forEach(t => {
            t.dependencies = t.dependencies.map(dep => {
                const depTaskId = typeof dep === 'string' ? dep : dep.taskId
                if (depTaskId === taskId) {
                    if (typeof dep !== 'string' && dep.sourcePort === portId) {
                         const { sourcePort, ...rest } = dep
                         return rest as TaskDependency
                    }
                }
                return dep
            })
        })
      }
    },
    batchUpdateDependencyPorts(updates: { taskId: string, depTaskId: string, sourcePort: string, targetPort: string }[]) {
      updates.forEach(update => {
        const { taskId, depTaskId, sourcePort, targetPort } = update;
        const task = this.tasks.find(t => t.id === taskId);
        if (task) {
          const depIndex = task.dependencies.findIndex(d => 
            (typeof d === 'string' ? d : d.taskId) === depTaskId
          );
          
          if (depIndex !== -1) {
             const existingDep = task.dependencies[depIndex];
             // Convert string dep to object if needed, or update existing object
             if (typeof existingDep === 'string') {
                 task.dependencies[depIndex] = {
                     taskId: existingDep,
                     sourcePort,
                     targetPort
                 };
             } else if (existingDep) {
                 // Update only if ports are changed to avoid infinite loops
                 if (existingDep.sourcePort !== sourcePort || existingDep.targetPort !== targetPort) {
                     const newDep: TaskDependency = {
                         ...existingDep,
                         sourcePort,
                         targetPort
                     };
                     // Explicitly preserve controlPoints and type to prevent data loss
                     if (existingDep.controlPoints) {
                         newDep.controlPoints = existingDep.controlPoints;
                         newDep.controlPointCount = existingDep.controlPointCount;
                     }
                     if (existingDep.type) {
                         newDep.type = existingDep.type;
                     }
                     task.dependencies[depIndex] = newDep;
                 }
             }
          }
        }
      });
    },
    clearSelection() {
      this.selectedElement = null
      if (this.socket && this.projectInfo.code) {
          this.socket.emit('element_selected', {
              projectId: this.projectInfo.code,
              clientId: this.clientId,
              type: null,
              id: null,
              user: this.currentUser
          });
      }
    },
    setZoom(level: number) {
      this.viewSettings.zoomLevel = level
    },
    addAttachment(taskId: string, attachment: Attachment) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        if (!task.attachments) task.attachments = []
        task.attachments.push(attachment)
        this.updateTask(taskId, { attachments: [...task.attachments] })
      }
    },
    removeAttachment(taskId: string, attachmentId: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task && task.attachments) {
        const newAttachments = task.attachments.filter(a => a.id !== attachmentId)
        this.updateTask(taskId, { attachments: newAttachments })
      }
    },
    updateTaskDates(taskId: string, start: string, end: string) {
      this.updateTask(taskId, { startDate: start, endDate: end })
    },
    addTaskPort(taskId: string, port: TaskPort) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        if (!task.ports) task.ports = []
        task.ports.push(port)
        this.updateTask(taskId, { ports: [...task.ports] })
      }
    },
    updateTaskPort(taskId: string, portId: string, percentage: number) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task && task.ports) {
        const portIndex = task.ports.findIndex(p => p.id === portId)
        if (portIndex !== -1) {
            const newPorts = [...task.ports]
            const existingPort = newPorts[portIndex]
            if (existingPort) {
              newPorts[portIndex] = { ...existingPort, percentage }
              this.updateTask(taskId, { ports: newPorts })
            }
        }
      }
    },
    updateDependencyPort(taskId: string, depTaskId: string, type: 'source' | 'target', port: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        // Find the dependency entry
        const depIndex = task.dependencies.findIndex(d => 
          (typeof d === 'string' ? d : d.taskId) === depTaskId
        )
        
        if (depIndex !== -1) {
          const currentDep = task.dependencies[depIndex]
          let newDep: TaskDependency
          
          if (typeof currentDep === 'string') {
            // Convert to object
            newDep = {
              taskId: depTaskId,
              [type === 'source' ? 'sourcePort' : 'targetPort']: port
            }
          } else {
            // Update existing object
            const depObj = currentDep as TaskDependency
            newDep = {
                ...depObj
            }
            if (type === 'source') {
              newDep.sourcePort = port
            } else {
              newDep.targetPort = port
            }
          }
          const newDeps = [...task.dependencies]
          newDeps[depIndex] = newDep
          this.updateTask(taskId, { dependencies: newDeps })
        }
      }
    },
    changeDependencySource(taskId: string, oldSourceId: string, newSourceId: string, newPort?: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (!task) return

      // Prevent self-dependency
      if (taskId === newSourceId) return

      // Prevent duplicates
      const exists = task.dependencies.some(d => (typeof d === 'string' ? d : d.taskId) === newSourceId)
      if (exists) return // Or maybe merge?

      // Find index
      const idx = task.dependencies.findIndex(d => (typeof d === 'string' ? d : d.taskId) === oldSourceId)
      if (idx !== -1) {
        const oldDep = task.dependencies[idx]
        let newDep: TaskDependency
        if (typeof oldDep === 'string') {
          newDep = { taskId: newSourceId }
          if (newPort) newDep.sourcePort = newPort
        } else {
          newDep = { ...oldDep, taskId: newSourceId }
          if (newPort) newDep.sourcePort = newPort
        }
        const newDeps = [...task.dependencies]
        newDeps[idx] = newDep
        this.updateTask(taskId, { dependencies: newDeps })
      }
    },
    moveDependencyTarget(oldTargetId: string, newTargetId: string, sourceId: string, newPort?: string) {
      const oldTask = this.tasks.find(t => t.id === oldTargetId)
      const newTask = this.tasks.find(t => t.id === newTargetId)
      if (!oldTask || !newTask) return

      // Prevent self-dependency
      if (newTargetId === sourceId) return

      // Remove from old
      const idx = oldTask.dependencies.findIndex(d => (typeof d === 'string' ? d : d.taskId) === sourceId)
      if (idx === -1) return
      
      const oldDep = oldTask.dependencies[idx]
      // oldTask.dependencies.splice(idx, 1) // Do not mutate directly
      const oldDeps = oldTask.dependencies.filter((_, i) => i !== idx)
      this.updateTask(oldTargetId, { dependencies: oldDeps })

      // Add to new (check duplicate)
      const exists = newTask.dependencies.some(d => (typeof d === 'string' ? d : d.taskId) === sourceId)
      if (!exists) {
        let newDep: TaskDependency
        if (typeof oldDep === 'string') {
          newDep = { taskId: sourceId }
          if (newPort) newDep.targetPort = newPort
        } else {
          newDep = { ...oldDep, taskId: sourceId } as TaskDependency // Keep sourcePort if any
          if (newPort) newDep.targetPort = newPort
        }
        // newTask.dependencies.push(newDep)
        const newDeps = [...newTask.dependencies, newDep]
        this.updateTask(newTargetId, { dependencies: newDeps })
      }
    },
    updateDependencyControlPointCount(taskId: string, depTaskId: string, count: number) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const depIndex = task.dependencies.findIndex(d => 
          (typeof d === 'string' ? d : d.taskId) === depTaskId
        )
        
        if (depIndex !== -1) {
          const currentDep = task.dependencies[depIndex]
          let newDep: TaskDependency
          
          if (typeof currentDep === 'string') {
             newDep = {
               taskId: depTaskId,
               controlPointCount: count,
               type: 'curve'
             }
          } else {
             const depObj = currentDep as TaskDependency
             newDep = {
               ...depObj,
               controlPointCount: count
             };
          }
          const newDeps = [...task.dependencies]
          newDeps[depIndex] = newDep
          this.updateTask(taskId, { dependencies: newDeps })
        }
      }
    },
    
    updateDependencyType(taskId: string, depTaskId: string, type: 'straight' | 'polyline' | 'curve') {
        const task = this.tasks.find(t => t.id === taskId)
        if (task) {
          const depIndex = task.dependencies.findIndex(d => 
            (typeof d === 'string' ? d : d.taskId) === depTaskId
          )
          
          if (depIndex !== -1) {
            const currentDep = task.dependencies[depIndex]
            let newDep: TaskDependency

            if (typeof currentDep === 'string') {
               newDep = {
                 taskId: depTaskId,
                 type: type
               }
            } else {
               const depObj = currentDep as TaskDependency
               newDep = {
                 ...depObj,
                 type: type
               };
            }
            const newDeps = [...task.dependencies]
            newDeps[depIndex] = newDep
            this.updateTask(taskId, { dependencies: newDeps })
          }
        }
    },

    // Add socket initialization
    initSocket() {
        if (!this.currentUser) return;
        
        // Connect to same host as page
        this.socket = io({
            path: '/socket.io'
        });

        this.socket.on('connect', () => {
            console.log('Socket connected');
            if (this.projectInfo.code && this.currentUser) {
                this.socket?.emit('join_project', { 
                    projectId: this.projectInfo.code,
                    user: this.currentUser,
                    clientId: this.clientId
                });
            }
        });

        this.socket.on('project_action', ({ action, payload, user }) => {
            console.log('Received action:', action, payload);
            // Allow syncing from same user (different window/session)
            // if (user.username === this.currentUser?.username) return; 

            // Update sync status
            this.saveStatus = 'synced';
            this.lastSyncTime = new Date();
            this.lastSyncUser = user.name || user.username;
            
            // Ensure UI updates
            this.triggerUpdate();

            switch (action) {
                case 'update_task':
                    if (payload && payload.id) {
                        this.updateTask(payload.id, payload, false); // Don't re-emit
                    }
                    break;
                case 'add_task':
                    if (payload && payload.id) {
                        // Check if exists
                        if (!this.tasks.find(t => t.id === payload.id)) {
                             this.tasks.push(payload)
                        }
                    }
                    break;
                case 'delete_task':
                    if (payload && payload.id) {
                        this.tasks = this.tasks.filter(t => t.id !== payload.id)
                    }
                    break;
                case 'batch_update_task_positions':
                    if (Array.isArray(payload)) {
                        this.batchUpdateTaskPositions(payload, false)
                    }
                    break;
                case 'update_project_info':
                    if (payload) {
                        this.updateProjectInfo(payload, false)
                    }
                    break;
                case 'add_phase':
                    if (payload && payload.id) {
                        if (!this.phases.find(p => p.id === payload.id)) {
                            this.phases.push(payload)
                        }
                    }
                    break;
                case 'update_phase':
                    if (payload && payload.id) {
                        this.updatePhase(payload, false)
                    }
                    break;
                case 'delete_phase':
                    if (payload && payload.id) {
                        this.deletePhase(payload.id, false)
                    }
                    break;
                case 'add_swimlane':
                    if (payload && payload.id) {
                        if (!this.swimlanes.find(s => s.id === payload.id)) {
                            this.swimlanes.push(payload)
                        }
                    }
                    break;
                case 'update_swimlane':
                    if (payload && payload.id) {
                        this.updateSwimlane(payload, false)
                    }
                    break;
                case 'delete_swimlane':
                    if (payload && payload.id) {
                        this.deleteSwimlane(payload.id, false)
                    }
                    break;
            }
        });
        
        this.socket.on('user_joined', ({ user }) => {
            console.log(`User ${user.name} joined`);
            // Could show a notification
        });

        this.socket.on('element_selected', ({ clientId, type, id, user }) => {
            console.log('Received element_selected:', { clientId, type, id, user, myClientId: this.clientId });
            if (clientId === this.clientId) return; // Ignore self
            
            const key = clientId || user.username;
            if (type === 'task' && id) {
                console.log(`Setting remote selection for ${user.name}: ${id}`);
                // Ensure user has a color
                if (!user.color) {
                    user.color = getUserColor(user.username || 'anon');
                }
                this.remoteSelections[key] = { clientId, taskId: id, user };
            } else {
                console.log(`Clearing remote selection for ${user.name}`);
                delete this.remoteSelections[key];
            }
            this.triggerUpdate();
        });

        this.socket.on('user_left', ({ user, clientId }) => {
            console.log(`User ${user.name} left`);
            const key = clientId || user.username;
            delete this.collaborators[key];
            delete this.remoteSelections[key];
            this.triggerUpdate();
        });

        this.socket.on('cursor_move', ({ x, y, user, clientId }) => {
            // Filter out events from this specific client instance
            if (clientId === this.clientId) return; 
            
            // Use clientId as key to support multiple tabs/windows for same user
            const key = clientId || user.username;
            this.updateCollaboratorCursor(key, x, y, user);
        });

        // Start cleanup interval
        setInterval(() => {
            this.removeInactiveCollaborators();
        }, 1000);
    },

    // Helper to get auth headers
    getAuthHeaders(): Record<string, string> {
        const token = localStorage.getItem('token');
        return token ? { 'Authorization': `Bearer ${token}` } : {};
    },

    async login(username: string, password: string) {
        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username, password })
            });
            const data = await response.json();
            if (data.success) {
                this.currentUser = data.user;
                if (this.currentUser && !this.currentUser.color) {
                    this.currentUser.color = getUserColor(this.currentUser.username);
                }
                this.isAuthenticated = true;
                this.currentView = 'projectList';
                localStorage.setItem('user', JSON.stringify(data.user));
                // Store JWT token
                if (data.token) {
                    localStorage.setItem('token', data.token);
                }
                await this.fetchProjects();
                return true;
            }
            return false;
        } catch (e) {
            console.error('Login error', e);
            return false;
        }
    },

    logout() {
        this.currentUser = null;
        this.isAuthenticated = false;
        this.currentView = 'login';
        this.projectInfo = { code: '' } as ProjectInfo; // Reset project info
        this.tasks = [];
        this.socket?.disconnect();
        this.socket = null;
        localStorage.removeItem('user');
        localStorage.removeItem('token');
    },

    checkAuth() {
        const userStr = localStorage.getItem('user');
        if (userStr) {
            try {
                this.currentUser = JSON.parse(userStr);
                if (this.currentUser && !this.currentUser.color) {
                    this.currentUser.color = getUserColor(this.currentUser.username);
                }
                this.isAuthenticated = true;
                this.currentView = 'projectList';
                this.fetchProjects();
            } catch (e) {
                console.error('Failed to parse user from localStorage');
                localStorage.removeItem('user');
                localStorage.removeItem('token');
            }
        }
    },

    async fetchProjects() {
        try {
            const response = await fetch('/api/projects');
            if (response.ok) {
                this.projectList = await response.json();
            }
        } catch (e) {
            console.error('Failed to fetch projects', e);
        }
    },

    async createProject(project: ProjectInfo) {
        // Init with default structure
        const phases = [
             { id: 'p1', name: '概念设计阶段', color: '#E3F2FD' },
             { id: 'p2', name: '方案设计阶段', color: '#E8F5E9' },
             { id: 'p3', name: '详细设计阶段', color: '#FFF3E0' },
             { id: 'p4', name: '设计验证阶段', color: '#F3E5F5' },
        ];
        const swimlanes = [
             { id: 'sl1', name: '项目管理', color: '#F5F5F5' },
             { id: 'sl2', name: '机械设计专业', color: '#E1F5FE' },
             { id: 'sl3', name: '电气设计专业', color: '#FFF3E0' },
             { id: 'sl4', name: '软件与控制专业', color: '#E8F5E9' },
             { id: 'sl5', name: '工业设计专业', color: '#F3E5F5' },
             { id: 'sl6', name: '系统集成与验证', color: '#EFEBE9' },
             { id: 'sl7', name: '质量管理', color: '#FFEBEE' },
        ];

        try {
            const response = await fetch(`/api/project/${project.code}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    projectInfo: project,
                    phases,
                    swimlanes,
                    tasks: []
                })
            });
            return response.ok;
        } catch (e) {
            console.error('Create project error', e);
            return false;
        }
    },

    async fetchUsers() {
        if (!this.currentUser) return [];
        try {
            const response = await fetch('/api/users', {
                headers: this.getAuthHeaders()
            });
            if (response.status === 401 || response.status === 403) {
                this.logout();
                return [];
            }
            return await response.json();
        } catch (e) {
            console.error('Fetch users error', e);
            return [];
        }
    },

    async fetchSelectableUsers() {
        if (!this.currentUser) return;
        try {
            const response = await fetch('/api/selectable-users', {
                headers: this.getAuthHeaders()
            });
            if (response.ok) {
                this.users = await response.json();
            } else if (response.status === 401 || response.status === 403) {
                this.logout();
            }
        } catch (e) {
            console.error('Fetch selectable users error', e);
        }
    },

    async createUser(user: any) {
        if (!this.currentUser) return false;
        try {
            const response = await fetch('/api/user', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    ...this.getAuthHeaders()
                },
                body: JSON.stringify(user)
            });
            if (response.status === 401 || response.status === 403) {
                this.logout();
                return false;
            }
            return response.ok;
        } catch (e) {
            console.error('Create user error', e);
            return false;
        }
    },

    async updateUser(id: number, user: any) {
        if (!this.currentUser) return false;
        try {
            const response = await fetch(`/api/user/${id}`, {
                method: 'PUT',
                headers: { 
                    'Content-Type': 'application/json',
                    ...this.getAuthHeaders()
                },
                body: JSON.stringify(user)
            });
            if (response.status === 401 || response.status === 403) {
                this.logout();
                return false;
            }
            return response.ok;
        } catch (e) {
            console.error('Update user error', e);
            return false;
        }
    },

    async deleteUser(id: number) {
        if (!this.currentUser) return false;
        try {
            const response = await fetch(`/api/user/${id}`, {
                method: 'DELETE',
                headers: this.getAuthHeaders()
            });
            if (response.status === 401 || response.status === 403) {
                this.logout();
                return false;
            }
            return response.ok;
        } catch (e) {
            console.error('Delete user error', e);
            return false;
        }
    },

    async changePassword(oldPassword: string, newPassword: string) {
        if (!this.currentUser) return false;
        try {
            const response = await fetch(`/api/user/password`, {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    ...this.getAuthHeaders()
                },
                body: JSON.stringify({
                    id: this.currentUser.id,
                    username: this.currentUser.username,
                    oldPassword,
                    newPassword
                })
            });
            
            if (response.status === 401 || response.status === 403) {
                this.logout();
                return false;
            }

            const data = await response.json();
            if (data.success) {
                // If password changed successfully, logout to force re-login with new password
                this.logout();
            }
            return data.success;
        } catch (e) {
            console.error('Change password error', e);
            return false;
        }
    },

    returnToProjectList() {
      this.currentView = 'projectList';
      this.projectInfo = { code: '' } as ProjectInfo;
      this.tasks = [];
      this.phases = [];
      this.swimlanes = [];
      this.selectedElement = null;
      
      if (this.socket) {
          this.socket.disconnect();
          this.socket = null;
      }
      
      window.history.pushState({}, '', '/pm/');
      this.fetchProjects();
    },

    async loadProjectFromServer(projectId: string) {
        try {
            const response = await fetch(`/api/project/${projectId}`)
            if (response.ok) {
                const data = await response.json()
                this.projectInfo = data.projectInfo
                this.phases = data.phases
                this.swimlanes = data.swimlanes
                this.tasks = data.tasks
                
                // Initialize socket for this project
                this.initSocket();
                this.currentView = 'projectDetail';
                
                return true
            }
            return false
        } catch (error) {
            console.error('Failed to load project:', error)
            return false
        }
    },

    async saveProjectToServer(projectId: string) {
      try {
        this.saveStatus = 'saving'
        const data = this.exportProjectData()
        // Use the API endpoint
        const response = await fetch(`/api/project/${projectId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: data,
        })
        
        if (!response.ok) {
           throw new Error(`Server responded with ${response.status}`)
        }
        console.log('Project saved successfully to server')
        this.saveStatus = 'saved'
        this.lastSaveTime = new Date()
        return true
      } catch (e) {
        console.error('Error saving project to server:', e)
        this.saveStatus = 'error'
        return false
      }
    }
  }
})
