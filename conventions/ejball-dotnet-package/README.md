# ejball-dotnet-package

The `ejball-dotnet-package` convention applies the standard convention collection for ejball .NET package, tool, and application repositories.

This convention composes common .NET repository conventions from `Faithlife/CodingGuidelines`, including build files, NuGet configuration, ignore files, contributing guidelines, common MSBuild properties, and the MIT license.

## Behavior

The convention is intended for SDK-style .NET repositories owned by `ejball`. Repository-specific version numbers, package validation baselines, target frameworks, package references, package descriptions, analyzer suppressions, and package metadata remain outside the convention.

The first `Directory.Build.props` property group remains repository-owned and is the right place for `VersionPrefix`, `PackageValidationBaselineVersion`, `GitHubOrganization`, `RepositoryName`, `PackageLicenseExpression`, and `Authors`.

Workflow files are intentionally handled by separate conventions so package repositories and desktop application repositories can choose the correct CI and release shape independently.

## Example

```yaml
conventions:
  - path: ejball/ejball-common/conventions/ejball-dotnet-package
  - path: ejball/ejball-common/conventions/ejball-dotnet-package-workflows
```
