#!/usr/bin/env bash
#
# stop.sh — Para o servidor Remote Control do Claude Code
#
# Uso:
#   ./stop.sh                    # Para gracefulmente
#   ./stop.sh --force            # Mata o processo (SIGKILL)
#   PID_FILE=/tmp/rc.pid ./stop.sh  # PID alternativo
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

LOG_DIR="${LOG_DIR:-$HOME/.claude/remote-control-logs}"
PID_FILE="${PID_FILE:-$LOG_DIR/remote-control.pid}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f "$PID_FILE" ]; then
    echo -e "${YELLOW}Nenhum PID encontrado em $PID_FILE${NC}"
    echo "Tentando encontrar processo claude remote-control..."
    PID=$(pgrep -f "claude remote-control" 2>/dev/null | head -1)
    if [ -z "$PID" ]; then
        echo -e "${RED}Nenhum processo 'claude remote-control' encontrado.${NC}"
        exit 1
    fi
    echo -e "${YELLOW}PID $PID encontrado via pgrep${NC}"
else
    PID=$(cat "$PID_FILE")
    echo "PID encontrado: $PID"
fi

# Verifica se o processo existe
if ! kill -0 "$PID" 2>/dev/null; then
    echo -e "${RED}Processo $PID não está mais rodando.${NC}"
    rm -f "$PID_FILE"
    exit 0
fi

echo -e "${GREEN}Enviando SIGTERM para PID $PID...${NC}"
kill "$PID" 2>/dev/null || true

# Aguarda até 10 segundos para parada graceful
for i in $(seq 1 10); do
    if ! kill -0 "$PID" 2>/dev/null; then
        echo -e "${GREEN}Processo $PID encerrado.${NC}"
        rm -f "$PID_FILE"
        exit 0
    fi
    sleep 1
done

# Se --force, mata com SIGKILL
if [ "${1:-}" = "--force" ]; then
    echo -e "${YELLOW}Processo não respondeu ao SIGTERM. Enviando SIGKILL...${NC}"
    kill -9 "$PID" 2>/dev/null || true
    rm -f "$PID_FILE"
    echo -e "${GREEN}Processo $PID morto (SIGKILL).${NC}"
else
    echo -e "${YELLOW}Processo $PID não encerrou após 10s. Use --force para SIGKILL.${NC}"
fi