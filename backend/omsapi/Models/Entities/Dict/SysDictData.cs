using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Dict
{
    [Table("sys_dict_data")]
    public class SysDictData
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("dict_type_id")]
        public long DictTypeId { get; set; } // FK to SysDictType

        [Column("label")]
        [Required]
        [MaxLength(100)]
        public string Label { get; set; } = string.Empty;

        [Column("value")]
        [Required]
        [MaxLength(100)]
        public string Value { get; set; } = string.Empty;

        [Column("sort")]
        public int Sort { get; set; }

        [Column("status")]
        [MaxLength(20)]
        public string Status { get; set; } = "normal"; // normal, disabled

        [Column("is_default")]
        public bool IsDefault { get; set; } = false;

        [Column("css_class")]
        [MaxLength(100)]
        public string? CssClass { get; set; }

        [Column("list_class")]
        [MaxLength(100)]
        public string? ListClass { get; set; }

        [Column("remark")]
        [MaxLength(500)]
        public string? Remark { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey("DictTypeId")]
        public virtual SysDictType? DictType { get; set; }
    }
}
