// Types
export interface PageCategory {
  id: number;
  name: string;
  parentId?: number | null;
  children?: PageCategory[];
  sortOrder?: number;
}

export interface ApiBinding {
  apiId: number;
  triggerEvent: string; // e.g., 'onMounted', 'onClick_btn1'
  paramsMap?: Record<string, string>; // e.g., { "page": "state.page" }
}

export interface PageDefinition {
  id: number;
  name: string;
  categoryId?: number;
  code?: string; // TSX Code
  config?: string; // Visual Config (JSON)
  apiBindings?: ApiBinding[]; // Multiple API Bindings
  description?: string;
  updatedAt?: string;
}

// Mock Data
const mockCategories: PageCategory[] = [
  {
    id: 1,
    name: 'Dashboard Pages',
    children: [
      { id: 11, name: 'Sales' },
      { id: 12, name: 'HR' }
    ]
  },
  {
    id: 2,
    name: 'Report Pages'
  }
];

const mockPages: PageDefinition[] = [
  { id: 101, name: 'Sales Overview', categoryId: 11, code: 'export default () => <div>Sales Overview</div>', updatedAt: '2023-10-01' },
  { id: 102, name: 'Employee List', categoryId: 12, code: 'export default () => <div>Employee List</div>', updatedAt: '2023-10-02' }
];

// API Methods
export const getPageCategoryTree = async () => {
  return new Promise<PageCategory[]>((resolve) => {
    setTimeout(() => resolve(mockCategories), 300);
  });
};

export const createPageCategory = async (data: any) => {
  return new Promise((resolve) => {
    const newCat = { ...data, id: Date.now() };
    mockCategories.push(newCat);
    resolve(newCat);
  });
};

export const updatePageCategory = async (_id: number, data: any) => {
    return Promise.resolve(data);
};

export const deletePageCategory = async (_id: number) => {
    return Promise.resolve(true);
};

export const getPages = async (params: any) => {
  return new Promise<{ items: PageDefinition[], total: number }>((resolve) => {
    setTimeout(() => {
        const list = mockPages.filter(p => !params.categoryId || p.categoryId === params.categoryId);
        resolve({ items: list, total: list.length });
    }, 300);
  });
};

export const getPageById = async (id: number) => {
    return new Promise<PageDefinition>((resolve) => {
        const page = mockPages.find(p => p.id === id);
        resolve(page || {} as any);
    });
};

export const savePage = async (data: any) => {
    return new Promise((resolve) => {
        const existing = mockPages.find(p => p.id === data.id);
        if (existing) {
            Object.assign(existing, data);
        } else {
            mockPages.push({ ...data, id: Date.now() });
        }
        resolve(data);
    });
};

export const deletePage = async (id: number) => {
    const idx = mockPages.findIndex(p => p.id === id);
    if (idx > -1) mockPages.splice(idx, 1);
    return Promise.resolve(true);
};
