# install.ps1 — deploy Claude config files on Windows
# Run once after cloning this repo, or re-run to update.
# Requires Developer Mode OR run as Administrator for symlinks.
# If neither is available, files will be copied instead.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoDir = $PSScriptRoot
$Hostname = (hostname).ToLower()

Write-Host "Installing Claude config from $RepoDir (hostname: $Hostname)"

# Find machine file — case-insensitive match against machines/ directory
$MachineFile = Get-ChildItem "$RepoDir\machines\*.md" |
    Where-Object { $_.BaseName.ToLower() -eq $Hostname } |
    Select-Object -First 1

$MachineJson = Get-ChildItem "$RepoDir\machines\*.json" |
    Where-Object { $_.BaseName.ToLower() -eq $Hostname } |
    Select-Object -First 1

# Helper: create a symlink, falling back to a file copy if symlinks aren't available
function Link-Or-Copy {
    param(
        [string]$Target,   # source (what to point at)
        [string]$Link,     # where to create the link/copy
        [string]$Label
    )

    if (Test-Path $Link) {
        Write-Host "  $Label already exists — skipping"
        return
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Host "  Linked $Label"
    } catch {
        # Symlinks failed (no Developer Mode / not admin) — fall back to copy
        Copy-Item -Path $Target -Destination $Link -Force
        Write-Host "  Copied $Label (symlinks unavailable — re-run install.ps1 after repo updates)"
    }
}

# Helper: create a directory symlink (junction), falling back to robocopy
function Link-Or-Copy-Dir {
    param(
        [string]$Target,
        [string]$Link,
        [string]$Label
    )

    if (Test-Path $Link) {
        Write-Host "  $Label already exists — skipping"
        return
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Host "  Linked $Label"
    } catch {
        # Fall back to junction (no admin needed on Windows)
        try {
            cmd /c "mklink /J `"$Link`" `"$Target`"" | Out-Null
            Write-Host "  Junction $Label"
        } catch {
            # Last resort: copy
            Copy-Item -Path $Target -Destination $Link -Recurse -Force
            Write-Host "  Copied $Label (re-run install.ps1 after repo updates)"
        }
    }
}

# ~/.claude/CLAUDE.md — universal rules
$ClaudeDir = "$env:USERPROFILE\.claude"
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
Link-Or-Copy -Target "$RepoDir\CLAUDE.md" -Link "$ClaudeDir\CLAUDE.md" -Label "~\.claude\CLAUDE.md"

# ~/CLAUDE.md — machine-specific context
if ($MachineFile) {
    Link-Or-Copy -Target $MachineFile.FullName -Link "$env:USERPROFILE\CLAUDE.md" -Label "~\CLAUDE.md → machines\$($MachineFile.Name)"
} else {
    Write-Host ""
    Write-Host "  WARNING: No machine file found matching machines\$Hostname.md"
    Write-Host "  Create machines\$Hostname.md and re-run."
}

# Skills — link each skill directory
$SkillsDir = "$ClaudeDir\skills"
New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
Get-ChildItem "$RepoDir\skills" -Directory | ForEach-Object {
    $SkillName = $_.Name
    Link-Or-Copy-Dir -Target $_.FullName -Link "$SkillsDir\$SkillName" -Label "~\.claude\skills\$SkillName"
}

# Machine config JSON → ~/.claude/machine-config.json
if ($MachineJson) {
    Copy-Item -Path $MachineJson.FullName -Destination "$ClaudeDir\machine-config.json" -Force
    Write-Host "  Wrote ~\.claude\machine-config.json"
} else {
    Write-Host "  No machines\$Hostname.json found — dashboard will use defaults"
}

# Secrets reminder
if (-not (Test-Path "$ClaudeDir\secrets.md")) {
    Write-Host ""
    Write-Host "  ACTION REQUIRED: ~\.claude\secrets.md not found."
    Write-Host "  Create it with your machine-specific credentials."
}

Write-Host ""
Write-Host "Done. Restart Claude Code to pick up changes."
