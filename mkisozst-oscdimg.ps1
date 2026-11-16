$ErrorActionPreference = 'Stop'

# WinDev incremental folder -> ISO -> ZST packager.
# Detects changes using file metadata (path, size, last-write time), not content hashes.
# First run creates a baseline and assumes existing ISO/ZST files are current.

$Root = $PSScriptRoot
$Oscdimg = Join-Path $Root 'oscdimg.exe'
$Zstd = Join-Path $Root 'zstd.exe'
$ManifestDir = Join-Path $Root '.win-dev-manifests'

$Modules = @(
    [pscustomobject]@{ Name = 'WinDev-Base';       Label = 'WinDev-Base' },
    [pscustomobject]@{ Name = 'WinDev-MSYS2';      Label = 'WinDev-MSYS2' },
    [pscustomobject]@{ Name = 'WinDev-Python';     Label = 'WinDev-Python' },
	[pscustomobject]@{ Name = 'WinDev-ToolChains';     Label = 'WinDev-ToolChains' },
    [pscustomobject]@{ Name = 'WinDev-DotNet'; Label = 'WinDev-DotNet' }
)

function Get-MetadataManifest {
    param([Parameter(Mandatory)][string]$Source)
    $base = (Get-Item -LiteralPath $Source).FullName.TrimEnd('\') + '\'
    $entries = @(
        Get-ChildItem -LiteralPath $Source -Force -File -Recurse |
        ForEach-Object {
            [pscustomobject]@{
                Path = $_.FullName.Substring($base.Length)
                Size = $_.Length
                LastWriteUtcTicks = $_.LastWriteTimeUtc.Ticks
            }
        } |
        Sort-Object -Property Path
    )
    return ConvertTo-Json -InputObject $entries -Depth 3 -Compress
}

function Test-Zstd {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    & $Zstd -t $Path
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-Path -LiteralPath $Oscdimg -PathType Leaf)) { throw "oscdimg.exe not found: $Oscdimg`nPlace oscdimg.exe beside this script or update `$Oscdimg to its full path." }
if (-not (Test-Path -LiteralPath $Zstd -PathType Leaf)) { throw "zstd.exe not found: $Zstd" }
New-Item -ItemType Directory -Force -Path $ManifestDir | Out-Null

Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host '       WinDev Incremental ISO + ZST Packager' -ForegroundColor Cyan
Write-Host '==================================================' -ForegroundColor Cyan
Write-Host "Root: $Root"
Write-Host 'Change detection: file metadata (no content hashing)'
Write-Host ''

$failed = $false
$baselineCreated = $false
$rebuilt = 0

foreach ($module in $Modules) {
    $name = $module.Name
    $source = Join-Path $Root $name
    $iso = Join-Path $Root "$name.iso"
    $zstFile = "$iso.zst"
    $manifest = Join-Path $ManifestDir "$name.json"
    $tempIso = Join-Path $Root "$name.building.iso"
    $tempZst = Join-Path $Root "$name.building.iso.zst"

    Write-Host ''
    Write-Host '--------------------------------------------------' -ForegroundColor Cyan
    Write-Host "Module: $name" -ForegroundColor Cyan
    Write-Host '--------------------------------------------------' -ForegroundColor Cyan

    try {
        if (-not (Test-Path -LiteralPath $source -PathType Container)) { throw "Source folder not found: $source" }

        Write-Host 'Scanning file metadata...'
        $current = Get-MetadataManifest -Source $source
        $hasManifest = Test-Path -LiteralPath $manifest -PathType Leaf
        $isoExists = Test-Path -LiteralPath $iso -PathType Leaf
        $zstExists = Test-Path -LiteralPath $zstFile -PathType Leaf

        if (-not $hasManifest -and $isoExists -and $zstExists) {
            # The user has already created these outputs manually. Seed the baseline without rebuilding.
            Set-Content -LiteralPath $manifest -Value $current -Encoding UTF8
            Write-Host 'BASELINE CREATED: existing ISO/ZST retained (assumed current).' -ForegroundColor Yellow
            $baselineCreated = $true
            continue
        }

        if ($hasManifest) {
            $previous = Get-Content -LiteralPath $manifest -Raw
            if ($current.Trim() -ceq $previous.Trim() -and $isoExists -and $zstExists) {
                # Avoid a full archive test on every run; that would read the entire compressed file.
                Write-Host 'UNCHANGED: ISO and ZST exist; skipping.' -ForegroundColor Green
                continue
            }
            if ($current.Trim() -ceq $previous.Trim()) {
                Write-Host 'Source unchanged, but ISO/ZST output is missing; rebuilding.' -ForegroundColor Yellow
            } else {
                Write-Host 'CHANGES DETECTED: rebuilding this module.' -ForegroundColor Yellow
            }
        } else {
            Write-Host 'No baseline and no complete output pair; building module.' -ForegroundColor Yellow
        }

        Remove-Item -LiteralPath $tempIso, $tempZst -Force -ErrorAction SilentlyContinue

        Write-Host '[1/3] Creating temporary ISO...'
        & $Oscdimg '-m' '-o' '-u2' '-udfver102' "-l$($module.Label)" $source $tempIso
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $tempIso -PathType Leaf)) {
            throw "oscdimg failed for $name (exit code $LASTEXITCODE)."
        }

        Write-Host '[2/3] Compressing ISO with Zstandard level 3...'
        & $Zstd '-T0' '-3' '-f' $tempIso '-o' $tempZst
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $tempZst -PathType Leaf)) {
            throw "zstd compression failed for $name (exit code $LASTEXITCODE)."
        }

        Write-Host '[3/3] Verifying compressed archive...'
        if (-not (Test-Zstd -Path $tempZst)) { throw "Zstandard integrity test failed for $name." }

        # Publish only after the new ISO and ZST have been created and ZST verified.
        Move-Item -LiteralPath $tempIso -Destination $iso -Force
        Move-Item -LiteralPath $tempZst -Destination $zstFile -Force
        Set-Content -LiteralPath $manifest -Value $current -Encoding UTF8

        $rebuilt++
        $isoSize = (Get-Item -LiteralPath $iso).Length
        $zstSize = (Get-Item -LiteralPath $zstFile).Length
        $saved = if ($isoSize -gt 0) { [math]::Round((1 - $zstSize / $isoSize) * 100, 1) } else { 0 }
        Write-Host "SUCCESS: $name" -ForegroundColor Green
        Write-Host "ISO: $([math]::Round($isoSize / 1GB, 2)) GiB | ZST: $([math]::Round($zstSize / 1GB, 2)) GiB | Reduction: $saved%"
    }
    catch {
        $failed = $true
        Write-Host "FAILED: $name" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Remove-Item -LiteralPath $tempIso, $tempZst -Force -ErrorAction SilentlyContinue
        # Keep the previous manifest so a failed build is retried next run.
    }
}

Write-Host ''
Write-Host '==================================================' -ForegroundColor Cyan
if ($failed) { Write-Host 'COMPLETED WITH ERRORS' -ForegroundColor Red; exit 1 }
if ($rebuilt -eq 0 -and $baselineCreated) {
    Write-Host 'BASELINE INITIALIZED. No rebuild performed.' -ForegroundColor Yellow
    Write-Host 'Next run will rebuild only modules whose metadata changes.'
} elseif ($rebuilt -eq 0) {
    Write-Host 'ALL MODULES UNCHANGED. Nothing to rebuild.' -ForegroundColor Green
} else {
    Write-Host "SUCCESS. Rebuilt $rebuilt module(s)." -ForegroundColor Green
}
exit 0
