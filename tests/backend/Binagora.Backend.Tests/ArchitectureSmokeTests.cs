using System.Runtime.Versioning;
using Binagora.Domain;
using Xunit;

namespace Binagora.Backend.Tests;

public sealed class ArchitectureSmokeTests
{
    [Fact]
    public void Domain_project_does_not_reference_outer_layers()
    {
        var referencedAssemblyNames = typeof(DomainAssemblyReference)
            .Assembly
            .GetReferencedAssemblies()
            .Select(assembly => assembly.Name)
            .ToArray();

        Assert.DoesNotContain("Binagora.Api", referencedAssemblyNames);
        Assert.DoesNotContain("Binagora.Application", referencedAssemblyNames);
        Assert.DoesNotContain("Binagora.Infrastructure", referencedAssemblyNames);
    }

    [Fact]
    public void Domain_project_targets_dotnet_8()
    {
        var targetFramework = typeof(DomainAssemblyReference)
            .Assembly
            .GetCustomAttributes(typeof(TargetFrameworkAttribute), inherit: false)
            .OfType<TargetFrameworkAttribute>()
            .Single()
            .FrameworkName;

        Assert.Equal(".NETCoreApp,Version=v8.0", targetFramework);
    }
}
