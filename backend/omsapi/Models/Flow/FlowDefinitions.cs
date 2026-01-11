namespace omsapi.Models.Flow
{
    public class FlowConfig
    {
        public List<FlowNode> Nodes { get; set; } = new();
        public List<FlowEdge> Edges { get; set; } = new();
    }

    public class FlowNode
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string? Label { get; set; }
        public FlowNodeData Data { get; set; } = new();
    }

    public class FlowNodeData
    {
        public string? Path { get; set; }
        public string? Method { get; set; }
        public string? SourceId { get; set; }
        public string? DatabaseName { get; set; }
        public string? OpType { get; set; }
        public string? Sql { get; set; }
        public string? Url { get; set; }
        public string? Script { get; set; }
        public string? Language { get; set; }
        public string? ContentType { get; set; }
        public string? ParamMode { get; set; }
        public List<FlowKeyValue>? Params { get; set; }
        public List<FlowKeyValue>? Headers { get; set; }
        public string? JoinMode { get; set; }
    }

    public class FlowKeyValue
    {
        public string Key { get; set; } = string.Empty;
        public string Value { get; set; } = string.Empty;
    }

    public class FlowEdge
    {
        public string Id { get; set; } = string.Empty;
        public string SourceId { get; set; } = string.Empty;
        public string TargetId { get; set; } = string.Empty;
        public string? Condition { get; set; }
    }
}
