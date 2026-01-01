using Microsoft.EntityFrameworkCore;
using omsapi.Data;
using omsapi.Infrastructure.Attributes;
using omsapi.Models.Dtos.Project;
using omsapi.Models.Entities.Project;
using omsapi.Services.Interfaces;
using System.Text.Json;

namespace omsapi.Services
{
    [AutoInject(ServiceLifetime.Scoped)]
    public class ProjectService : IProjectService
    {
        private readonly OmsContext _context;

        public ProjectService(OmsContext context)
        {
            _context = context;
        }

        public async Task<List<ProjectListItemDto>> GetProjectsAsync()
        {
            var projects = await _context.ProjectInfos.ToListAsync();
            
            // To avoid N+1, we might want to group tasks by project code if we want real progress
            // For now, let's keep it simple.
            
            return projects.Select(p => new ProjectListItemDto
            {
                Code = p.Code,
                Name = p.Name ?? "Untitled",
                Type = p.Type ?? "General",
                Manager = p.Manager ?? "Unknown",
                Status = "ongoing", // logic to be added
                Progress = 0, // logic to be added
                PlannedEndDate = p.PlannedEndDate
            }).ToList();
        }

        public async Task<ProjectFullDto?> GetProjectAsync(string code)
        {
            var project = await _context.ProjectInfos.FirstOrDefaultAsync(p => p.Code == code);
            if (project == null) return null;

            var phases = await _context.ProjectPhases.Where(p => p.ProjectCode == code).ToListAsync();
            var swimlanes = await _context.ProjectSwimlanes.Where(s => s.ProjectCode == code).ToListAsync();
            var tasks = await _context.ProjectTasks.Where(t => t.ProjectCode == code).ToListAsync();
            var dependencies = await _context.ProjectTaskDependencies.Where(d => d.ProjectCode == code).ToListAsync();
            var attachments = await _context.ProjectAttachments.Where(a => a.ProjectCode == code).ToListAsync();

            var taskDtos = tasks.Select(t => new TaskDto
            {
                Id = t.Id,
                Name = t.Name,
                PhaseId = t.PhaseId,
                SwimlaneId = t.SwimlaneId,
                Status = t.Status,
                Progress = t.Progress,
                Owner = t.Owner,
                StartDate = t.StartDate,
                EndDate = t.EndDate,
                Type = t.Type,
                Description = t.Description,
                X = t.X,
                Y = t.Y,
                Width = t.Width,
                StartColor = t.StartColor,
                EndColor = t.EndColor,
                Dependencies = dependencies
                    .Where(d => d.TaskId == t.Id)
                    .Select(d => new TaskDependencyDto
                    {
                        TaskId = d.DependencyId,
                        Type = d.Type,
                        SourcePort = d.SourcePort,
                        TargetPort = d.TargetPort,
                        ControlPoints = d.ControlPoints,
                        ControlPointCount = d.ControlPointCount
                    }).ToList(),
                Attachments = attachments
                    .Where(a => a.TaskId == t.Id)
                    .Select(a => new AttachmentDto
                    {
                        Id = a.Id,
                        Name = a.Name,
                        Url = a.Url,
                        Type = a.Type,
                        UploadDate = a.UploadDate
                    }).ToList()
            }).ToList();

            return new ProjectFullDto
            {
                ProjectInfo = new ProjectInfoDto
                {
                    Code = project.Code,
                    Name = project.Name,
                    Type = project.Type,
                    Description = project.Description,
                    Manager = project.Manager,
                    PlannedStartDate = project.PlannedStartDate,
                    PlannedEndDate = project.PlannedEndDate
                },
                Phases = phases.Select(p => new PhaseDto { Id = p.Id, Name = p.Name, Color = p.Color }).ToList(),
                Swimlanes = swimlanes.Select(s => new SwimlaneDto { Id = s.Id, Name = s.Name, Color = s.Color }).ToList(),
                Tasks = taskDtos
            };
        }

