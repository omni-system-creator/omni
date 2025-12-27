using System.Data;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Flow;

using omsapi.Models.Debug;
using omsapi.Services.Debug;
using Jint;
using Jint.Runtime;
using Microsoft.CodeAnalysis.CSharp.Scripting;
using Microsoft.CodeAnalysis.Scripting;
using System.Diagnostics;

namespace omsapi.Services
{
    public class ScriptGlobals
    {
        public required Dictionary<string, object?> context { get; set; }
        public required Action<string> log { get; set; }
    }

    public class ExecuteRequestDto
    {
        public Dictionary<string, object>? Params { get; set; }
        public object? Body { get; set; }
        public string? SessionId { get; set; } // For debug real-time feedback
    }

    public class ExecuteResultDto
    {
        public int StatusCode { get; set; }
        public object? Data { get; set; }
        public string? Error { get; set; }
        public List<string>? Logs { get; set; }
        public List<string> ExecutedNodes { get; set; } = new();
    }

    public class DebugFlowRequestDto
    {
        public string FlowConfig { get; set; } = string.Empty;
        public ExecuteRequestDto Data { get; set; } = new();
    }

    [AutoInject]
    public class InterfaceExecutionService
    {
        private readonly OmsContext _context;
        private readonly ILogger<InterfaceExecutionService> _logger;
        private readonly IDebugNotifier _notifier;
        private readonly IHttpClientFactory _httpClientFactory;

        public InterfaceExecutionService(OmsContext context, ILogger<InterfaceExecutionService> logger, IDebugNotifier notifier, IHttpClientFactory httpClientFactory)
        {
            _context = context;
            _logger = logger;
            _notifier = notifier;
            _httpClientFactory = httpClientFactory;
        }

        public async Task<ExecuteResultDto> ExecuteInterfaceAsync(long interfaceId, ExecuteRequestDto request, bool isDebug = false)
        {
            var iface = await _context.InterfaceDefinitions.FindAsync(interfaceId);
            if (iface == null) throw new Exception("接口不存在");

            return await ExecuteFlowAsync(iface.FlowConfig, request, isDebug);
        }
        
