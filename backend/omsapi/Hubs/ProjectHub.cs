using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace omsapi.Hubs
{
    public class ProjectHub : Hub
    {
        public async Task JoinProject(string projectId, object user, string clientId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, projectId);
            // Notify others in the group
            await Clients.OthersInGroup(projectId).SendAsync("UserJoined", new { user, clientId, timestamp = System.DateTime.Now });
        }

        public async Task LeaveProject(string projectId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, projectId);
        }

        public async Task ProjectAction(string projectId, string action, object payload, object user)
        {
            // Broadcast to others in the group
            await Clients.OthersInGroup(projectId).SendAsync("ProjectAction", new { action, payload, user });
        }

        public async Task CursorMove(string projectId, double x, double y, object user, string clientId)
        {
             await Clients.OthersInGroup(projectId).SendAsync("CursorMove", new { x, y, user, clientId });
        }

        public async Task ElementSelected(string projectId, string clientId, string type, string id, object user)
        {
             await Clients.OthersInGroup(projectId).SendAsync("ElementSelected", new { clientId, type, id, user });
        }
    }
}
