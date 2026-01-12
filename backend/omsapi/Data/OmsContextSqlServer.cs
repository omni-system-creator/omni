using Microsoft.EntityFrameworkCore;

namespace omsapi.Data
{
    public class OmsContextSqlServer : OmsContext
    {
        public OmsContextSqlServer(DbContextOptions<OmsContextSqlServer> options) : base(options)
        {
        }
    }
}
