using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;

namespace omsapi.Data
{
    public class OmsContextSqlServerFactory : IDesignTimeDbContextFactory<OmsContextSqlServer>
    {
        public OmsContextSqlServer CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<OmsContextSqlServer>();
            
            IConfigurationRoot configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();

            var connectionString = configuration.GetConnectionString("DefaultConnection_mssql");
            optionsBuilder.UseSqlServer(connectionString);

            return new OmsContextSqlServer(optionsBuilder.Options);
        }
    }

    public class OmsContextFactory : IDesignTimeDbContextFactory<OmsContext>
    {
        public OmsContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<OmsContext>();
            
            IConfigurationRoot configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();

            var connectionString = configuration.GetConnectionString("DefaultConnection_mysql");
            optionsBuilder.UseMySql(connectionString, new MySqlServerVersion(new Version(8, 0, 21)));

            return new OmsContext(optionsBuilder.Options);
        }
    }

    public class OmsContextPostgreSqlFactory : IDesignTimeDbContextFactory<OmsContextPostgreSql>
    {
        public OmsContextPostgreSql CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<OmsContextPostgreSql>();
            
            IConfigurationRoot configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .Build();

            var connectionString = configuration.GetConnectionString("DefaultConnection_postgres");
            optionsBuilder.UseNpgsql(connectionString);

            return new OmsContextPostgreSql(optionsBuilder.Options);
        }
    }
}
