namespace omsapi.Models.Dtos.Data
{
    public class DatabaseSchemaDto
    {
        public string Name { get; set; } = string.Empty;
        public string? CharSet { get; set; }
        public string? Collation { get; set; }
        public long? TableCount { get; set; }
        public long? DataLength { get; set; }
    }

    public class TableSchemaDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Comment { get; set; }
        public string? Engine { get; set; }
        public long? Rows { get; set; }
        public long? DataLength { get; set; }
        public DateTime? CreateTime { get; set; }
    }

    public class ColumnSchemaDto
    {
        public string Name { get; set; } = string.Empty;
        public string DataType { get; set; } = string.Empty;
        public string ColumnType { get; set; } = string.Empty; // e.g., varchar(100)
        public bool IsNullable { get; set; }
        public bool IsPrimaryKey { get; set; }
        public string? DefaultValue { get; set; }
        public string? Comment { get; set; }
        public int OrdinalPosition { get; set; }
        public bool IsAutoIncrement { get; set; }
    }
    
    public class DataPreviewDto
    {
        public List<string> Columns { get; set; } = new();
        public List<Dictionary<string, object?>> Rows { get; set; } = new();
    }

    public class TableDataQueryDto
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
        public string? SortField { get; set; }
        public string? SortOrder { get; set; } // "asc" or "desc"
        public List<FilterConditionDto> Filters { get; set; } = new();
    }

    public class FilterConditionDto
    {
        public string Field { get; set; } = string.Empty;
        public string Operator { get; set; } = "="; // =, !=, >, <, >=, <=, like, in
        public string Value { get; set; } = string.Empty;
    }

    public class TableDataResultDto
    {
        public long Total { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public List<ColumnSchemaDto> Columns { get; set; } = new();
        public List<Dictionary<string, object?>> Rows { get; set; } = new();
    }

    public class InsertRowDto
    {
        public Dictionary<string, object?> Data { get; set; } = new();
    }

    public class UpdateRowDto
    {
        public Dictionary<string, object?> Keys { get; set; } = new();
        public Dictionary<string, object?> Data { get; set; } = new();
    }

    public class DeleteRowDto
    {
        public Dictionary<string, object?> Keys { get; set; } = new();
    }

    public class CreateDatabaseDto
    {
        public string Name { get; set; } = string.Empty;
        public string? CharSet { get; set; } = "utf8mb4";
        public string? Collation { get; set; } = "utf8mb4_general_ci";
    }

    public class CreateTableDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Comment { get; set; }
        public string? Engine { get; set; } = "InnoDB";
        public string? CharSet { get; set; } = "utf8mb4";
        public string? Collation { get; set; } = "utf8mb4_general_ci";
        public List<ColumnDefinitionDto> Columns { get; set; } = new();
    }

    public class ColumnDefinitionDto
    {
        public string Name { get; set; } = string.Empty;
        public string DataType { get; set; } = string.Empty; // int, varchar, etc.
        public int? Length { get; set; }
        public int? Precision { get; set; } // for decimal
        public int? Scale { get; set; } // for decimal
        public bool IsNullable { get; set; } = true;
        public bool IsPrimaryKey { get; set; }
        public bool IsAutoIncrement { get; set; }
        public string? DefaultValue { get; set; }
        public string? Comment { get; set; }
    }

    public class AddColumnDto : ColumnDefinitionDto
    {
        /// <summary>
        /// Name of the column after which to insert the new column.
        /// If null and IsFirst is false, the column is added at the end.
        /// </summary>
        public string? AfterColumn { get; set; }
        
        /// <summary>
        /// Whether to insert the column at the beginning of the table.
        /// </summary>
        public bool IsFirst { get; set; }
    }

    public class ModifyColumnDto : ColumnDefinitionDto
    {
        /// <summary>
        /// New name for the column (if renaming).
        /// </summary>
        public string? NewName { get; set; }

        /// <summary>
        /// Move column after this column.
        /// </summary>
        public string? AfterColumn { get; set; }

        /// <summary>
        /// Move column to the first position.
        /// </summary>
        public bool IsFirst { get; set; }
    }
}
