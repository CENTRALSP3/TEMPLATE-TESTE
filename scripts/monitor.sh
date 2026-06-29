#!/usr/bin/env bash
#
# monitor.sh — Monitora o servidor Remote Control e notifica se cair
#
# Uso:
#   ./monitor.sh                          # Modo monitoramento único
#   ./monitor.sh --daemon                 # Modo daemon (loop infinito)
#   ./monitor.sh --daemon --interval 30   # Verifica a cada 30s (padrão: 60s)
#   ./monitor.sh --restart                # Reinicia automaticamente se cair
#
# Dependências (opcionais):
#   - notify-send (Linux com libnotify) — notificação desktop
#   - curl / wget — webhook (Slack, Discord, etc.)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SESSION_NAME="${SESSION_NAME:-Claude Remote}"
LOG_DIR="${LOG_DIR:-$HOME/.claude/remote-control-logs}"
MONITOR_LOG="$LOG_DIR/monitor.log"

INTERVAL=60
DAEMON=false
AUTO_RESTART=false

# Webhook para notificação externa (opcional)
WEBHOOK_URL="${WEBHOOK_URL:-}"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$MONITOR_LOG"
}

notify_desktop() {
    if command -v notify-send &>/dev/null; then
        notify-send "Claude Remote Control" "$1" -i dialog-warning
    fi
}

notify_webhook() {
    if [ -n "$WEBHOOK_URL" ]; then
        if command -v curl &>/dev/null; then
            curl -s -H "Content-Type: application/json" \
                -d "{\"text\": \"⚠ Claude Remote Control: $1\"}" \
                "$WEBHOOK_URL" &>/dev/null || true
        fi
    fi
}

check_and_notify() {
    if "$SCRIPT_DIR/status.sh" --quiet; then
        return 0
    else
        log "⚠ Servidor REMOTE CONTROL CAIU!"
        notify_desktop "O servidor Remote Control caiu!"
        notify_webhook "Servidor Remote Control caiu em $(hostname)"

        if [ "$AUTO_RESTART" = true ]; then
            log "→ Reiniciando automaticamente..."
            "$SCRIPT_DIR/start.sh" "$SESSION_NAME"
        fi

        return 1
    fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --daemon) DAEMON=true ;;
            --restart) AUTO_RESTART=true ;;
            --interval)
                shift
                INTERVAL="$1"
                ;;
            --webhook)
                shift
                WEBHOOK_URL="$1"
                ;;
            *)
                SESSION_NAME="$1"
                ;;
        esac
        shift
    done
}

parse_args "$@"

log "Monitor iniciado — sessão: $SESSION_NAME"
log "Auto-restart: $AUTO_RESTART"
[ -n "$WEBHOOK_URL" ] && log "Webhook configurado"

if [ "$DAEMON" = true ]; then
    log "Modo daemon — verificando a cada ${INTERVAL}s"
    while true; do
        check_and_notify
        sleep "$INTERVAL"
    done
else
    check_and_notify
fi