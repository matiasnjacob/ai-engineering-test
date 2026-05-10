# Binagora

Learning environment for practicing multi-agent software development workflows.

## Backend validation

The backend solution is located at `src/backend/Binagora.Backend.sln` and targets .NET 8.

From `src/backend`, run:

```bash
dotnet restore
dotnet build --no-restore
dotnet test --no-build
```

Equivalent commands from the repository root:

```bash
dotnet restore src/backend/Binagora.Backend.sln
dotnet build src/backend/Binagora.Backend.sln --no-restore
dotnet test src/backend/Binagora.Backend.sln --no-build
```
