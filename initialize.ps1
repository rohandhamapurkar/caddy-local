$ErrorActionPreference = 'Stop'
docker network inspect local-apps *> $null
if ($LASTEXITCODE -ne 0) {
    docker network create local-apps | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not create local-apps Docker network.' }
}
Write-Output 'Shared local-apps network is ready.'
