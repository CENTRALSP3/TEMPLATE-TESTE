# Troubleshooting — Claude Code Remote Control

## Problemas Comuns

### Servidor não inicia

**Sintoma:** `start.sh` falha silenciosamente.

**Verificações:**

```bash
# 1. Claude Code está instalado?
claude --version

# 2. Está autenticado?
claude auth status

# 3. Há logs de erro?
cat ~/.claude/remote-control-logs/remote-control.log
```

**Solução:** Reautentique com `claude auth login` e tente novamente.

---

### Conexão recusada no claude.ai/code

**Sintoma:** A sessão aparece como "offline" ou não aparece.

**Causas possíveis:**

| Causa | Como verificar | Solução |
|-------|---------------|---------|
| Firewall bloqueando HTTPS | `curl -I https://api.anthropic.com` | Liberar porta 443 |
| Proxy corporativo | `env \| grep -i proxy` | Configurar proxy |
| VPN bloqueando | Desconectar VPN e testar | Ajustar regras de VPN |
| Sessão expirou | Verificar terminal do servidor | Reiniciar servidor |

---

### Servidor cai após alguns minutos

**Sintoma:** O processo morre sozinho após rodar por um tempo.

**Verificações:**

```bash
# Ver logs
tail -50 ~/.claude/remote-control-logs/remote-control.log

# Ver uso de memória
ps aux | grep claude

# Limitar memória (Linux systemd)
# Edite /etc/systemd/system/claude-remote-control.service
# Adicione: MemoryMax=4G
sudo systemctl daemon-reload
sudo systemctl restart claude-remote-control
```

**Causas comuns:**

- Pouca memória RAM no servidor
- Limite de processos do sistema
- Sessão expirou por inatividade (verifique plano: Team/Enterprise têm sessões mais longas)

---

### Múltiplas sessões aparecem no claude.ai/code

**Sintoma:** Várias sessões "Claude Remote" listadas.

**Solução:**

```bash
# Ver PIDs ativos
pgrep -af "claude remote-control"

# Parar todas
pkill -f "claude remote-control"

# Remover PID file stale
rm -f ~/.claude/remote-control-logs/remote-control.pid

# Iniciar novamente
./scripts/start.sh "Meu Servidor"
```

Para prevenir, sempre use `--name` com um identificador único.

---

### PID file stale (processo morto mas PID file existe)

**Sintoma:** `status.sh` mostra "PARADO" mas o PID file existe.

**Solução:**

```bash
# Remover o PID file manualmente
rm -f ~/.claude/remote-control-logs/remote-control.pid

# Iniciar novamente
./scripts/start.sh
```

---

### Erro de permissão (Linux systemd)

**Sintoma:** `systemctl status` mostra "permission denied".

**Solução:**

```bash
# Verificar dono do diretório
ls -la ~/.claude/

# Ajustar permissões
chown -R $USER:$USER ~/.claude

# Verificar o serviço
sudo journalctl -u claude-remote-control -n 20 --no-pager
```

---

### Erro de permissão (Windows)

**Sintoma:** A tarefa no Agendador falha com "access denied".

**Solução:**

1. Execute o PowerShell **como Administrador**
2. Verifique se o usuário "SYSTEM" tem acesso ao diretório do projeto
3. Se necessário, mude a tarefa para rodar como seu usuário:

```powershell
$cred = Get-Credential
Register-ScheduledTask -TaskName "ClaudeCodeRemoteControl" -User $cred.UserName -Password $cred.Password
```

---

### Servidor não reinicia automaticamente

**Sintoma:** O processo cai e não sobe de volta.

**Verificações:**

```bash
# Se está usando o loop do start.sh
# Verifique se MAX_RETRIES foi configurado
grep MAX_RETRIES scripts/start.sh

# Se está usando systemd
sudo systemctl status claude-remote-control | grep "Active:"

# Se está usando o monitor
pgrep -af monitor.sh
```

**Solução:** Configure o auto-restart no método que escolher:

- **start.sh:** `MAX_RETRIES=0` (infinito)
- **systemd:** `Restart=on-failure` (já configurado no .service)
- **monitor.sh:** `./scripts/monitor.sh --daemon --restart`

---

## Diagnosticando Problemas de Rede

```bash
# Testar conectividade com Anthropic
curl -I https://api.anthropic.com
curl -I https://code.claude.com

# Verificar latência
ping -c 3 api.anthropic.com

# Verificar rotas (Linux)
traceroute api.anthropic.com

# Verificar portas abertas (Linux)
ss -tlnp | grep claude

# Verificar conexões ativas (Linux)
ss -tup | grep claude
```

## Logs Detalhados

```bash
# Ativar modo verbose
EXTRA_FLAGS="--verbose" ./scripts/start.sh

# Ver logs completos
cat ~/.claude/remote-control-logs/remote-control.log

# Ver logs do monitor (se configurado)
cat ~/.claude/remote-control-logs/monitor.log

# Linux systemd
sudo journalctl -u claude-remote-control -f

# Windows (Event Viewer)
Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational" | Where-Object { $_.Message -like "*ClaudeCode*" } | Format-Table -AutoSize
```

---

## Ainda com problemas?

1. Verifique a [documentação oficial](https://code.claude.com/docs/en/remote-control)
2. Abra uma issue no [GitHub](https://github.com/anthropics/claude-code/issues)
3. Inclua os logs relevantes ao reportar o problema