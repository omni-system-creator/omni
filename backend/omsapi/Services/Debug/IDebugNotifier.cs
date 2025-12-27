using omsapi.Models.Debug;

namespace omsapi.Services.Debug
{
    public interface IDebugNotifier
    {
        Task NotifyAsync(string sessionId, DebugEventType type, object? data);
    }
}
