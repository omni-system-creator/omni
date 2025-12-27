namespace omsapi.Models.Debug
{
    public enum DebugEventType
    {
        ExecutionStart,
        NodeStart,
        NodeEnd,
        Log,
        Error,
        ExecutionEnd
    }

    public class DebugEvent
    {
        public string SessionId { get; set; } = string.Empty;
        public DebugEventType Type { get; set; }
        public DateTime Timestamp { get; set; } = DateTime.Now;
        public object? Data { get; set; }
    }

    public class NodeEventData
    {
        public string NodeId { get; set; } = string.Empty;
        public string NodeType { get; set; } = string.Empty;
        public string? NodeName { get; set; }
        public object? Input { get; set; }
        public object? Output { get; set; }
        public long DurationMs { get; set; }
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }
    }

    public class LogEventData
    {
        public string Level { get; set; } = "Info";
        public string Message { get; set; } = string.Empty;
    }
}
