import request from '@/utils/request';

export interface TaskItem {
  id: string;
  title: string;
  type: string;
  priority: string;
  creatorId: string;
  creatorName: string;
  creatorAvatar?: string;
  assigneeId: string;
  assigneeName: string;
  assigneeAvatar?: string;
  createTime: string;
  startTime?: string;
  deadline: string;
  finishTime?: string;
  status: string;
  description?: string;
  orgId: string;
  attachments?: any[]; // FileDto
  members?: TaskMember[];
}

export interface TaskMember {
  userId: number;
  name: string;
  avatar?: string;
  joinTime: string;
}

export interface CreateTaskParams {
  title: string;
  type?: string;
  priority?: string;
  description?: string;
  assigneeId?: string;
  memberIds?: number[];
  startTime?: string;
  deadline?: string;
}

export interface UpdateTaskParams {
  title?: string;
  type?: string;
  priority?: string;
  description?: string;
  startTime?: string;
  deadline?: string;
  status?: string;
  assigneeId?: number;
  memberIds?: number[];
}

export interface TaskProcessItem {
  id: number;
  taskId: number;
  operatorId: number;
  operatorName: string;
  action: string;
  comment?: string;
  createTime: string;
  attachmentIds?: string;
  attachments?: any[]; // FileDto
}

export interface CreateTaskProcessParams {
  action: string;
  comment?: string;
  attachmentIds?: string;
  newStatus?: string;
}

export function getPendingTasks() {
  return request.get<any, TaskItem[]>('/task/pending');
}

export function getCompletedTasks() {
  return request.get<any, TaskItem[]>('/task/completed');
}

export function getSubordinateTasks() {
  return request.get<any, TaskItem[]>('/task/subordinate');
}

export function createTask(data: CreateTaskParams, attachments?: File[]) {
  const formData = new FormData();
  Object.keys(data).forEach(key => {
    const value = (data as any)[key];
    if (value !== undefined && value !== null) {
      if (Array.isArray(value)) {
        value.forEach(v => formData.append(key, v));
      } else {
        formData.append(key, value);
      }
    }
  });
  
  if (attachments && attachments.length > 0) {
    attachments.forEach(file => {
      formData.append('attachments', file);
    });
  }
  
  return request.post<any, TaskItem>('/task', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
}

export function updateTask(id: string, data: UpdateTaskParams) {
  return request.put<any, TaskItem>(`/task/${id}`, data);
}

export function deleteTask(id: number) {
  return request.delete<any, boolean>(`/task/${id}`);
}

export function getTaskProcesses(taskId: number) {
  return request.get<any, TaskProcessItem[]>(`/task/${taskId}/process`);
}

export function addTaskProcess(taskId: number, data: CreateTaskProcessParams, attachments?: File[]) {
  const formData = new FormData();
  Object.keys(data).forEach(key => {
    const value = (data as any)[key];
    if (value !== undefined && value !== null) {
      formData.append(key, value);
    }
  });

  if (attachments && attachments.length > 0) {
    attachments.forEach(file => {
      formData.append('attachments', file);
    });
  }

  return request.post<any, TaskProcessItem>(`/task/${taskId}/process`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
}

export function uploadTaskAttachment(taskId: number, file: File) {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, any>(`/task/${taskId}/attachment`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
}
