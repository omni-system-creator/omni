using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Models.Dtos.Pdm;
using omsapi.Models.Entities.Pdm;
using omsapi.Services.Interfaces;
using omsapi.Infrastructure.Attributes;
using System.Security.Claims;
using NPOI.XSSF.UserModel;
using NPOI.SS.UserModel;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class PdmService : IPdmService
    {
        private readonly OmsContext _context;
        private readonly IWebHostEnvironment _environment;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PdmService(OmsContext context, IWebHostEnvironment environment, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _environment = environment;
            _httpContextAccessor = httpContextAccessor;
        }

        private string GetCurrentUserName()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user?.Identity?.IsAuthenticated == true)
            {
                // Try to get nickname or name, fallback to username or ID
                var name = user.FindFirst(ClaimTypes.Name)?.Value; // Usually username
                var id = user.FindFirst("id")?.Value;
                
                // If we want the nickname, we might need to query DB or if it's in claims.
                // For now, let's use Name claim or "User {id}"
                return name ?? (id != null ? $"User {id}" : "Unknown");
            }
            return "System";
        }

        public async Task<List<EbomItemDto>> GetEbomTreesAsync()
        {
            // Getting all items and building tree in memory is easier for small datasets
            var allItems = await _context.PdmEbomItems.ToListAsync();
            var allRelations = await _context.PdmEbomStructures.OrderBy(x => x.SortOrder).ToListAsync();
            var allDocuments = await _context.PdmEbomDocuments.ToListAsync();

            var childIds = allRelations.Select(x => x.ChildId).ToHashSet();
            // Roots are items that are not children of any other item
            var rootItems = allItems.Where(x => !childIds.Contains(x.Id)).ToList();

            // Recursively build tree
            var result = new List<EbomItemDto>();
            foreach (var root in rootItems)
            {
                result.Add(BuildTree(root, allItems, allRelations, allDocuments));
            }

            return result;
        }

        private EbomItemDto BuildTree(PdmEbomItem node, List<PdmEbomItem> allItems, List<PdmEbomStructure> allRelations, List<PdmEbomDocument> allDocuments)
        {
            var dto = new EbomItemDto
            {
                Key = node.Id,
                Title = node.Name,
                Spec = node.Spec,
                Unit = node.Unit,
                Status = node.Status,
                ProductType = node.ProductType,
                Version = node.Version,
                Designer = node.Designer,
                IsLeaf = node.IsLeaf,
                Qty = 1 // Default for root/node itself
            };

            dto.RelatedDocuments = allDocuments
                .Where(d => d.EbomItemId == node.Id)
                .Select(d => new EbomDocumentDto
                {
                    Id = d.Id,
                    Name = d.Name,
                    Path = $"/api/pdm/ebom/documents/{d.Id}/download",
                    FileType = d.FileType,
                    Size = d.Size,
                    UploadedAt = d.UploadedAt
                })
                .ToList();

            var relations = allRelations.Where(r => r.ParentId == node.Id).ToList();
            if (relations.Any())
            {
                foreach (var rel in relations)
                {
                    var childNode = allItems.FirstOrDefault(x => x.Id == rel.ChildId);
                    if (childNode != null)
                    {
                        var childDto = BuildTree(childNode, allItems, allRelations, allDocuments);
                        childDto.Qty = rel.Quantity;
                        if (!string.IsNullOrEmpty(rel.ChildVersion))
                        {
                            childDto.Version = rel.ChildVersion;
                        }
                        dto.Children.Add(childDto);
                    }
                }
            }
            return dto;
        }

        public async Task<EbomDetailDto?> GetEbomItemAsync(string id)
        {
            var item = await _context.PdmEbomItems.FindAsync(id);
            if (item == null) return null;

            var documents = await _context.PdmEbomDocuments
                .Where(d => d.EbomItemId == id)
                .Select(d => new EbomDocumentDto
                {
                    Id = d.Id,
                    Name = d.Name,
                    Path = $"/api/pdm/ebom/documents/{d.Id}/download",
                    FileType = d.FileType,
                    Size = d.Size,
                    UploadedAt = d.UploadedAt
                })
                .ToListAsync();

            var dto = new EbomDetailDto
            {
                Key = item.Id,
                Title = item.Name,
                Version = item.Version,
                Designer = item.Designer,
                Status = item.Status,
                ProductType = item.ProductType,
                Spec = item.Spec,
                Unit = item.Unit,
                RelatedDocuments = documents
            };

            return dto;
        }

        public async Task<List<EbomItemDto>> GetEbomChildrenAsync(string id)
        {
            var relations = await _context.PdmEbomStructures
                .Where(x => x.ParentId == id)
                .OrderBy(x => x.SortOrder)
                .ToListAsync();

            var result = new List<EbomItemDto>();
            foreach (var rel in relations)
            {
                var child = await _context.PdmEbomItems.FindAsync(rel.ChildId);
                if (child != null)
                {
                    var documents = await _context.PdmEbomDocuments
                        .Where(d => d.EbomItemId == child.Id)
                        .Select(d => new EbomDocumentDto
                        {
                            Id = d.Id,
                            Name = d.Name,
                            Path = $"/api/pdm/ebom/documents/{d.Id}/download",
                            FileType = d.FileType,
                            Size = d.Size,
                            UploadedAt = d.UploadedAt
                        })
                        .ToListAsync();

                    var dto = new EbomItemDto
                    {
                        Key = child.Id,
                        Title = child.Name,
                        Spec = child.Spec,
                        Unit = child.Unit,
                        Status = child.Status,
                        ProductType = child.ProductType,
                        Version = !string.IsNullOrEmpty(rel.ChildVersion) ? rel.ChildVersion : child.Version,
                        Designer = child.Designer,
                        IsLeaf = child.IsLeaf,
                        Qty = rel.Quantity,
                        RelatedDocuments = documents
                    };

                    result.Add(dto);
                }
            }
            return result;
        }

        public async Task<EbomItemDto> CreateEbomItemAsync(CreateEbomItemDto dto)
        {
            if (await _context.PdmEbomItems.AnyAsync(x => x.Id == dto.Key))
            {
                throw new InvalidOperationException($"Item with ID '{dto.Key}' already exists.");
            }

            var item = new PdmEbomItem
            {
                Id = dto.Key,
                Name = dto.Title,
                Spec = dto.Spec,
                Unit = dto.Unit,
                ProductType = dto.ProductType,
                IsLeaf = dto.IsLeaf,
                Status = "设计中", // Default
                Version = string.IsNullOrEmpty(dto.Version) ? "1.0" : dto.Version,
                Designer = string.IsNullOrEmpty(dto.Designer) ? "-" : dto.Designer,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.PdmEbomItems.Add(item);

            if (dto.RelatedDocuments != null && dto.RelatedDocuments.Any())
            {
                foreach (var docDto in dto.RelatedDocuments)
                {
                    if (docDto.Id > 0)
                    {
                        var existingDoc = await _context.PdmEbomDocuments.FindAsync(docDto.Id);
                        if (existingDoc != null)
                        {
                            existingDoc.EbomItemId = item.Id;
                            _context.PdmEbomDocuments.Update(existingDoc);
                        }
                    }
                    else
                    {
                        var doc = new PdmEbomDocument
                        {
                            EbomItemId = item.Id,
                            Name = docDto.Name,
                            Path = docDto.Path,
                            FileType = docDto.FileType,
                            Size = docDto.Size,
                            UploadedAt = DateTime.UtcNow,
                            UploadedBy = GetCurrentUserName()
                        };
                        _context.PdmEbomDocuments.Add(doc);
                    }
                }
            }

            if (!string.IsNullOrEmpty(dto.ParentId))
            {
                var parent = await _context.PdmEbomItems.FindAsync(dto.ParentId);
                if (parent == null)
                {
                    throw new InvalidOperationException($"Parent item '{dto.ParentId}' not found.");
                }

                var relation = new PdmEbomStructure
                {
                    ParentId = dto.ParentId,
                    ChildId = dto.Key,
                    Quantity = dto.Qty, // Use DTO Qty
                    SortOrder = 0 // Default sort
                };
                _context.PdmEbomStructures.Add(relation);
            }

            await _context.SaveChangesAsync();

            // Refetch documents to get Ids
            var savedDocs = await _context.PdmEbomDocuments
                .Where(d => d.EbomItemId == item.Id)
                .Select(d => new EbomDocumentDto
                {
                    Id = d.Id,
                    Name = d.Name,
                    Path = d.Path,
                    FileType = d.FileType,
                    Size = d.Size,
                    UploadedAt = d.UploadedAt
                })
                .ToListAsync();

            return new EbomItemDto
            {
                Key = item.Id,
                Title = item.Name,
                Spec = item.Spec,
                Unit = item.Unit,
                Status = item.Status,
                ProductType = item.ProductType,
                Version = item.Version,
                Designer = item.Designer,
                RelatedDocuments = savedDocs,
                IsLeaf = item.IsLeaf,
                Qty = dto.Qty
            };
        }

        public async Task<EbomItemDto> UpdateEbomItemAsync(string id, UpdateEbomItemDto dto)
        {
            var item = await _context.PdmEbomItems.FindAsync(id);
            if (item == null)
            {
                throw new InvalidOperationException($"Item with ID '{id}' not found.");
            }

            item.Name = dto.Title;
            item.Spec = dto.Spec;
            item.Unit = dto.Unit;
            item.ProductType = dto.ProductType;
            if (!string.IsNullOrEmpty(dto.Status))
            {
                item.Status = dto.Status;
            }
            
            if (!string.IsNullOrEmpty(dto.Version))
            {
                item.Version = dto.Version;
            }

            if (!string.IsNullOrEmpty(dto.Designer))
            {
                item.Designer = dto.Designer;
            }

            item.UpdatedAt = DateTime.UtcNow;

            // Handle documents update: 
            // For simplicity, we can remove all existing and add new ones, 
            // or we can try to match. 
            // Given the frontend might just send the current list, 
            // let's assume the list in DTO is authoritative.
            // BUT, if DTO list has IDs, we keep them. If not, we add. 
            // If ID is missing from DTO but exists in DB, we delete.

            if (dto.RelatedDocuments != null)
            {
                var existingDocs = await _context.PdmEbomDocuments.Where(d => d.EbomItemId == id).ToListAsync();
                var incomingDocIds = dto.RelatedDocuments.Where(d => d.Id > 0).Select(d => d.Id).ToHashSet();

                // Delete removed
                var toDelete = existingDocs.Where(d => !incomingDocIds.Contains(d.Id)).ToList();
                if (toDelete.Any())
                {
                    // Delete physical files
                    var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                    foreach (var delDoc in toDelete)
                    {
                        if (!string.IsNullOrEmpty(delDoc.Path))
                        {
                            var fullPath = Path.Combine(webRoot, delDoc.Path);
                            if (File.Exists(fullPath))
                            {
                                try { File.Delete(fullPath); } catch { /* Ignore delete errors */ }
                            }
                        }
                    }
                    _context.PdmEbomDocuments.RemoveRange(toDelete);
                }

                // Link existing orphans (Id > 0 and not in existingDocs)
                var existingDocIds = existingDocs.Select(d => d.Id).ToHashSet();
                var idsToLink = incomingDocIds.Where(id => !existingDocIds.Contains(id)).ToList();
                
                foreach (var docId in idsToLink)
                {
                    var doc = await _context.PdmEbomDocuments.FindAsync(docId);
                    if (doc != null)
                    {
                        doc.EbomItemId = item.Id;
                        _context.PdmEbomDocuments.Update(doc);
                    }
                }

                // Add new
                var toAdd = dto.RelatedDocuments.Where(d => d.Id == 0).ToList();
                foreach (var newDoc in toAdd)
                {
                    _context.PdmEbomDocuments.Add(new PdmEbomDocument
                    {
                        EbomItemId = item.Id,
                        Name = newDoc.Name,
                        Path = newDoc.Path,
                        FileType = newDoc.FileType,
                        Size = newDoc.Size,
                        UploadedAt = DateTime.UtcNow,
                        UploadedBy = GetCurrentUserName()
                    });
                }
            }

            await _context.SaveChangesAsync();

            var savedDocs = await _context.PdmEbomDocuments
                .Where(d => d.EbomItemId == item.Id)
                .Select(d => new EbomDocumentDto
                {
                    Id = d.Id,
                    Name = d.Name,
                    Path = d.Path,
                    FileType = d.FileType,
                    Size = d.Size,
                    UploadedAt = d.UploadedAt
                })
                .ToListAsync();

            return new EbomItemDto
            {
                Key = item.Id,
                Title = item.Name,
                Spec = item.Spec,
                Unit = item.Unit,
                Status = item.Status,
                ProductType = item.ProductType,
                Version = item.Version,
                Designer = item.Designer,
                RelatedDocuments = savedDocs,
                IsLeaf = item.IsLeaf,
                Qty = 1
            };
        }

        public async Task<bool> DeleteEbomItemAsync(string id)
        {
            var item = await _context.PdmEbomItems.FindAsync(id);
            if (item == null)
            {
                throw new InvalidOperationException($"Item with ID '{id}' not found.");
            }

            // Check if it has children
            var hasChildren = await _context.PdmEbomStructures.AnyAsync(x => x.ParentId == id);
            if (hasChildren)
            {
                throw new InvalidOperationException("Cannot delete item with children. Please delete children first.");
            }

            // Remove relations where this item is a child
            var parentRelations = await _context.PdmEbomStructures.Where(x => x.ChildId == id).ToListAsync();
            _context.PdmEbomStructures.RemoveRange(parentRelations);

            // Remove documents
            var docs = await _context.PdmEbomDocuments.Where(d => d.EbomItemId == id).ToListAsync();
            
            // Delete physical files
            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            foreach (var doc in docs)
            {
                if (!string.IsNullOrEmpty(doc.Path))
                {
                    var fullPath = Path.Combine(webRoot, doc.Path);
                    if (File.Exists(fullPath))
                    {
                        try { File.Delete(fullPath); } catch { /* Ignore delete errors */ }
                    }
                }
            }

            _context.PdmEbomDocuments.RemoveRange(docs);

            _context.PdmEbomItems.Remove(item);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> AddChildItemAsync(AddChildItemDto dto)
        {
            if (dto.ParentId == dto.ChildId) throw new InvalidOperationException("Cannot add item as its own child.");
            
            var parent = await _context.PdmEbomItems.FindAsync(dto.ParentId);
            if (parent == null) throw new InvalidOperationException("Parent not found.");
            
            var child = await _context.PdmEbomItems.FindAsync(dto.ChildId);
            if (child == null) throw new InvalidOperationException("Child not found.");

            // Check existing
            var exists = await _context.PdmEbomStructures.AnyAsync(x => x.ParentId == dto.ParentId && x.ChildId == dto.ChildId);
            if (exists) throw new InvalidOperationException("Child already exists in this parent.");

            var relation = new PdmEbomStructure
            {
                ParentId = dto.ParentId,
                ChildId = dto.ChildId,
                Quantity = dto.Qty,
                SortOrder = 0,
                ChildVersion = child.Version // Snapshot current version
            };
            _context.PdmEbomStructures.Add(relation);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> UpdateChildItemQtyAsync(string parentId, string childId, decimal qty)
        {
            var relation = await _context.PdmEbomStructures
                .FirstOrDefaultAsync(x => x.ParentId == parentId && x.ChildId == childId);
            
            if (relation == null) throw new InvalidOperationException("Relation not found.");

            relation.Quantity = qty;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RemoveChildItemAsync(string parentId, string childId)
        {
            var relation = await _context.PdmEbomStructures
                .FirstOrDefaultAsync(x => x.ParentId == parentId && x.ChildId == childId);
            
            if (relation == null) throw new InvalidOperationException("Relation not found.");

            _context.PdmEbomStructures.Remove(relation);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<List<EbomItemDto>> SearchEbomItemsAsync(string keyword, string excludeId)
        {
            var query = _context.PdmEbomItems.AsQueryable();
            
            if (!string.IsNullOrEmpty(excludeId))
            {
                query = query.Where(x => x.Id != excludeId);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(x => x.Id.Contains(keyword) || x.Name.Contains(keyword));
            }

            var items = await query.Take(20).ToListAsync();
            
            return items.Select(x => new EbomItemDto
            {
                Key = x.Id,
                Title = x.Name,
                Spec = x.Spec,
                Unit = x.Unit,
                Status = x.Status,
                ProductType = x.ProductType,
                IsLeaf = x.IsLeaf,
                Version = x.Version,
                Designer = x.Designer
            }).ToList();
        }

        public async Task InitEbomDataAsync()
        {
            if (await _context.PdmEbomItems.AnyAsync()) return;

            var items = new List<PdmEbomItem>();
            var relations = new List<PdmEbomStructure>();

            // Helper to add item
            void AddItem(string id, string name, bool isLeaf = false, string productType = "")
            {
                items.Add(new PdmEbomItem { Id = id, Name = name, IsLeaf = isLeaf, ProductType = productType });
            }

            // Helper to add relation
            void AddRel(string parent, string child, int sort)
            {
                relations.Add(new PdmEbomStructure { ParentId = parent, ChildId = child, SortOrder = sort });
            }

            // 1. Server
            AddItem("PRD-2024001", "高性能服务器主机 A1", false, "finished");
            
            AddItem("ASM-001", "机箱组件", false, "semi_finished");
            AddRel("PRD-2024001", "ASM-001", 1);
            
            AddItem("PRT-101", "前面板", true, "raw_material");
            AddRel("ASM-001", "PRT-101", 1);
            AddItem("PRT-102", "侧板", true);
            AddRel("ASM-001", "PRT-102", 2);
            AddItem("PRT-103", "机架", true);
            AddRel("ASM-001", "PRT-103", 3);

            AddItem("ASM-002", "主板模组");
            AddRel("PRD-2024001", "ASM-002", 2);

            AddItem("PRT-201", "PCB主板", true);
            AddRel("ASM-002", "PRT-201", 1);
            AddItem("PRT-202", "CPU插槽", true);
            AddRel("ASM-002", "PRT-202", 2);
            AddItem("PRT-203", "散热器", true);
            AddRel("ASM-002", "PRT-203", 3);

            AddItem("ASM-003", "电源模块", true);
            AddRel("PRD-2024001", "ASM-003", 3);

            // 2. Subway
            AddItem("SUB-0001", "地铁车辆 S1");
            
            AddItem("SYS-SUB-001", "车体系统");
            AddRel("SUB-0001", "SYS-SUB-001", 1);

            AddItem("ASM-SUB-001-01", "车体结构");
            AddRel("SYS-SUB-001", "ASM-SUB-001-01", 1);

            AddItem("ASM-SUB-001-01-01", "底架组件");
            AddRel("ASM-SUB-001-01", "ASM-SUB-001-01-01", 1);
            
            AddItem("PRT-SUB-001-01-01-01", "左主梁");
            AddRel("ASM-SUB-001-01-01", "PRT-SUB-001-01-01-01", 1);

            AddItem("PRT-SUB-001-01-01-01-01", "加强板", true);
            AddRel("PRT-SUB-001-01-01-01", "PRT-SUB-001-01-01-01-01", 1);

            AddItem("ASM-SUB-001-02", "内装系统");
            AddRel("SYS-SUB-001", "ASM-SUB-001-02", 2);

            AddItem("ASM-SUB-001-02-01", "座椅组件");
            AddRel("ASM-SUB-001-02", "ASM-SUB-001-02-01", 1);

            AddItem("PRT-SUB-001-02-01-01", "座椅骨架");
            AddRel("ASM-SUB-001-02-01", "PRT-SUB-001-02-01-01", 1);

            AddItem("PRT-SUB-001-02-01-01-01", "连接件", true);
            AddRel("PRT-SUB-001-02-01-01", "PRT-SUB-001-02-01-01-01", 1);

            AddItem("SYS-SUB-002", "牵引系统");
            AddRel("SUB-0001", "SYS-SUB-002", 2);
            
            AddItem("ASM-SUB-002-01", "电机总成");
            AddRel("SYS-SUB-002", "ASM-SUB-002-01", 1);

            AddItem("ASM-SUB-002-01-01", "转子组件");
            AddRel("ASM-SUB-002-01", "ASM-SUB-002-01-01", 1);

            AddItem("PRT-SUB-002-01-01-01", "轴心");
            AddRel("ASM-SUB-002-01-01", "PRT-SUB-002-01-01-01", 1);

            AddItem("PRT-SUB-002-01-01-01-01", "轴承", true);
            AddRel("PRT-SUB-002-01-01-01", "PRT-SUB-002-01-01-01-01", 1);

            // 3. Engine E1
            AddItem("ENG-0001", "飞机发动机 E1");
            
            AddItem("SYS-ENG-001", "高压压气机系统");
            AddRel("ENG-0001", "SYS-ENG-001", 1);
            
            AddItem("ASM-ENG-001-01", "压气机总成");
            AddRel("SYS-ENG-001", "ASM-ENG-001-01", 1);

            AddItem("ASM-ENG-001-01-01", "叶片组件");
            AddRel("ASM-ENG-001-01", "ASM-ENG-001-01-01", 1);

            AddItem("PRT-ENG-001-01-01-01", "第一级叶片");
            AddRel("ASM-ENG-001-01-01", "PRT-ENG-001-01-01-01", 1);

            AddItem("PRT-ENG-001-01-01-01-01", "叶片根部嵌件", true);
            AddRel("PRT-ENG-001-01-01-01", "PRT-ENG-001-01-01-01-01", 1);

            AddItem("SYS-ENG-002", "燃烧室系统");
            AddRel("ENG-0001", "SYS-ENG-002", 2);

            AddItem("ASM-ENG-002-01", "喷嘴总成");
            AddRel("SYS-ENG-002", "ASM-ENG-002-01", 1);

            AddItem("PRT-ENG-002-01", "内喷管");
            AddRel("ASM-ENG-002-01", "PRT-ENG-002-01", 1);

            AddItem("PRT-ENG-002-01-01", "密封圈");
            AddRel("PRT-ENG-002-01", "PRT-ENG-002-01-01", 1);

            AddItem("PRT-ENG-002-01-01-01", "扣件", true);
            AddRel("PRT-ENG-002-01-01", "PRT-ENG-002-01-01-01-01", 1);

            // 4. Car M1
            AddItem("CAR-0001", "汽车 M1");

            AddItem("SYS-CAR-001", "发动机系统");
            AddRel("CAR-0001", "SYS-CAR-001", 1);

            AddItem("ASM-CAR-001-01", "发动机总成");
            AddRel("SYS-CAR-001", "ASM-CAR-001-01", 1);

            AddItem("ASM-CAR-001-01-01", "缸盖组件");
            AddRel("ASM-CAR-001-01", "ASM-CAR-001-01-01", 1);

            AddItem("ASM-CAR-001-01-01-01", "气门总成");
            AddRel("ASM-CAR-001-01-01", "ASM-CAR-001-01-01-01", 1);

            AddItem("PRT-CAR-001-01-01-01-01", "进气门", true);
            AddRel("ASM-CAR-001-01-01-01", "PRT-CAR-001-01-01-01-01", 1);

            AddItem("SYS-CAR-002", "底盘系统");
            AddRel("CAR-0001", "SYS-CAR-002", 2);

            AddItem("ASM-CAR-002-01", "悬架总成");
            AddRel("SYS-CAR-002", "ASM-CAR-002-01", 1);

            AddItem("ASM-CAR-002-01-01", "减震器组件");
            AddRel("ASM-CAR-002-01", "ASM-CAR-002-01-01", 1);

            AddItem("PRT-CAR-002-01-01-01", "活塞杆");
            AddRel("ASM-CAR-002-01-01", "PRT-CAR-002-01-01-01", 1);

            AddItem("PRT-CAR-002-01-01-01-01", "密封件", true);
            AddRel("PRT-CAR-002-01-01-01", "PRT-CAR-002-01-01-01-01", 1);

            await _context.PdmEbomItems.AddRangeAsync(items);
            await _context.PdmEbomStructures.AddRangeAsync(relations);
            await _context.SaveChangesAsync();
        }

        public async Task<(bool Success, string Message, EbomDocumentDto? Data)> UploadEbomDocumentAsync(IFormFile file)
        {
            if (file == null || file.Length == 0) return (false, "请选择文件", null);

            var fileName = Path.GetFileName(file.FileName);
            var fileExt = Path.GetExtension(fileName);
            // Use Guid to prevent name collision
            var uniqueName = $"{Guid.NewGuid()}_{fileName}";
            
            // Path: wwwroot/uploads/pdm/ebom/{Year}/{Month}/
            var relativePath = Path.Combine("uploads", "pdm", "ebom", DateTime.Now.Year.ToString(), DateTime.Now.Month.ToString("00"));
            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var uploadDir = Path.Combine(webRoot, relativePath);
            
            if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);
            
            var filePath = Path.Combine(uploadDir, uniqueName);
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Create orphaned document record
            var doc = new PdmEbomDocument
            {
                EbomItemId = "", // Orphan initially
                Name = fileName,
                Path = Path.Combine(relativePath, uniqueName), // Physical relative path
                FileType = fileExt,
                Size = file.Length,
                UploadedAt = DateTime.UtcNow,
                UploadedBy = GetCurrentUserName()
            };

            _context.PdmEbomDocuments.Add(doc);
            await _context.SaveChangesAsync();

            return (true, "上传成功", new EbomDocumentDto
            {
                Id = doc.Id,
                Name = doc.Name,
                // Return API Download URL for frontend display/usage
                Path = $"/api/pdm/ebom/documents/{doc.Id}/download", 
                FileType = doc.FileType,
                Size = doc.Size,
                UploadedAt = doc.UploadedAt
            });
        }

        public async Task<(bool Success, string Message, string? ContentType, Stream? FileStream, string? FileName)> DownloadEbomDocumentAsync(long id)
        {
            var doc = await _context.PdmEbomDocuments.FindAsync(id);
            if (doc == null) return (false, "文档不存在", null, null, null);

            var webRoot = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            var filePath = Path.Combine(webRoot, doc.Path);

            if (!File.Exists(filePath)) return (false, "文件在磁盘上不存在", null, null, null);

            var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var contentType = "application/octet-stream"; // Default
            
            // Simple content type mapping if needed
            var ext = doc.FileType.ToLower();
            if (ext == ".pdf") contentType = "application/pdf";
            else if (ext == ".jpg" || ext == ".jpeg") contentType = "image/jpeg";
            else if (ext == ".png") contentType = "image/png";
            else if (ext == ".txt") contentType = "text/plain";
            
            return (true, "获取成功", contentType, stream, doc.Name);
        }

        public async Task<(bool Success, string Message, byte[]? FileContent, string? FileName)> ExportEbomAsync(string? rootId)
        {
            try
            {
                var items = await GetEbomTreesAsync();
                if (!string.IsNullOrEmpty(rootId))
                {
                    items = items.Where(x => x.Key == rootId).ToList();
                }

                using var memoryStream = new MemoryStream();
                {
                    var workbook = new XSSFWorkbook();
                    var sheet = workbook.CreateSheet("EBOM");
                    
                    var headerRow = sheet.CreateRow(0);
                    string[] headers = { "层级", "物料编码", "物料名称", "规格型号", "数量", "单位", "状态", "版本", "设计者" };
                    for (int i = 0; i < headers.Length; i++)
                    {
                        headerRow.CreateCell(i).SetCellValue(headers[i]);
                    }

                    int rowIndex = 1;
                    foreach (var item in items)
                    {
                        WriteItemToSheet(sheet, item, 0, ref rowIndex);
                    }

                    workbook.Write(memoryStream);
                }

                return (true, "导出成功", memoryStream.ToArray(), $"EBOM_Export_{DateTime.Now:yyyyMMddHHmmss}.xlsx");
            }
            catch (Exception ex)
            {
                return (false, $"导出失败: {ex.Message}", null, null);
            }
        }

        private void WriteItemToSheet(ISheet sheet, EbomItemDto item, int level, ref int rowIndex)
        {
            var row = sheet.CreateRow(rowIndex++);
            row.CreateCell(0).SetCellValue(level);
            row.CreateCell(1).SetCellValue(item.Key);
            row.CreateCell(2).SetCellValue(item.Title);
            row.CreateCell(3).SetCellValue(item.Spec);
            row.CreateCell(4).SetCellValue((double)item.Qty);
            row.CreateCell(5).SetCellValue(item.Unit);
            row.CreateCell(6).SetCellValue(item.Status);
            row.CreateCell(7).SetCellValue(item.Version);
            row.CreateCell(8).SetCellValue(item.Designer);

            if (item.Children != null)
            {
                foreach (var child in item.Children)
                {
                    WriteItemToSheet(sheet, child, level + 1, ref rowIndex);
                }
            }
        }

        public async Task<(bool Success, string Message)> ImportEbomAsync(IFormFile file)
        {
            // Placeholder: In a real app, read stream with NPOI, parse, and update DB.
            await Task.Delay(100); 
            return (true, "导入成功 (模拟)");
        }

        public async Task<(bool Success, string Message, object? ComparisonResult)> CompareEbomAsync(List<string> itemIds)
        {
            if (itemIds == null || itemIds.Count < 2)
            {
                return (false, "请至少选择两个项目进行对比", null);
            }

            try
            {
                // 1. Gather data for all requested items
                var parents = new List<EbomDetailDto>();
                var childrenMap = new Dictionary<string, List<EbomItemDto>>();

                foreach (var id in itemIds)
                {
                    var parent = await GetEbomItemAsync(id);
                    if (parent != null)
                    {
                        parents.Add(parent);
                        var children = await GetEbomChildrenAsync(id);
                        childrenMap[id] = children;
                    }
                }

                if (parents.Count < 2)
                {
                    return (false, "有效对比项目不足两个 (部分项目可能不存在)", null);
                }

                // 2. Identify all unique child keys (Part Number / ID) across all parents
                var allChildKeys = childrenMap.Values
                    .SelectMany(c => c)
                    .Select(c => c.Key)
                    .Distinct()
                    .OrderBy(k => k)
                    .ToList();

                // 3. Build the comparison matrix
                var rows = new List<object>();
                int diffCount = 0;

                foreach (var childKey in allChildKeys)
                {
                    // Find basic info from the first occurrence
                    var referenceChild = childrenMap.Values
                        .SelectMany(c => c)
                        .First(c => c.Key == childKey);

                    var rowData = new Dictionary<string, object>
                    {
                        { "Key", referenceChild.Key },
                        { "Title", referenceChild.Title },
                        { "Spec", referenceChild.Spec },
                        { "Unit", referenceChild.Unit }
                    };

                    bool isPresentInAll = true;
                    bool isIdentical = true;
                    decimal? firstQty = null;
                    string? firstVersion = null;
                    bool firstSet = false;

                    var cells = new Dictionary<string, object?>();

                    foreach (var parent in parents)
                    {
                        var childInParent = childrenMap[parent.Key].FirstOrDefault(c => c.Key == childKey);

                        if (childInParent != null)
                        {
                            cells[parent.Key] = new { Exists = true, Qty = childInParent.Qty, Version = childInParent.Version };

                            if (!firstSet)
                            {
                                firstQty = childInParent.Qty;
                                firstVersion = childInParent.Version;
                                firstSet = true;
                            }
                            else
                            {
                                if (childInParent.Qty != firstQty || childInParent.Version != firstVersion)
                                {
                                    isIdentical = false;
                                }
                            }
                        }
                        else
                        {
                            cells[parent.Key] = new { Exists = false };
                            isPresentInAll = false;
                            isIdentical = false;
                        }
                    }

                    string diffType = "Common"; // Default
                    if (!isPresentInAll)
                    {
                        diffType = "Unique"; // Missing in some
                        diffCount++;
                    }
                    else if (!isIdentical)
                    {
                        diffType = "Modified"; // Present in all but values differ
                        diffCount++;
                    }

                    rowData["DiffType"] = diffType;
                    rowData["Cells"] = cells;
                    rows.Add(rowData);
                }

                // 4. Construct response
                var result = new
                {
                    Headers = parents.Select(p => new { Id = p.Key, Name = p.Title, Version = p.Version }).ToList(),
                    Rows = rows,
                    DiffCount = diffCount
                };

                return (true, "对比完成", result);
            }
            catch (Exception ex)
            {
                return (false, $"对比失败: {ex.Message}", null);
            }
        }
    }
}
