using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Chat
{
    [Table("sys_chat_conversation")]
    public class ChatConversation
    {
        [Key]
        public long Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string ConversationKey { get; set; } = string.Empty;

        /// <summary>
        /// 0=Private, 1=Group, 2=System, 3=App
        /// </summary>
        public int Type { get; set; } = 0;

        public long? User1Id { get; set; }
        public long? User2Id { get; set; }
        
        /// <summary>
        /// 关联ID。
        /// 对于群组(Type=1)，此处存GroupId。
        /// 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 "workflow")，则此处存null，通过 ConversationKey 区分。
        /// </summary>
        public long? RelatedId { get; set; }
        
        [MaxLength(100)]
        public string? Name { get; set; }
        
        [MaxLength(500)]
        public string? Avatar { get; set; }

        // Cache last message info for list display
        [MaxLength(2000)]
        public string LastMessageContent { get; set; } = string.Empty;
        [MaxLength(20)]
        public string LastMessageType { get; set; } = "text";
        public DateTime LastMessageTime { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
    }
}
