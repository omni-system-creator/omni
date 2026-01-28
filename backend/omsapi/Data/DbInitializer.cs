using Microsoft.EntityFrameworkCore;
using omsapi.Models.Entities;
using omsapi.Models.Entities.Contract;
using omsapi.Models.Entities.Dict;
using OmsApi.Models.Entities.Kb;

namespace omsapi.Data
{
    public static class DbInitializer
    {
        public static async Task InitializeAsync(OmsContext context, OmsPgContext pgContext)
        {
            await context.Database.CanConnectAsync();
        }
    }
}
