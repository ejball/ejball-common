#requires -PSEdition Core
#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$script:utf8 = $utf8
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

# Define the Pester suite for the ejball app workflow convention.
Describe 'ejball-dotnet-app-workflows convention' {
	BeforeAll {
		# Record shared test state for direct convention invocation in isolated repositories.
		$script:utf8 = [System.Text.UTF8Encoding]::new($false)
		$script:conventionScriptPath = Join-Path $PSScriptRoot 'convention.ps1'

		# Invoke the workflow convention script from the specified temporary repository.
		function script:InvokeEjballAppWorkflowConvention {
			param(
				[Parameter(Mandatory = $true)]
				[string] $TestDirectory,

				[hashtable] $Settings = @{}
			)

			$inputPath = Join-Path $TestDirectory 'convention-input.json'
			$inputData = @{ settings = $Settings } | ConvertTo-Json -Depth 10
			[System.IO.File]::WriteAllText($inputPath, $inputData, $script:utf8)
			try {
				Push-Location $TestDirectory
				try {
					& $script:conventionScriptPath $inputPath
				}
				finally {
					Pop-Location
				}
			}
			finally {
				Remove-Item -LiteralPath $inputPath -ErrorAction SilentlyContinue
			}
		}
	}

	It 'copies static workflows, generates release workflow, and is idempotent' {
		# Set up an isolated repository directory for workflow generation.
		$testDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString('N'))

		try {
			[System.IO.Directory]::CreateDirectory($testDirectory) | Out-Null

			# Apply the convention and assert the expected workflows exist.
			InvokeEjballAppWorkflowConvention -TestDirectory $testDirectory
			foreach ($workflowName in @('apply-repo-conventions.yml', 'ci.yml', 'release.yaml')) {
				(Test-Path -LiteralPath (Join-Path $testDirectory '.github' 'workflows' $workflowName)) | Should -Be $true
			}

			# Assert the default release workflow uses the repository-name win-x64 path.
			$releaseContent = Get-Content -LiteralPath (Join-Path $testDirectory '.github' 'workflows' 'release.yaml') -Raw
			$releaseContent | Should -Match 'release_win-x64'
			$releaseContent | Should -Match '\$\{\{ github\.event\.repository\.name \}\}\.zip'

			# Re-run the convention and assert no workflow content changes.
			$before = Get-ChildItem -LiteralPath (Join-Path $testDirectory '.github' 'workflows') -File | Sort-Object Name | ForEach-Object { $_.Name, (Get-Content -LiteralPath $_.FullName -Raw) }
			InvokeEjballAppWorkflowConvention -TestDirectory $testDirectory
			$after = Get-ChildItem -LiteralPath (Join-Path $testDirectory '.github' 'workflows') -File | Sort-Object Name | ForEach-Object { $_.Name, (Get-Content -LiteralPath $_.FullName -Raw) }
			$after | Should -Be $before
		}
		finally {
			# Remove the isolated repository after the test completes.
			Remove-Item -LiteralPath $testDirectory -Recurse -Force
		}
	}

	It 'uses configured release artifact path' {
		# Generate workflows with a custom release artifact path.
		$testDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString('N'))

		try {
			[System.IO.Directory]::CreateDirectory($testDirectory) | Out-Null
			InvokeEjballAppWorkflowConvention -TestDirectory $testDirectory -Settings @{ 'release-artifact-path' = './artifacts/publish/ToggleResolution/release_win-x86/ToggleResolution.exe' }

			# Assert the generated release workflow uses the configured path.
			$releaseContent = Get-Content -LiteralPath (Join-Path $testDirectory '.github' 'workflows' 'release.yaml') -Raw
			$releaseContent | Should -Match 'release_win-x86/ToggleResolution\.exe'
		}
		finally {
			# Remove the isolated repository after the test completes.
			Remove-Item -LiteralPath $testDirectory -Recurse -Force
		}
	}

	It 'uses the ejball Bot GitHub App token in the apply workflow' {
		# Read the published apply workflow and assert the app-token wiring is present.
		$content = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'files' 'apply-repo-conventions.yml') -Raw
		$content | Should -Match 'actions/create-github-app-token@v3'
		$content | Should -Match 'vars\.EJBALL_BOT_CLIENT_ID'
		$content | Should -Match 'secrets\.EJBALL_BOT_PRIVATE_KEY'
		$content | Should -Match 'ejball-bot\[app\]'
		$content | Should -Not -Match 'BOT_GITHUB_TOKEN'
	}
}