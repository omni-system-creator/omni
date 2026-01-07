using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Hubs;
using omsapi.Models.Entities.Chat;

namespace omsapi.Controllers
{
    [ApiController]
    [Route("api/chat")]
    public class ChatController : ControllerBase
    {
        private readonly OmsContext _context;
        private readonly IHubContext<UserHub> _hubContext;

        public ChatController(OmsContext context, IHubContext<UserHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        private static string BuildConversationKey(string a, string b)
        {
            if (string.IsNullOrWhiteSpace(a) || string.IsNullOrWhiteSpace(b)) return string.Empty;
            return string.CompareOrdinal(a, b) < 0 ? $"{a}|{b}" : $"{b}|{a}";
        }

        private async Task EnsureConversation(string key, long senderId, long? receiverId, int type, string lastMessage, string msgType, DateTime time)
        {
            var conv = await _context.ChatConversations.FirstOrDefaultAsync(c => c.ConversationKey == key);
            if (conv == null)
            {
                conv = new ChatConversation
                {
                    ConversationKey = key,
                    Type = type,
                    CreatedAt = time,
                    UpdatedAt = time
                };
                
                if (type == 0 && receiverId.HasValue) // Private
                {
                    conv.User1Id = senderId < receiverId ? senderId : receiverId;
                    conv.User2Id = senderId < receiverId ? receiverId : senderId;
                }
                else
                {
                    // For System/App messages, User1Id could be the recipient if it's a direct message
                    // But if it's a broadcast, we might handle it differently.
                    // Assuming 1-on-1 system notification for now as per current logic
                    // User1Id = sender (system/app), User2Id = receiver
                    conv.User1Id = senderId;
                    conv.User2Id = receiverId;
                }
                
                _context.ChatConversations.Add(conv);
            }
            
            conv.LastMessageContent = lastMessage;
            conv.LastMessageType = msgType;
            conv.LastMessageTime = time;
            conv.UpdatedAt = time;
            
            // Should save changes here or let caller do it? 
            // Better to let caller do it if part of larger transaction, but here we can just save.
            // But since we are calling this inside Send/Upload which also save messages, we should probably attach to context and save once.
            // However, to keep it simple, we can save here. But wait, Send/Upload calls SaveChanges for message.
            // We can rely on EF tracking.
        }
 
        [HttpPost("seed-mock")]
        public async Task<ActionResult<object>> SeedMock([FromQuery] long userId = 10)
        {
            // Seed conversations and messages visible to userId=10
            var now = DateTime.Now;
            // Private conversations with user 11 and 12
            var key1 = BuildConversationKey(userId.ToString(), "11");
            var key2 = BuildConversationKey(userId.ToString(), "12");
            await EnsureConversation(key1, userId, 11, 0, "好的，我稍后看一下", "text", new DateTime(2023, 10, 25, 10, 45, 0));
            await EnsureConversation(key2, userId, 12, 0, "这个组件的样式有点问题", "text", new DateTime(2023, 10, 25, 9, 0, 0));
            
            // System and App conversations for user 10
            var sysKey = "sys|10";
            var bizKey = "biz|10";
            try
            {
                await EnsureConversation(sysKey, 0, userId, 2, "系统维护通知：本周六凌晨2点进行升级", "text", new DateTime(2023, 10, 25, 10, 0, 0));
                await EnsureConversation(bizKey, 0, userId, 3, "您有一条新的报销申请待审批", "text", new DateTime(2023, 10, 25, 9, 30, 0));
                var sysConv = await _context.ChatConversations.FirstOrDefaultAsync(c => c.ConversationKey == sysKey);
                if (sysConv != null) sysConv.Name = "系统消息";
                var bizConv = await _context.ChatConversations.FirstOrDefaultAsync(c => c.ConversationKey == bizKey);
                if (bizConv != null) bizConv.Name = "业务审批提醒";
            }
            catch { /* ChatConversation 表不存在时忽略 */ }
            
            // Seed messages for 10|11
            bool has1011 = await _context.ChatMessages.AnyAsync(m => m.ConversationKey == key1);
            if (!has1011)
            {
                _context.ChatMessages.AddRange(new[]
                {
                    new ChatMessage { ConversationKey = key1, SenderConnectionId = "seed", SenderUserId = 11, SenderUserName = "用户 11", Type = "text", Content = "张工，上周那个API接口文档更新了吗？", CreatedAt = new DateTime(2023, 10, 25, 10, 30, 0) },
                    new ChatMessage { ConversationKey = key1, SenderConnectionId = "seed", SenderUserId = userId, SenderUserName = "用户 10", Type = "text", Content = "已经更新了，在Wiki上可以看到。", CreatedAt = new DateTime(2023, 10, 25, 10, 32, 0) },
                    new ChatMessage { ConversationKey = key1, SenderConnectionId = "seed", SenderUserId = 11, SenderUserName = "用户 11", Type = "text", Content = "好的，我稍后看一下", CreatedAt = new DateTime(2023, 10, 25, 10, 45, 0) },
                });
            }
            // Seed messages for 10|12 (one example message)
            bool has1012 = await _context.ChatMessages.AnyAsync(m => m.ConversationKey == key2);
            if (!has1012)
            {
                _context.ChatMessages.AddRange(new[]
                {
                    new ChatMessage { ConversationKey = key2, SenderConnectionId = "seed", SenderUserId = 12, SenderUserName = "用户 12", Type = "text", Content = "这个组件的样式有点问题", CreatedAt = new DateTime(2023, 10, 25, 9, 0, 0) }
                });
            }
            // Seed messages for system/app
            bool hasSys = await _context.ChatMessages.AnyAsync(m => m.ConversationKey == sysKey);
            if (!hasSys)
            {
                _context.ChatMessages.AddRange(new[]
                {
                    new ChatMessage { ConversationKey = sysKey, SenderConnectionId = "seed", SenderUserId = null, SenderUserName = "系统", Type = "text", Content = "系统维护通知：本周六凌晨2点进行升级", CreatedAt = new DateTime(2023, 10, 25, 10, 0, 0) },
                });
            }
            bool hasBiz = await _context.ChatMessages.AnyAsync(m => m.ConversationKey == bizKey);
            if (!hasBiz)
            {
                _context.ChatMessages.AddRange(new[]
                {
                    new ChatMessage { ConversationKey = bizKey, SenderConnectionId = "seed", SenderUserId = null, SenderUserName = "业务", Type = "text", Content = "您有一条新的报销申请待审批", CreatedAt = new DateTime(2023, 10, 25, 9, 30, 0) },
                });
            }
            
            await _context.SaveChangesAsync();
            return Ok(new { code = 200, msg = "Mock 数据已插入", data = (object?)null });
        }
 
        public class SendRequest
        {
            public long MyUserId { get; set; }
            public long PeerUserId { get; set; }
            public string Type { get; set; } = "text";
            public string Content { get; set; } = string.Empty;
            public string? FileName { get; set; }
            public string? FileSize { get; set; }
        }

        public class MessageDto
        {
            public long Id { get; set; }
            public string ConversationKey { get; set; } = string.Empty;
            public long SenderUserId { get; set; }
            public string SenderName { get; set; } = string.Empty;
            public string? SenderNickname { get; set; }
            public string? SenderAvatar { get; set; }
            public string Type { get; set; } = "text";
            public string Content { get; set; } = string.Empty;
            public string? FileName { get; set; }
            public string? FileSize { get; set; }
            public DateTime CreatedAt { get; set; }
            public bool IsSelf { get; set; }
        }

        public class ConversationDto
        {
            public string Id { get; set; } = string.Empty;
            public string Type { get; set; } = "private";
            public string Name { get; set; } = string.Empty;
            public string? Avatar { get; set; }
            public string LastMessage { get; set; } = string.Empty;
            public DateTime LastTime { get; set; }
            public int UnreadCount { get; set; } = 0;
        }

        [HttpGet("conversations")]
        public async Task<ActionResult<object>> GetConversations([FromQuery] long userId)
        {
            var myIdStr = userId.ToString();
            try
            {
                var convs = await _context.ChatConversations
                    .Where(c => c.User1Id == userId || c.User2Id == userId)
                    .OrderByDescending(c => c.LastMessageTime)
                    .ToListAsync();
                var peerIds = convs
                    .Where(c => c.Type == 0)
                    .Select(c => c.User1Id == userId ? (c.User2Id ?? 0) : (c.User1Id ?? 0))
                    .Where(id => id > 0)
                    .Distinct()
                    .ToList();
                var peers = await _context.Users
                    .Where(u => peerIds.Contains(u.Id))
                    .ToDictionaryAsync(u => u.Id, u => new { Name = u.Nickname ?? u.Username, u.Avatar });
                var result = new List<ConversationDto>();
                foreach (var c in convs)
                {
                    string id = "";
                    string name = c.Name ?? "Unknown";
                    string? avatar = c.Avatar;
                    string typeStr = "private";
                    if (c.Type == 0)
                    {
                        typeStr = "private";
                        long peerId = c.User1Id == userId ? (c.User2Id ?? 0) : (c.User1Id ?? 0);
                        id = peerId.ToString();
                        if (peers.ContainsKey(peerId))
                        {
                            name = peers[peerId].Name;
                            avatar = peers[peerId].Avatar;
                        }
                        else
                        {
                            name = $"用户 {peerId}";
                        }
                    }
                    else if (c.Type == 1)
                    {
                        typeStr = "group";
                        id = c.ConversationKey;
                    }
                    else if (c.Type == 2)
                    {
                        typeStr = "system";
                        id = c.ConversationKey;
                    }
                    else if (c.Type == 3)
                    {
                        typeStr = "app";
                        id = c.ConversationKey;
                    }
                    result.Add(new ConversationDto
                    {
                        Id = id,
                        Type = typeStr,
                        Name = name,
                        Avatar = avatar,
                        LastMessage = c.LastMessageContent,
                        LastTime = c.LastMessageTime,
                        UnreadCount = 0
                    });
                }
                return Ok(new { code = 200, msg = "获取成功", data = result });
            }
            catch
            {
                // Fallback: derive conversations from ChatMessages when ChatConversation table doesn't exist
                var rawList = await _context.ChatMessages
                    .Where(m => m.ConversationKey.StartsWith(myIdStr + "|") || m.ConversationKey.EndsWith("|" + myIdStr))
                    .GroupBy(m => m.ConversationKey)
                    .Select(g => g.OrderByDescending(m => m.Id).First())
                    .ToListAsync();
                var peerIds = new List<long>();
                foreach (var msg in rawList)
                {
                    var parts = msg.ConversationKey.Split('|');
                    if (parts.Length == 2)
                    {
                        var p1 = parts[0];
                        var p2 = parts[1];
                        if (p1 == myIdStr && long.TryParse(p2, out long id2)) peerIds.Add(id2);
                        else if (p2 == myIdStr && long.TryParse(p1, out long id1)) peerIds.Add(id1);
                    }
                }
                peerIds = peerIds.Distinct().ToList();
                var peers = await _context.Users
                    .Where(u => peerIds.Contains(u.Id))
                    .ToDictionaryAsync(u => u.Id, u => new { Name = u.Nickname ?? u.Username, u.Avatar });
                var result = new List<ConversationDto>();
                foreach (var msg in rawList)
                {
                    var parts = msg.ConversationKey.Split('|');
                    if (parts.Length != 2) continue;
                    var other = parts[0] == myIdStr ? parts[1] : parts[1] == myIdStr ? parts[0] : "";
                    if (string.IsNullOrEmpty(other)) continue;
                    string typeStr = "private";
                    string id = other;
                    string name = $"用户 {other}";
                    string? avatar = null;
                    if (long.TryParse(other, out long peerId) && peerId > 0)
                    {
                        if (peers.ContainsKey(peerId))
                        {
                            name = peers[peerId].Name;
                            avatar = peers[peerId].Avatar;
                        }
                    }
                    else
                    {
                        // Non-numeric peer key: treat as system/app
                        if (other.Equals("sys", StringComparison.OrdinalIgnoreCase))
                        {
                            typeStr = "system";
                            name = "系统消息";
                        }
                        else
                        {
                            typeStr = "app";
                            name = "业务审批提醒";
                        }
                        id = msg.ConversationKey;
                    }
                    result.Add(new ConversationDto
                    {
                        Id = id,
                        Type = typeStr,
                        Name = name,
                        Avatar = avatar,
                        LastMessage = msg.Type == "image" ? "[图片]" : (msg.Type == "file" ? "[文件]" : msg.Content),
                        LastTime = msg.CreatedAt,
                        UnreadCount = 0
                    });
                }
                return Ok(new { code = 200, msg = "获取成功", data = result.OrderByDescending(x => x.LastTime).ToList() });
            }
        }

        [HttpPost("send")]
        public async Task<ActionResult<object>> Send([FromBody] SendRequest req)
        {
            var key = BuildConversationKey(req.MyUserId.ToString(), req.PeerUserId.ToString());
            if (string.IsNullOrEmpty(key)) return Ok(new { code = 400, msg = "参数错误", data = (object?)null });

            var senderUser = await _context.Users
                .Where(u => u.Id == req.MyUserId)
                .Select(u => new { Name = u.Nickname ?? u.Username, u.Avatar, u.Nickname })
                .FirstOrDefaultAsync();
            
            var senderName = senderUser?.Name ?? "Unknown";

            var msg = new ChatMessage
            {
                ConversationKey = key,
                SenderConnectionId = string.Empty,
                SenderUserId = req.MyUserId,
                SenderUserName = senderName,
                Type = req.Type,
                Content = req.Content,
                FileName = req.FileName,
                FileSize = req.FileSize,
                CreatedAt = DateTime.Now
            };
            _context.ChatMessages.Add(msg);

            // Update Conversation
            await EnsureConversation(key, req.MyUserId, req.PeerUserId, 0, // 0=Private
                req.Type == "image" ? "[图片]" : (req.Type == "file" ? "[文件]" : req.Content),
                req.Type,
                msg.CreatedAt);

            await _context.SaveChangesAsync();

            var dto = new MessageDto
            {
                Id = msg.Id,
                ConversationKey = msg.ConversationKey,
                SenderUserId = msg.SenderUserId ?? 0,
                SenderName = senderName,
                SenderNickname = senderUser?.Nickname,
                SenderAvatar = senderUser?.Avatar,
                Type = msg.Type,
                Content = msg.Content,
                FileName = msg.FileName,
                FileSize = msg.FileSize,
                CreatedAt = msg.CreatedAt,
                IsSelf = false
            };

            // 推送给对端的所有连接
            try
            {
                var peerConns = UserHub.GetConnectionsByUserId(req.PeerUserId).Select(x => x.ConnectionId).ToList();
                if (peerConns.Count > 0)
                {
                    await _hubContext.Clients.Clients(peerConns).SendAsync("ReceivePrivateMessage", dto);
                }
            }
            catch { }
            // 回显给自己所有连接
            try
            {
                var myConns = UserHub.GetConnectionsByUserId(req.MyUserId).Select(x => x.ConnectionId).ToList();
                if (myConns.Count > 0)
                {
                    var selfDto = new MessageDto
                    {
                        Id = msg.Id,
                        ConversationKey = msg.ConversationKey,
                        SenderUserId = msg.SenderUserId ?? 0,
                        SenderName = senderName,
                        SenderNickname = senderUser?.Nickname,
                        SenderAvatar = senderUser?.Avatar,
                        Type = msg.Type,
                        Content = msg.Content,
                        FileName = msg.FileName,
                        FileSize = msg.FileSize,
                        CreatedAt = msg.CreatedAt,
                        IsSelf = true
                    };
                    await _hubContext.Clients.Clients(myConns).SendAsync("ReceivePrivateMessage", selfDto);
                }
            }
            catch { }

            return Ok(new { code = 200, msg = "发送成功", data = (object?)null });
        }

        [HttpGet("history")]
        public async Task<ActionResult<object>> History([FromQuery] long myUserId, [FromQuery] long peerUserId, [FromQuery] int page = 1, [FromQuery] int pageSize = 50)
        {
            var key = BuildConversationKey(myUserId.ToString(), peerUserId.ToString());
            if (string.IsNullOrEmpty(key)) return Ok(new { code = 400, msg = "参数错误", data = (object?)null });

            var query = _context.ChatMessages
                .Where(m => m.ConversationKey == key)
                .OrderByDescending(m => m.Id);

            var total = await query.CountAsync();
            var list = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
            list.Reverse(); // 从旧到新

            var userIds = list.Select(m => m.SenderUserId ?? 0).Distinct().ToList();
            var users = await _context.Users
                .Where(u => userIds.Contains(u.Id))
                .Select(u => new { u.Id, Name = u.Nickname ?? u.Username, u.Avatar, u.Nickname })
                .ToDictionaryAsync(u => u.Id, u => u);

            var result = list.Select(m => {
                var senderId = m.SenderUserId ?? 0;
                var hasUser = users.ContainsKey(senderId);
                var user = hasUser ? users[senderId] : null;
                return new MessageDto
                {
                    Id = m.Id,
                    ConversationKey = m.ConversationKey,
                    SenderUserId = senderId,
                    SenderName = m.SenderUserName ?? (user?.Name ?? "Unknown"),
                    SenderNickname = user?.Nickname,
                    SenderAvatar = user?.Avatar,
                    Type = m.Type,
                    Content = m.Content,
                    FileName = m.FileName,
                    FileSize = m.FileSize,
                    CreatedAt = m.CreatedAt,
                    IsSelf = senderId == myUserId
                };
            }).ToList();

            return Ok(new { code = 200, msg = "获取成功", data = new { items = result, total } });
        }

        [HttpDelete("history")]
        public async Task<ActionResult<object>> DeleteHistory([FromQuery] long myUserId, [FromQuery] long peerUserId)
        {
            var key = BuildConversationKey(myUserId.ToString(), peerUserId.ToString());
            if (string.IsNullOrEmpty(key)) return Ok(new { code = 400, msg = "参数错误", data = (object?)null });

            // Delete messages
            var messages = await _context.ChatMessages.Where(m => m.ConversationKey == key).ToListAsync();
            if (messages.Any())
            {
                _context.ChatMessages.RemoveRange(messages);
            }
            
            // Delete conversation record
            var conv = await _context.ChatConversations.FirstOrDefaultAsync(c => c.ConversationKey == key);
            if (conv != null)
            {
                _context.ChatConversations.Remove(conv);
            }

            await _context.SaveChangesAsync();
            return Ok(new { code = 200, msg = "删除成功", data = (object?)null });
        }

        [HttpDelete("message/{id}")]
        public async Task<ActionResult<object>> DeleteMessage(long id)
        {
            var msg = await _context.ChatMessages.FindAsync(id);
            if (msg == null) return Ok(new { code = 404, msg = "消息不存在", data = (object?)null });

            var key = msg.ConversationKey;
            _context.ChatMessages.Remove(msg);
            
            // Update conversation's LastMessage/LastTime if necessary
            var conv = await _context.ChatConversations.FirstOrDefaultAsync(c => c.ConversationKey == key);
            if (conv != null)
            {
                // Find the new last message (excluding the one being deleted)
                var newLastMsg = await _context.ChatMessages
                    .Where(m => m.ConversationKey == key && m.Id != id)
                    .OrderByDescending(m => m.Id)
                    .FirstOrDefaultAsync();

                if (newLastMsg != null)
                {
                    conv.LastMessageContent = newLastMsg.Type == "image" ? "[图片]" : (newLastMsg.Type == "file" ? "[文件]" : newLastMsg.Content);
                    conv.LastMessageTime = newLastMsg.CreatedAt;
                    conv.UpdatedAt = DateTime.Now;
                }
                else
                {
                    // No messages left
                    conv.LastMessageContent = string.Empty;
                    conv.LastMessageTime = conv.CreatedAt; // Reset to creation time or some default
                    conv.UpdatedAt = DateTime.Now;
                }
            }
            
            await _context.SaveChangesAsync();
            return Ok(new { code = 200, msg = "删除成功", data = (object?)null });
        }

        [HttpPost("upload")]
        public async Task<ActionResult<object>> Upload([FromForm] long myUserId, [FromForm] long peerUserId, [FromForm] IFormFile file)
        {
            if (file == null || file.Length == 0) return Ok(new { code = 400, msg = "文件为空", data = (object?)null });
            var uploadDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "chat", DateTime.Now.ToString("yyyyMM"));
            Directory.CreateDirectory(uploadDir);
            var ext = Path.GetExtension(file.FileName);
            var name = $"{Guid.NewGuid().ToString("N")}{ext}";
            var fullPath = Path.Combine(uploadDir, name);
            using (var stream = System.IO.File.Create(fullPath))
            {
                await file.CopyToAsync(stream);
            }
            var relativeUrl = $"/uploads/chat/{DateTime.Now:yyyyMM}/{name}";

            var key = BuildConversationKey(myUserId.ToString(), peerUserId.ToString());

            var senderName = await _context.Users
                .Where(u => u.Id == myUserId)
                .Select(u => u.Nickname ?? u.Username)
                .FirstOrDefaultAsync() ?? "Unknown";

            var msg = new ChatMessage
            {
                ConversationKey = key,
                SenderUserId = myUserId,
                SenderUserName = senderName,
                Type = (file.ContentType?.StartsWith("image/") ?? false) ? "image" : "file",
                Content = relativeUrl,
                FileName = file.FileName,
                FileSize = $"{Math.Round(file.Length / 1024.0, 1)}KB",
                CreatedAt = DateTime.Now
            };
            _context.ChatMessages.Add(msg);

            // Update Conversation
            await EnsureConversation(key, myUserId, peerUserId, 0, // 0=Private
                msg.Type == "image" ? "[图片]" : "[文件]",
                msg.Type,
                msg.CreatedAt);

            await _context.SaveChangesAsync();

            var dto = new MessageDto
            {
                Id = msg.Id,
                ConversationKey = msg.ConversationKey,
                SenderUserId = msg.SenderUserId ?? 0,
                SenderName = senderName,
                Type = msg.Type,
                Content = msg.Content,
                FileName = msg.FileName,
                FileSize = msg.FileSize,
                CreatedAt = msg.CreatedAt,
                IsSelf = false
            };

            // 广播给双方所有连接
            var peerConns = UserHub.GetConnectionsByUserId(peerUserId).Select(x => x.ConnectionId).ToList();
            var myConns = UserHub.GetConnectionsByUserId(myUserId).Select(x => x.ConnectionId).ToList();
            if (peerConns.Count > 0) await _hubContext.Clients.Clients(peerConns).SendAsync("ReceivePrivateMessage", dto);
            if (myConns.Count > 0) await _hubContext.Clients.Clients(myConns).SendAsync("ReceivePrivateMessage", new MessageDto { 
                Id = msg.Id, ConversationKey = msg.ConversationKey, SenderUserId = msg.SenderUserId ?? 0, SenderName = senderName, Type = msg.Type, Content = msg.Content, FileName = msg.FileName, FileSize = msg.FileSize, CreatedAt = msg.CreatedAt, IsSelf = true 
            });

            return Ok(new { code = 200, msg = "上传成功", data = new { url = relativeUrl } });
        }
    }
}
