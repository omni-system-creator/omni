using Microsoft.EntityFrameworkCore;
using System.Reflection;
using System.Xml.Linq;

namespace omsapi.Data
{
    public static class XmlCommentExtensions
    {
        /// <summary>
        /// Reads XML documentation and applies comments to database tables and columns.
        /// </summary>
        /// <param name="modelBuilder">The model builder.</param>
        public static void ApplyXmlDocumentation(this ModelBuilder modelBuilder)
        {
            try
            {
                var assembly = Assembly.GetExecutingAssembly();
                // Check multiple locations for the XML file
                var xmlPaths = new[]
                {
                    Path.Combine(AppContext.BaseDirectory, $"{assembly.GetName().Name}.xml"),
                    Path.Combine(Directory.GetCurrentDirectory(), $"{assembly.GetName().Name}.xml"),
                    Path.Combine(Directory.GetCurrentDirectory(), "bin", "Debug", "net10.0", $"{assembly.GetName().Name}.xml")
                };

                string? xmlFile = null;
                foreach (var path in xmlPaths)
                {
                    if (File.Exists(path))
                    {
                        xmlFile = path;
                        break;
                    }
                }

                if (xmlFile == null)
                {
                    // XML file not found, skip comments
                    return;
                }

                var doc = XDocument.Load(xmlFile);
                var members = doc.Descendants("member")
                    .Where(x => x.Attribute("name") != null)
                    .ToDictionary(
                        x => x.Attribute("name")!.Value, 
                        x => x.Element("summary")?.Value.Trim()
                    );

                foreach (var entityType in modelBuilder.Model.GetEntityTypes())
                {
                    // Skip if ClrType is null (e.g. shadow entities)
                    if (entityType.ClrType == null) continue;

                    // Apply table comment
                    var typeName = "T:" + entityType.ClrType.FullName;
                    if (members.TryGetValue(typeName, out var tableComment) && !string.IsNullOrWhiteSpace(tableComment))
                    {
                        // Clean up comment (remove newlines, extra spaces)
                        tableComment = CleanComment(tableComment);
                        entityType.SetComment(tableComment);
                    }

                    // Apply column comments
                    foreach (var property in entityType.GetProperties())
                    {
                        var propertyName = "P:" + entityType.ClrType.FullName + "." + property.Name;
                        if (members.TryGetValue(propertyName, out var columnComment) && !string.IsNullOrWhiteSpace(columnComment))
                        {
                            columnComment = CleanComment(columnComment);
                            property.SetComment(columnComment);
                        }
                    }
                }
            }
            catch (Exception)
            {
                // Ignore errors during comment application to prevent app crash
            }
        }

        private static string CleanComment(string comment)
        {
            if (string.IsNullOrWhiteSpace(comment)) return string.Empty;
            
            // Replace newlines with space and trim multiple spaces
            var lines = comment.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
                               .Select(l => l.Trim())
                               .Where(l => !string.IsNullOrEmpty(l));
            return string.Join(" ", lines);
        }
    }
}
