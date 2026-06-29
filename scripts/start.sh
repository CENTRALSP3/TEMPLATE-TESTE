#!/usr/bin/env bash
#
# start.sh — Inicia o servidor Remote Control do Claude Code
#
# Uso:
#   ./start.sh                     # Inicia com nome padrão
#   ./start.sh "Meu Servidor"      # Inicia com nome personalizado
#   SESSION_NAME="Projeto X" ./start.sh  # Ou via variável de ambiente
#
# Comportamento:
#   - Inicia claude remote-control em modo servidor
#   - Cria diretório de logs se não existir
#   - Salva PID para stop.sh e status.sh
#   - Reconexão automática em caso de falha (opcional)

set -euo pipefail

# ─── Configurações ───────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Nome da sessão (sobrescreva com SESSION_NAME ou argumento)
SESSION_NAME="${SESSION_NAME:-Claude Remote}"
if [ $# -ge 1 ]; then
    SESSION_NAME="$1"
fi

# Diretório para logs
LOG_DIR="${LOG_DIR:-$HOME/.claude/remote-control-logs}"
PID_FILE="$LOG_DIR/remote-control.pid"
LOG_FILE="$LOG_DIR/remote-control.log"

# Flags extras (ex: --sandbox --verbose)
EXTRA_FLAGS="${EXTRA_FLAGS:-}"

# Número máximo de tentativas de reinicialização (0 = infinito)
MAX_RETRIES="${MAX_RETRIES:-0}"
RETRY_DELAY="${RETRY_DELAY:-5}"  # segundos

# ─── Funções ──────────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

cleanup() {
    log "Encerrando servidor Remote Control..."
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE"
    fi
    exit 0
}

# ─── Verificações ─────────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
    log "ERRO: Comando 'claude' não encontrado. Instale o Claude Code primeiro."
    exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "0.0.0")
log "Claude Code versão: $CLAUDE_VERSION"

# ─── Setup ────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR"

# Trap para parada graceful
trap cleanup SIGTERM SIGINT SIGHUP

# ─── Inicialização ────────────────────────────────────────────────
log "Iniciando Remote Control: $SESSION_NAME"
log "Logs: $LOG_FILE"
log "PID: $$"

# Salva PID atual para outros scripts
echo "$$" > "$PID_FILE"

RETRY_COUNT=0
while true; do
    log "Executando: claude remote-control --name \"$SESSION_NAME\" $EXTRA_FLAGS"
    claude remote-control --name "$SESSION_NAME" $EXTRA_FLAGS 2>&1 | tee -a "$LOG_FILE"
    EXIT_CODE=$?

    log "Processo encerrado com código $EXIT_CODE"

    # Se não for pra reiniciar, sai
    if [ "$MAX_RETRIES" -eq 0 ]; then
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ "$MAX_RETRIES" -gt 0 ] && [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
        log "Número máximo de tentativas ($MAX_RETRIES) atingido. Encerrando."
        break
    fi

    log "Reiniciando em $RETRY_DELAY segundos... (tentativa $RETRY_COUNT)"
    sleep "$RETRY_DELAY"
done

cleanup