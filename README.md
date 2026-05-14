# Binagora

Learning environment for practicing multi-agent software development workflows.

## Backend

The backend foundation is a .NET 8 solution located at `src/backend/Binagora.Backend.sln`.

Projects:

- `src/backend/Api`
- `src/backend/Application`
- `src/backend/Domain`
- `src/backend/Infrastructure`
- `tests/backend/Binagora.Backend.Tests`

## Backend validation

Run backend restore, build, and tests from the repository root:

```bash
dotnet restore src/backend/Binagora.Backend.sln
dotnet build src/backend/Binagora.Backend.sln
dotnet test src/backend/Binagora.Backend.sln
```

Alternatively, from `src/backend`, run:

```bash
dotnet restore
dotnet build
dotnet test
```