        public async Task<ExecuteResultDto> ExecuteFlowAsync(string? flowConfigJson, ExecuteRequestDto request, bool isDebug = false)
        {
            var logs = new List<string>();
            var executedNodes = new List<string>();
            var sessionId = request.SessionId;
            var flowSw = System.Diagnostics.Stopwatch.StartNew();

            // Helper for logging both locally and to SignalR
            async Task LogAsync(string msg, string level = "Info") 
            { 
                if (isDebug) 
                {
                    logs.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");
                    if (!string.IsNullOrEmpty(sessionId))
                    {
                        await _notifier.NotifyAsync(sessionId, DebugEventType.Log, new LogEventData { Level = level, Message = msg });
                    }
                } 
            }

            if (!string.IsNullOrEmpty(sessionId))
            {
                await _notifier.NotifyAsync(sessionId, DebugEventType.ExecutionStart, null);
            }

            if (string.IsNullOrEmpty(flowConfigJson))
            {
                var err = "Flow config is empty";
                if (!string.IsNullOrEmpty(sessionId)) await _notifier.NotifyAsync(sessionId, DebugEventType.Error, err);
                return new ExecuteResultDto { StatusCode = 500, Logs = logs, Error = err };
            }

            FlowConfig? flow;
            try
            {
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                flow = JsonSerializer.Deserialize<FlowConfig>(flowConfigJson, options);
            }
            catch (Exception ex)
            {
                 var err = "Invalid flow config: " + ex.Message;
                 if (!string.IsNullOrEmpty(sessionId)) await _notifier.NotifyAsync(sessionId, DebugEventType.Error, err);
                 return new ExecuteResultDto { StatusCode = 500, Logs = logs, Error = err };
            }

            if (flow == null || !flow.Nodes.Any())
            {
                 var err = "Empty flow";
                 if (!string.IsNullOrEmpty(sessionId)) await _notifier.NotifyAsync(sessionId, DebugEventType.Error, err);
                 return new ExecuteResultDto { StatusCode = 500, Logs = logs, Error = err };
            }

            // Context for variables
            var context = new Dictionary<string, object>();
            // Flatten params into context
            if (request.Params != null)
            {
                foreach (var kvp in request.Params)
                {
                    context[kvp.Key] = kvp.Value;
                }
            }
            if (request.Body != null)
            {
                context["body"] = request.Body;
            }

            // Find Start Node (Request)
            var currentNode = flow.Nodes.FirstOrDefault(n => n.Type == "request");
            if (currentNode == null)
            {
                 var err = "No request node found";
                 if (!string.IsNullOrEmpty(sessionId)) await _notifier.NotifyAsync(sessionId, DebugEventType.Error, err);
                 return new ExecuteResultDto { StatusCode = 500, Logs = logs, Error = err };
            }

            await LogAsync($"Start execution from node {currentNode.Id} ({currentNode.Label ?? currentNode.Type})");

            object? lastResult = null;
            int steps = 0;
            
            // Queue for BFS traversal to support branching
            var nodeQueue = new Queue<FlowNode>();
            nodeQueue.Enqueue(currentNode);

            // Simple traversal
            while (nodeQueue.Count > 0 && steps < 100)
            {
                currentNode = nodeQueue.Dequeue();
                steps++;
                executedNodes.Add(currentNode.Id);

                // Capture Input Snapshot (Shallow Copy)
                var inputSnapshot = new Dictionary<string, object>(context);

                // Log Node Execution Details
                try 
                {
                    await LogAsync($"[Node Start] ID: {currentNode.Id}, Type: {currentNode.Type}, Label: {currentNode.Label ?? "N/A"}");
                    await LogAsync($"[Node Config] {JsonSerializer.Serialize(currentNode.Data)}");
                    await LogAsync($"[Node Input] {JsonSerializer.Serialize(inputSnapshot)}");
                }
                catch (Exception logEx)
                {
                    await LogAsync($"[Log Error] Failed to serialize node info/input: {logEx.Message}", "Warning");
                }
                
                // Notify Node Start
                if (!string.IsNullOrEmpty(sessionId))
                {
                    await _notifier.NotifyAsync(sessionId, DebugEventType.NodeStart, new NodeEventData 
                    { 
                        NodeId = currentNode.Id, 
                        NodeType = currentNode.Type,
                        NodeName = currentNode.Label 
                    });
                }

                var sw = System.Diagnostics.Stopwatch.StartNew();
                // bool nodeSuccess = true; // Removed unused variable
                // string? nodeError = null; // Removed unused variable

                try
                {
                    switch (currentNode.Type)
                    {
                        case "request":
                            // Input node
                            break;
                        case "database":
                            // ... existing db logic ...
                            
                            lastResult = await ExecuteDatabaseNode(currentNode, context, (msg) => {
                                // Sync log locally
                                if (isDebug) logs.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");
                                // Async notify (fire and forget for now inside this sync delegate)
                                if (!string.IsNullOrEmpty(sessionId)) _notifier.NotifyAsync(sessionId, DebugEventType.Log, new LogEventData { Message = msg });
                            });

                            if (lastResult != null)
                            {
                                context["dbResult"] = lastResult;
                                context[currentNode.Id] = lastResult;
                            }
                            break;
                        case "response":
                            await LogAsync("Response node reached.");

                            // Log total time
                            flowSw.Stop();
                            await LogAsync($"Total execution time: {flowSw.ElapsedMilliseconds} ms");

                            object? responseData;
                            int finalStatusCode = 200;
                            ExecuteResultDto result;        
                            // Determine the raw response data (either from script or last result)
                            if (currentNode.Data.ParamMode == "custom" && !string.IsNullOrWhiteSpace(currentNode.Data.Script))
                            {
                                var jsContext = ConvertToJsFriendly(context) as Dictionary<string, object?>;
                                responseData = ExecuteJintScript(currentNode.Data.Script, jsContext ?? new Dictionary<string, object?>(), (msg) =>
                                {
                                    if (isDebug) logs.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");
                                });
                            }
                            else
                            {
                                responseData = lastResult ?? context;
                            }

                            // Always wrap the data in standard structure
                            responseData = new
                            {
                                code = 200,
                                data = responseData,
                                msg = "Success"
                            };

                            result = new ExecuteResultDto
                            {
                                StatusCode = finalStatusCode,
                                Data = responseData,
                                Logs = logs,
                                ExecutedNodes = executedNodes
                            };

                            // Notify End
                            sw.Stop();
                            if (!string.IsNullOrEmpty(sessionId))
                            {
                                await _notifier.NotifyAsync(sessionId, DebugEventType.NodeEnd, new NodeEventData 
                                { 
                                    NodeId = currentNode.Id, 
                                    Success = true, 
                                    DurationMs = sw.ElapsedMilliseconds,
                                    Input = inputSnapshot,
                                    Output = result.Data
                                });
                                await _notifier.NotifyAsync(sessionId, DebugEventType.ExecutionEnd, result);
                            }
                            return result;

                        case "script":
                            lastResult = await ExecuteScriptNode(currentNode, context, (msg) => {
                                if (isDebug) logs.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");
                                if (!string.IsNullOrEmpty(sessionId)) _notifier.NotifyAsync(sessionId, DebugEventType.Log, new LogEventData { Message = msg });
                            });

                            if (lastResult != null)
                            {
                                context["scriptResult"] = lastResult;
                                context[currentNode.Id] = lastResult;
                            }
                            break;
                        case "api":
                            lastResult = await ExecuteApiNode(currentNode, context, (msg) => {
                                if (isDebug) logs.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");
                                if (!string.IsNullOrEmpty(sessionId)) _notifier.NotifyAsync(sessionId, DebugEventType.Log, new LogEventData { Message = msg });
                            });
                            
                            if (lastResult != null)
                            {
                                context["apiResult"] = lastResult;
                                context[currentNode.Id] = lastResult;
                            }
                            break;
                        default:
                            await LogAsync($"Skipping unsupported node type: {currentNode.Type}");
                            break;
                    }

                    try 
                    {
                        await LogAsync($"[Node Output] {JsonSerializer.Serialize(lastResult)}");
                    }
                    catch (Exception logEx)
                    {
                        await LogAsync($"[Log Error] Failed to serialize output: {logEx.Message}", "Warning");
                    }
                }
                catch (Exception ex)
                {
                    // nodeSuccess = false; // Removed unused
                    var errorMsg = ex.Message;
                    await LogAsync($"Error in node {currentNode.Id}: {errorMsg}", "Error");
                    
                    flowSw.Stop();
                    await LogAsync($"Total execution time (failed): {flowSw.ElapsedMilliseconds} ms");
                    
                    sw.Stop();
                    if (!string.IsNullOrEmpty(sessionId))
                    {
                        await _notifier.NotifyAsync(sessionId, DebugEventType.NodeEnd, new NodeEventData 
                        { 
                            NodeId = currentNode.Id, 
                            Success = false, 
                            ErrorMessage = errorMsg, 
                            DurationMs = sw.ElapsedMilliseconds,
                            Input = inputSnapshot,
                            Output = null
                        });
                        await _notifier.NotifyAsync(sessionId, DebugEventType.Error, errorMsg);
                    }

                    return new ExecuteResultDto { StatusCode = 500, Logs = logs, Error = errorMsg, ExecutedNodes = executedNodes };
                }
                
                sw.Stop();
                if (!string.IsNullOrEmpty(sessionId))
                {
                    await _notifier.NotifyAsync(sessionId, DebugEventType.NodeEnd, new NodeEventData 
                    { 
                        NodeId = currentNode.Id, 
                        Success = true, 
                        DurationMs = sw.ElapsedMilliseconds,
                        Input = inputSnapshot,
                        Output = lastResult
                    });
                }

                // Find next nodes
                var outgoingEdges = flow.Edges.Where(e => e.SourceId == currentNode.Id).ToList();
                if (!outgoingEdges.Any())
                {
                    await LogAsync($"Node {currentNode.Id} has no outgoing edges.");
                    continue;
                }

                // 1. Check Conditional Edges
                foreach (var edge in outgoingEdges.Where(e => !string.IsNullOrWhiteSpace(e.Condition)))
                {
                    try 
                    {
                        var jsContext = ConvertToJsFriendly(context) as Dictionary<string, object?>;
                        if (EvaluateCondition(edge.Condition!, jsContext, (msg) => { }))
                        {
                            await LogAsync($"Condition matched: {edge.Condition}");
                            var targetNode = flow.Nodes.FirstOrDefault(n => n.Id == edge.TargetId);
                            if (targetNode != null) nodeQueue.Enqueue(targetNode);
                        }
                    }
                    catch (Exception ex)
                    {
                        await LogAsync($"Condition error ({edge.Condition}): {ex.Message}", "Warning");
                    }
                }

                // 2. Execute Unconditional Edges (Always)
                foreach (var edge in outgoingEdges.Where(e => string.IsNullOrWhiteSpace(e.Condition)))
                {
                    var targetNode = flow.Nodes.FirstOrDefault(n => n.Id == edge.TargetId);
                    if (targetNode != null) nodeQueue.Enqueue(targetNode);
                }
            }

            flowSw.Stop();
            await LogAsync($"Total execution time: {flowSw.ElapsedMilliseconds} ms");

            var finalResult = new ExecuteResultDto 
            { 
                StatusCode = 200, 
                Data = lastResult,
                Logs = logs,
                ExecutedNodes = executedNodes
            };
            
            if (!string.IsNullOrEmpty(sessionId))
            {
                 await _notifier.NotifyAsync(sessionId, DebugEventType.ExecutionEnd, finalResult);
            }

            return finalResult;
        }

