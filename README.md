# Binagora

Learning repository for practicing multi-agent software development workflows.

## Backend validation

The backend uses .NET 8 project targets and requires a .NET 8 SDK/runtime to build and run tests locally.
Validate the backend stack with:

```bash
dotnet --info
dotnet restore src/backend/Binagora.Backend.sln
dotnet build src/backend/Binagora.Backend.sln -c Release
dotnet test src/backend/Binagora.Backend.sln -c Release
```
