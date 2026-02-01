import request from '@/utils/request';

export interface FinanceSubject {
  id: number;
  code: string;
  name: string;
  parentId?: number;
  direction: string;
  description?: string;
  isSystem: boolean;
  isActive: boolean;
  children?: FinanceSubject[];
}

export interface FinanceAttachment {
  id: number;
  targetType: string;
  targetId: number;
  fileName: string;
  filePath: string;
  size: string;
  contentType: string;
  uploadDate: string;
  uploader: string;
}

export interface CreateFinanceSubjectDto {
  code: string;
  name: string;
  parentId?: number;
  direction: string;
  description?: string;
}

export interface UpdateFinanceSubjectDto {
  name: string;
  parentId?: number;
  direction: string;
  description?: string;
  isActive: boolean;
}

export interface FinanceApAr {
  id: number;
  billNo: string;
  type: string;
  subjectId?: number;
  subjectName?: string;
  amount: number;
  dueDate: string | null;
  partnerName: string;
  partnerId?: string;
  status: number;
  sourceType: string;
  sourceId?: number;
  description?: string;
  overdueDays: number;
  attachments: FinanceAttachment[];
}

export interface CreateFinanceApArDto {
  type: string;
  subjectId?: number;
  amount: number;
  dueDate: string;
  partnerName: string;
  partnerId?: string;
  description?: string;
}

export interface UpdateFinanceApArDto {
  subjectId?: number;
  amount?: number;
  dueDate?: string;
  partnerName?: string;
  partnerId?: string;
  status?: number;
  description?: string;
}

export interface FinanceStats {
  totalReceivables: number;
  totalPayables: number;
  overdueReceivables: number;
  overduePayables: number;
}

// Subjects
export function getSubjects(direction?: string) {
  return request<FinanceSubject[]>({
    url: '/finance/subject',
    method: 'get',
    params: { direction }
  }) as unknown as Promise<FinanceSubject[]>;
}

export function createSubject(data: CreateFinanceSubjectDto) {
  return request({
    url: '/finance/subject',
    method: 'post',
    data
  });
}

export function updateSubject(id: number, data: UpdateFinanceSubjectDto) {
  return request({
    url: `/finance/subject/${id}`,
    method: 'put',
    data
  });
}

export function deleteSubject(id: number) {
  return request({
    url: `/finance/subject/${id}`,
    method: 'delete'
  });
}

// ApAr
export function getApArList(params: any) {
  return request<FinanceApAr[]>({
    url: '/finance/apar',
    method: 'get',
    params
  }) as unknown as Promise<FinanceApAr[]>;
}

export function getStats() {
  return request<FinanceStats>({
    url: '/finance/stats',
    method: 'get'
  }) as unknown as Promise<FinanceStats>;
}

export function createApAr(data: FormData) {
  return request<{ id: number }>({
    url: '/finance/apar',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }) as unknown as Promise<{ id: number }>;
}

export function updateApAr(id: number, data: UpdateFinanceApArDto | FormData) {
  const isFormData = data instanceof FormData;
  return request({
    url: `/finance/apar/${id}`,
    method: 'put',
    data,
    headers: isFormData ? { 'Content-Type': 'multipart/form-data' } : undefined
  });
}

export function deleteApAr(id: number) {
  return request({
    url: `/finance/apar/${id}`,
    method: 'delete'
  });
}

// Attachment
export function uploadAttachment(data: FormData) {
  return request<FinanceAttachment>({
    url: '/finance/attachment',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }) as unknown as Promise<FinanceAttachment>;
}

export function deleteAttachment(id: number) {
  return request({
    url: `/finance/attachment/${id}`,
    method: 'delete'
  });
}
