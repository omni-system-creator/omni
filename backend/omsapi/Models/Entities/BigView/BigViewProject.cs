using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.BigView
{
    [Table("bigview_project")]
    public class BigViewProject
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("project_name")]
        [StringLength(255)]
        public string? ProjectName { get; set; }

        /// <summary>
        /// 状态 [-1未发布,1发布]
        /// </summary>
        [Column("state")]
        [StringLength(1)]
        public string? State { get; set; }

        [Column("create_time")]
        public DateTime? CreateTime { get; set; }

        [Column("create_by")]
        public string? CreateBy { get; set; }

        [Column("is_delete")]
        [StringLength(1)]
        public string? IsDelete { get; set; }

        [Column("index_image")]
        [StringLength(1000)]
        public string? IndexImage { get; set; }

        [Column("content")]
        public string? Content { get; set; }

        [Column("remarks")]
        [StringLength(1000)]
        public string? Remarks { get; set; }
    }
}
