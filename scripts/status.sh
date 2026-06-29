#!/usr/bin/env bash
#
# status.sh — Verifica o status do servidor Remote Control do Claude Code
#
# Uso:
#   ./status.sh                    # Status completo
#   ./status.sh --quiet            # Apenas código de saída (0=rodando, 1=parado)
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

# Modo quiet: só código de saída
if [ "${1:-}" = "--quiet" ]; then
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            exit 0
        fi
    fi
    exit 1
fi

echo "═══════════════════════════════════════════════"
echo "  Claude Code Remote Control — Status"
echo "═══════════════════════════════════════════════"

# Verifica PID file
if [ ! -f "$PID_FILE" ]; then
    echo -e "  ${YELLOW}PID file não encontrado${NC}"
    echo "  Caminho esperado: $PID_FILE"
else
    PID=$(cat "$PID_FILE")
    echo "  PID file: $PID_FILE"
    echo "  PID: $PID"
fi

# Verifica se o processo está rodando
if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    echo -e "  Status: ${GREEN}RODANDO${NC}"
    echo ""
    echo "  Detalhes do processo:"
    ps -p "$PID" -o pid,ppid,user,start,etime,comm 2>/dev/null || echo "  (ps não disponível)"
    echo ""
    echo "  Conexões de rede (HTTPS):"
    lsof -p "$PID" -i 2>/dev/null | grep -i https | head -5 || ss -p 2>/dev/null | grep "$PID" | head -5 || echo "  (lsof/ss não disponível)"
else
    if [ -f "$PID_FILE" ]; then
        echo -e "  Status: ${RED}PARADO${NC} (PID $PID não encontrado)"
        echo "  (PID file stale — remova com: rm -f $PID_FILE)"
    else
        echo -e "  Status: ${RED}PARADO${NC}"
    fi
fi

echo "═══════════════════════════════════════════════"

# Log file info
LOG_FILE="$LOG_DIR/remote-control.log"
if [ -f "$LOG_FILE" ]; then
    echo ""
    echo "  Últimas 5 linhas do log:"
    tail -5 "$LOG_FILE" | sed 's/^/  /'
    echo ""
    echo "  Log completo: $LOG_FILE"
fi