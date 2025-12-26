import request from '@/utils/request';

export function getFormDetail(id: number) {
  return request({
    url: `/form/definitions/${id}`,
    method: 'get'
  });
}

export function submitForm(data: { formId: number; data: string; submittedBy?: string }) {
  return request({
    url: '/form/submit',
    method: 'post',
    data
  });
}
