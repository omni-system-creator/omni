import { defineStore } from 'pinia'
import type { Phase, Swimlane, Task, ViewSettings, TaskDependency, ProjectInfo, TaskPort } from '../types/project'
import { getProject, saveProject } from '../api/project'
import { HubConnection, HubConnectionBuilder } from '@microsoft/signalr'
import { v4 as uuidv4 } from 'uuid'
import { useUserStore } from './user'

let saveTimeout: any = null;

interface User {
  username: string
  name: string
  role: string
  color?: string
}

export const useProjectFlowStore = defineStore('projectFlow', {
  state: () => ({
    // Auth
    currentUser: null as User | null,
    isAuthenticated: false,
    
    // Real-time Collaboration
    clientId: uuidv4(),
    socket: null as HubConnection | null,
    remoteCursors: new Map<string, { x: number, y: number, user: User, clientId: string }>(),
    remoteSelections: {} as Record<string, { type: string, id: string, user: User, clientId: string }>,
    saveStatus: 'saved' as 'saved' | 'saving' | 'synced' | 'error',
    lastSaveTime: null as Date | null,
    lastSyncTime: null as Date | null,
    lastSyncUser: '',

    // Project
    projectInfo: {
      code: '',
      name: '',
      type: '',
      description: '',
      manager: '',
      plannedStartDate: '',
      plannedEndDate: ''
    } as ProjectInfo,
    phases: [] as Phase[],
    swimlanes: [] as Swimlane[],
    tasks: [] as Task[],
    viewSettings: {
      zoomLevel: 1,
      showDependencies: true,
      filterOwner: '',
      filterStatuses: [],
      filterPhases: [],
      filterSwimlanes: [],
      resetViewTrigger: 0,
      fitViewTrigger: 0,
      searchText: '',
    } as ViewSettings,
    selectedElement: null as { type: 'task' | 'phase' | 'swimlane' | 'dependency' | 'port', id: string, taskId?: string } | null,
    exportImageHandler: null as null | (() => Promise<void> | void),
    copyImageHandler: null as (() => void) | null,
  }),
  actions: {
    async fetchProject(code: string) {
      try {
        const data = await getProject(code)
        if (data && data.projectInfo) {
          this.projectInfo = data.projectInfo
          this.phases = data.phases || []
          this.swimlanes = data.swimlanes || []
          this.tasks = (data.tasks || []).map((t: any) => ({
             ...t,
             dependencies: (t.dependencies || []).map((d: any) => ({
                ...d,
                controlPoints: d.controlPoints && typeof d.controlPoints === 'string' 
                  ? JSON.parse(d.controlPoints) 
                  : d.controlPoints
             })),
             attachments: t.attachments || []
          }))
        }
      } catch (error) {
        console.error("Failed to fetch project", error)
      }
    },
    async saveProject() {
       try {
           this.saveStatus = 'saving'
           // Prepare payload with serialized controlPoints
           const tasksForSave = this.tasks.map(t => ({
               ...t,
               dependencies: t.dependencies.map(d => {
                   if (typeof d === 'string') {
                       return { taskId: d }
                   }
                   return {
                       ...d,
                       controlPoints: d.controlPoints ? JSON.stringify(d.controlPoints) : undefined
                   }
               })
           }))

           const payload: any = {
               projectInfo: this.projectInfo,
               phases: this.phases,
               swimlanes: this.swimlanes,
               tasks: tasksForSave
           }
           await saveProject(payload)
           this.saveStatus = 'saved'
           this.lastSaveTime = new Date()
       } catch (error) {
           console.error("Failed to save project", error)
           this.saveStatus = 'error'
           throw error
       }
    },
    triggerAutoSave() {
        if (saveTimeout) clearTimeout(saveTimeout)
        this.saveStatus = 'saving'
        saveTimeout = setTimeout(async () => {
            try {
                await this.saveProject()
            } catch (e) {
                // Error already handled in saveProject
            }
        }, 2000)
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
    updateProjectInfo(info: Partial<ProjectInfo>, emit: boolean = true) {
      Object.assign(this.projectInfo, info)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('update_project_info', info);
    },
    addPhase(phase: Phase, emit: boolean = true) {
      this.phases.push(phase)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('add_phase', phase);
    },
    updatePhase(phase: Phase, emit: boolean = true) {
      const index = this.phases.findIndex(p => p.id === phase.id)
      if (index !== -1) {
        this.phases[index] = phase
        this.triggerAutoSave()
        if (emit) this.emitProjectAction('update_phase', phase);
      }
    },
    deletePhase(id: string, emit: boolean = true) {
      this.phases = this.phases.filter(p => p.id !== id)
      // Also delete tasks in this phase?
      this.tasks = this.tasks.filter(t => t.phaseId !== id)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('delete_phase', { id });
    },

    addSwimlane(swimlane: Swimlane, emit: boolean = true) {
      this.swimlanes.push(swimlane)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('add_swimlane', swimlane);
    },
    updateSwimlane(swimlane: Swimlane, emit: boolean = true) {
      const index = this.swimlanes.findIndex(s => s.id === swimlane.id)
      if (index !== -1) {
        this.swimlanes[index] = swimlane
        this.triggerAutoSave()
        if (emit) this.emitProjectAction('update_swimlane', swimlane);
      }
    },
    deleteSwimlane(id: string, emit: boolean = true) {
      this.swimlanes = this.swimlanes.filter(s => s.id !== id)
      this.tasks = this.tasks.filter(t => t.swimlaneId !== id)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('delete_swimlane', { id });
    },

    addTask(task: Task, emit: boolean = true) {
      this.tasks.push(task)
      this.triggerAutoSave()
      if (emit) this.emitProjectAction('add_task', task);
    },
    updateTask(id: string, updates: Partial<Task>, emit: boolean = true) {
      const task = this.tasks.find(t => t.id === id)
      if (task) {
        Object.assign(task, updates)
        this.triggerAutoSave()
        if (emit) this.emitProjectAction('update_task', { id, ...updates });
      }
    },
    updateDependencyControlPoints(taskId: string, depTaskId: string, controlPoints: { x: number, y: number }[], controlPointCount?: number, type?: 'straight' | 'polyline' | 'curve', sourcePort?: string, targetPort?: string, emit: boolean = true) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const depIndex = task.dependencies.findIndex(d => 
          (typeof d === 'string' ? d : d.taskId) === depTaskId
        )
        
        if (depIndex !== -1) {
          const currentDep = task.dependencies[depIndex]
          
          if (typeof currentDep === 'string') {
             task.dependencies[depIndex] = {
               taskId: depTaskId,
               controlPoints,
               controlPointCount,
               type: type || 'polyline',
               sourcePort,
               targetPort
             }
          } else {
             const depObj = currentDep as TaskDependency
             const newDep: TaskDependency = {
               ...depObj,
               controlPoints,
               controlPointCount,
               type: type || depObj.type || 'polyline'
             };
             if (sourcePort) newDep.sourcePort = sourcePort;
             if (targetPort) newDep.targetPort = targetPort;
             task.dependencies[depIndex] = newDep;
          }

          this.triggerAutoSave()
          if (emit) {
               this.emitProjectAction('update_dependency', {
                   taskId,
                   depTaskId,
                   controlPoints,
                   controlPointCount,
                   type,
                   sourcePort,
                   targetPort
               });
          }
        }
      }
    },
    batchUpdateTaskPositions(updates: {id: string, x: number, y: number, autoPositioned?: boolean}[], emit: boolean = true) {
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
        this.triggerAutoSave()
        if (emit) this.emitProjectAction('batch_update_task_positions', updates);
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
          this.projectInfo = data.projectInfo
          this.phases = data.phases
          this.swimlanes = data.swimlanes
          this.tasks = data.tasks
          
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

    deleteTask(id: string, emit: boolean = true) {
      this.tasks = this.tasks.filter(t => t.id !== id)
      if (emit) this.emitProjectAction('delete_task', { id });
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
      this.tasks = [...otherTasks, task]
      
      // Emit update for the task properties
      this.emitProjectAction('update_task', { id: taskId, phaseId, swimlaneId });
    },

    addDependency(sourceId: string, targetId: string, sourcePort?: string, targetPort?: string, emit: boolean = true) {
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
               if (sourcePort || targetPort) {
                   targetTask.dependencies.push({
                       taskId: sourceId,
                       type: 'curve',
                       sourcePort,
                       targetPort
                   });
               } else {
                   targetTask.dependencies.push(sourceId);
               }
               
               if (emit) {
                   this.emitProjectAction('add_dependency', {
                       targetId,
                       sourceId,
                       sourcePort,
                       targetPort
                   });
               }
            } else {
               throw new Error('无法创建依赖：会导致循环依赖')
            }
        }
      }
    },

    removeDependency(sourceId: string, targetId: string, emit: boolean = true) {
      const targetTask = this.tasks.find(t => t.id === targetId)
      if (targetTask) {
        targetTask.dependencies = targetTask.dependencies.filter(dep => {
            const depId = typeof dep === 'string' ? dep : dep.taskId
            return depId !== sourceId
        })
        this.triggerAutoSave()
        if (emit) {
            this.emitProjectAction('remove_dependency', { targetId, sourceId });
        }
      }
    },
    
    checkCycle(sourceId: string, targetId: string): boolean {
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
      this.emitElementSelected(type, id);
    },
    async initSocket() {
        if (!this.currentUser) {
            const userStore = useUserStore();
            if (userStore.username) {
                this.currentUser = {
                    username: userStore.username,
                    name: userStore.nickname || userStore.username,
                    role: 'member' // Default role
                };
            }
        }

        if (!this.currentUser || !this.projectInfo.code) return;
        
        // Ensure user has color
        if (!this.currentUser.color) {
            const colors = ['#f44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107', '#FF9800', '#FF5722'];
            this.currentUser.color = colors[Math.floor(Math.random() * colors.length)];
        }

        if (this.socket) {
             try { await this.socket.stop(); } catch {}
        }

        this.socket = new HubConnectionBuilder()
            .withUrl('/hubs/project')
            .withAutomaticReconnect()
            .build();

        this.socket.on('UserJoined', ({ user, clientId }) => {
            console.log(`User ${user.name} joined`, clientId);
        });

        this.socket.on('ProjectAction', ({ action, payload, user }) => {
             this.handleProjectAction(action, payload, user);
        });

        this.socket.on('CursorMove', ({ x, y, user, clientId }) => {
             this.remoteCursors.set(clientId, { x, y, user, clientId });
             
             // Also handle disconnection logic implicitly if needed, or use separate event
        });
        
        // Handle User Disconnect to clear cursor/selection
        this.socket.on('UserLeft', (clientId) => {
             this.remoteCursors.delete(clientId);
             delete this.remoteSelections[clientId];
        });

        this.socket.on('ElementSelected', ({ clientId, type, id, user }) => {
             // this.remoteSelections.set(clientId, { type, id, user, clientId });
             if (type && id) {
                this.remoteSelections[clientId] = { type, id, user, clientId };
             } else {
                delete this.remoteSelections[clientId];
             }
        });

        try {
            await this.socket.start();
            console.log('SignalR Connected');
            await this.socket.invoke('JoinProject', this.projectInfo.code, this.currentUser, this.clientId);
        } catch (err) {
            console.error('SignalR Connection Error: ', err);
        }
    },

    async disconnectSocket() {
        if (this.socket) {
            try {
                await this.socket.stop();
                this.socket = null;
                console.log('SignalR Disconnected');
            } catch (err) {
                console.error('SignalR Disconnection Error: ', err);
            }
        }
    },

    emitProjectAction(action: string, payload: any) {
        if (this.socket && this.socket.state === 'Connected') {
            this.socket.invoke('ProjectAction', this.projectInfo.code, action, payload, this.currentUser)
                .catch(err => console.error(err));
        }
    },

    handleProjectAction(action: string, payload: any, user: any) {
        // console.log('Received ProjectAction:', action, payload);
        this.saveStatus = 'synced';
        this.lastSyncTime = new Date();
        this.lastSyncUser = user.name || user.username;

        switch (action) {
            case 'add_task':
                if (payload) this.addTask(payload, false);
                break;
            case 'update_task':
                if (payload && payload.id) this.updateTask(payload.id, payload, false);
                break;
            case 'delete_task':
                if (payload && payload.id) this.deleteTask(payload.id, false);
                break;
            case 'batch_update_task_positions':
                if (Array.isArray(payload)) this.batchUpdateTaskPositions(payload, false);
                break;
            case 'update_project_info':
                if (payload) this.updateProjectInfo(payload, false);
                break;
            case 'add_phase':
                if (payload) this.addPhase(payload, false);
                break;
            case 'update_phase':
                if (payload) this.updatePhase(payload, false);
                break;
            case 'delete_phase':
                if (payload && payload.id) this.deletePhase(payload.id, false);
                break;
            case 'add_swimlane':
                if (payload) this.addSwimlane(payload, false);
                break;
            case 'update_swimlane':
                if (payload) this.updateSwimlane(payload, false);
                break;
            case 'delete_swimlane':
                if (payload && payload.id) this.deleteSwimlane(payload.id, false);
                break;
            case 'add_dependency':
                if (payload && payload.targetId && payload.sourceId) {
                     this.addDependency(payload.sourceId, payload.targetId, payload.sourcePort, payload.targetPort, false);
                }
                break;
            case 'remove_dependency':
                if (payload && payload.targetId && payload.sourceId) {
                     this.removeDependency(payload.sourceId, payload.targetId, false);
                }
                break;
             case 'update_dependency':
                if (payload && payload.taskId && payload.depTaskId) {
                    this.updateDependencyControlPoints(payload.taskId, payload.depTaskId, payload.controlPoints, payload.controlPointCount, payload.type, payload.sourcePort, payload.targetPort, false);
                }
                break;
        }
    },

    emitCursorMove(x: number, y: number) {
        if (this.socket && this.socket.state === 'Connected') {
            this.socket.invoke('CursorMove', this.projectInfo.code, x, y, this.currentUser, this.clientId)
                .catch(err => console.error(err));
        }
    },

    emitElementSelected(type: string, id: string) {
        if (this.socket && this.socket.state === 'Connected') {
            this.socket.invoke('ElementSelected', this.projectInfo.code, this.clientId, type, id, this.currentUser)
                .catch(err => console.error(err));
        }
    },
    clearSelection() {
        this.selectedElement = null
    },
    removeTaskPort(taskId: string, portId: string) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task && task.ports) {
        // 1. Remove port from task
        task.ports = task.ports.filter(p => p.id !== portId)
        this.emitProjectAction('update_task', { id: taskId, ports: task.ports });
        
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
            let changed = false;
            t.dependencies = t.dependencies.map(dep => {
                const depTaskId = typeof dep === 'string' ? dep : dep.taskId
                if (depTaskId === taskId) {
                    if (typeof dep === 'object' && dep.sourcePort === portId) {
                        const { sourcePort, ...rest } = dep
                        changed = true;
                        return rest as TaskDependency
                    }
                }
                return dep
            })
            if (changed) {
                // Emit update for the source task's dependencies
                 this.emitProjectAction('update_task', { id: t.id, dependencies: t.dependencies });
            }
        })
      }
    },
    updateTaskPort(taskId: string, portId: string, percentage: number) {
        const task = this.tasks.find(t => t.id === taskId)
        if (task && task.ports) {
            const port = task.ports.find(p => p.id === portId)
            if (port) {
                port.percentage = percentage
                this.emitProjectAction('update_task', { id: taskId, ports: task.ports });
            }
        }
    },
    addTaskPort(taskId: string, port: TaskPort) {
        const task = this.tasks.find(t => t.id === taskId)
        if (task) {
            if (!task.ports) task.ports = []
            task.ports.push(port)
            this.emitProjectAction('update_task', { id: taskId, ports: task.ports });
        }
    },
    batchUpdateDependencyPorts(updates: { taskId: string, depTaskId: string, sourcePort: string, targetPort: string }[]) {
      updates.forEach(update => {
           const { taskId, depTaskId, sourcePort, targetPort } = update;
           // We can use updateDependencyControlPoints to emit update_dependency
           // We need current control points
           const task = this.tasks.find(t => t.id === taskId);
           if (task) {
                const dep = task.dependencies.find(d => (typeof d === 'string' ? d : d.taskId) === depTaskId);
                if (dep) {
                    const depObj = typeof dep === 'string' ? { taskId: dep } : dep;
                    this.updateDependencyControlPoints(
                        taskId, 
                        depTaskId, 
                        depObj.controlPoints || [], 
                        depObj.controlPointCount, 
                        depObj.type, 
                        sourcePort, 
                        targetPort, 
                        true
                    );
                }
           }
      });
    },
    updateDependencyPort(taskId: string, depTaskId: string, type: 'source' | 'target', portId: string, emit: boolean = true) {
        const task = this.tasks.find(t => t.id === taskId);
        if (task) {
            const depIndex = task.dependencies.findIndex(d => 
                (typeof d === 'string' ? d : d.taskId) === depTaskId
            );
            if (depIndex !== -1) {
                const existingDep = task.dependencies[depIndex];
                let newDep: TaskDependency;
                
                if (typeof existingDep === 'string') {
                    newDep = { taskId: existingDep };
                } else {
                    newDep = { ...existingDep } as TaskDependency;
                }
                
                if (type === 'source') {
                    newDep.sourcePort = portId;
                } else {
                    newDep.targetPort = portId;
                }
                
                task.dependencies[depIndex] = newDep;

                if (emit) {
                     this.emitProjectAction('update_dependency', {
                         taskId,
                         depTaskId,
                         controlPoints: newDep.controlPoints,
                         controlPointCount: newDep.controlPointCount,
                         type: newDep.type,
                         sourcePort: newDep.sourcePort,
                         targetPort: newDep.targetPort
                     });
                }
            }
        }
    },
    changeDependencySource(targetTaskId: string, oldSourceId: string, newSourceId: string, sourcePort?: string) {
        // Remove old
        this.removeDependency(oldSourceId, targetTaskId, true);
        
        // Add new
        this.addDependency(newSourceId, targetTaskId, sourcePort, undefined, true);
    },
    updateDependencyType(taskId: string, depTaskId: string, type: 'straight' | 'polyline' | 'curve', emit: boolean = true) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const dep = task.dependencies.find(d => (typeof d === 'string' ? d : d.taskId) === depTaskId)
        if (dep) {
          const depObj = typeof dep === 'string' ? { taskId: dep } : dep
          this.updateDependencyControlPoints(
            taskId,
            depTaskId,
            depObj.controlPoints || [],
            depObj.controlPointCount,
            type,
            depObj.sourcePort,
            depObj.targetPort,
            emit
          )
        }
      }
    },
    updateDependencyControlPointCount(taskId: string, depTaskId: string, count: number, emit: boolean = true) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        const dep = task.dependencies.find(d => (typeof d === 'string' ? d : d.taskId) === depTaskId)
        if (dep) {
          const depObj = typeof dep === 'string' ? { taskId: dep } : dep
          this.updateDependencyControlPoints(
            taskId,
            depTaskId,
            depObj.controlPoints || [],
            count,
            depObj.type,
            depObj.sourcePort,
            depObj.targetPort,
            emit
          )
        }
      }
    },
    addAttachment(taskId: string, attachment: any, emit: boolean = true) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task) {
        if (!task.attachments) task.attachments = []
        task.attachments.push(attachment)
        if (emit) this.emitProjectAction('update_task', { id: taskId, attachments: task.attachments })
      }
    },
    removeAttachment(taskId: string, attachmentId: string, emit: boolean = true) {
      const task = this.tasks.find(t => t.id === taskId)
      if (task && task.attachments) {
        task.attachments = task.attachments.filter(a => a.id !== attachmentId)
        if (emit) this.emitProjectAction('update_task', { id: taskId, attachments: task.attachments })
      }
    },
    moveDependencyTarget(oldTargetId: string, newTargetId: string, sourceId: string, targetPort?: string) {
        // Remove from old
        this.removeDependency(sourceId, oldTargetId, true);
        
        // Add to new
        this.addDependency(sourceId, newTargetId, undefined, targetPort, true);
    }
  }
})
