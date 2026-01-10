using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos;
using omsapi.Models.Entities;
using omsapi.Services.Interfaces;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class FileService : IFileService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<FileService> _logger;

        public FileService(OmsContext context, IWebHostEnvironment environment, ILogger<FileService> logger)
        {
            _context = context;
            _environment = environment;
            _logger = logger;
        }

        public async Task<(bool Success, string Message, List<FileDto>? Data)> GetFilesAsync(FileQueryDto query, long currentUserId)
        {
            var dbQuery = _context.Files.AsQueryable();

            if (query.ParentId.HasValue)
            {
                dbQuery = dbQuery.Where(f => f.ParentId == query.ParentId);
            }
            else
            {
                // If ParentId is null, we might want root files.
                // But usually query.ParentId is null means root.
                // However, we should also check if we want ALL files or just root files.
                // Assuming null ParentId means root folder.
                dbQuery = dbQuery.Where(f => f.ParentId == null);
            }

            if (query.OwnerId.HasValue)
            {
                dbQuery = dbQuery.Where(f => f.OwnerId == query.OwnerId);
            }

            if (query.DeptId.HasValue)
            {
                // Get all related dept IDs (self + descendants) to show subordinate organization content
                var allDepts = await _context.Depts.Select(d => new { d.Id, d.ParentId }).ToListAsync();
                var targetDeptIds = new HashSet<long>();
                var stack = new Stack<long>();
                stack.Push(query.DeptId.Value);
                
                while (stack.Count > 0)
                {
                    var currentId = stack.Pop();
                    targetDeptIds.Add(currentId);
                    
                    foreach (var child in allDepts.Where(d => d.ParentId == currentId))
                    {
                        stack.Push(child.Id);
                    }
                }

                dbQuery = dbQuery.Where(f => f.DeptId.HasValue && targetDeptIds.Contains(f.DeptId.Value));

                // Visibility Logic
                var currentUser = await _context.Users.FindAsync(currentUserId);
                var isAdmin = await _context.UserRoles.AnyAsync(ur => ur.UserId == currentUserId && ur.Role.Name == "admin");
                
                if (!isAdmin && currentUser != null)
                {
                    // Users can see:
                    // 1. Public files
                    // 2. Their own files
                    // 3. Files in their own department (internal files) - Assuming dept members can see internal files
                    // If the file belongs to a different dept (even if child), they can only see if Public or Owned.
                    
                    dbQuery = dbQuery.Where(f => 
                        f.IsPublic || 
                        f.OwnerId == currentUserId || 
                        f.DeptId == currentUser.DeptId
                    );
                }
            }
            else
            {
                // If DeptId is not specified, maybe we only want personal files?
                // Or maybe we want all files the user has access to?
                // For now, let's assume strict filtering.
                // If query.DeptId is null, we filter where DeptId is null (personal files).
                // Unless query.OwnerId is set, then we trust OwnerId.
                // Let's rely on the query params passed by controller.
                
                // If IsPublic is requested, we allow files from any Dept (or no Dept)
                if (query.IsPublic.HasValue && query.IsPublic.Value)
                {
                    // Do not restrict DeptId
                }
                else if (query.OwnerId.HasValue && !query.DeptId.HasValue)
                {
                    dbQuery = dbQuery.Where(f => f.DeptId == null);
                }
            }

            if (!string.IsNullOrEmpty(query.Name))
            {
                dbQuery = dbQuery.Where(f => f.Name.Contains(query.Name));
            }

            if (query.IsFolder.HasValue)
            {
                dbQuery = dbQuery.Where(f => f.IsFolder == query.IsFolder);
            }

            if (query.IsPublic.HasValue)
            {
                dbQuery = dbQuery.Where(f => f.IsPublic == query.IsPublic.Value);
            }

            var files = await dbQuery
                .Include(f => f.Owner)
                .Include(f => f.Dept)
                .OrderByDescending(f => f.IsFolder) // Folders first
                .ThenBy(f => f.Name)
                .Select(f => new FileDto
                {
                    Id = f.Id,
                    Name = f.Name,
                    Extension = f.Extension,
                    Size = f.Size,
                    IsFolder = f.IsFolder,
                    ContentType = f.ContentType,
                    ParentId = f.ParentId,
                    OwnerId = f.OwnerId,
                    OwnerName = f.Owner != null ? (f.Owner.Nickname ?? f.Owner.Username) : string.Empty,
                    DeptId = f.DeptId,
                    DeptName = null, 
                    IsPublic = f.IsPublic,
                    CreatedAt = f.CreatedAt,
                    UpdatedAt = f.UpdatedAt,
                    HasChildren = f.Children.Any()
                })
                .ToListAsync();

            // Populate DeptName with full path (e.g. A>B>C)
            var deptIds = files.Where(f => f.DeptId.HasValue).Select(f => f.DeptId!.Value).Distinct().ToList();
            if (deptIds.Any())
            {
                var allRelatedDepts = await _context.Depts
                    .Select(d => new { d.Id, d.ParentId, d.Name })
                    .ToListAsync();
                
                var deptMap = allRelatedDepts.ToDictionary(d => d.Id);

                foreach (var file in files.Where(f => f.DeptId.HasValue))
                {
                    var parts = new List<string>();
                    var currentId = file.DeptId;
                    while (currentId.HasValue && deptMap.ContainsKey(currentId.Value))
                    {
                        // If we encounter the queried department, stop traversing up (show relative path)
                        if (query.DeptId.HasValue && currentId.Value == query.DeptId.Value)
                        {
                            break;
                        }

                        var node = deptMap[currentId.Value];
                        parts.Insert(0, node.Name);
                        currentId = node.ParentId;
                    }
                    file.DeptName = string.Join(">", parts);
                }
            }

            return (true, "获取成功", files);
        }

        public async Task<(bool Success, string Message, FileDto? Data)> GetFileByIdAsync(long id)
        {
            var f = await _context.Files
                .Include(f => f.Owner)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (f == null) return (false, "文件不存在", null);

            var dto = new FileDto
            {
                Id = f.Id,
                Name = f.Name,
                Extension = f.Extension,
                Size = f.Size,
                IsFolder = f.IsFolder,
                ContentType = f.ContentType,
                ParentId = f.ParentId,
                OwnerId = f.OwnerId,
                OwnerName = f.Owner != null ? (f.Owner.Nickname ?? f.Owner.Username) : string.Empty,
                DeptId = f.DeptId,
                CreatedAt = f.CreatedAt,
                UpdatedAt = f.UpdatedAt,
                HasChildren = await _context.Files.AnyAsync(c => c.ParentId == f.Id)
            };

            return (true, "获取成功", dto);
        }

        public async Task<(bool Success, string Message, FileDto? Data)> CreateFolderAsync(CreateFolderDto dto, long ownerId)
        {
            // Inherit IsPublic from parent if parent exists and is public
            if (dto.ParentId.HasValue && !dto.IsPublic)
            {
                var parentFolder = await _context.Files.FindAsync(dto.ParentId.Value);
                if (parentFolder != null && parentFolder.IsPublic)
                {
                    dto.IsPublic = true;
                }
            }

            // Check for duplicate name in same parent
            var exists = await _context.Files.AnyAsync(f => 
                f.ParentId == dto.ParentId && 
                f.Name == dto.Name && 
                f.IsFolder &&
                f.OwnerId == ownerId && // Should we scope uniqueness by owner? Or just parent?
                f.DeptId == dto.DeptId // Scope by dept too
            );

            // Actually, uniqueness should be per parent folder.
            // If ParentId is shared, uniqueness is enforced there.
            var parentCheck = _context.Files.Where(f => f.ParentId == dto.ParentId && f.Name == dto.Name);
            if (dto.DeptId.HasValue)
            {
                parentCheck = parentCheck.Where(f => f.DeptId == dto.DeptId);
            }
            else
            {
                parentCheck = parentCheck.Where(f => f.OwnerId == ownerId && f.DeptId == null);
            }

            if (await parentCheck.AnyAsync())
            {
                return (false, "同名文件夹已存在", null);
            }

            var folder = new SystemFile
            {
                Name = dto.Name,
                IsFolder = true,
                ParentId = dto.ParentId,
                OwnerId = ownerId,
                DeptId = dto.DeptId,
                IsPublic = dto.IsPublic,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now,
                Size = 0
            };

            _context.Files.Add(folder);
            await _context.SaveChangesAsync();

            return (true, "创建成功", new FileDto
            {
                Id = folder.Id,
                Name = folder.Name,
                IsFolder = true,
                ParentId = folder.ParentId,
                OwnerId = folder.OwnerId,
                DeptId = folder.DeptId,
                IsPublic = folder.IsPublic,
                CreatedAt = folder.CreatedAt,
                UpdatedAt = folder.UpdatedAt
            });
        }

        public async Task<(bool Success, string Message, FileDto? Data)> UploadFileAsync(IFormFile file, long? parentId, long ownerId, long? deptId, bool isPublic = false)
        {
            if (file == null || file.Length == 0)
            {
                return (false, "请选择文件", null);
            }

            // Inherit IsPublic from parent if parent exists and is public
            if (parentId.HasValue && !isPublic)
            {
                var parentFolder = await _context.Files.FindAsync(parentId.Value);
                if (parentFolder != null && parentFolder.IsPublic)
                {
                    isPublic = true;
                }
            }

            // Check duplicate name and auto-rename
            var fileName = Path.GetFileNameWithoutExtension(file.FileName);
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fullName = fileName + extension;

            int count = 1;
            while (true)
            {
                var check = _context.Files.Where(f => f.ParentId == parentId && f.Name == fullName);
                if (deptId.HasValue)
                {
                    check = check.Where(f => f.DeptId == deptId);
                }
                else
                {
                    check = check.Where(f => f.OwnerId == ownerId && f.DeptId == null);
                }

                if (!await check.AnyAsync()) break;

                fullName = $"{fileName} ({count}){extension}";
                count++;
            }

            try 
            {
                // Build logical path: uploads/drive/{username}/{path}/{filename}
                var user = await _context.Users.FindAsync(ownerId);
                var rawUsername = user?.Username ?? "unknown";
                // Sanitize username
                var username = string.Join("_", rawUsername.Split(Path.GetInvalidFileNameChars()));

                var pathSegments = new List<string>();

                // Recursively find parents to build path
                var currentParentId = parentId;
                while (currentParentId.HasValue)
                {
                    var parent = await _context.Files.FindAsync(currentParentId.Value);
                    if (parent == null) break;
                    
                    // Sanitize folder name
                    var safeParentName = string.Join("_", parent.Name.Split(Path.GetInvalidFileNameChars()));
                    pathSegments.Insert(0, safeParentName);
                    
                    currentParentId = parent.ParentId;
                }

                var drivePath = Path.Combine("uploads", "drive", username);
                if (pathSegments.Any())
                {
                    drivePath = Path.Combine(drivePath, Path.Combine(pathSegments.ToArray()));
                }

                var relativeFolder = drivePath;
                var webRootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                var uploadPath = Path.Combine(webRootPath, relativeFolder);
                
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                // Handle duplicate filenames on disk by appending (1), (2), etc.
                // Sanitize filename
                var safeFileName = string.Join("_", fileName.Split(Path.GetInvalidFileNameChars()));
                var uniqueFileName = safeFileName + extension;
                
                var filePath = Path.Combine(uploadPath, uniqueFileName);
                int duplicateCount = 1;
                while (File.Exists(filePath))
                {
                    uniqueFileName = $"{safeFileName} ({duplicateCount}){extension}";
                    filePath = Path.Combine(uploadPath, uniqueFileName);
                    duplicateCount++;
                }

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }

                var dbFile = new SystemFile
                {
                    Name = fullName, // Keep original name for display
                    Extension = extension,
                    Size = file.Length,
                    IsFolder = false,
                    ContentType = file.ContentType,
                    FilePath = Path.Combine(relativeFolder, uniqueFileName).Replace("\\", "/"),
                    ParentId = parentId,
                    OwnerId = ownerId,
                    DeptId = deptId,
                    IsPublic = isPublic,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now
                };

                _context.Files.Add(dbFile);
                await _context.SaveChangesAsync();

                return (true, "上传成功", new FileDto
                {
                    Id = dbFile.Id,
                    Name = dbFile.Name,
                    Extension = dbFile.Extension,
                    Size = dbFile.Size,
                    IsFolder = false,
                    ContentType = dbFile.ContentType,
                    ParentId = dbFile.ParentId,
                    OwnerId = dbFile.OwnerId,
                    DeptId = dbFile.DeptId,
                    IsPublic = dbFile.IsPublic,
                    CreatedAt = dbFile.CreatedAt,
                    UpdatedAt = dbFile.UpdatedAt
                });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "File upload failed");
                return (false, "上传失败: " + ex.Message, null);
            }
        }

        public async Task<(bool Success, string Message)> DeleteFileAsync(long id, long ownerId)
        {
            var file = await _context.Files.FindAsync(id);
            if (file == null) return (false, "文件不存在");

            // Permission check: Owner or Admin (not implemented here, assuming caller checks or ownerId matches)
            // For now, strict owner check if personal file
            if (file.DeptId == null && file.OwnerId != ownerId)
            {
                 // In a real app, we might check if user is admin.
                 // Here we assume the Controller passes the current user ID.
                 // If it's a dept file, we need to check dept permissions (skipped for now).
                 return (false, "无权删除");
            }

            // Recursive delete helper
            async Task DeleteRecursive(SystemFile f)
            {
                if (f.IsFolder)
                {
                    var children = await _context.Files.Where(c => c.ParentId == f.Id).ToListAsync();
                    foreach (var child in children)
                    {
                        await DeleteRecursive(child);
                    }
                }
                
                // Delete physical file
                if (!f.IsFolder && !string.IsNullOrEmpty(f.FilePath))
                {
                    try
                    {
                        var fullPath = Path.Combine(_environment.WebRootPath, f.FilePath.Replace("/", Path.DirectorySeparatorChar.ToString()));
                        if (File.Exists(fullPath))
                        {
                            File.Delete(fullPath);
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Failed to delete physical file: {Path}", f.FilePath);
                    }
                }

                _context.Files.Remove(f);
            }

            await DeleteRecursive(file);
            await _context.SaveChangesAsync();

            return (true, "删除成功");
        }

        public async Task<(bool Success, string Message)> UpdateFileAsync(long id, UpdateFileDto dto, long currentUserId)
        {
            var file = await _context.Files.FindAsync(id);
            if (file == null) return (false, "文件不存在");

            // Permission check: Owner or Admin
            // For dept files, ideally Dept Leader too.
            var canManage = file.OwnerId == currentUserId;
            if (!canManage)
            {
                var isAdmin = await _context.UserRoles.AnyAsync(ur => ur.UserId == currentUserId && ur.Role.Name == "admin");
                if (isAdmin) canManage = true;
            }

            if (!canManage && file.DeptId.HasValue)
            {
                 // Check if user is Dept Leader
                 // This requires joining Dept table or fetching it.
                 // For now, let's keep it simple: Owner/Admin.
                 // If the user is the leader of the file's department, they should be able to manage.
                 // Let's implement this later if needed, or assume OwnerId covers the person who uploaded it (who might be the leader).
            }

            if (!canManage) return (false, "无权修改");

            if (!string.IsNullOrEmpty(dto.Name))
            {
                file.Name = dto.Name;
                if (!file.IsFolder)
                {
                     file.Extension = Path.GetExtension(dto.Name).ToLowerInvariant();
                }
            }
            
            if (dto.IsPublic.HasValue)
            {
                file.IsPublic = dto.IsPublic.Value;
            }

            file.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return (true, "更新成功");
        }

        public async Task<(bool Success, string Message)> RenameFileAsync(long id, RenameFileDto dto, long ownerId)
        {
            var file = await _context.Files.FindAsync(id);
            if (file == null) return (false, "文件不存在");

            if (file.DeptId == null && file.OwnerId != ownerId)
            {
                return (false, "无权操作");
            }

            // Check duplicate
            var parentCheck = _context.Files.Where(f => f.ParentId == file.ParentId && f.Name == dto.Name && f.Id != id);
             if (file.DeptId.HasValue)
            {
                parentCheck = parentCheck.Where(f => f.DeptId == file.DeptId);
            }
            else
            {
                parentCheck = parentCheck.Where(f => f.OwnerId == ownerId && f.DeptId == null);
            }

            if (await parentCheck.AnyAsync())
            {
                return (false, "同名文件已存在");
            }

            file.Name = dto.Name;
            if (!file.IsFolder)
            {
                // Update extension if needed? Usually we don't change extension on rename unless specified.
                // The Name usually includes extension for files.
                file.Extension = Path.GetExtension(dto.Name).ToLowerInvariant();
            }
            file.UpdatedAt = DateTime.Now;
            
            await _context.SaveChangesAsync();
            return (true, "重命名成功");
        }

        public async Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadFileAsync(long id, long ownerId)
        {
            var file = await _context.Files.FindAsync(id);
            if (file == null) return (false, "文件不存在", null, null, null);

            if (file.IsFolder) return (false, "无法下载文件夹", null, null, null);

            // Permission check (simplified)
            // if (file.DeptId == null && file.OwnerId != ownerId) return (false, "无权访问", null, null, null);

            if (string.IsNullOrEmpty(file.FilePath)) return (false, "文件路径无效", null, null, null);

            var fullPath = Path.Combine(_environment.WebRootPath, file.FilePath.Replace("/", Path.DirectorySeparatorChar.ToString()));
            if (!File.Exists(fullPath)) return (false, "物理文件丢失", null, null, null);

            var stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read);
            return (true, "获取成功", file.ContentType, stream, file.Name);
        }

        public async Task<(bool Success, string Message)> ShareFileAsync(ShareFileDto dto, long currentUserId)
        {
            var file = await _context.Files.FindAsync(dto.FileId);
            if (file == null) return (false, "文件不存在");

            if (file.OwnerId != currentUserId) return (false, "无权分享该文件");

            // Handle Public Link Share
            if (dto.IsPublicLink)
            {
                var token = Guid.NewGuid().ToString("N");
                var publicShare = new SystemFileShare
                {
                    FileId = dto.FileId,
                    SharedByUserId = currentUserId,
                    SharedToUserId = null,
                    Permission = dto.Permission,
                    CreatedAt = DateTime.Now,
                    Token = token,
                    ExpirationTime = dto.ExpirationTime
                };
                _context.FileShares.Add(publicShare);
                await _context.SaveChangesAsync();
                return (true, token); // Return token as message for frontend to display link
            }

            // Handle User Shares
            if (dto.TargetUserIds == null || !dto.TargetUserIds.Any())
            {
                return (false, "未选择分享对象");
            }

            // Avoid duplicate shares for same user
            // Since SharedToUserId is nullable in DB but we are querying for specific users here, we cast to long
            // or verify it is not null.
            // Actually, we can just check if SharedToUserId matches any of the targets.
            
            var existingUserIds = await _context.FileShares
                .Where(s => s.FileId == dto.FileId && s.SharedToUserId.HasValue && dto.TargetUserIds.Contains(s.SharedToUserId.Value))
                .Select(s => s.SharedToUserId!.Value)
                .ToListAsync();

            var newShares = dto.TargetUserIds
                .Except(existingUserIds)
                .Select(userId => new SystemFileShare
                {
                    FileId = dto.FileId,
                    SharedByUserId = currentUserId,
                    SharedToUserId = userId,
                    Permission = dto.Permission,
                    CreatedAt = DateTime.Now,
                    ExpirationTime = dto.ExpirationTime
                });

            if (newShares.Any())
            {
                _context.FileShares.AddRange(newShares);
                await _context.SaveChangesAsync();
            }

            return (true, "分享成功");
        }

        public async Task<(bool Success, string Message, List<FileShareDto>? Data)> GetSharedWithMeAsync(long currentUserId)
        {
            var shares = await _context.FileShares
                .Include(s => s.File)
                .Include(s => s.SharedByUser)
                .Where(s => s.SharedToUserId == currentUserId && (s.ExpirationTime == null || s.ExpirationTime > DateTime.Now))
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => new FileShareDto
                {
                    Id = s.Id,
                    FileId = s.FileId,
                    FileName = s.File.Name,
                    IsFolder = s.File.IsFolder,
                    SharedByUserId = s.SharedByUserId,
                    SharedByUserName = s.SharedByUser.Nickname ?? s.SharedByUser.Username,
                    SharedToUserId = s.SharedToUserId,
                    Permission = s.Permission,
                    CreatedAt = s.CreatedAt,
                    ExpirationTime = s.ExpirationTime
                })
                .ToListAsync();

            return (true, "获取成功", shares);
        }

        public async Task<(bool Success, string Message, List<FileShareDto>? Data)> GetMySharedFilesAsync(long currentUserId)
        {
            var shares = await _context.FileShares
                .Include(s => s.File)
                .Include(s => s.SharedToUser)
                .Where(s => s.SharedByUserId == currentUserId)
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => new FileShareDto
                {
                    Id = s.Id,
                    FileId = s.FileId,
                    FileName = s.File.Name,
                    IsFolder = s.File.IsFolder,
                    SharedByUserId = s.SharedByUserId,
                    SharedToUserId = s.SharedToUserId,
                    SharedToUserName = s.SharedToUser != null ? (s.SharedToUser.Nickname ?? s.SharedToUser.Username) : "公开链接",
                    Permission = s.Permission,
                    CreatedAt = s.CreatedAt,
                    Token = s.Token,
                    ExpirationTime = s.ExpirationTime
                })
                .ToListAsync();

            return (true, "获取成功", shares);
        }

        public async Task<(bool Success, string Message, FileShareDto? Data)> GetPublicShareByTokenAsync(string token)
        {
            var share = await _context.FileShares
                .Include(s => s.File)
                .Include(s => s.SharedByUser)
                .FirstOrDefaultAsync(s => s.Token == token);

            if (share == null) return (false, "分享不存在或已取消", null);
            if (share.ExpirationTime.HasValue && share.ExpirationTime.Value < DateTime.Now) return (false, "分享已过期", null);

            var dto = new FileShareDto
            {
                Id = share.Id,
                FileId = share.FileId,
                FileName = share.File.Name,
                IsFolder = share.File.IsFolder,
                SharedByUserId = share.SharedByUserId,
                SharedByUserName = share.SharedByUser.Nickname ?? share.SharedByUser.Username,
                Permission = share.Permission,
                CreatedAt = share.CreatedAt,
                ExpirationTime = share.ExpirationTime
            };

            return (true, "获取成功", dto);
        }

        public async Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadPublicShareAsync(string token)
        {
            var share = await _context.FileShares
                .Include(s => s.File)
                .FirstOrDefaultAsync(s => s.Token == token);

            if (share == null) return (false, "分享不存在或已取消", null, null, null);
            if (share.ExpirationTime.HasValue && share.ExpirationTime.Value < DateTime.Now) return (false, "分享已过期", null, null, null);

            var file = share.File;
            if (file.IsFolder) return (false, "无法下载文件夹", null, null, null);

            if (string.IsNullOrEmpty(file.FilePath)) return (false, "文件路径无效", null, null, null);

            var fullPath = Path.Combine(_environment.WebRootPath, file.FilePath.Replace("/", Path.DirectorySeparatorChar.ToString()));
            if (!File.Exists(fullPath)) return (false, "物理文件丢失", null, null, null);

            var stream = new FileStream(fullPath, FileMode.Open, FileAccess.Read);
            return (true, "获取成功", file.ContentType, stream, file.Name);
        }
    }
}
