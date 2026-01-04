using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Dict
{
    [Table("sys_dict_type")]
    public class SysDictType
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("category_id")]
        public long? CategoryId { get; set; }

        [Column("name")]
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Column("code")]
        [Required]
        [MaxLength(100)]
        public string Code { get; set; } = string.Empty;

        [Column("status")]
        [MaxLength(20)]
        public string Status { get; set; } = "normal"; // normal, disabled

        [Column("remark")]
        [MaxLength(500)]
        public string? Remark { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        [ForeignKey("CategoryId")]
        public virtual SysDictCategory? Category { get; set; }

        public virtual ICollection<SysDictData> DictDatas { get; set; } = new List<SysDictData>();
    }
}
