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
        public string? OpType { get; set; }
        public string? Sql { get; set; }
        public string? Url { get; set; }
        public string? Script { get; set; }
        public string? Language { get; set; }
        public string? ContentType { get; set; }
    }

    public class FlowEdge
    {
        public string Id { get; set; } = string.Empty;
        public string SourceId { get; set; } = string.Empty;
        public string TargetId { get; set; } = string.Empty;
    }
}
