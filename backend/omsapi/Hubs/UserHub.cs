using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using System.Linq;
using System.Security.Claims;
using omsapi.Data;
using Microsoft.EntityFrameworkCore;

namespace omsapi.Hubs
{
    public class UserHub : Hub
    {
        private readonly OmsContext _context;

        public UserHub(OmsContext context)
        {
            _context = context;
        }

        // Thread-safe dictionary to store online users: ConnectionId -> UserInfo
        private static readonly ConcurrentDictionary<string, OnlineUserInfo> _onlineUsers = new();

        public static IEnumerable<OnlineUserInfo> GetConnectionsByUserId(long userId)
        {
            var uidStr = userId.ToString();
            return _onlineUsers.Values.Where(u => u.UserId == uidStr);
        }

        public IEnumerable<OnlineUserInfo> GetOnlineUsers()
        {
            return _onlineUsers.Values;
        }

        public OnlineUserInfo? GetUserByConnection(string connectionId)
        {
            _onlineUsers.TryGetValue(connectionId, out var info);
            return info;
        }

        public override async Task OnConnectedAsync()
        {
            var user = Context.User;
            if (user?.Identity?.IsAuthenticated == true)
            {
                // Use "id" claim which contains the numeric user ID
                var userId = user.FindFirst("id")?.Value;
                var userName = user.FindFirst(ClaimTypes.Name)?.Value ?? "Unknown";

                string? nickname = null;
                string? avatar = null;

                if (long.TryParse(userId, out long uid))
                {
                    // Fetch user details from DB to get latest Nickname and Avatar
                    // We create a new scope or use the injected context. 
                    // Hub lifetime is per-invocation, but OnConnectedAsync is an invocation.
                    // However, ensure DbContext is not disposed if we were to access it later, but here we just await it.
                    var dbUser = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == uid);
                    if (dbUser != null)
                    {
                        nickname = dbUser.Nickname;
                        avatar = dbUser.Avatar;
                    }
                }

                var userInfo = new OnlineUserInfo
                {
                    ConnectionId = Context.ConnectionId,
                    UserId = userId,
                    UserName = userName,
                    Nickname = nickname,
                    Avatar = avatar,
                    LoginTime = DateTime.Now,
                    IpAddress = Context.GetHttpContext()?.Connection?.RemoteIpAddress?.ToString()
                };

                _onlineUsers.TryAdd(Context.ConnectionId, userInfo);

                // Broadcast to all clients that a new user connected
                await Clients.All.SendAsync("UserConnected", userInfo);
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            if (_onlineUsers.TryRemove(Context.ConnectionId, out var userInfo))
            {
                // Broadcast to all clients that a user disconnected
                await Clients.All.SendAsync("UserDisconnected", userInfo.ConnectionId);
            }

            await base.OnDisconnectedAsync(exception);
        }
    }

    public class OnlineUserInfo
    {
        public string ConnectionId { get; set; } = string.Empty;
        public string? UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string? Nickname { get; set; }
        public string? Avatar { get; set; }
        public DateTime LoginTime { get; set; }
        public string? IpAddress { get; set; }
    }
}
