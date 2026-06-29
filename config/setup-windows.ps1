<#
.SYNOPSIS
    Instala o Claude Code Remote Control como serviço no Windows via Agendador de Tarefas.
.DESCRIPTION
    Cria uma tarefa no Agendador que mantém o claude remote-control rodando 24/7,
    com reinicialização automática em caso de falha. Deve ser executado como Administrador.
.NOTES
    Versão: 1.0
    Executar como: PowerShell -ExecutionPolicy Bypass -File setup-windows.ps1
#>

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$LogDir = "$env:USERPROFILE\.claude\remote-control-logs"
$StartScript = Join-Path $ProjectRoot "scripts\start.bat"
$SessionName = "Claude Remote"

Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Claude Code Remote Control — Instalação Windows" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ─── Verificações ───────────────────────────────────
Write-Host "Verificando pré-requisitos..." -ForegroundColor Yellow

# 1. Claude Code instalado?
try {
    $claudeVersion = claude --version 2>&1
    Write-Host "  ✓ Claude Code: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Comando 'claude' não encontrado. Instale o Claude Code primeiro." -ForegroundColor Red
    exit 1
}

# 2. Autenticado?
$authCheck = claude auth status 2>&1
if ($authCheck -match "logged in|authenticated") {
    Write-Host "  ✓ Autenticação OK" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Execute 'claude auth login' antes de iniciar o serviço" -ForegroundColor Yellow
}

# 3. Git bash disponível?
$gitBash = Get-Command "C:\Program Files\Git\bin\bash.exe" -ErrorAction SilentlyContinue
if (-not $gitBash) {
    Write-Host "  ✗ Git Bash não encontrado. Instale Git for Windows." -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Git Bash encontrado" -ForegroundColor Green

# ─── Criar diretórios ───────────────────────────────
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Write-Host "  ✓ Diretório de logs: $LogDir" -ForegroundColor Green

# ─── Criar script de inicialização (.bat) ───────────
@"
@echo off
REM start.bat — Inicia claude remote-control via Git Bash
"%ProgramFiles%\Git\bin\bash.exe" -c "SESSION_NAME='%SESSION_NAME%' LOG_DIR='%LOG_DIR%' %START_SCRIPT%"
"@ | Set-Content -Path "$ProjectRoot\scripts\start.bat"

# ─── Criar tarefa no Agendador ─────────────────────
$TaskName = "ClaudeCodeRemoteControl"
$TaskDescription = "Mantém o Claude Code Remote Control rodando 24 horas por dia, 7 dias por semana"
$TaskAction = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$StartScript`"" -WorkingDirectory $ProjectRoot

# Reiniciar a cada 30s se falhar
$TaskSettings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Seconds 30) `
    -ExecutionTimeLimit 0 `
    -Priority 6

# Iniciar na inicialização do sistema
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup

# Registrar tarefa
Register-ScheduledTask -TaskName $TaskName `
    -Action $TaskAction `
    -Settings $TaskSettings `
    -Trigger $TaskTrigger `
    -Description $TaskDescription `
    -User "SYSTEM" `
    -RunLevel Highest

Write-Host ""
Write-Host "  ✓ Tarefa '$TaskName' criada no Agendador" -ForegroundColor Green
Write-Host "  ✓ Inicia automaticamente com o Windows" -ForegroundColor Green
Write-Host ""

# ─── Iniciar agora ─────────────────────────────────
Write-Host "Iniciando serviço agora..." -ForegroundColor Yellow
Start-ScheduledTask -TaskName $TaskName
Write-Host "  ✓ Serviço iniciado!" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Instalação concluída!"
Write-Host ""
Write-Host "  Gerenciamento:" -ForegroundColor White
Write-Host "    Verificar status: Get-ScheduledTask -TaskName '$TaskName' | Start-ScheduledTask"
Write-Host "    Parar tarefa:     Stop-ScheduledTask -TaskName '$TaskName'"
Write-Host "    Remover tarefa:   Unregister-ScheduledTask -TaskName '$TaskName' -Confirm"
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan