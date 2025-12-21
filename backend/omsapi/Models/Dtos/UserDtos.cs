using System.ComponentModel.DataAnnotations;

namespace omsapi.Models.Dtos
{
    public class UpdateProfileDto
    {
        [MaxLength(50)]
        public string? Nickname { get; set; }

        [EmailAddress]
        [MaxLength(100)]
        public string? Email { get; set; }

        [Phone]
        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(20)]
        public string? Status { get; set; }
    }

    public class ChangePasswordDto
    {
        [Required]
        public string OldPassword { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; } = string.Empty;
    }

    public class CreateUserDto
    {
        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        [MaxLength(100)]
        public string Password { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? Nickname { get; set; }

        public List<long> RoleIds { get; set; } = new();
        
        public long? DeptId { get; set; }

        public List<UserPostRelationDto> PostRelations { get; set; } = new();
    }

    public class UpdateUserDto
    {
        [MaxLength(50)]
        public string? Nickname { get; set; }

        [EmailAddress]
        [MaxLength(100)]
        public string? Email { get; set; }

        [Phone]
        [MaxLength(20)]
        public string? Phone { get; set; }

        public bool? IsActive { get; set; }

        public List<long>? RoleIds { get; set; }

        public long? DeptId { get; set; }

        public List<UserPostRelationDto>? PostRelations { get; set; }
    }

    public class UserPostRelationDto
    {
        public long DeptId { get; set; }
        public long PostId { get; set; }
    }

    public class UserListDto
    {
        public long Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? Nickname { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Avatar { get; set; }
        public string? Status { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public List<string> Roles { get; set; } = new();
        public List<UserPostDto> Posts { get; set; } = new();
        public DeptDto? Dept { get; set; }
    }

    public class UserPostDto
    {
        public long PostId { get; set; }
        public string PostName { get; set; } = string.Empty;
        public long DeptId { get; set; }
        public string DeptName { get; set; } = string.Empty;
    }
}
