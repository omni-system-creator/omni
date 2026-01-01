export interface ProjectInfo {
  code: string
  name: string
  type?: string
  description?: string
  manager?: string
  plannedStartDate?: string
  plannedEndDate?: string
}

export interface Phase {
  id: string
  name: string
  color: string
}

export interface Swimlane {
  id: string
  name: string
  color: string
}

export type TaskStatus = 'pending' | 'in_progress' | 'completed' | 'delayed'

export interface Attachment {
  id: string
  name: string
  url: string
  type: string
  uploadDate: string
}

export interface TaskDependency {
  taskId: string
  sourcePort?: string // 'top' | 'bottom' | 'left' | 'right' or custom ID
  targetPort?: string // 'top' | 'bottom' | 'left' | 'right' or custom ID
  type?: 'straight' | 'polyline' | 'curve'
  controlPoints?: { x: number, y: number }[]
  controlPointCount?: number // 2 or 4
}

export interface TaskPort {
  id: string
  side: 'top' | 'bottom' | 'left' | 'right'
  percentage: number // 0 to 1
}

export interface Task {
  id: string
  name: string
  phaseId: string
  swimlaneId: string
  status: TaskStatus
  progress: number
  owner: string
  startDate: string
  endDate: string
  dependencies: (string | TaskDependency)[] // IDs of tasks this task depends on, or detailed dependency objects
  type: 'milestone' | 'task' | 'delivery'
  attachments?: Attachment[]
  description?: string
  x?: number // Relative X position within the cell
  y?: number // Relative Y position within the cell
  width?: number
  startColor?: string
  endColor?: string
  autoPositioned?: boolean
  ports?: TaskPort[]
}

export interface ViewSettings {
  zoomLevel: number
  showDependencies: boolean
  filterOwner: string
  filterStatuses: TaskStatus[]
  filterPhases: string[]
  filterSwimlanes: string[]
  resetViewTrigger?: number
  fitViewTrigger?: number
  searchText: string
}

export interface ProjectFullDto {
  projectInfo: ProjectInfo
  phases: Phase[]
  swimlanes: Swimlane[]
  tasks: Task[]
}

export interface ProjectListItem {
  code: string
  name: string
  type: string
  manager: string
  status: string
  progress: number
  plannedEndDate?: string
}
