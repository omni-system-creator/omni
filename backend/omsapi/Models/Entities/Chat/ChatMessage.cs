using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Chat
{
    [Table("sys_chat_message")]
    public class ChatMessage
    {
        [Key]
        public long Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string ConversationKey { get; set; } = string.Empty; // e.g., connA|connB (sorted)
        
        [Required]
        [MaxLength(100)]
        public string SenderConnectionId { get; set; } = string.Empty;
        
        public long? SenderUserId { get; set; }
        
        [MaxLength(100)]
        public string? SenderUserName { get; set; }
        
        [Required]
        [MaxLength(20)]
        public string Type { get; set; } = "text"; // text, image, file
        
        [Required]
        [MaxLength(2000)]
        public string Content { get; set; } = string.Empty;
        
        public string? FileName { get; set; }
        public string? FileSize { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
