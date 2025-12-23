import service from '@/utils/request';
import type { ApiResponse } from '@/utils/request';

export interface DataSourceConnection {
  id: number;
  name: string;
  type: string;
  host: string;
  port: string;
  user: string;
  database: string;
  createdAt: string;
}

export interface CreateDataSourceDto {
  name: string;
  type: string;
  host: string;
  port: string;
  user: string;
  password?: string;
  database: string;
}

export interface UpdateDataSourceDto {
  name?: string;
  type?: string;
  host?: string;
  port?: string;
  user?: string;
  password?: string;
  database?: string;
}

export interface DatabaseSchema {
  name: string;
  charSet?: string;
  collation?: string;
  tableCount?: number;
  dataLength?: number;
}

export interface TableSchema {
  name: string;
  comment?: string;
  engine?: string;
  rows?: number;
  dataLength?: number;
  createTime?: string;
}

export interface ColumnSchema {
  name: string;
  dataType: string;
  columnType: string;
  isNullable: boolean;
  isPrimaryKey: boolean;
  defaultValue?: string;
  comment?: string;
  ordinalPosition: number;
}

export interface FilterCondition {
  field: string;
  operator: string;
  value: string;
}

export interface TableDataQuery {
  page: number;
  pageSize: number;
  sortField?: string;
  sortOrder?: string;
  filters: FilterCondition[];
}

export interface TableDataResult {
  total: number;
  page: number;
  pageSize: number;
  columns: ColumnSchema[];
  rows: Record<string, any>[];
}

export const getDataSources = () => {
  return service.get<any, DataSourceConnection[]>('/DataSource');
};

export const getDataSource = (id: number) => {
  return service.get<any, DataSourceConnection>(`/DataSource/${id}`);
};

export const createDataSource = (data: CreateDataSourceDto) => {
  return service.post<any, DataSourceConnection>('/DataSource', data);
};

export const updateDataSource = (id: number, data: UpdateDataSourceDto) => {
  return service.put<any, DataSourceConnection>(`/DataSource/${id}`, data);
};

export const deleteDataSource = (id: number) => {
  return service.delete<any, any>(`/DataSource/${id}`);
};

export const testConnection = (data: CreateDataSourceDto) => {
  return service.post<any, ApiResponse<boolean>>('/DataSource/test', data);
};

export interface CreateDatabaseDto {
  name: string;
  charSet?: string;
  collation?: string;
}

export const getDatabases = (id: number) => {
  return service.get<any, DatabaseSchema[]>(`/DataSource/${id}/databases`);
};

export interface InsertRowDto {
  data: Record<string, any>;
}

export interface UpdateRowDto {
  keys: Record<string, any>;
  data: Record<string, any>;
}

export interface DeleteRowDto {
  keys: Record<string, any>;
}

export const insertRow = (connectionId: number, databaseName: string, tableName: string, data: Record<string, any>) => {
  return service.post<boolean>(`/DataSource/${connectionId}/databases/${databaseName}/tables/${tableName}/data/insert`, { data });
};

export const updateRow = (connectionId: number, databaseName: string, tableName: string, keys: Record<string, any>, data: Record<string, any>) => {
  return service.post<boolean>(`/DataSource/${connectionId}/databases/${databaseName}/tables/${tableName}/data/update`, { keys, data });
};

export const deleteRow = (connectionId: number, databaseName: string, tableName: string, keys: Record<string, any>) => {
  return service.post<boolean>(`/DataSource/${connectionId}/databases/${databaseName}/tables/${tableName}/data/delete`, { keys });
};

export const createDatabase = (connectionId: number, data: CreateDatabaseDto) => {
  return service.post<any, any>(`/DataSource/${connectionId}/databases`, data);
};

export interface ColumnDefinitionDto {
  name: string;
  dataType: string;
  length?: number;
  precision?: number;
  scale?: number;
  isNullable: boolean;
  isPrimaryKey: boolean;
  isAutoIncrement: boolean;
  defaultValue?: string;
  comment?: string;
}

export interface CreateTableDto {
  name: string;
  comment?: string;
  engine?: string;
  charSet?: string;
  collation?: string;
  columns: ColumnDefinitionDto[];
}

export const createTable = (id: number, databaseName: string, data: CreateTableDto) => {
  return service.post<any, any>(`/DataSource/${id}/databases/${databaseName}/tables`, data);
};

export const getTables = (id: number, databaseName: string) => {
  return service.get<any, TableSchema[]>(`/DataSource/${id}/databases/${databaseName}/tables`);
};

export const getColumns = (id: number, databaseName: string, tableName: string) => {
  return service.get<any, ColumnSchema[]>(`/DataSource/${id}/databases/${databaseName}/tables/${tableName}/columns`);
};

export const getTableData = (id: number, databaseName: string, tableName: string, query: TableDataQuery) => {
  return service.post<any, TableDataResult>(`/DataSource/${id}/databases/${databaseName}/tables/${tableName}/data`, query);
};

export interface AddColumnDto extends ColumnDefinitionDto {
  afterColumn?: string;
  isFirst: boolean;
}

export interface ModifyColumnDto extends ColumnDefinitionDto {
  newName?: string;
  afterColumn?: string;
  isFirst: boolean;
}

export const addColumn = (id: number, databaseName: string, tableName: string, data: AddColumnDto) => {
  return service.post<any, any>(`/DataSource/${id}/databases/${databaseName}/tables/${tableName}/columns`, data);
};

export const modifyColumn = (id: number, databaseName: string, tableName: string, columnName: string, data: ModifyColumnDto) => {
  return service.put<any, any>(`/DataSource/${id}/databases/${databaseName}/tables/${tableName}/columns/${columnName}`, data);
};

export const deleteColumn = (id: number, databaseName: string, tableName: string, columnName: string) => {
  return service.delete<any, any>(`/DataSource/${id}/databases/${databaseName}/tables/${tableName}/columns/${columnName}`);
};
