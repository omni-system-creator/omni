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
  lifecycleStatus?: string;
  pricingType?: string;
  description?: string;
  latestTransactionDate?: string;
  files?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface CreateContractDto {
  contractNo?: string;
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
  lifecycleStatus?: string;
  pricingType?: string;
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

export interface ContractTemplateFileUploadResultDto {
  filePath: string;
  fileName: string;
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

export interface ContractInvoiceDto {
  id: number;
  invoiceNo: string;
  invoiceDate: string;
  amount: number;
  direction: string;
  type?: string;
  status: string;
  attachmentFilePath?: string;
  attachmentFileName?: string;
}

export interface ContractAttachmentDto {
  id: number;
  fileName: string;
  filePath?: string;
  size?: string;
  uploadDate: string;
}

export interface RelatedContractDto {
  id: number;
  contractNo: string;
  contractName: string;
  type: string;
  manager?: string;
  totalAmount: number;
  currency: string;
  status: string;
  signDate?: string;
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
  paymentPlans: ContractPaymentPlanDto[];
  paymentRecords: ContractPaymentRecordDto[];
  invoices: ContractInvoiceDto[];
  relatedContracts: RelatedContractDto[];
  contacts: {
    id: number;
    name: string;
    role: string;
    phone: string;
    email: string;
  }[];
  attachments: ContractAttachmentDto[];
}

export interface ContractPaymentPlanDto {
  id: number;
  phase: string;
  dueDate?: string;
  amount: number;
  condition?: string;
  status: string;
}

export interface ContractPaymentRecordDto {
  id: number;
  paymentDate: string;
  amount: number;
  type?: string;
  method?: string;
  operator?: string;
  remark?: string;
  voucherFilePath?: string;
  voucherFileName?: string;
}

export interface ContractCustomerSelectDto {
  id: string;
  name: string;
  industry: string;
  contact: string;
  phone: string;
  level: string;
}

export interface SetRelatedContractsDto {
  relatedContractIds: number[];
}

// --- API Functions ---

// Contracts
export const getContracts = (type?: string, keyword?: string, expiryStatus?: string) => {
  return request.get<any, ContractDto[]>('/contract', { params: { type, keyword, expiryStatus } });
};

export const getContractCustomers = (keyword?: string) => {
  return request.get<any, ContractCustomerSelectDto[]>('/contract/customers', { params: { keyword } });
};

export const getContractById = (id: number) => {
  return request.get<any, ContractDetailDto>(`/contract/${id}`);
};

export const getRelatedContracts = (id: number) => {
  return request.get<any, RelatedContractDto[]>(`/contract/${id}/related-contracts`);
};

export const uploadContractAttachment = (contractId: number, file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, ContractAttachmentDto>(`/contract/${contractId}/attachments`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
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

export const setRelatedContracts = (id: number, data: SetRelatedContractsDto) => {
  return request.post<any, RelatedContractDto[]>(`/contract/${id}/related-contracts`, data);
};

export const deleteContractAttachment = (id: number) => {
  return request.delete(`/contract/attachments/${id}`);
};

// Payments
export interface CreateContractPaymentPlanDto {
  phase: string;
  dueDate?: string;
  amount: number;
  condition?: string;
  status?: string;
}

export interface UpdateContractPaymentPlanDto extends CreateContractPaymentPlanDto {}

export interface CreateContractPaymentRecordDto {
  paymentDate: string;
  amount: number;
  type?: string;
  method?: string;
  operator?: string;
  remark?: string;
}

export interface UpdateContractPaymentRecordDto extends CreateContractPaymentRecordDto {}

export interface CreateContractInvoiceDto {
  invoiceNo: string;
  invoiceDate: string;
  amount: number;
  direction: string;
  type?: string;
  status?: string;
}

export interface UpdateContractInvoiceDto extends CreateContractInvoiceDto {}

export const createPaymentPlan = (contractId: number, data: CreateContractPaymentPlanDto) => {
  return request.post<any, ContractPaymentPlanDto>(`/contract/${contractId}/payment-plans`, data);
};

export const updatePaymentPlan = (id: number, data: UpdateContractPaymentPlanDto) => {
  return request.put<any, ContractPaymentPlanDto>(`/contract/payment-plans/${id}`, data);
};

export const deletePaymentPlan = (id: number) => {
  return request.delete(`/contract/payment-plans/${id}`);
};

export const createPaymentRecord = (contractId: number, data: CreateContractPaymentRecordDto) => {
  return request.post<any, ContractPaymentRecordDto>(`/contract/${contractId}/payment-records`, data);
};

export const updatePaymentRecord = (id: number, data: UpdateContractPaymentRecordDto) => {
  return request.put<any, ContractPaymentRecordDto>(`/contract/payment-records/${id}`, data);
};

export const deletePaymentRecord = (id: number) => {
  return request.delete(`/contract/payment-records/${id}`);
};

export const uploadPaymentRecordVoucher = (id: number, file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, ContractPaymentRecordDto>(`/contract/payment-records/${id}/voucher`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
};

export const createInvoice = (contractId: number, data: CreateContractInvoiceDto) => {
  return request.post<any, ContractInvoiceDto>(`/contract/${contractId}/invoices`, data);
};

export const updateInvoice = (id: number, data: UpdateContractInvoiceDto) => {
  return request.put<any, ContractInvoiceDto>(`/contract/invoices/${id}`, data);
};

export const deleteInvoice = (id: number) => {
  return request.delete(`/contract/invoices/${id}`);
};

export const uploadInvoiceAttachment = (id: number, file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, ContractInvoiceDto>(`/contract/invoices/${id}/attachment`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
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

export const uploadTemplateFile = (id: number, file: File) => {
  const formData = new FormData();
  formData.append('file', file);
  return request.post<any, ContractTemplateDto>(`/contract/templates/${id}/file`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
};

export const deleteTemplateFile = (id: number) => {
  return request.delete(`/contract/templates/${id}/file`);
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
