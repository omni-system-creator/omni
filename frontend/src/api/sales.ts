import request from '@/utils/request';

// --- Customer Interfaces ---

export interface CustomerDto {
  id: string;
  name: string;
  industry: string;
  contact: string;
  phone: string;
  level: string;
  status: 'active' | 'potential' | 'lost';
  owner: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateCustomerDto {
  name: string;
  industry?: string;
  contact?: string;
  phone?: string;
  level?: string;
  status?: 'active' | 'potential' | 'lost';
  owner?: string;
}

export interface UpdateCustomerDto extends Partial<CreateCustomerDto> {}

export interface CustomerSearchParams {
  searchText?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

// --- Opportunity Interfaces ---

export interface OpportunityDto {
  id: string;
  title: string;
  customer: string;
  amount: number;
  stage: 'new' | 'proposition' | 'negotiation' | 'won' | 'lost';
  owner: string;
  date: string; // Estimated Close Date
  createdAt?: string;
}

export interface CreateOpportunityDto {
  title: string;
  customer: string;
  amount: number;
  stage: 'new' | 'proposition' | 'negotiation' | 'won' | 'lost';
  owner: string;
  date: string;
}

export interface UpdateOpportunityDto extends Partial<CreateOpportunityDto> {}

// --- Materials Interfaces ---

export interface SalesScriptDto {
  id: string;
  title: string;
  content: string;
  category?: string;
  description?: string;
}

export interface ProductDocDto {
  id: string;
  title: string;
  size: string;
  url: string;
  type: string; // "file" | "folder"
  parentId?: string;
  children?: ProductDocDto[];
  uploadDate?: string;
}

export interface CreateProductDocDto {
  title: string;
  type: string;
  parentId?: string;
  size?: string;
  url?: string;
}

export interface ProcessRuleDto {
  id: string;
  title: string;
  content: string;
}

export interface SalesScriptChatDto {
  message: string;
  scriptId: string;
  userRole: 'salesman' | 'customer';
  model?: string;
}

export interface SalesScriptChatResponseDto {
  content: string;
  role: 'salesman' | 'customer';
}

// --- Target/Stats Interfaces ---

export interface SalesDashboardStatsDto {
  monthlyTarget: number;
  monthlyProgress: number; // percent 0-100
  quarterlyProgress: number; // percent 0-100
  newOpportunities: number;
  newOpportunitiesGrowth: number; // percentage change
  winRate: number; // percent 0-100
  winRateGrowth: number; // percentage change
}

export interface TeamRankingDto {
  rank: number;
  name: string;
  amount: number;
  rate: number; // percent 0-100
}

// --- Registration Interfaces ---

export interface SalesRegistrationDto {
  id: string;
  projectName: string;
  customerName: string;
  contact: string;
  phone: string;
  amount: number;
  date: string;
  status: 'pending' | 'approved' | 'rejected';
  owner: string;
  remarks?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateRegistrationDto {
  projectName: string;
  customerName: string;
  contact?: string;
  phone?: string;
  amount: number;
  date: string;
  remarks?: string;
}

export interface UpdateRegistrationDto extends Partial<CreateRegistrationDto> {
  status?: string;
  owner?: string;
}

export interface RegistrationSearchParams {
  searchText?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

// --- Bid Project Interfaces ---

export interface BidProjectDto {
  id: string;
  code: string;
  name: string;
  customer?: string;
  region?: string;
  type?: string;
  budget?: string;
  bidTime?: string;
  leader?: string;
  status: string;
  description?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateBidProjectDto {
  code: string;
  name: string;
  customer?: string;
  region?: string;
  type?: string;
  budget?: string;
  bidTime?: string;
  leader?: string;
  status?: string;
  description?: string;
}

export interface UpdateBidProjectDto extends Partial<CreateBidProjectDto> {}

export interface BidProjectSearchParams {
  keyword?: string;
  region?: string;
  type?: string;
  status?: string;
  page?: number;
  pageSize?: number;
}

// ==========================================
// API Functions
// ==========================================

// --- Customer APIs ---

export function getCustomers(params?: CustomerSearchParams) {
  return request.get<any, { items: CustomerDto[]; total: number }>('/sales/customers', { params });
}

export function getCustomer(id: string) {
  return request.get<any, CustomerDto>(`/sales/customers/${id}`);
}

export function createCustomer(data: CreateCustomerDto) {
  return request.post<any, CustomerDto>('/sales/customers', data);
}

export function updateCustomer(id: string, data: UpdateCustomerDto) {
  return request.put<any, CustomerDto>(`/sales/customers/${id}`, data);
}

export function deleteCustomer(id: string) {
  return request.delete<any, boolean>(`/sales/customers/${id}`);
}

export function exportCustomers(params?: CustomerSearchParams) {
  return request.get<any, Blob>('/sales/customers/export', { 
    params,
    responseType: 'blob' 
  });
}

// --- Opportunity APIs ---

export function getOpportunities(params?: any) {
  return request.get<any, OpportunityDto[]>('/sales/opportunities', { params });
}

export function createOpportunity(data: CreateOpportunityDto) {
  return request.post<any, OpportunityDto>('/sales/opportunities', data);
}

export function updateOpportunity(id: string, data: UpdateOpportunityDto) {
  return request.put<any, OpportunityDto>(`/sales/opportunities/${id}`, data);
}

export function deleteOpportunity(id: string) {
  return request.delete<any, boolean>(`/sales/opportunities/${id}`);
}

// --- Materials APIs ---

export interface CreateSalesScriptDto {
  title: string;
  content: string;
  category?: string;
  description?: string;
}

export interface UpdateSalesScriptDto extends Partial<CreateSalesScriptDto> {}

export function getSalesScripts(params?: any) {
  return request.get<any, SalesScriptDto[]>('/sales/materials/scripts', { params });
}

export function createSalesScript(data: CreateSalesScriptDto) {
  return request.post<any, SalesScriptDto>('/sales/materials/scripts', data);
}

export function updateSalesScript(id: string, data: UpdateSalesScriptDto) {
  return request.put<any, SalesScriptDto>(`/sales/materials/scripts/${id}`, data);
}

export function getProductDocs(params?: any) {
  return request.get<any, ProductDocDto[]>('/sales/materials/docs', { params });
}

export function createProductDoc(data: CreateProductDocDto) {
  return request.post<any, ProductDocDto>('/sales/materials/docs', data);
}

export function uploadProductDoc(file: File, parentId?: string) {
  const formData = new FormData();
  formData.append('file', file);
  if (parentId) {
    formData.append('parentId', parentId);
  }
  return request.post('/sales/materials/docs/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
}

export function deleteProductDoc(id: string) {
  return request.delete<any, boolean>(`/sales/materials/docs/${id}`);
}

export function renameProductDoc(id: string, newName: string) {
  return request.put<any, boolean>(`/sales/materials/docs/${id}/rename`, null, { params: { newName } });
}

export function moveProductDoc(id: string, newParentId?: string) {
  return request.put<any, boolean>(`/sales/materials/docs/${id}/move`, null, { params: { newParentId } });
}

export function getProcessRules(params?: any) {
  return request.get<any, ProcessRuleDto[]>('/sales/materials/rules', { params });
}

export interface GenerateScriptFieldRequest {
  targetField: 'title' | 'description' | 'content';
  title?: string;
  description?: string;
  content?: string;
  model?: string;
}

export function generateScriptField(data: GenerateScriptFieldRequest) {
  return request.post<any, string>('/sales/materials/scripts/generate', data);
}

// --- Stats/Target APIs ---

export function getSalesDashboardStats() {
  return request.get<any, SalesDashboardStatsDto>('/sales/stats/dashboard');
}

export function getTeamRanking() {
  return request.get<any, TeamRankingDto[]>('/sales/stats/ranking');
}

export function getSalesTargets(params?: any) {
  return request.get<any, any>('/sales/targets', { params });
}

export function createSalesTarget(data: any) {
  return request.post<any, any>('/sales/targets', data);
}

export function updateSalesTarget(id: string, data: any) {
  return request.put<any, any>(`/sales/targets/${id}`, data);
}

export function deleteSalesTarget(id: string) {
  return request.delete<any, boolean>(`/sales/targets/${id}`);
}

// --- Sales Script Chat API ---

export function sendSalesScriptChat(data: SalesScriptChatDto) {
  return request.post<any, SalesScriptChatResponseDto>('/sales/scripts/chat', data);
}

// --- Registration APIs ---

export function getRegistrations(params?: RegistrationSearchParams) {
  return request.get<any, { items: SalesRegistrationDto[]; total: number }>('/sales/registrations', { params });
}

export function getRegistration(id: string) {
  return request.get<any, SalesRegistrationDto>(`/sales/registrations/${id}`);
}

export function createRegistration(data: CreateRegistrationDto) {
  return request.post<any, SalesRegistrationDto>('/sales/registrations', data);
}

export function updateRegistration(id: string, data: UpdateRegistrationDto) {
  return request.put<any, SalesRegistrationDto>(`/sales/registrations/${id}`, data);
}

export function deleteRegistration(id: string) {
  return request.delete<any, boolean>(`/sales/registrations/${id}`);
}

export function generateRegistration() {
  return request.post<any, CreateRegistrationDto>('/sales/registrations/generate', {}, { timeout: 60000 });
}

// --- Bid Project APIs ---

export function getBidProjects(params?: BidProjectSearchParams) {
  return request.get<any, { items: BidProjectDto[]; total: number }>('/sales/bid-project', { params });
}

export function getBidProject(id: string) {
  return request.get<any, BidProjectDto>(`/sales/bid-project/${id}`);
}

export function createBidProject(data: CreateBidProjectDto) {
  return request.post<any, BidProjectDto>('/sales/bid-project', data);
}

export function updateBidProject(id: string, data: UpdateBidProjectDto) {
  return request.put<any, BidProjectDto>(`/sales/bid-project/${id}`, data);
}

export function deleteBidProject(id: string) {
  return request.delete<any, boolean>(`/sales/bid-project/${id}`);
}
