# Script para gerar changelog de mods a partir do Git
# Detecta mods adicionados, removidos e atualizados

param(
    [string]$OutputFile = "CHANGELOG-MODS.md",
    [string]$FromCommit = $null,  # Se null, usa HEAD~1
    [string]$ToCommit = "HEAD"
)

function Get-ModName {
    param([string]$FilePath)
    return [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
}

try {
    # Se FromCommit não foi especificado, tentar usar HEAD~1
    if (-not $FromCommit) {
        $commitCount = (git rev-list --count HEAD 2>$null)
        if ($commitCount -gt 1) {
            $FromCommit = "HEAD~1"
        } else {
            # Se houver apenas 1 commit, comparar com git hash vazio (show all)
            $FromCommit = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        }
    }

    # Obter lista de commits
    $commits = git log --oneline "$FromCommit..$ToCommit" 2>$null
    if (-not $commits) {
        Write-Host "Nenhuma mudança encontrada entre $FromCommit e $ToCommit"
        return
    }

    # Diferenciar arquivos
    $diff = git diff --name-status "$FromCommit..$ToCommit" -- mods/ 2>$null
    
    $added = @()
    $removed = @()
    $updated = @()
    
    foreach ($line in $diff) {
        if (-not $line) { continue }
        $parts = $line -split '\s+', 2
        $status = $parts[0]
        $file = $parts[1]
        $modName = Get-ModName $file
        
        switch ($status) {
            'A' { $added += $modName }
            'D' { $removed += $modName }
            'M' { $updated += $modName }
        }
    }

    # Gerar changelog
    $changelog = @"
# Changelog de Mods
**Data:** $(Get-Date -Format 'dd/MM/yyyy HH:mm')  
**Versão Modpack:** 1.4.2

"@

    if ($added) {
        $changelog += "## [+] Adicionados`n"
        $changelog += ($added | ForEach-Object { "- $_" }) -join "`n"
        $changelog += "`n`n"
    }
    
    if ($removed) {
        $changelog += "## [-] Removidos`n"
        $changelog += ($removed | ForEach-Object { "- $_" }) -join "`n"
        $changelog += "`n`n"
    }
    
    if ($updated) {
        $changelog += "## [~] Atualizados`n"
        $changelog += ($updated | ForEach-Object { "- $_" }) -join "`n"
        $changelog += "`n`n"
    }

    # Adicionar commits
    $changelog += "## Commits`n"
    $changelog += ($commits | ForEach-Object { "- $_" }) -join "`n"

    # Salvar arquivo
    $changelog | Out-File $OutputFile -Encoding UTF8
    Write-Host "[OK] Changelog gerado: $OutputFile"
    Write-Host ""
    Write-Host "Resumo:"
    Write-Host "  Adicionados: $($added.Count)"
    Write-Host "  Removidos: $($removed.Count)"
    Write-Host "  Atualizados: $($updated.Count)"
}
catch {
    Write-Host "[ERRO] $_"
}
