using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_user_post")]
    public class SystemUserPost
    {
        public long UserId { get; set; }

        public long PostId { get; set; }

        public long DeptId { get; set; }

        [ForeignKey("UserId")]
        public virtual SystemUser User { get; set; } = null!;

        [ForeignKey("PostId")]
        public virtual SystemPost Post { get; set; } = null!;

        [ForeignKey("DeptId")]
        public virtual SystemDept Dept { get; set; } = null!;
    }
}
