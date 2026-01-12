using Microsoft.EntityFrameworkCore;

namespace omsapi.Data
{
    public class OmsContextPostgreSql : OmsContext
    {
        public OmsContextPostgreSql(DbContextOptions<OmsContextPostgreSql> options) : base(options)
        {
        }
    }
}
