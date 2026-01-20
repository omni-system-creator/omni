using ACadSharp.IO;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class DwgService : IDwgService
    {
        private readonly ILogger<DwgService> _logger;

        public DwgService(ILogger<DwgService> logger)
        {
            _logger = logger;
        }

        public Stream ConvertToDxf(string filePath)
        {
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException("DWG file not found", filePath);
            }

            try
            {
                // Read the DWG file
                using var reader = new DwgReader(filePath);
                var document = reader.Read();

                if (document.Header.Version > ACadSharp.ACadVersion.AC1021)
                {
                    document.Header.Version = ACadSharp.ACadVersion.AC1021;
                }
                
                // Force use of a standard unicode font for all styles to ensure visibility
                // LibreCAD may not support SHX or complex fonts, leading to missing text
                foreach (var style in document.TextStyles)
                {
                    // Use "unicode.lff" which is present in LibreCAD fonts and supports wide characters
                    // This replaces "standard" which might be ASCII only
                    style.Filename = "unicode.lff";
                    
                    // Also set the BigFontFilename to empty to avoid confusion
                    style.BigFontFilename = "";
                }

                // Iterate over all entities and ensure text entities have valid styles/heights
                foreach (var entity in document.Entities)
                {
                    if (entity is ACadSharp.Entities.TextEntity text)
                    {
                        // Ensure height is positive
                        if (text.Height <= 0) text.Height = 2.5;
                    }
                    else if (entity is ACadSharp.Entities.MText mtext)
                    {
                        if (mtext.Height <= 0) mtext.Height = 2.5;
                    }
                }

                // Also process blocks
                foreach (var block in document.BlockRecords)
                {
                    foreach (var entity in block.Entities)
                    {
                        if (entity is ACadSharp.Entities.TextEntity text)
                        {
                            if (text.Height <= 0) text.Height = 2.5;
                        }
                        else if (entity is ACadSharp.Entities.MText mtext)
                        {
                            if (mtext.Height <= 0) mtext.Height = 2.5;
                        }
                    }
                }

                // Save to DXF memory stream
                using var memoryStream = new MemoryStream();
                // DxfWriter version: ACadSharp's writer follows the document's version.
                var writer = new DxfWriter(memoryStream, document, false); // binary=false for text DXF
                writer.Write();
                
                var bytes = memoryStream.ToArray();
                return new MemoryStream(bytes);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error converting DWG to DXF: {FilePath}", filePath);
                throw new Exception($"Failed to convert DWG file: {ex.Message}", ex);
            }
        }

        public async Task<Stream> ConvertToPdfAsync(string filePath, string paperSize = "A3", string orientation = "portrait", CancellationToken cancellationToken = default)
        {
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException("DWG file not found", filePath);
            }

            var tempRoot = Path.Combine(Path.GetTempPath(), "oms_dwg_preview");
            Directory.CreateDirectory(tempRoot);

            var baseName = Guid.NewGuid().ToString("N");
            var dxfPath = Path.Combine(tempRoot, baseName + ".dxf");
            var pdfPath = Path.Combine(tempRoot, baseName + ".pdf");

            await using (var dxfStream = ConvertToDxf(filePath))
            {
                dxfStream.Position = 0;
                await using var fileStream = File.Create(dxfPath);
                await dxfStream.CopyToAsync(fileStream, cancellationToken);
            }

            var librecadPath = @"C:\Program Files\LibreCAD\librecad.exe";
            if (!File.Exists(librecadPath))
            {
                // Fallback to PATH or other common locations if needed
                librecadPath = "librecad";
            }

            var dimensions = paperSize.ToUpper() switch
            {
                "A0" => "841x1189",
                "A1" => "594x841",
                "A2" => "420x594",
                "A3" => "297x420",
                "A4" => "210x297",
                "A5" => "148x210",
                "A6" => "105x148",
                "B0" => "1000x1414",
                "B1" => "707x1000",
                "B2" => "500x707",
                "B3" => "353x500",
                "B4" => "250x353",
                "B5" => "176x250",
                "B6" => "125x176",
                _ => "297x420"
            };

            var orientationNormalized = (orientation ?? "portrait").ToLowerInvariant();
            if (orientationNormalized == "landscape")
            {
                var parts = dimensions.Split('x');
                if (parts.Length == 2)
                {
                    dimensions = parts[1] + "x" + parts[0];
                }
            }

            var startInfo = new ProcessStartInfo
            {
                FileName = librecadPath,
                Arguments = $"dxf2pdf -a -p {dimensions} -r 300 -f 5,5,5,5 -t \"{tempRoot}\" -o \"{baseName}.pdf\" \"{dxfPath}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            // Only set offscreen platform on non-Windows systems (e.g. Linux/Docker)
            if (!System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(System.Runtime.InteropServices.OSPlatform.Windows))
            {
                startInfo.Environment["QT_QPA_PLATFORM"] = "offscreen";
            }

            using var process = new Process { StartInfo = startInfo };

            if (!process.Start())
            {
                throw new InvalidOperationException("Failed to start LibreCAD process");
            }

            await process.WaitForExitAsync(cancellationToken);

            if (process.ExitCode != 0)
            {
                var error = await process.StandardError.ReadToEndAsync();
                _logger.LogError("LibreCAD PDF conversion failed with code {Code}: {Error}", process.ExitCode, error);
                throw new Exception("LibreCAD PDF conversion failed");
            }

            if (!File.Exists(pdfPath))
            {
                throw new FileNotFoundException("LibreCAD output not found", pdfPath);
            }

            var bytesResult = await File.ReadAllBytesAsync(pdfPath, cancellationToken);

            try
            {
                File.Delete(dxfPath);
                File.Delete(pdfPath);
            }
            catch
            {
            }

            return new MemoryStream(bytesResult);
        }

        public async Task<Stream> ConvertToSvgAsync(string filePath, CancellationToken cancellationToken = default)
        {
            if (!File.Exists(filePath))
            {
                throw new FileNotFoundException("DWG file not found", filePath);
            }

            var tempRoot = Path.Combine(Path.GetTempPath(), "oms_dwg_preview");
            Directory.CreateDirectory(tempRoot);

            var baseName = Guid.NewGuid().ToString("N");
            var dxfPath = Path.Combine(tempRoot, baseName + ".dxf");
            var svgPath = Path.Combine(tempRoot, baseName + ".svg");

            await using (var dxfStream = ConvertToDxf(filePath))
            {
                dxfStream.Position = 0;
                await using var fileStream = File.Create(dxfPath);
                await dxfStream.CopyToAsync(fileStream, cancellationToken);
            }

            var librecadPath = @"C:\Program Files\LibreCAD\librecad.exe";
            if (!File.Exists(librecadPath))
            {
                librecadPath = "librecad";
            }

            var startInfo = new ProcessStartInfo
            {
                FileName = librecadPath,
                Arguments = $"dxf2svg \"{dxfPath}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };

            // Set working directory to LibreCAD's directory to ensure it finds Qt plugins
            if (Path.IsPathRooted(librecadPath))
            {
                startInfo.WorkingDirectory = Path.GetDirectoryName(librecadPath);
            }

            // Only set offscreen platform on non-Windows systems (e.g. Linux/Docker)
            if (!System.Runtime.InteropServices.RuntimeInformation.IsOSPlatform(System.Runtime.InteropServices.OSPlatform.Windows))
            {
                startInfo.Environment["QT_QPA_PLATFORM"] = "offscreen";
            }

            using var process = new Process { StartInfo = startInfo };

            if (!process.Start())
            {
                throw new InvalidOperationException("Failed to start LibreCAD process");
            }

            await process.WaitForExitAsync(cancellationToken);

            if (process.ExitCode != 0)
            {
                var error = await process.StandardError.ReadToEndAsync();
                _logger.LogError("LibreCAD SVG conversion failed with code {Code}: {Error}", process.ExitCode, error);
                throw new Exception("LibreCAD SVG conversion failed");
            }

            if (!File.Exists(svgPath))
            {
                throw new FileNotFoundException("LibreCAD output not found", svgPath);
            }

            var rawBytes = await File.ReadAllBytesAsync(svgPath, cancellationToken);
            string text;

            try
            {
                text = Encoding.UTF8.GetString(rawBytes);
            }
            catch
            {
                text = string.Empty;
            }

            if (string.IsNullOrEmpty(text) || text.Contains("�"))
            {
                try
                {
                    var gbk = Encoding.GetEncoding(936);
                    text = gbk.GetString(rawBytes);
                }
                catch
                {
                    text = Encoding.Default.GetString(rawBytes);
                }
            }

            if (!text.StartsWith("<?xml", StringComparison.Ordinal))
            {
                text = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + text;
            }

            var bytesResult = Encoding.UTF8.GetBytes(text);

            try
            {
                File.Delete(dxfPath);
                File.Delete(svgPath);
            }
            catch
            {
            }

            return new MemoryStream(bytesResult);
        }
    }
}