        private async Task<object?> ExecuteDatabaseNode(FlowNode node, Dictionary<string, object> context, Action<string> log)
        {
            var sql = node.Data.Sql;
            if (string.IsNullOrWhiteSpace(sql)) return null;

            log($"Executing SQL: {sql}");
            
            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open) await connection.OpenAsync();

            using var command = connection.CreateCommand();
            command.CommandText = sql;

            // Basic Parameter Injection
            foreach (var kvp in context)
            {
                object? value = kvp.Value;
                if (value is JsonElement element)
                {
                    switch (element.ValueKind)
                    {
                        case JsonValueKind.String:
                            value = element.GetString();
                            break;
                        case JsonValueKind.Number:
                            if (element.TryGetInt64(out var l)) value = l;
                            else value = element.GetDouble();
                            break;
                        case JsonValueKind.True:
                            value = true;
                            break;
                        case JsonValueKind.False:
                            value = false;
                            break;
                        case JsonValueKind.Null:
                            value = null;
                            break;
                    }
                }

                if (value != null && (value is string || value is int || value is long || value is double || value is bool || value is DateTime))
                {
                    var p = command.CreateParameter();
                    p.ParameterName = "@" + kvp.Key;
                    p.Value = value;
                    command.Parameters.Add(p);
                    log($"Added param @{kvp.Key} = {value}");
                }
            }

