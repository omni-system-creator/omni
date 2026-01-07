import request from '@/utils/request';

export const Api = {
  List: '/sys/org-registration/list',
  Approve: '/sys/org-registration/approve',
  Reject: '/sys/org-registration/reject',
} as const;

export interface SysOrgRegistration {
  id: number;
  orgName: string;
  orgShortName?: string;
  orgAbbr?: string;
  licenseCode?: string;
  licenseFileUrl?: string;
  authLetterFileUrl?: string;
  contactName: string;
  contactPhone: string;
  contactEmail?: string;
  adminUsername: string;
  status: string;
  rejectReason?: string;
  createdAt: string;
}

export interface RegistrationListResult {
  total: number;
  items: SysOrgRegistration[];
}

export const getOrgRegistrationList = (params?: any) =>
  request.get<any, RegistrationListResult>(Api.List, { params });

export const approveOrgRegistration = (id: number) =>
  request.post(`${Api.Approve}/${id}`);

export const rejectOrgRegistration = (id: number, reason: string) =>
  request.post(`${Api.Reject}/${id}`, { reason });

export const deleteOrgRegistration = (id: number) =>
  request.delete(`/sys/org-registration/${id}`);
