# Claude Code Remote Control

Mantenha sua sessão do Claude Code rodando **24 horas por dia, 7 dias por semana** e acesse de qualquer dispositivo — navegador, celular ou tablet.

> ⚠️ **Filosofia:** Este repositório **não** cria protocolos, APIs ou mecanismos de comunicação alternativos. Toda a comunicação utiliza exclusivamente o recurso oficial **Remote Control** do Claude Code. O `claude.ai/code` já é a interface remota oficial — estes são apenas scripts de automação e configuração para manter o serviço rodando.

---

## Como funciona

```
Seu Computador (ligado 24/7)
│
├─ claude remote-control ─── HTTPS (TLS) ─── Anthropic API ───┬── claude.ai/code
│                                                             └── Claude App (mobile)
│
└─ Serviço systemd/Windows mantém o processo vivo
```

O Claude Code faz conexão **HTTPS outbound** com a Anthropic — **nunca abre portas no seu computador**. O servidor roteia mensagens entre o cliente web/mobile e sua sessão local.

## Requisitos

| Item | Versão / Plano |
|------|----------------|
| Claude Code | v2.1.51+ (`claude --version`) |
| Assinatura | Pro, Max, Team ou Enterprise |
| Autenticação | `claude auth login` (conta claude.ai) |

## Início Rápido

```bash
# 1. Autentique-se (se ainda não fez)
claude auth login

# 2. Inicie o servidor remoto
claude remote-control --name "Meu Servidor"

# 3. Aperte ESPAÇO para ver o QR code
#    Escaneie com o app Claude no celular
#    OU abra claude.ai/code no navegador
```

Pronto. Sua sessão já está acessível de qualquer dispositivo.

---

## Instalação como Serviço (24/7)

### Linux (systemd)

```bash
sudo cp config/claude-remote-control.service /etc/systemd/system/
sudo nano /etc/systemd/system/claude-remote-control.service  # ajuste USER e caminhos
sudo systemctl daemon-reload
sudo systemctl enable --now claude-remote-control
sudo systemctl status claude-remote-control
```

### Windows

```powershell
# PowerShell como Administrador
Set-ExecutionPolicy Bypass -Scope Process
.\config\setup-windows.ps1
```

---

## Scripts

| Script | Descrição |
|--------|-----------|
| `scripts/start.sh` | Inicia `claude remote-control` com nome e log |
| `scripts/stop.sh` | Para o processo gracefulmente |
| `scripts/status.sh` | Mostra se o serviço está rodando |
| `scripts/restart.sh` | Reinicia o servidor |
| `scripts/monitor.sh` | (Opcional) Notifica se o processo caiu |

---

## Conectando-se

| Dispositivo | Como conectar |
|-------------|---------------|
| **Navegador** (qualquer) | Abra `claude.ai/code` |
| **iPhone / iPad** | App Claude na App Store, escaneie o QR code |
| **Android** | App Claude no Google Play, escaneie o QR code |
| **Outro computador** | Abra a Session URL no navegador |

## Sincronização entre Dispositivos

Com o Remote Control ativo, você pode usar **simultaneamente**:

- O terminal onde o servidor está rodando
- O navegador em `claude.ai/code`
- O app Claude no celular

Todas as mensagens ficam sincronizadas em tempo real via Anthropic API. Você pode alternar livremente entre dispositivos.

---

## Configurações Recomendadas

```bash
# No terminal do Claude Code, configure:
/config set Enable Remote Control for all sessions true

# Para sessão nomeada:
claude remote-control --name "Servidor Central" --spawn session

# Com sandboxing (isola filesystem/rede):
claude remote-control --name "Servidor" --sandbox
```

---

## Comandos Úteis

| Comando | Descrição |
|---------|-----------|
| `claude remote-control` | Modo servidor (fica ouvindo conexões) |
| `claude --remote-control` | Sessão interativa + remota |
| `/remote-control` ou `/rc` | Ativa remote control em sessão existente |
| Espaço | Mostra/esconde QR code |
| `w` | Alterna same-dir / worktree |
| `/config` | Configurações do Claude Code |
| `/compact` | Resumo do contexto da sessão |
| `/recap` | Resumo das últimas ações |

### Flags do `claude remote-control`

| Flag | Descrição |
|------|-----------|
| `--name "Nome"` | Nome da sessão (visível em claude.ai/code) |
| `--spawn session` | Modo sessão única (rejeita conexões extras) |
| `--spawn worktree` | Cada sessão em git worktree próprio |
| `--capacity N` | Máximo de sessões simultâneas (padrão: 32) |
| `--sandbox` | Habilita sandboxing de filesystem/rede |
| `--verbose` | Logs detalhados de conexão |

---

## Estrutura do Repositório

```
claude-remote-control/
├── scripts/
│   ├── start.sh              # Inicia o servidor remoto
│   ├── stop.sh               # Para o servidor remoto
│   ├── status.sh             # Verifica status da sessão
│   ├── restart.sh            # Reinicia o servidor
│   └── monitor.sh            # Notifica se o processo caiu
├── config/
│   ├── claude-remote-control.service   # systemd (Linux)
│   └── setup-windows.ps1              # Instalação Windows (Agendador)
├── docs/
│   ├── setup-guide.md         # Guia detalhado de instalação
│   ├── troubleshooting.md     # Solução de problemas
│   └── references.md          # Links da documentação oficial
└── README.md                  # Este arquivo
```

---

## Documentação Oficial

- [Remote Control](https://code.claude.com/docs/en/remote-control) — Documentação oficial do recurso
- [Claude Code Overview](https://docs.anthropic.com/en/docs/claude-code/overview) — Visão geral
- [CLI Reference](https://code.claude.com/docs/en/cli-reference) — Todos os comandos e flags
- [Security Model](https://code.claude.com/docs/en/security) — Modelo de segurança
- [Authentication](https://code.claude.com/docs/en/authentication) — Configuração de login

---

## Licença

MIT