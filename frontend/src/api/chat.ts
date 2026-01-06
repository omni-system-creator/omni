import request from '@/utils/request';

export interface ChatMessageDto {
  id: number;
  conversationKey: string;
  senderUserId: number;
  senderName?: string;
  type: 'text' | 'image' | 'file';
  content: string;
  fileName?: string;
  fileSize?: string;
  createdAt: string;
  isSelf: boolean;
}

export interface ConversationDto {
  id: string;
  type: 'private' | 'group' | 'system' | 'app';
  name: string;
  avatar?: string;
  lastMessage: string;
  lastTime: string;
  unreadCount: number;
}

export const chatApi = {
  getConversations(userId: number) {
    return request.get('/chat/conversations', { params: { userId } }) as unknown as Promise<ConversationDto[]>;
  },
  getHistory(params: { myUserId: number; peerUserId: number; page?: number; pageSize?: number }) {
    return request.get('/chat/history', { params }) as unknown as Promise<{ total: number; page: number; pageSize: number; items: ChatMessageDto[] }>;
  },
  send(data: { myUserId: number; peerUserId: number; type?: 'text' | 'image' | 'file'; content: string; fileName?: string; fileSize?: string }) {
    return request.post('/chat/send', data);
  },
  upload(data: { myUserId: number; peerUserId: number; file: File }) {
    const form = new FormData();
    form.append('myUserId', String(data.myUserId));
    form.append('peerUserId', String(data.peerUserId));
    form.append('file', data.file);
    return request.post('/chat/upload', form, {
      headers: {
        'Content-Type': undefined
      }
    });
  },
  seedMock(userId: number = 10) {
    return request.post('/chat/seed-mock', null, { params: { userId } });
  }
};
