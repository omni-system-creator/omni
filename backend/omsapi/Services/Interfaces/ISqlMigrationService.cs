namespace omsapi.Services.Interfaces
{
    public interface ISqlMigrationService
    {
        Task ApplyMigrationsAsync();
    }
}