        public async Task<bool> SaveProjectAsync(ProjectFullDto dto)
        {
            if (dto.ProjectInfo == null) return false;
            var code = dto.ProjectInfo.Code;
            if (string.IsNullOrEmpty(code)) return false;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // Update Project Info
                var project = await _context.ProjectInfos.FirstOrDefaultAsync(p => p.Code == code);
                if (project == null)
                {
                    project = new ProjectInfo { Code = code };
                    _context.ProjectInfos.Add(project);
                }
                project.Name = dto.ProjectInfo.Name;
                project.Type = dto.ProjectInfo.Type;
                project.Description = dto.ProjectInfo.Description;
                project.Manager = dto.ProjectInfo.Manager;
                project.PlannedStartDate = dto.ProjectInfo.PlannedStartDate;
                project.PlannedEndDate = dto.ProjectInfo.PlannedEndDate;

                // Clear existing children
                var phases = await _context.ProjectPhases.Where(p => p.ProjectCode == code).ToListAsync();
                _context.ProjectPhases.RemoveRange(phases);

                var swimlanes = await _context.ProjectSwimlanes.Where(s => s.ProjectCode == code).ToListAsync();
                _context.ProjectSwimlanes.RemoveRange(swimlanes);

                var tasks = await _context.ProjectTasks.Where(t => t.ProjectCode == code).ToListAsync();
                _context.ProjectTasks.RemoveRange(tasks);

                var dependencies = await _context.ProjectTaskDependencies.Where(d => d.ProjectCode == code).ToListAsync();
                _context.ProjectTaskDependencies.RemoveRange(dependencies);

                var attachments = await _context.ProjectAttachments.Where(a => a.ProjectCode == code).ToListAsync();
                _context.ProjectAttachments.RemoveRange(attachments);

                await _context.SaveChangesAsync();

                // Insert new children
                if (dto.Phases != null)
                {
                    _context.ProjectPhases.AddRange(dto.Phases.Select(p => new ProjectPhase
                    {
                        Id = p.Id,
                        ProjectCode = code,
                        Name = p.Name,
                        Color = p.Color
                    }));
                }

                if (dto.Swimlanes != null)
                {
                    _context.ProjectSwimlanes.AddRange(dto.Swimlanes.Select(s => new ProjectSwimlane
                    {
                        Id = s.Id,
                        ProjectCode = code,
                        Name = s.Name,
                        Color = s.Color
                    }));
                }

                if (dto.Tasks != null)
                {
                    foreach (var t in dto.Tasks)
                    {
                        _context.ProjectTasks.Add(new ProjectTask
                        {
                            Id = t.Id,
                            ProjectCode = code,
                            Name = t.Name,
                            PhaseId = t.PhaseId,
                            SwimlaneId = t.SwimlaneId,
                            Status = t.Status,
                            Progress = t.Progress,
                            Owner = t.Owner,
                            StartDate = t.StartDate,
                            EndDate = t.EndDate,
                            Type = t.Type,
                            Description = t.Description,
                            X = t.X,
                            Y = t.Y,
                            Width = t.Width,
                            StartColor = t.StartColor,
                            EndColor = t.EndColor
                        });

                        if (t.Dependencies != null)
                        {
                            _context.ProjectTaskDependencies.AddRange(t.Dependencies.Select(d => new ProjectTaskDependency
                            {
                                TaskId = t.Id,
                                DependencyId = d.TaskId,
                                ProjectCode = code,
                                Type = d.Type,
                                SourcePort = d.SourcePort,
                                TargetPort = d.TargetPort,
                                ControlPoints = d.ControlPoints,
                                ControlPointCount = d.ControlPointCount
                            }));
                        }

                        if (t.Attachments != null)
                        {
                            _context.ProjectAttachments.AddRange(t.Attachments.Select(a => new ProjectAttachment
                            {
                                Id = a.Id,
                                TaskId = t.Id,
                                ProjectCode = code,
                                Name = a.Name,
                                Url = a.Url,
                                Type = a.Type,
                                UploadDate = a.UploadDate
                            }));
                        }
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return true;
            }
            catch (Exception)
            {
                await transaction.RollbackAsync();
                throw;
            }
        }
    }
}
