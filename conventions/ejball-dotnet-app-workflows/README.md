# ejball-dotnet-app-workflows

The `ejball-dotnet-app-workflows` convention manages GitHub Actions workflows for ejball desktop application repositories that ship GitHub release ZIPs instead of NuGet packages.

It writes CI, release, and repository-convention application workflows. The apply workflow opens convention-update pull requests through the `ejball bot` GitHub App.

## Settings

- `release-artifact-path` is optional. It sets the executable path compressed into the release ZIP. The default is `./artifacts/publish/${{ github.event.repository.name }}/release_win-x64/${{ github.event.repository.name }}.exe`.

Use `release-artifact-path` for repositories whose release executable is not in the default `release_win-x64` location.

## Behavior

The convention writes these files:

- `.github/workflows/apply-repo-conventions.yml`
- `.github/workflows/ci.yml`
- `.github/workflows/release.yaml`

The release workflow runs on date tags shaped like `yyyy-MM-dd`, builds on Windows, packages with `./build.ps1 package`, compresses the configured executable into `<repository>.zip`, and uploads that ZIP to the GitHub release.

The apply workflow generates a GitHub App token with `actions/create-github-app-token@v3`, using repository or organization variable `EJBALL_BOT_CLIENT_ID` and secret `EJBALL_BOT_PRIVATE_KEY`. It commits as `ejball-bot[app]`.

## Example

```yaml
conventions:
  - path: ejball/ejball-common/conventions/ejball-dotnet-package
  - path: ejball/ejball-common/conventions/ejball-dotnet-app-workflows
```

```yaml
conventions:
  - path: ejball/ejball-common/conventions/ejball-dotnet-package
  - path: ejball/ejball-common/conventions/ejball-dotnet-app-workflows
    settings:
      release-artifact-path: ./artifacts/publish/ToggleResolution/release_win-x86/ToggleResolution.exe
```