            if (node.Data.OpType?.ToLower() == "select")
            {
                using var reader = await command.ExecuteReaderAsync();
                var results = new List<object>();
                while (await reader.ReadAsync())
                {
                    var row = new Dictionary<string, object?>();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                    }
                    results.Add(row!);
                }
                log($"SQL returned {results.Count} rows.");
                return results;
            }
            else
            {
                var affected = await command.ExecuteNonQueryAsync();
                log($"SQL affected {affected} rows.");
                return new { affectedRows = affected };
            }
        }
        private async Task<object?> ExecuteApiNode(FlowNode node, Dictionary<string, object> context, Action<string> log)
        {
            var url = node.Data.Url;
            var method = node.Data.Method?.ToUpper() ?? "GET";
            if (string.IsNullOrWhiteSpace(url)) return null;

            var paramMode = node.Data.ParamMode ?? "all";
            var parameters = new Dictionary<string, object?>();

            if (paramMode == "custom")
            {
                 // Only use configured params
                 if (node.Data.Params != null)
                 {
                     foreach (var p in node.Data.Params)
                     {
                         if (string.IsNullOrWhiteSpace(p.Key)) continue;
                         
                         object? val = p.Value;
                         val = EvaluateParamValue(p.Value, context, log);
                         parameters[p.Key] = val;
                     }
                 }
            }
            else
            {
                // Legacy: Use all context
                foreach(var kvp in context)
                {
                    parameters[kvp.Key] = kvp.Value;
                }
            }

            // 1. URL Parameter Replacement (e.g. @id or {id})
            // Iterate parameters to replace in URL
            foreach (var kvp in parameters)
            {
                var valStr = GetValueString(kvp.Value);
                if (valStr != null)
                {
                    url = url.Replace("@" + kvp.Key, valStr).Replace("{" + kvp.Key + "}", valStr);
                }
            }

            var client = _httpClientFactory.CreateClient();
            var request = new HttpRequestMessage(new HttpMethod(method), url);
            
            // Headers
            if (node.Data.Headers != null)
            {
                foreach(var h in node.Data.Headers)
                {
                    if (!string.IsNullOrEmpty(h.Key)) request.Headers.TryAddWithoutValidation(h.Key, h.Value);
                }
            }

            log($"Request: {method} {url}");

            // 2. Body or Query
            if (method == "GET" || method == "DELETE")
            {
                 if (parameters.Any())
                 {
                     var queryBuilder = new System.Text.StringBuilder();
                     var hasQuery = url.Contains("?");
                     
                     foreach (var kvp in parameters)
                     {
                         var valStr = GetValueString(kvp.Value);
                         if (valStr != null)
                         {
                             queryBuilder.Append(hasQuery ? "&" : "?");
                             queryBuilder.Append(System.Web.HttpUtility.UrlEncode(kvp.Key));
                             queryBuilder.Append("=");
                             queryBuilder.Append(System.Web.HttpUtility.UrlEncode(valStr));
                             hasQuery = true;
                         }
                     }
                     request.RequestUri = new Uri(url + queryBuilder.ToString());
                 }
            }
            else // POST, PUT
            {
                // Serialize parameters
                var json = JsonSerializer.Serialize(parameters);
                request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");
            }

            try 
            {
                var response = await client.SendAsync(request);
                log($"Response Status: {response.StatusCode}");
                
                var content = await response.Content.ReadAsStringAsync();
                
                if (response.IsSuccessStatusCode)
                {
                    try 
                    {
                        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                        return JsonSerializer.Deserialize<object>(content, options);
                    }
                    catch
                    {
                        return content;
                    }
                }
                else
                {
                    log($"API Error: {content}");
                    throw new Exception($"API returned {response.StatusCode}: {content}");
                }
            }
            catch (Exception ex)
            {
                log($"Request Failed: {ex.Message}");
                throw;
            }
        }

        private async Task<object?> ExecuteScriptNode(FlowNode node, Dictionary<string, object> context, Action<string> log)
        {
            var script = node.Data.Script;
            var lang = node.Data.Language?.ToLower() ?? "javascript";

            if (string.IsNullOrWhiteSpace(script)) return null;

            // Prepare context
            var jsContext = ConvertToJsFriendly(context) as Dictionary<string, object?> ?? new Dictionary<string, object?>();

            switch (lang)
            {
                case "csharp":
                    return await ExecuteCSharpScript(script, jsContext, log);
                case "python":
                    return await ExecuteProcessScript("python", script, jsContext, log);
                case "matlab":
                    return await ExecuteProcessScript("matlab", script, jsContext, log);
                case "javascript":
                default:
                    return ExecuteJintScript(script, jsContext, log);
            }
        }

        private bool EvaluateCondition(string condition, Dictionary<string, object?>? context, Action<string> log)
        {
             var engine = new Engine(cfg => cfg.AllowClr());
             
             engine.SetValue("context", context);
             if (context != null)
             {
                 foreach (var kvp in context)
                 {
                     engine.SetValue(kvp.Key, kvp.Value);
                 }
             }

             try 
             {
                 var result = engine.Evaluate($"Boolean({condition})");
                 return result.AsBoolean();
             }
             catch (Exception ex)
             {
                 log($"Condition Error: {ex.Message}");
                 throw;
             }
        }

        private object? ExecuteJintScript(string script, Dictionary<string, object?> context, Action<string> log)
        {
             var engine = new Engine(cfg => cfg.AllowClr());
             
             engine.SetValue("context", context);
             engine.SetValue("log", new Action<object>(obj => log(obj?.ToString() ?? "null")));

             try 
             {
                 // If script contains "return", wrap in function. Otherwise evaluate as expression/block.
                 // But user is instructed to use "return".
                 // And complex scripts need to be function wrapped to support return.
                 // If user writes "return {...}", it must be in a function.
                 var wrappedScript = $"(function() {{ {script} }})()";
                 var result = engine.Evaluate(wrappedScript);
                 return result.ToObject();
             }
             catch (JavaScriptException jsex) when (jsex.Message.Contains("return"))
             {
                  // Fallback: If "return" is used outside function (shouldn't happen with wrapper), or syntax error
                  // Try eval raw if wrapper fails? No, wrapper is safer for "return".
                  log($"JS Error: {jsex.Message}");
                  throw;
             }
             catch (Exception ex)
             {
                 log($"JS Error: {ex.Message}");
                 throw;
             }
        }

        private async Task<object?> ExecuteCSharpScript(string script, Dictionary<string, object?> context, Action<string> log)
        {
            try
            {
                var globals = new ScriptGlobals { context = context, log = log };
                var options = ScriptOptions.Default
                    .WithImports("System", "System.Collections.Generic", "System.Linq")
                    .WithReferences(typeof(System.Linq.Enumerable).Assembly);

                // C# scripts return the value of the last expression
                var state = await CSharpScript.RunAsync(script, options, globals);
                return state.ReturnValue;
            }
            catch (CompilationErrorException e)
            {
                log("C# Compilation Error: " + string.Join(Environment.NewLine, e.Diagnostics));
                throw new Exception("Compilation failed");
            }
            catch (Exception ex)
            {
                log($"C# Execution Error: {ex.Message}");
                throw;
            }
        }

        private async Task<object?> ExecuteProcessScript(string type, string script, Dictionary<string, object?> context, Action<string> log)
        {
            var tempDir = Path.Combine(Path.GetTempPath(), "oms_scripts", Guid.NewGuid().ToString());
            Directory.CreateDirectory(tempDir);
            
            var contextPath = Path.Combine(tempDir, "context.json");
            var resultPath = Path.Combine(tempDir, "result.json");
            var scriptPath = Path.Combine(tempDir, type == "python" ? "script.py" : "script.m");

            try
            {
                // Write context
                var jsonOptions = new JsonSerializerOptions { WriteIndented = true };
                await File.WriteAllTextAsync(contextPath, JsonSerializer.Serialize(context, jsonOptions));
                
                // Write script
                await File.WriteAllTextAsync(scriptPath, script);

                ProcessStartInfo psi;
                if (type == "python")
                {
                    // Assume python is in PATH
                    psi = new ProcessStartInfo("python", $"\"{scriptPath}\"")
                    {
                        WorkingDirectory = tempDir,
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };
                }
                else // matlab
                {
                    // Matlab batch execution
                    // matlab -batch "run('script.m')"
                    psi = new ProcessStartInfo("matlab", $"-batch \"run('{Path.GetFileNameWithoutExtension(scriptPath)}');\"")
                    {
                        WorkingDirectory = tempDir,
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };
                }

                log($"Executing {type} script...");
                using var process = Process.Start(psi);
                if (process == null) throw new Exception($"Failed to start {type}");

                var stdout = await process.StandardOutput.ReadToEndAsync();
                var stderr = await process.StandardError.ReadToEndAsync();
                
                await process.WaitForExitAsync();

                if (!string.IsNullOrWhiteSpace(stdout)) log($"STDOUT: {stdout}");
                if (!string.IsNullOrWhiteSpace(stderr)) log($"STDERR: {stderr}");

                if (process.ExitCode != 0)
                {
                    throw new Exception($"{type} exited with code {process.ExitCode}");
                }

                // Try read result.json first (Matlab style)
                if (File.Exists(resultPath))
                {
                    var resultJson = await File.ReadAllTextAsync(resultPath);
                    return JsonSerializer.Deserialize<object>(resultJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                }
                
                // For Python, if it printed JSON to stdout, try to parse the last line or the whole thing
                if (type == "python" && !string.IsNullOrWhiteSpace(stdout))
                {
                    try 
                    {
                        // Try parsing the whole output
                        return JsonSerializer.Deserialize<object>(stdout.Trim());
                    }
                    catch 
                    {
                        // Maybe user printed logs then JSON? Try last line?
                        var lines = stdout.Trim().Split('\n');
                        if (lines.Length > 0)
                        {
                            try { return JsonSerializer.Deserialize<object>(lines.Last().Trim()); } catch { }
                        }
                    }
                }

                return null;
            }
            finally
            {
                try { Directory.Delete(tempDir, true); } catch { }
            }
        }

        private object? EvaluateParamValue(string value, Dictionary<string, object> context, Action<string> log)
        {
             if (string.IsNullOrWhiteSpace(value)) return value;
             
             if (value.StartsWith("@"))
             {
                 try 
                 {
                     var expr = "context." + value.Substring(1);
                     var jsContext = ConvertToJsFriendly(context) as Dictionary<string, object?>;
                     var engine = new Engine(cfg => cfg.AllowClr());
                     engine.SetValue("context", jsContext);
                     var result = engine.Evaluate(expr);
                     return result.ToObject();
                 }
                 catch (Exception ex)
                 {
                     log($"Param evaluation failed ({value}): {ex.Message}. Using literal.");
                     return value; 
                 }
             }
             
             return value;
        }

        private object? ConvertToJsFriendly(object? obj)
        {
            if (obj == null) return null;
            if (obj is JsonElement element)
            {
                switch (element.ValueKind)
                {
                    case JsonValueKind.Object:
                        var dict = new Dictionary<string, object?>();
                        foreach (var prop in element.EnumerateObject())
                        {
                            dict[prop.Name] = ConvertToJsFriendly(prop.Value);
                        }
                        return dict;
                    case JsonValueKind.Array:
                        var jsonList = new List<object?>();
                        foreach (var item in element.EnumerateArray())
                        {
                            jsonList.Add(ConvertToJsFriendly(item));
                        }
                        return jsonList.ToArray();
                    case JsonValueKind.String: return element.GetString();
                    case JsonValueKind.Number: 
                        if (element.TryGetInt64(out var valLong)) return valLong;
                        return element.GetDouble();
                    case JsonValueKind.True: return true;
                    case JsonValueKind.False: return false;
                    default: return null;
                }
            }
            if (obj is IDictionary<string, object> d)
            {
                 var newDict = new Dictionary<string, object?>();
                 foreach(var kvp in d) newDict[kvp.Key] = ConvertToJsFriendly(kvp.Value);
                 return newDict;
            }
            if (obj is IDictionary<string, object?> d2) // Handle nullable value dict
            {
                 var newDict = new Dictionary<string, object?>();
                 foreach(var kvp in d2) newDict[kvp.Key] = ConvertToJsFriendly(kvp.Value);
                 return newDict;
            }
            if (obj is IEnumerable<object> enumerableList)
            {
                return enumerableList.Select(ConvertToJsFriendly).ToList();
            }
            
            return obj;
        }

        private string? GetValueString(object? value)
        {
            if (value == null) return null;
            if (value is JsonElement element)
            {
                switch (element.ValueKind)
                {
                    case JsonValueKind.String: return element.GetString();
                    case JsonValueKind.Number: return element.GetRawText();
                    case JsonValueKind.True: return "true";
                    case JsonValueKind.False: return "false";
                    default: return null;
                }
            }
            if (value is DateTime dt) return dt.ToString("yyyy-MM-dd HH:mm:ss");
            return value.ToString();
        }

    }
}
