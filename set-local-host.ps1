param([string[]]$Names = @('searxng.test','pihole.test'))
$ErrorActionPreference = 'Stop'
$hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'
$hostsText = [IO.File]::ReadAllText($hostsPath)
$missing = @()
foreach ($name in $Names) {
    if ($name -notmatch '^[a-z0-9][a-z0-9.-]*\.test$') { throw 'Only local .test hostnames are supported.' }
    $found = $false
    foreach ($line in ($hostsText -split '\r?\n')) {
        $fields = (($line -split '#', 2)[0].Trim() -split '\s+')
        if ($fields.Count -gt 1 -and $fields[1..($fields.Count - 1)] -contains $name) {
            if ($fields[0] -ne '127.0.0.1') { throw "Conflicting hosts entry for $name; no changes made." }
            $found = $true
        }
    }
    if (-not $found) { $missing += $name }
}
if ($missing.Count -gt 0) {
    Copy-Item -LiteralPath $hostsPath -Destination "$hostsPath.caddy-backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
    $additions = "`r`n" + (($missing | ForEach-Object { "127.0.0.1 $_ # Caddy local services" }) -join "`r`n") + "`r`n"
    [IO.File]::AppendAllText($hostsPath, $additions, [Text.Encoding]::ASCII)
}
ipconfig /flushdns | Out-Null
