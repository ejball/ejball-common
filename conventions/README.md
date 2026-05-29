# Repository Conventions

This directory contains shared conventions for repositories owned by the `ejball` GitHub user.

These conventions compose the common .NET conventions from `Faithlife/CodingGuidelines` with ejball-specific workflow policy. Repository-owned metadata such as `GitHubOrganization`, `RepositoryName`, and `PackageLicenseExpression` remains in each repository's first `Directory.Build.props` property group.

## Available Conventions

- [`ejball-dotnet-package`](./ejball-dotnet-package/README.md) applies the common .NET repository baseline for package and tool repositories.
- [`ejball-dotnet-package-workflows`](./ejball-dotnet-package-workflows/README.md) manages CI, Copilot setup, and repository-convention application workflows for NuGet package repositories.
- [`ejball-dotnet-app-workflows`](./ejball-dotnet-app-workflows/README.md) manages CI, release, and repository-convention application workflows for desktop application repositories.
