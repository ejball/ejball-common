# ejball-dotnet-package-workflows

The `ejball-dotnet-package-workflows` convention manages GitHub Actions workflows for ejball .NET package and tool repositories.

It writes CI, Copilot setup, and repository-convention application workflows that build, test, package, upload NuGet artifacts, publish packages from `master`, and open convention-update pull requests through the `ejball bot` GitHub App.

## Behavior

The convention writes these files:

- `.github/workflows/apply-repo-conventions.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/copilot-setup-steps.yml`

The apply workflow generates a GitHub App token with `actions/create-github-app-token@v3`, using repository or organization variable `EJBALL_BOT_CLIENT_ID` and secret `EJBALL_BOT_PRIVATE_KEY`. It commits as `ejball-bot[app]`.

The CI workflow builds on Ubuntu, Windows, and macOS. It uploads NuGet packages from Windows and publishes them from the `ejball` `master` branch with `NUGET_API_KEY`.

## Example

```yaml
conventions:
  - path: ejball/ejball-common/conventions/ejball-dotnet-package
  - path: ejball/ejball-common/conventions/ejball-dotnet-package-workflows
```
