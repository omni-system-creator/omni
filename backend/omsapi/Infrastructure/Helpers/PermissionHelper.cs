namespace omsapi.Infrastructure.Helpers
{
    public static class PermissionHelper
    {
        public static bool RoleIdsIntersect(string? roleIdsStr, List<long> userRoleIds)
        {
            if (string.IsNullOrEmpty(roleIdsStr)) return false;
            var formRoles = roleIdsStr.Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(s => long.TryParse(s, out var id) ? id : (long?)null)
                .Where(id => id.HasValue)
                .Select(id => id!.Value)
                .ToList();
            
            return formRoles.Intersect(userRoleIds).Any();
        }
    }
}
