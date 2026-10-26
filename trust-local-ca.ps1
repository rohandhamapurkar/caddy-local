$ErrorActionPreference = 'Stop'
$composePath = Join-Path $PSScriptRoot 'compose.yaml'
$certificatePath = Join-Path $PSScriptRoot 'caddy-local-root.crt'
docker compose -f $composePath cp caddy:/data/caddy/pki/authorities/local/root.crt $certificatePath
if ($LASTEXITCODE -ne 0) { throw 'Start the containers and wait for Caddy to generate its CA, then retry.' }
Import-Certificate -FilePath $certificatePath -CertStoreLocation Cert:\CurrentUser\Root | Select-Object Subject, Thumbprint, NotAfter
Write-Output 'Trusted this instance CA for the current Windows user. Restart browsers if needed.'
