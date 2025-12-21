using Microsoft.Extensions.DependencyInjection;

namespace omsapi.Infrastructure.Attributes
{
    [AttributeUsage(AttributeTargets.Class)]
    public class AutoInjectAttribute : Attribute
    {
        public ServiceLifetime Lifetime { get; }

        public AutoInjectAttribute(ServiceLifetime lifetime = ServiceLifetime.Scoped)
        {
            Lifetime = lifetime;
        }
    }
}
