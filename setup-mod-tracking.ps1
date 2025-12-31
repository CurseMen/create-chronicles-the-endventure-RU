# Setup Git para rastrear mudanças de mods
# Execute este script uma vez para inicializar o repositório

$instanceDir = Get-Location
$gitDir = Join-Path $instanceDir ".git"

# 1. Inicializar Git se não existir
if (-not (Test-Path $gitDir)) {
    Write-Host "Inicializando repositório Git..."
    git init
    
    # Criar .gitignore
    $gitignore = @"
# Minecraft logs e cache
logs/
crash-reports/
cache/
*.log

# Launcher e config local
launcher_profiles.json
options.txt
usercache.json

# Grandes arquivos
saves/
screenshots/
resourcepacks/*.zip
shaderpacks/*.zip

# Arquivos temporários
*.tmp
*.bak
.DS_Store

# Excluir tudo menos mods (descomente se quiser)
# /*
# !/mods/
# !.gitignore
# !CHANGELOG-MODS.md
"@
    $gitignore | Out-File ".gitignore" -Encoding UTF8
    
    Write-Host ".gitignore criado"
}

# 2. Primeiro commit com estado inicial
if (-not (git rev-parse --verify HEAD 2>$null)) {
    Write-Host "Fazendo commit inicial..."
    git add mods/
    git commit -m "v1.4.2 - Estado inicial dos mods"
    Write-Host "Commit inicial concluído"
}

Write-Host "`nGit configurado! Use os próximos comandos:"
Write-Host "  git status              # Ver mudanças"
Write-Host "  git diff mods/          # Ver detalhes das mudanças"
Write-Host "  git add mods/           # Adicionar mudanças"
Write-Host "  git commit -m 'msg'     # Fazer commit com mensagem"
Write-Host "  git log --oneline       # Ver histórico"
