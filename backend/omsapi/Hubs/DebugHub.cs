using Microsoft.AspNetCore.SignalR;

namespace omsapi.Hubs
{
    public class DebugHub : Hub
    {
        public async Task JoinGroup(string sessionId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, sessionId);
        }

        public async Task LeaveGroup(string sessionId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, sessionId);
        }
    }
}
