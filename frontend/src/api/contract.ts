import request from '@/utils/request';

// --- Interfaces ---

export interface ContractDto {
  id: number;
  contractNo: string;
  contractName: string;
  type: string;
  partnerName: string;
  signDate?: string;
  startDate?: string;
  endDate?: string;
  manager?: string;
  totalAmount: number;
  paidAmount: number;
  invoicedAmount: number;
  progress: number;
  currency: string;
  paymentMethod?: string;
  taxId?: string;
  status: string;
  description?: string;
  latestTransactionDate?: string;
  files?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface CreateContractDto {
  contractName: string;
  type: string;
  partnerName: string;
  signDate?: string;
  startDate?: string;
  endDate?: string;
  manager?: string;
  totalAmount: number;
  currency?: string;
  paymentMethod?: string;
  taxId?: string;
  description?: string;
  files?: string;
}

export interface UpdateContractDto extends Partial<CreateContractDto> {
  status?: string;
  paidAmount?: number;
  invoicedAmount?: number;
  progress?: number;
}

export interface ContractTemplateDto {
  id: number;
  name: string;
  type: string;
  description?: string;
  filePath?: string;
  fileName?: string;
  status: string;
  createdAt: string;
  updatedAt?: string;
}

export interface CreateContractTemplateDto {
  name: string;
  type: string;
  description?: string;
  filePath?: string;
  fileName?: string;
  status?: string;
}

export interface ContractStatDto {
  id: number;
  periodType: string;
  periodKey: string;
  statDate: string;
  totalContracts: number;
  totalContractsGrowth: number;
  totalAmount: number;
  amountCompletionRate: number;
  receivedAmount: number;
  receivedRate: number;
  invoicedAmount: number;
  pendingInvoiceAmount: number;
  salesCount: number;
  purchaseCount: number;
}

export interface ContractKnowledgeCategoryDto {
  id: number;
  name: string;
  parentId?: number;
  sortOrder: number;
  children: ContractKnowledgeCategoryDto[];
}

export interface CreateContractKnowledgeCategoryDto {
  name: string;
  parentId?: number;
  sortOrder: number;
}

export interface UpdateContractKnowledgeCategoryDto {
  name: string;
  parentId?: number;
  sortOrder: number;
}

export interface ContractKnowledgeFileDto {
  id: number;
  categoryId: number;
  name: string;
  type: string;
  filePath?: string;
  size: number;
  contentType?: string;
  uploader?: string;
  uploadTime: string;
}

export interface CreateContractKnowledgeFileDto {
  categoryId: number;
  name: string;
  type: string;
  filePath?: string;
  size?: number;
  uploader?: string;
}

export interface ContractDetailDto {
  id: number;
  contractNo: string;
  contractName: string;
  status: string;
  customerName: string;
  signDate: string;
  totalAmount: number;
  receivedAmount: number;
  latestCollectionDate?: string;
  remark?: string;
  paymentPlans: {
    id: number;
    phase: number;
    dueDate?: string;
    amount: number;
    condition: string;
    status: string;
  }[];
  paymentRecords: {
    id: number;
    paymentDate: string;
    amount: number;
    method: string;
    operator: string;
    remark?: string;
  }[];
  invoices: {
    id: number;
    invoiceNo: string;
    invoiceDate: string;
    amount: number;
    type: string;
    status: string;
  }[];
  contacts: {
    id: number;
    name: string;
    role: string;
    phone: string;
    email: string;
  }[];
  attachments: {
    id: number;
    fileName: string;
    size?: string;
    uploadDate: string;
  }[];
}

// --- API Methods ---

// Contracts
export const getContracts = (type?: string, keyword?: string) => {
  return request.get<any, ContractDto[]>('/contract', { params: { type, keyword } });
};

export const getContractById = (id: number) => {
  return request.get<any, ContractDetailDto>(`/contract/${id}`);
};

export const createContract = (data: CreateContractDto) => {
  return request.post<any, ContractDto>('/contract', data);
};

export const updateContract = (id: number, data: UpdateContractDto) => {
  return request.put<any, ContractDto>(`/contract/${id}`, data);
};

export const deleteContract = (id: number) => {
  return request.delete(`/contract/${id}`);
};

// Templates
export const getTemplates = (type?: string) => {
  return request.get<any, ContractTemplateDto[]>('/contract/templates', { params: { type } });
};

export const createTemplate = (data: CreateContractTemplateDto) => {
  return request.post<any, ContractTemplateDto>('/contract/templates', data);
};

export const updateTemplate = (id: number, data: CreateContractTemplateDto) => {
  return request.put<any, ContractTemplateDto>(`/contract/templates/${id}`, data);
};

export const deleteTemplate = (id: number) => {
  return request.delete(`/contract/templates/${id}`);
};

// Stats
export const getCurrentStats = (periodType: string = 'Month') => {
  return request.get<any, ContractStatDto>('/contract/stats/current', { params: { periodType } });
};

export const getTrendStats = (periodType: string = 'Year', count: number = 5) => {
  return request.get<any, ContractStatDto[]>('/contract/stats/trend', { params: { periodType, count } });
};

// Knowledge
export const getKnowledgeCategories = () => {
  return request.get<any, ContractKnowledgeCategoryDto[]>('/contract/knowledge/categories');
};

export const createKnowledgeCategory = (data: CreateContractKnowledgeCategoryDto) => {
  return request.post<any, ContractKnowledgeCategoryDto>('/contract/knowledge/categories', data);
};

export const updateKnowledgeCategory = (id: number, data: UpdateContractKnowledgeCategoryDto) => {
  return request.put<any, ContractKnowledgeCategoryDto>(`/contract/knowledge/categories/${id}`, data);
};

export const deleteKnowledgeCategory = (id: number) => {
  return request.delete(`/contract/knowledge/categories/${id}`);
};

export const getKnowledgeFiles = (categoryId: number, keyword?: string) => {
  return request.get<any, ContractKnowledgeFileDto[]>('/contract/knowledge/files', { params: { categoryId, keyword } });
};

export const uploadKnowledgeFile = (data: FormData) => {
  return request.post<any, ContractKnowledgeFileDto>('/contract/knowledge/files', data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
};

export const updateKnowledgeFile = (id: number, data: { name: string }) => {
  return request.put<any, ContractKnowledgeFileDto>(`/contract/knowledge/files/${id}`, data);
};

export const deleteKnowledgeFile = (id: number) => {
  return request.delete(`/contract/knowledge/files/${id}`);
};

export const downloadKnowledgeFileUrl = (id: number) => {
  return `/api/contract/knowledge/files/${id}/download`; // Direct URL for download
};
