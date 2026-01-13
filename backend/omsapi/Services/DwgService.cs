using ACadSharp.IO;
using omsapi.Infrastructure.Attributes;
using omsapi.Services.Interfaces;

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

                // Ensure the document version is compatible with netDxf (up to R2018/AC1032)
                // netDxf supports AC1009 (R12) to AC1032 (R2018).
                // Let's force AC1024 (R2010) or AC1027 (R2013) for better compatibility.
                if (document.Header.Version > ACadSharp.ACadVersion.AC1032)
                {
                    document.Header.Version = ACadSharp.ACadVersion.AC1032;
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
    }
}
