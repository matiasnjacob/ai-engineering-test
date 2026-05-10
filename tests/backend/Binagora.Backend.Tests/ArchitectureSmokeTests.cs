using System.Xml.Linq;
using Xunit;

namespace Binagora.Backend.Tests;

public sealed class ArchitectureSmokeTests
{
    private static readonly string RepositoryRoot = FindRepositoryRoot();

    [Fact]
    public void Backend_solution_includes_expected_projects()
    {
        var solutionContent = File
            .ReadAllText(ProjectPath("src/backend/Binagora.Backend.sln"))
            .Replace('\\', '/');

        Assert.Contains("Api/Binagora.Api.csproj", solutionContent);
        Assert.Contains("Application/Binagora.Application.csproj", solutionContent);
        Assert.Contains("Domain/Binagora.Domain.csproj", solutionContent);
        Assert.Contains("Infrastructure/Binagora.Infrastructure.csproj", solutionContent);
        Assert.Contains("../../tests/backend/Binagora.Backend.Tests/Binagora.Backend.Tests.csproj", solutionContent);
    }

    [Theory]
    [InlineData("src/backend/Api/Binagora.Api.csproj")]
    [InlineData("src/backend/Application/Binagora.Application.csproj")]
    [InlineData("src/backend/Domain/Binagora.Domain.csproj")]
    [InlineData("src/backend/Infrastructure/Binagora.Infrastructure.csproj")]
    [InlineData("tests/backend/Binagora.Backend.Tests/Binagora.Backend.Tests.csproj")]
    public void Backend_projects_target_dotnet_8(string projectRelativePath)
    {
        var targetFramework = LoadProject(projectRelativePath)
            .Descendants("TargetFramework")
            .Single()
            .Value;

        Assert.Equal("net8.0", targetFramework);
    }

    [Fact]
    public void Project_references_follow_layered_dependency_direction()
    {
        AssertProjectReferences(
            "src/backend/Api/Binagora.Api.csproj",
            "src/backend/Application/Binagora.Application.csproj",
            "src/backend/Infrastructure/Binagora.Infrastructure.csproj");

        AssertProjectReferences(
            "src/backend/Application/Binagora.Application.csproj",
            "src/backend/Domain/Binagora.Domain.csproj");

        AssertProjectReferences("src/backend/Domain/Binagora.Domain.csproj");

        AssertProjectReferences(
            "src/backend/Infrastructure/Binagora.Infrastructure.csproj",
            "src/backend/Application/Binagora.Application.csproj",
            "src/backend/Domain/Binagora.Domain.csproj");

        AssertProjectReferences(
            "tests/backend/Binagora.Backend.Tests/Binagora.Backend.Tests.csproj",
            "src/backend/Domain/Binagora.Domain.csproj");
    }

    private static void AssertProjectReferences(string projectRelativePath, params string[] expectedReferences)
    {
        var actualReferences = LoadProject(projectRelativePath)
            .Descendants("ProjectReference")
            .Select(reference => reference.Attribute("Include")?.Value)
            .Select(include => ToRepositoryRelativePath(projectRelativePath, include))
            .Order()
            .ToArray();

        Assert.Equal(expectedReferences.Order().ToArray(), actualReferences);
    }

    private static XDocument LoadProject(string relativePath) => XDocument.Load(ProjectPath(relativePath));

    private static string ProjectPath(string relativePath) => Path.Combine(RepositoryRoot, relativePath);

    private static string ToRepositoryRelativePath(string projectRelativePath, string? include)
    {
        Assert.False(string.IsNullOrWhiteSpace(include));

        var projectDirectory = Path.GetDirectoryName(ProjectPath(projectRelativePath))!;
        var normalizedInclude = include.Replace('\\', Path.DirectorySeparatorChar);
        var referencedProjectPath = Path.GetFullPath(Path.Combine(projectDirectory, normalizedInclude));

        return Path.GetRelativePath(RepositoryRoot, referencedProjectPath).Replace('\\', '/');
    }

    private static string FindRepositoryRoot()
    {
        foreach (var startDirectory in new[] { Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(startDirectory);

            while (directory is not null)
            {
                if (File.Exists(Path.Combine(directory.FullName, "src", "backend", "Binagora.Backend.sln")))
                {
                    return directory.FullName;
                }

                directory = directory.Parent;
            }
        }

        throw new InvalidOperationException("Could not locate repository root for backend architecture tests.");
    }
}
