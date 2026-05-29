#requires -PSEdition Core
#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

function Normalize-WorkflowContent {
  param(
    [AllowNull()]
    [string] $Content
  )

  if ($null -eq $Content) {
    return $null
  }

  # Keep workflow writes idempotent by requiring exactly one trailing LF.
  return ($Content.TrimEnd("`r", "`n") + "`n")
}

# Read convention settings for app release artifact customization.
$inputData = Get-Content -LiteralPath $args[0] -Raw | ConvertFrom-Json -AsHashtable
$settings = if ($inputData.ContainsKey('settings') -and $null -ne $inputData['settings']) { $inputData['settings'] } else { @{} }
$releaseArtifactPath = if ($settings.ContainsKey('release-artifact-path')) { [string] $settings['release-artifact-path'] } else { './artifacts/publish/${{ github.event.repository.name }}/release_win-x64/${{ github.event.repository.name }}.exe' }

# Ensure the target workflows directory exists before writing templates.
$targetDirectory = Join-Path (Get-Location) '.github' 'workflows'
[System.IO.Directory]::CreateDirectory($targetDirectory) | Out-Null

# Copy static workflow templates using stable UTF-8 output.
foreach ($workflowName in @('apply-repo-conventions.yml', 'ci.yml')) {
	$sourcePath = Join-Path $PSScriptRoot 'files' $workflowName
	$targetPath = Join-Path $targetDirectory $workflowName
  $sourceContent = Normalize-WorkflowContent ([System.IO.File]::ReadAllText($sourcePath))
  $targetContent = if (Test-Path -LiteralPath $targetPath -PathType Leaf) { Normalize-WorkflowContent ([System.IO.File]::ReadAllText($targetPath)) } else { $null }

	if ($sourceContent -cne $targetContent) {
		[System.IO.File]::WriteAllText($targetPath, $sourceContent, $utf8)
		Write-Host "Updated ejball workflow '.github/workflows/$workflowName'."
	}
}

# Generate the release workflow from the configured artifact path.
$releaseContent = @"
name: Release

on:
  push:
    tags:
    - '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'

env:
  DOTNET_NOLOGO: 1
  DOTNET_CLI_TELEMETRY_OPTOUT: 1

defaults:
  run:
    shell: pwsh

permissions:
  contents: write

jobs:
  build:
    name: Build
    runs-on: windows-latest
    steps:
    - name: Check out code
      uses: actions/checkout@v6
    - name: Install .NET
      uses: actions/setup-dotnet@v5
    - name: Package
      run: ./build.ps1 package
    - name: Create zip
      run: Compress-Archive $releaseArtifactPath `${{ github.event.repository.name }}.zip
    - name: Create release
      uses: softprops/action-gh-release@v2
      with:
        files: ./`${{ github.event.repository.name }}.zip
"@.Replace("`r`n", "`n")

$releaseContent = Normalize-WorkflowContent $releaseContent

# Write the release workflow when the generated content differs.
$releasePath = Join-Path $targetDirectory 'release.yaml'
$targetReleaseContent = if (Test-Path -LiteralPath $releasePath -PathType Leaf) { Normalize-WorkflowContent ([System.IO.File]::ReadAllText($releasePath)) } else { $null }
if ($releaseContent -cne $targetReleaseContent) {
	[System.IO.File]::WriteAllText($releasePath, $releaseContent, $utf8)
	Write-Host "Updated ejball workflow '.github/workflows/release.yaml'."
}