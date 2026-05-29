param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Release,

    [switch] $SkipChecks,
    [switch] $NoCommit
)

$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..')
$VersionFile = Join-Path $Root 'VERSION'
$BackendDir = Join-Path $Root 'backend'
$FrontendDir = Join-Path $Root 'frontend'
$PomFile = Join-Path $BackendDir 'pom.xml'
$PackageFile = Join-Path $FrontendDir 'package.json'
$PackageLockFile = Join-Path $FrontendDir 'package-lock.json'
$AngularVersionFile = Join-Path $FrontendDir 'src/environments/version.ts'

function Assert-SemVer {
    param([string] $Version)

    if ($Version -notmatch '^\d+\.\d+\.\d+$') {
        throw "Versao invalida: '$Version'. Use o formato x.y.z."
    }
}

function Get-NextVersion {
    param(
        [string] $CurrentVersion,
        [string] $ReleaseType
    )

    Assert-SemVer $CurrentVersion
    $parts = $CurrentVersion.Split('.') | ForEach-Object { [int] $_ }

    switch ($ReleaseType) {
        'patch' { $parts[2] += 1 }
        'minor' {
            $parts[1] += 1
            $parts[2] = 0
        }
        'major' {
            $parts[0] += 1
            $parts[1] = 0
            $parts[2] = 0
        }
        default {
            Assert-SemVer $ReleaseType
            return $ReleaseType
        }
    }

    return '{0}.{1}.{2}' -f $parts[0], $parts[1], $parts[2]
}

function Set-ProjectVersion {
    param([string] $Version)

    Set-Content -Path $VersionFile -Value $Version -NoNewline -Encoding UTF8

    [xml] $pom = Get-Content -Path $PomFile
    $pom.project.version = $Version
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.Encoding = New-Object System.Text.UTF8Encoding($false)
    $writer = [System.Xml.XmlWriter]::Create($PomFile, $settings)
    try {
        $pom.Save($writer)
    }
    finally {
        $writer.Close()
    }

    $nodeScript = @"
const fs = require('fs');
const [packageFile, packageLockFile, version] = process.argv.slice(1);
const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, ''));

const packageJson = readJson(packageFile);
packageJson.version = version;
fs.writeFileSync(packageFile, JSON.stringify(packageJson, null, 2) + '\n');

const packageLockJson = readJson(packageLockFile);
packageLockJson.version = version;
if (packageLockJson.packages && packageLockJson.packages['']) {
  packageLockJson.packages[''].version = version;
}
fs.writeFileSync(packageLockFile, JSON.stringify(packageLockJson, null, 2) + '\n');
"@
    node -e $nodeScript $PackageFile $PackageLockFile $Version
    if ($LASTEXITCODE -ne 0) {
        throw 'Falha ao atualizar package.json ou package-lock.json.'
    }

    $versionSource = "export const APP_VERSION = '$Version';"
    Set-Content -Path $AngularVersionFile -Value $versionSource -Encoding UTF8
}

function Invoke-Checks {
    Push-Location $BackendDir
    try {
        ./mvnw test
    }
    finally {
        Pop-Location
    }

    Push-Location $FrontendDir
    try {
        npm run build
    }
    finally {
        Pop-Location
    }
}

function Invoke-ReleaseCommit {
    param(
        [string] $RepositoryDir,
        [string] $Version,
        [string[]] $Paths
    )

    Push-Location $RepositoryDir
    try {
        $changed = git status --short -- $Paths
        if (-not $changed) {
            Write-Host "Sem alteracoes de release em $RepositoryDir"
            return
        }

        git add -- $Paths
        git commit -m "chore(release): v$Version"
        git tag -a "v$Version" -m "Release v$Version"
    }
    finally {
        Pop-Location
    }
}

function Test-GitRepository {
    param([string] $RepositoryDir)

    return (Test-Path -LiteralPath (Join-Path $RepositoryDir '.git'))
}

function Invoke-RootReleaseCommit {
    param([string] $Version)

    if (-not (Test-GitRepository -RepositoryDir $Root)) {
        Write-Warning 'A raiz do workspace nao e um repositorio Git; VERSION, AGENTS.md e scripts/release.ps1 nao serao commitados automaticamente.'
        return
    }

    Invoke-ReleaseCommit -RepositoryDir $Root -Version $Version -Paths @(
        'VERSION',
        'AGENTS.md',
        'scripts/release.ps1',
        'backend/pom.xml',
        'frontend/package.json',
        'frontend/package-lock.json',
        'frontend/src/environments/version.ts'
    )
}

$CurrentVersion = (Get-Content -Path $VersionFile -Raw).Trim()
$NextVersion = Get-NextVersion -CurrentVersion $CurrentVersion -ReleaseType $Release

Set-ProjectVersion -Version $NextVersion

if (-not $SkipChecks) {
    Invoke-Checks
}

if (-not $NoCommit) {
    Invoke-RootReleaseCommit -Version $NextVersion
}

Write-Host "Release v$NextVersion preparada com sucesso."
