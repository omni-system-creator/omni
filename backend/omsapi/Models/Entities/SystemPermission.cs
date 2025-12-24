using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities
{
    [Table("sys_permission")]
    public class SystemPermission
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public long? ParentId { get; set; } // 父级权限ID (null为顶级)

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty; // 权限名称 (e.g. "用户管理")

        [Required]
        [MaxLength(100)]
        public string Code { get; set; } = string.Empty; // 权限编码 (e.g. "system:user:view")

        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = "MENU"; // 权限类型: MENU(菜单), BUTTON(按钮/功能), API(接口)

        [MaxLength(200)]
        public string? Path { get; set; } // 路由路径 (仅菜单有效)

        [MaxLength(200)]
        public string? Component { get; set; } // 前端组件路径 (仅菜单有效)

        [MaxLength(1000)]
        public string? Query { get; set; } // 传给组件的参数

        [MaxLength(50)]
        public string? Icon { get; set; } // 菜单图标

        public int SortOrder { get; set; } = 0; // 排序

        public bool IsVisible { get; set; } = true; // 是否在菜单中显示 (即使是MENU类型，也可能隐藏)

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
