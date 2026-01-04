using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Dict
{
    [Table("sys_dict_category")]
    public class SysDictCategory
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("parent_id")]
        public long? ParentId { get; set; }

        [Column("name")]
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Column("code")]
        [Required]
        [MaxLength(100)]
        public string Code { get; set; } = string.Empty;

        [Column("sort")]
        public int Sort { get; set; }

        [Column("remark")]
        [MaxLength(500)]
        public string? Remark { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey("ParentId")]
        public virtual SysDictCategory? Parent { get; set; }
        
        public virtual ICollection<SysDictCategory> Children { get; set; } = new List<SysDictCategory>();
        public virtual ICollection<SysDictType> DictTypes { get; set; } = new List<SysDictType>();
    }
}
