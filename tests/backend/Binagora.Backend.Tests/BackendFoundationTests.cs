using System.Xml.Linq;

namespace Binagora.Backend.Tests;

public sealed class BackendFoundationTests
{
    [Fact]
    public void BackendSolutionAndProjectsExist()
    {
        string[] expectedFiles =
        [
            "src/backend/Binagora.Backend.sln",
            "src/backend/Api/Binagora.Api.csproj",
            "src/backend/Application/Binagora.Application.csproj",
            "src/backend/Domain/Binagora.Domain.csproj",
            "src/backend/Infrastructure/Binagora.Infrastructure.csproj",
            "tests/backend/Binagora.Backend.Tests/Binagora.Backend.Tests.csproj"
        ];

        foreach (var expectedFile in expectedFiles)
        {
            Assert.True(File.Exists(FullPath(expectedFile)), $"Expected file to exist: {expectedFile}");
        }
    }

    [Fact]
    public void ProjectsTargetNet8AndRespectLayeredReferences()
    {
        AssertProjectReferences(
            "src/backend/Domain/Binagora.Domain.csproj",
            []);

        AssertProjectReferences(
            "src/backend/Application/Binagora.Application.csproj",
            ["../Domain/Binagora.Domain.csproj"]);

        AssertProjectReferences(
            "src/backend/Infrastructure/Binagora.Infrastructure.csproj",
            ["../Application/Binagora.Application.csproj", "../Domain/Binagora.Domain.csproj"]);

        AssertProjectReferences(
            "src/backend/Api/Binagora.Api.csproj",
            ["../Application/Binagora.Application.csproj", "../Infrastructure/Binagora.Infrastructure.csproj"]);
    }

    private static void AssertProjectReferences(string projectPath, string[] expectedReferences)
    {
        var project = XDocument.Load(FullPath(projectPath));

        var targetFramework = project.Descendants("TargetFramework").Single().Value;
        Assert.Equal("net8.0", targetFramework);

        var actualReferences = project
            .Descendants("ProjectReference")
            .Select(reference => NormalizePath(reference.Attribute("Include")?.Value))
            .Order(StringComparer.Ordinal)
            .ToArray();

        var normalizedExpectedReferences = expectedReferences
            .Select(NormalizePath)
            .Order(StringComparer.Ordinal)
            .ToArray();

        Assert.Equal(normalizedExpectedReferences, actualReferences);
    }

    private static string FullPath(string relativePath) => Path.Combine(RepoRoot, relativePath);

    private static string RepoRoot { get; } = FindRepoRoot();

    private static string FindRepoRoot()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);

        while (directory is not null)
        {
            var solutionPath = Path.Combine(directory.FullName, "src", "backend", "Binagora.Backend.sln");
            if (File.Exists(solutionPath))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }

        throw new InvalidOperationException("Could not locate the repository root.");
    }

    private static string NormalizePath(string? path) =>
        (path ?? string.Empty).Replace('\\', '/');
}
