# Installs one blueprint folder (e.g. "backend") from DMK980/Blueprints into
# a local project, without needing git or npm - just tar, bundled with
# Windows 10 1803+ / Windows 11.
#
# Usage:
#   iwr -useb https://raw.githubusercontent.com/DMK980/Blueprints/main/install.ps1 -OutFile install.ps1
#   .\install.ps1 backend
#
# Or, as a one-liner that passes arguments through to the remote script:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/DMK980/Blueprints/main/install.ps1))) backend
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Blueprint,

    [Parameter(Position = 1)]
    [string]$Destination,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$Repo = "DMK980/Blueprints"
$Branch = "main"

if (-not $Destination) {
    $Destination = ".\$Blueprint"
}

if ((Test-Path $Destination) -and (-not $Force)) {
    Write-Error "'$Destination' already exists. Use -Force to overwrite, or pass a different -Destination."
    exit 1
}

if (-not (Get-Command tar -ErrorAction SilentlyContinue)) {
    Write-Error "tar is required (bundled with Windows 10 1803+ / Windows 11)."
    exit 1
}

$TmpDir = Join-Path $env:TEMP ("blueprints-install-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

try {
    $TarballPath = Join-Path $TmpDir "repo.tar.gz"
    $TarballUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.tar.gz"
    Invoke-WebRequest -Uri $TarballUrl -OutFile $TarballPath -UseBasicParsing

    $Top = "Blueprints-$Branch"
    & tar -xzf $TarballPath -C $TmpDir "$Top/$Blueprint" 2>$null
    $ExtractedOk = ($LASTEXITCODE -eq 0) -and (Test-Path (Join-Path $TmpDir "$Top/$Blueprint"))
    if (-not $ExtractedOk) {
        Write-Error "Blueprint '$Blueprint' not found in $Repo@$Branch. See https://github.com/$Repo for available blueprints."
        exit 1
    }

    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }
    $DestParent = Split-Path -Parent $Destination
    if ($DestParent -and -not (Test-Path $DestParent)) {
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
    }
    Move-Item -Path (Join-Path $TmpDir "$Top/$Blueprint") -Destination $Destination

    Write-Host "Installed '$Blueprint' blueprint into '$Destination'."
    Write-Host "Next: start a coding-agent session in that directory and tell it to follow the instructions in $Blueprint/AGENTS.md (Claude Code auto-loads $Blueprint/CLAUDE.md instead)."
}
finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
