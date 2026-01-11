using System;

namespace omsapi.Models.Dtos.BigView
{
    public class CreateBigViewProjectDto
    {
        public string? ProjectName { get; set; }
        public string? State { get; set; }
        public string? IndexImage { get; set; }
        public object? Content { get; set; }
        public string? Remarks { get; set; }
    }

    public class UpdateBigViewProjectDto
    {
        public long Id { get; set; }
        public string? ProjectName { get; set; }
        public string? State { get; set; }
        public string? IndexImage { get; set; }
        public object? Content { get; set; }
        public string? Remarks { get; set; }
    }

    public class PublishBigViewProjectDto
    {
        public long Id { get; set; }
        public int State { get; set; } = -1;
    }

    public class BigViewProjectDto
    {
        public long Id { get; set; }
        public string? ProjectName { get; set; }
        public string? State { get; set; }
        public DateTime? CreateTime { get; set; }
        public string? CreateBy { get; set; }
        public string? IsDelete { get; set; }
        public string? IndexImage { get; set; }
        public object? Content { get; set; }
        public string? Remarks { get; set; }
    }
}
