using omsapi.Infrastructure.Attributes;
using System.Reflection;

namespace omsapi.Infrastructure.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddAppServices(this IServiceCollection services)
        {
            var assembly = Assembly.GetExecutingAssembly();
            
            var typesToRegister = assembly.GetTypes()
                .Where(t => t.GetCustomAttribute<AutoInjectAttribute>() != null && !t.IsAbstract && !t.IsInterface);

            foreach (var type in typesToRegister)
            {
                var attribute = type.GetCustomAttribute<AutoInjectAttribute>();
                if (attribute == null) continue;

                var interfaces = type.GetInterfaces();
                
                // 如果类实现了接口，默认注册第一个匹配名称的接口 (例如 AuthService -> IAuthService)
                // 也可以简单地注册所有接口，或者只注册特定的接口
                // 这里采用简单的策略：如果实现了接口，注册第一个接口；如果没有，注册类本身
                
                var interfaceType = interfaces.FirstOrDefault(i => i.Name == $"I{type.Name}") ?? interfaces.FirstOrDefault();

                if (interfaceType != null)
                {
                    services.Add(new ServiceDescriptor(interfaceType, type, attribute.Lifetime));
                }
                else
                {
                    services.Add(new ServiceDescriptor(type, type, attribute.Lifetime));
                }
            }

            return services;
        }
    }
}
