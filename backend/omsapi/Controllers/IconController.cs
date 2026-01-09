using Microsoft.AspNetCore.Mvc;
using System.Text.Json.Nodes;

namespace omsapi.Controllers
{
    /// <summary>
    /// Iconify On-Demand API
    /// Serves icons from local JSON files (node_modules or wwwroot)
    /// </summary>
    [Route("api/icons")]
    [ApiController]
    public class IconController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;

        public IconController(IWebHostEnvironment env)
        {
            _env = env;
        }

        [HttpGet("{prefix}.json")]
        public async Task<IActionResult> GetIcons(string prefix, [FromQuery] string? icons)
        {
            if (string.IsNullOrEmpty(icons))
            {
                return BadRequest(new { message = "Icons parameter is required" });
            }

            var iconList = icons.Split(',');

            var jsonPath = Path.Combine(_env.WebRootPath ?? _env.ContentRootPath, "icons", $"{prefix}.json");
            if (!System.IO.File.Exists(jsonPath))
            {
                return NotFound(new { message = $"Icon set '{prefix}' not found. Please ensure it is placed in backend/wwwroot/icons." });
            }

            try
            {
                var jsonString = await System.IO.File.ReadAllTextAsync(jsonPath);
                var root = JsonNode.Parse(jsonString)?.AsObject();

                if (root == null || !root.ContainsKey("icons"))
                {
                    return StatusCode(500, new { message = "Invalid icon set file format" });
                }

                var sourceIcons = root["icons"]?.AsObject();
                var filteredIcons = new JsonObject();
                var aliases = root["aliases"]?.AsObject();
                var filteredAliases = new JsonObject();

                // Create result object with metadata
                var result = new JsonObject();
                foreach (var kvp in root)
                {
                    if (kvp.Key != "icons" && kvp.Key != "aliases" && kvp.Key != "chars" && kvp.Key != "not_found")
                    {
                        result.Add(kvp.Key, kvp.Value?.DeepClone());
                    }
                }

                // Filter icons
                if (sourceIcons != null)
                {
                    foreach (var iconName in iconList)
                    {
                        if (sourceIcons.ContainsKey(iconName))
                        {
                            filteredIcons.Add(iconName, sourceIcons[iconName]?.DeepClone());
                        }
                        // Handle aliases if necessary (basic implementation)
                        else if (aliases != null && aliases.ContainsKey(iconName))
                        {
                            filteredAliases.Add(iconName, aliases[iconName]?.DeepClone());
                            // We should also include the target of the alias if it's not already included
                            // But for simplicity, we just return the alias definition
                            var parent = aliases[iconName]?["parent"]?.ToString();
                            if (!string.IsNullOrEmpty(parent) && sourceIcons.ContainsKey(parent) && !filteredIcons.ContainsKey(parent))
                            {
                                filteredIcons.Add(parent, sourceIcons[parent]?.DeepClone());
                            }
                        }
                    }
                }

                result.Add("icons", filteredIcons);
                if (filteredAliases.Count > 0)
                {
                    result.Add("aliases", filteredAliases);
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Error processing icon set: {ex.Message}" });
            }
        }
    }
}
