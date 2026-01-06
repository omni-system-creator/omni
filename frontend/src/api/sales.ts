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
  uploadDate?: string;
}

export interface ProcessRuleDto {
  id: string;
  title: string;
  content: string;
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

export function getSalesScripts(params?: any) {
  return request.get<any, SalesScriptDto[]>('/sales/materials/scripts', { params });
}

export function getProductDocs(params?: any) {
  return request.get<any, ProductDocDto[]>('/sales/materials/docs', { params });
}

export function getProcessRules(params?: any) {
  return request.get<any, ProcessRuleDto[]>('/sales/materials/rules', { params });
}

// --- Stats/Target APIs ---

export function getSalesDashboardStats() {
  return request.get<any, SalesDashboardStatsDto>('/sales/stats/dashboard');
}

export function getTeamRanking() {
  return request.get<any, TeamRankingDto[]>('/sales/stats/ranking');
}
