import { defineStore } from 'pinia'
import type { Phase, Swimlane, Task, ViewSettings, TaskDependency, ProjectInfo, TaskPort, ProjectFullDto } from '../types/project'
import { getProject, saveProject } from '../api/project'

interface User {
  username: string
  name: string
  role: string
}

export const useProjectFlowStore = defineStore('projectFlow', {
  state: () => ({
    // Auth
    currentUser: null as User | null,
    isAuthenticated: false,
    
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
             dependencies: t.dependencies || [],
             attachments: t.attachments || []
          }))
        }
      } catch (error) {
        console.error("Failed to fetch project", error)
      }
    },
    async saveProject() {
       try {
           const payload: ProjectFullDto = {
               projectInfo: this.projectInfo,
               phases: this.phases,
               swimlanes: this.swimlanes,
               tasks: this.tasks
           }
           await saveProject(payload)
       } catch (error) {
           console.error("Failed to save project", error)
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
    updateProjectInfo(info: Partial<ProjectInfo>) {
      Object.assign(this.projectInfo, info)
    },
    addPhase(phase: Phase) {
      this.phases.push(phase)
    },
    updatePhase(phase: Phase) {
      const index = this.phases.findIndex(p => p.id === phase.id)
      if (index !== -1) {
        this.phases[index] = phase
      }
    },
    deletePhase(id: string) {
      this.phases = this.phases.filter(p => p.id !== id)
      // Also delete tasks in this phase?
      this.tasks = this.tasks.filter(t => t.phaseId !== id)
    },

    addSwimlane(swimlane: Swimlane) {
      this.swimlanes.push(swimlane)
    },
    updateSwimlane(swimlane: Swimlane) {
      const index = this.swimlanes.findIndex(s => s.id === swimlane.id)
      if (index !== -1) {
        this.swimlanes[index] = swimlane
      }
    },
    deleteSwimlane(id: string) {
      this.swimlanes = this.swimlanes.filter(s => s.id !== id)
      this.tasks = this.tasks.filter(t => t.swimlaneId !== id)
    },

    addTask(task: Task) {
      this.tasks.push(task)
    },
    updateTask(id: string, updates: Partial<Task>) {
      const task = this.tasks.find(t => t.id === id)
      if (task) {
        Object.assign(task, updates)
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
        }
      }
    },
    batchUpdateTaskPositions(updates: {id: string, x: number, y: number, autoPositioned?: boolean}[]) {
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

    deleteTask(id: string) {
      this.tasks = this.tasks.filter(t => t.id !== id)
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
            } else {
               throw new Error('无法创建依赖：会导致循环依赖')
            }
        }
      }
    },

    removeDependency(sourceId: string, targetId: string) {
      const targetTask = this.tasks.find(t => t.id === targetId)
      if (targetTask) {
        targetTask.dependencies = targetTask.dependencies.filter(dep => {
            const depId = typeof dep === 'string' ? dep : dep.taskId
            return depId !== sourceId
        })
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
    },
    clearSelection() {
        this.selectedElement = null
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
                    if (typeof dep === 'object' && dep.sourcePort === portId) {
                        const { sourcePort, ...rest } = dep
                        return rest as TaskDependency
                    }
                }
                return dep
            })
        })
      }
    },
    updateTaskPort(taskId: string, portId: string, percentage: number) {
        const task = this.tasks.find(t => t.id === taskId)
        if (task && task.ports) {
            const port = task.ports.find(p => p.id === portId)
            if (port) {
                port.percentage = percentage
            }
        }
    },
    addTaskPort(taskId: string, port: TaskPort) {
        const task = this.tasks.find(t => t.id === taskId)
        if (task) {
            if (!task.ports) task.ports = []
            task.ports.push(port)
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
    updateDependencyPort(taskId: string, depTaskId: string, type: 'source' | 'target', portId: string) {
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
            }
        }
    },
    changeDependencySource(targetTaskId: string, oldSourceId: string, newSourceId: string, sourcePort?: string) {
        const task = this.tasks.find(t => t.id === targetTaskId);
        if (task) {
            // Remove old dependency
            task.dependencies = task.dependencies.filter(d => 
                (typeof d === 'string' ? d : d.taskId) !== oldSourceId
            );
            
            // Add new dependency
            // Check if already exists to avoid duplicates
            const exists = task.dependencies.some(d => 
                (typeof d === 'string' ? d : d.taskId) === newSourceId
            );
            
            if (!exists) {
                const newDep: TaskDependency = {
                    taskId: newSourceId,
                    type: 'curve', // Default type
                    sourcePort: sourcePort
                };
                task.dependencies.push(newDep);
            }
        }
    },
    moveDependencyTarget(oldTargetId: string, newTargetId: string, sourceId: string, targetPort?: string) {
        // Remove dependency from old target
        const oldTargetTask = this.tasks.find(t => t.id === oldTargetId);
        if (oldTargetTask) {
             const depIndex = oldTargetTask.dependencies.findIndex(d => 
                (typeof d === 'string' ? d : d.taskId) === sourceId
            );
            if (depIndex !== -1) {
                oldTargetTask.dependencies.splice(depIndex, 1);
            }
        }
        
        // Add dependency to new target
        const newTargetTask = this.tasks.find(t => t.id === newTargetId);
        if (newTargetTask) {
             // Check cycle and existence
             const exists = newTargetTask.dependencies.some(d => 
                (typeof d === 'string' ? d : d.taskId) === sourceId
            );
            
            if (!exists && !this.checkCycle(sourceId, newTargetId)) {
                 const newDep: TaskDependency = {
                    taskId: sourceId,
                    type: 'curve',
                    targetPort: targetPort
                };
                newTargetTask.dependencies.push(newDep);
            }
        }
    }
  }
})
