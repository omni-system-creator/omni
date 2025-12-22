using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Archive;
using omsapi.Models.Entities.Archive;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class ArchiveService : IArchiveService
    {
        private readonly OmsContext _context;
        private readonly ILogger<ArchiveService> _logger;

        public ArchiveService(OmsContext context, ILogger<ArchiveService> logger)
        {
            _context = context;
            _logger = logger;
        }

        #region Fond
        public async Task<(bool Success, string Message, List<ArchFondDto>? Data)> GetFondsAsync()
        {
            var fonds = await _context.ArchFonds
                .OrderBy(f => f.SortOrder)
                .Select(f => new ArchFondDto
                {
                    Id = f.Id,
                    Code = f.Code,
                    Name = f.Name,
                    Description = f.Description,
                    SortOrder = f.SortOrder,
                    CreatedAt = f.CreatedAt
                })
                .ToListAsync();
            return (true, "Success", fonds);
        }

        public async Task<(bool Success, string Message, ArchFondDto? Data)> CreateFondAsync(CreateFondDto dto)
        {
            if (await _context.ArchFonds.AnyAsync(f => f.Code == dto.Code))
            {
                return (false, "全宗号已存在", null);
            }

            var fond = new ArchFond
            {
                Code = dto.Code,
                Name = dto.Name,
                Description = dto.Description,
                SortOrder = dto.SortOrder
            };

            _context.ArchFonds.Add(fond);
            await _context.SaveChangesAsync();

            return (true, "创建成功", new ArchFondDto
            {
                Id = fond.Id,
                Code = fond.Code,
                Name = fond.Name,
                Description = fond.Description,
                SortOrder = fond.SortOrder,
                CreatedAt = fond.CreatedAt
            });
        }

        public async Task<(bool Success, string Message)> UpdateFondAsync(long id, UpdateFondDto dto)
        {
            var fond = await _context.ArchFonds.FindAsync(id);
            if (fond == null) return (false, "全宗不存在");

            if (!string.IsNullOrEmpty(dto.Code) && dto.Code != fond.Code)
            {
                if (await _context.ArchFonds.AnyAsync(f => f.Code == dto.Code))
                    return (false, "全宗号已存在");
                fond.Code = dto.Code;
            }

            if (!string.IsNullOrEmpty(dto.Name)) fond.Name = dto.Name;
            if (dto.Description != null) fond.Description = dto.Description;
            if (dto.SortOrder.HasValue) fond.SortOrder = dto.SortOrder.Value;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteFondAsync(long id)
        {
            var fond = await _context.ArchFonds.FindAsync(id);
            if (fond == null) return (false, "全宗不存在");

            if (await _context.ArchFiles.AnyAsync(f => f.FondId == id))
                return (false, "该全宗下存在档案，无法删除");

            _context.ArchFonds.Remove(fond);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }
        #endregion

        #region Type
        public async Task<(bool Success, string Message, List<ArchTypeDto>? Data)> GetTypesAsync()
        {
            // Get flat list and build tree
            var types = await _context.ArchTypes
                .OrderBy(t => t.SortOrder)
                .Select(t => new ArchTypeDto
                {
                    Id = t.Id,
                    ParentId = t.ParentId,
                    Code = t.Code,
                    Name = t.Name,
                    SortOrder = t.SortOrder
                })
                .ToListAsync();

            var tree = BuildTypeTree(types, null);
            return (true, "Success", tree);
        }

        private List<ArchTypeDto> BuildTypeTree(List<ArchTypeDto> all, long? parentId)
        {
            return all.Where(t => t.ParentId == parentId)
                .Select(t =>
                {
                    t.Children = BuildTypeTree(all, t.Id);
                    return t;
                })
                .ToList();
        }

        public async Task<(bool Success, string Message, ArchTypeDto? Data)> CreateTypeAsync(CreateArchTypeDto dto)
        {
            if (await _context.ArchTypes.AnyAsync(t => t.Code == dto.Code))
                return (false, "分类号已存在", null);

            var type = new ArchType
            {
                ParentId = dto.ParentId,
                Code = dto.Code,
                Name = dto.Name,
                SortOrder = dto.SortOrder
            };

            _context.ArchTypes.Add(type);
            await _context.SaveChangesAsync();

            return (true, "创建成功", new ArchTypeDto
            {
                Id = type.Id,
                ParentId = type.ParentId,
                Code = type.Code,
                Name = type.Name,
                SortOrder = type.SortOrder
            });
        }

        public async Task<(bool Success, string Message)> UpdateTypeAsync(long id, UpdateArchTypeDto dto)
        {
            var type = await _context.ArchTypes.FindAsync(id);
            if (type == null) return (false, "分类不存在");

            if (!string.IsNullOrEmpty(dto.Code) && dto.Code != type.Code)
            {
                if (await _context.ArchTypes.AnyAsync(t => t.Code == dto.Code))
                    return (false, "分类号已存在");
                type.Code = dto.Code;
            }

            if (!string.IsNullOrEmpty(dto.Name)) type.Name = dto.Name;
            if (dto.ParentId.HasValue) type.ParentId = dto.ParentId;
            if (dto.SortOrder.HasValue) type.SortOrder = dto.SortOrder.Value;

            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteTypeAsync(long id)
        {
            var type = await _context.ArchTypes.FindAsync(id);
            if (type == null) return (false, "分类不存在");

            if (await _context.ArchTypes.AnyAsync(t => t.ParentId == id))
                return (false, "存在子分类，无法删除");

            if (await _context.ArchFiles.AnyAsync(f => f.TypeId == id))
                return (false, "该分类下存在档案，无法删除");

            _context.ArchTypes.Remove(type);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }
        #endregion

        #region ArchFile
        public async Task<(bool Success, string Message, List<ArchFileDto>? Data)> GetArchFilesAsync(ArchQueryDto query)
        {
            var dbQuery = _context.ArchFiles
                .Include(f => f.Fond)
                .Include(f => f.Type)
                .Include(f => f.Box)
                .AsQueryable();

            if (query.FondId.HasValue) dbQuery = dbQuery.Where(f => f.FondId == query.FondId);
            if (query.TypeId.HasValue) dbQuery = dbQuery.Where(f => f.TypeId == query.TypeId);
            if (query.BoxId.HasValue) dbQuery = dbQuery.Where(f => f.BoxId == query.BoxId);
            
            if (!string.IsNullOrEmpty(query.Title)) dbQuery = dbQuery.Where(f => f.Title.Contains(query.Title));
            if (!string.IsNullOrEmpty(query.ArchCode)) dbQuery = dbQuery.Where(f => f.ArchCode.Contains(query.ArchCode));
            if (!string.IsNullOrEmpty(query.Year)) dbQuery = dbQuery.Where(f => f.Year == query.Year);
            if (!string.IsNullOrEmpty(query.RetentionPeriod)) dbQuery = dbQuery.Where(f => f.RetentionPeriod == query.RetentionPeriod);
            if (!string.IsNullOrEmpty(query.SecurityLevel)) dbQuery = dbQuery.Where(f => f.SecurityLevel == query.SecurityLevel);

            // TODO: Pagination
            // For now return all (or top 100)
            
            var files = await dbQuery
                .OrderByDescending(f => f.CreatedAt)
                .Take(1000)
                .Select(f => new ArchFileDto
                {
                    Id = f.Id,
                    FondId = f.FondId,
                    FondName = f.Fond.Name,
                    TypeId = f.TypeId,
                    TypeName = f.Type.Name,
                    BoxId = f.BoxId,
                    BoxCode = f.Box != null ? f.Box.BoxCode : null,
                    ArchCode = f.ArchCode,
                    Title = f.Title,
                    DocNumber = f.DocNumber,
                    Author = f.Author,
                    FileDate = f.FileDate,
                    Year = f.Year,
                    RetentionPeriod = f.RetentionPeriod,
                    SecurityLevel = f.SecurityLevel,
                    PageCount = f.PageCount,
                    Status = f.Status,
                    Keywords = f.Keywords,
                    Remark = f.Remark,
                    SourceFileId = f.SourceFileId,
                    CreatedAt = f.CreatedAt
                })
                .ToListAsync();

            return (true, "Success", files);
        }

        public async Task<(bool Success, string Message, ArchFileDto? Data)> GetArchFileByIdAsync(long id)
        {
            var f = await _context.ArchFiles
                .Include(f => f.Fond)
                .Include(f => f.Type)
                .Include(f => f.Box)
                .Include(f => f.Attachments)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (f == null) return (false, "档案不存在", null);

            var dto = new ArchFileDto
            {
                Id = f.Id,
                FondId = f.FondId,
                FondName = f.Fond.Name,
                TypeId = f.TypeId,
                TypeName = f.Type.Name,
                BoxId = f.BoxId,
                BoxCode = f.Box?.BoxCode,
                ArchCode = f.ArchCode,
                Title = f.Title,
                DocNumber = f.DocNumber,
                Author = f.Author,
                FileDate = f.FileDate,
                Year = f.Year,
                RetentionPeriod = f.RetentionPeriod,
                SecurityLevel = f.SecurityLevel,
                PageCount = f.PageCount,
                Status = f.Status,
                Keywords = f.Keywords,
                Remark = f.Remark,
                SourceFileId = f.SourceFileId,
                CreatedAt = f.CreatedAt,
                Attachments = f.Attachments.Select(a => new ArchAttachmentDto
                {
                    Id = a.Id,
                    FileName = a.FileName,
                    Extension = a.Extension,
                    Size = a.Size,
                    FilePath = a.FilePath,
                    FileId = a.FileId
                }).ToList()
            };

            return (true, "Success", dto);
        }

        public async Task<(bool Success, string Message, ArchFileDto? Data)> CreateArchFileAsync(CreateArchFileDto dto, long currentUserId)
        {
            if (await _context.ArchFiles.AnyAsync(f => f.ArchCode == dto.ArchCode))
                return (false, "档号已存在", null);

            var file = new ArchFile
            {
                FondId = dto.FondId,
                TypeId = dto.TypeId,
                BoxId = dto.BoxId,
                ArchCode = dto.ArchCode,
                Title = dto.Title,
                DocNumber = dto.DocNumber,
                Author = dto.Author,
                FileDate = dto.FileDate,
                Year = dto.Year,
                RetentionPeriod = dto.RetentionPeriod,
                SecurityLevel = dto.SecurityLevel,
                PageCount = dto.PageCount,
                Status = 0, // Draft
                Keywords = dto.Keywords,
                Remark = dto.Remark,
                SourceFileId = dto.SourceFileId,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.ArchFiles.Add(file);
            await _context.SaveChangesAsync();
            
            // If source file exists, we might want to auto-create attachment
            // ... (skipped for now, usually explicit)

            return (true, "创建成功", new ArchFileDto { Id = file.Id });
        }

        public async Task<(bool Success, string Message)> UpdateArchFileAsync(long id, UpdateArchFileDto dto)
        {
            var file = await _context.ArchFiles.FindAsync(id);
            if (file == null) return (false, "档案不存在");

            if (!string.IsNullOrEmpty(dto.ArchCode) && dto.ArchCode != file.ArchCode)
            {
                 if (await _context.ArchFiles.AnyAsync(f => f.ArchCode == dto.ArchCode))
                    return (false, "档号已存在");
                 file.ArchCode = dto.ArchCode;
            }

            if (dto.FondId.HasValue) file.FondId = dto.FondId.Value;
            if (dto.TypeId.HasValue) file.TypeId = dto.TypeId.Value;
            if (dto.BoxId.HasValue) file.BoxId = dto.BoxId.Value;
            if (dto.Title != null) file.Title = dto.Title;
            if (dto.DocNumber != null) file.DocNumber = dto.DocNumber;
            if (dto.Author != null) file.Author = dto.Author;
            if (dto.FileDate.HasValue) file.FileDate = dto.FileDate.Value;
            if (dto.Year != null) file.Year = dto.Year;
            if (dto.RetentionPeriod != null) file.RetentionPeriod = dto.RetentionPeriod;
            if (dto.SecurityLevel != null) file.SecurityLevel = dto.SecurityLevel;
            if (dto.PageCount.HasValue) file.PageCount = dto.PageCount.Value;
            if (dto.Keywords != null) file.Keywords = dto.Keywords;
            if (dto.Remark != null) file.Remark = dto.Remark;

            file.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> DeleteArchFileAsync(long id)
        {
            var file = await _context.ArchFiles.FindAsync(id);
            if (file == null) return (false, "档案不存在");

            _context.ArchFiles.Remove(file);
            await _context.SaveChangesAsync();
            return (true, "删除成功");
        }
        #endregion
    }
}