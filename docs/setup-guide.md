# Guia de Instalação — Claude Code Remote Control

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Instalação Manual](#instalação-manual)
- [Linux (systemd)](#linux-systemd)
- [Windows (Agendador de Tarefas)](#windows-agendador-de-tarefas)
- [Pós-instalação](#pós-instalação)
- [Manutenção](#manutenção)

---

## Pré-requisitos

| Item | Detalhe |
|------|---------|
| **Claude Code** | v2.1.51+ (`claude --version`) |
| **Assinatura** | Pro, Max, Team ou Enterprise |
| **Autenticação** | `claude auth login` (uma vez) |
| **Conexão** | Apenas HTTPS outbound (porta 443) |

### Verificação rápida

```bash
claude --version          # Deve ser v2.1.51+
claude auth status        # Deve mostrar "logged in"
```

---

## Instalação Manual

A forma mais simples é rodar o servidor diretamente no terminal:

```bash
# Navegue até o diretório do projeto
cd claude-remote-control

# Inicie com nome personalizado
./scripts/start.sh "Meu Servidor"
```

Para manter rodando após fechar o terminal, use `screen`, `tmux` ou instale como serviço.

---

## Linux (systemd)

### 1. Ajustar o arquivo de serviço

Edite `config/claude-remote-control.service` e substitua `YOUR_USERNAME` pelo seu usuário:

```bash
sed -i 's/YOUR_USERNAME/'$(whoami)'/g' config/claude-remote-control.service
```

Verifique também o caminho do projeto (ajuste se necessário):
```bash
echo $PWD  # Deve ser /home/$(whoami)/claude-remote-control
```

### 2. Instalar

```bash
sudo cp config/claude-remote-control.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now claude-remote-control
```

### 3. Verificar

```bash
sudo systemctl status claude-remote-control
journalctl -u claude-remote-control -f  # Logs ao vivo
```

### Gerenciamento

```bash
sudo systemctl stop claude-remote-control     # Parar
sudo systemctl restart claude-remote-control   # Reiniciar
sudo systemctl disable claude-remote-control   # Remover da inicialização
```

---

## Windows (Agendador de Tarefas)

### 1. Executar instalação

Abra o **PowerShell como Administrador** e execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\config\setup-windows.ps1
```

O script irá:

1. Verificar se o Claude Code está instalado e autenticado
2. Verificar se o Git Bash está disponível (necessário para rodar scripts `.sh`)
3. Criar a tarefa `ClaudeCodeRemoteControl` no Agendador
4. Iniciar o serviço imediatamente

### 2. Gerenciamento

```powershell
# Status
Get-ScheduledTask -TaskName "ClaudeCodeRemoteControl" | Format-List

# Logs
Get-Content "$env:USERPROFILE\.claude\remote-control-logs\remote-control.log" -Tail 20

# Parar
Stop-ScheduledTask -TaskName "ClaudeCodeRemoteControl"

# Iniciar
Start-ScheduledTask -TaskName "ClaudeCodeRemoteControl"

# Desinstalar
Unregister-ScheduledTask -TaskName "ClaudeCodeRemoteControl" -Confirm
```

### Requisitos Windows

- **Windows 10/11** (qualquer edição)
- **Git for Windows** (para Git Bash) — [git-scm.com](https://git-scm.com)
- **Claude Code** instalado e no `PATH`

---

## Pós-instalação

### Verificar se está rodando

```bash
./scripts/status.sh
```

Saída esperada:

```
═══════════════════════════════════════════════
  Claude Code Remote Control — Status
═══════════════════════════════════════════════
  PID file: /home/user/.claude/remote-control-logs/remote-control.pid
  PID: 12345
  Status: RODANDO
═══════════════════════════════════════════════
```

### Conectar de outro dispositivo

1. Abra `claude.ai/code` no navegador ou o app Claude no celular
2. Escaneie o QR code mostrado no terminal do servidor
3. Pronto — você está na mesma sessão

### Configurar no Claude Code

Dentro de qualquer sessão do Claude Code:

```
/config set Enable Remote Control for all sessions true
```

---

## Manutenção

### Atualizar o projeto

```bash
cd claude-remote-control
git pull
# Reiniciar o serviço (Linux)
sudo systemctl restart claude-remote-control
# ou (Windows)
Restart-ScheduledTask -TaskName "ClaudeCodeRemoteControl"
```

### Logs

```bash
# Todos os logs
cat ~/.claude/remote-control-logs/remote-control.log

# Últimas 50 linhas
tail -50 ~/.claude/remote-control-logs/remote-control.log

# Monitorar em tempo real (Linux)
tail -f ~/.claude/remote-control-logs/remote-control.log
```

### Monitoramento (opcional)

```bash
# Verificação única
./scripts/monitor.sh

# Daemon (verifica a cada 30s e reinicia se cair)
./scripts/monitor.sh --daemon --interval 30 --restart

# Com webhook (Slack/Discord)
WEBHOOK_URL="https://hooks.slack.com/..." ./scripts/monitor.sh --daemon --restart
```

### Solução de problemas

Veja o [Guia de Troubleshooting](troubleshooting.md) para problemas comuns.