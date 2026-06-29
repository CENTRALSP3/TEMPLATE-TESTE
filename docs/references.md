# Referências — Claude Code Remote Control

Links oficiais e documentações úteis para configurar e manter o Remote Control.

---

## Documentação Oficial

| Recurso | Link |
|---------|------|
| Remote Control | [code.claude.com/docs/en/remote-control](https://code.claude.com/docs/en/remote-control) |
| Visão Geral | [docs.anthropic.com/en/docs/claude-code/overview](https://docs.anthropic.com/en/docs/claude-code/overview) |
| CLI Reference | [code.claude.com/docs/en/cli-reference](https://code.claude.com/docs/en/cli-reference) |
| Security Model | [code.claude.com/docs/en/security](https://code.claude.com/docs/en/security) |
| Authentication | [code.claude.com/docs/en/authentication](https://code.claude.com/docs/en/authentication) |

## Comandos Essenciais

```bash
# Modo servidor dedicado
claude remote-control --name "Nome"

# Sessão interativa + remota
claude --remote-control

# Ativar em sessão existente
/remote-control   # ou /rc
```

## Flags do Remote Control

| Flag | Descrição |
|------|-----------|
| `--name "Nome"` | Nome visível em claude.ai/code |
| `--spawn session` | Sessão única (rejeita extras) |
| `--spawn worktree` | Uma sessão por git worktree |
| `--capacity N` | Máx. sessões simultâneas (padrão 32) |
| `--sandbox` | Isola filesystem/rede |
| `--verbose` | Logs detalhados |

## Atalhos no Terminal

| Tecla | Ação |
|-------|------|
| `Espaço` | Mostra/esconde QR code |
| `w` | Alterna same-dir / worktree |

## Planos e Limites

| Plano | Sessões remotas | Duração de sessão |
|-------|----------------|-------------------|
| Pro | 1 sessão simultânea | Padrão |
| Max | Múltiplas sessões | Estendida |
| Team | Múltiplas sessões | Sob demanda |
| Enterprise | Ilimitado | Sob demanda |

## Ferramentas Relacionadas

- [Claude Code CLI](https://code.claude.com/docs/en/cli-reference) — Todos os comandos
- [Claude Code Settings](https://code.claude.com/docs/en/settings) — Configurações
- [Claude Code FAQ](https://code.claude.com/docs/en/faq) — Perguntas frequentes

## Comunidade

- [GitHub Issues](https://github.com/anthropics/claude-code/issues) — Reportar bugs e sugestões
- [Anthropic Discord](https://discord.gg/anthropic) — Comunidade de usuários

---

> *Última atualização: Junho de 2026*