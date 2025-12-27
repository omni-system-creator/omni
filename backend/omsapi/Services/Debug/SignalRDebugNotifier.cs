using Microsoft.AspNetCore.SignalR;
using omsapi.Hubs;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Debug;

namespace omsapi.Services.Debug
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class SignalRDebugNotifier : IDebugNotifier
    {
        private readonly IHubContext<DebugHub> _hubContext;
        private readonly ILogger<SignalRDebugNotifier> _logger;

        public SignalRDebugNotifier(IHubContext<DebugHub> hubContext, ILogger<SignalRDebugNotifier> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task NotifyAsync(string sessionId, DebugEventType type, object? data)
        {
            if (string.IsNullOrEmpty(sessionId)) return;

            var evt = new DebugEvent
            {
                SessionId = sessionId,
                Type = type,
                Timestamp = DateTime.Now,
                Data = data
            };

            try 
            {
                await _hubContext.Clients.Group(sessionId).SendAsync("ReceiveDebugEvent", evt);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send debug event to session {SessionId}", sessionId);
            }
        }
    }
}
