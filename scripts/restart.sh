#!/usr/bin/env bash
#
# restart.sh — Reinicia o servidor Remote Control do Claude Code
#
# Uso:
#   ./restart.sh                   # Reinício simples
#   ./restart.sh "Novo Nome"       # Reinicia com nome diferente
#   ./restart.sh --sandbox         # Reinicia com sandbox
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

SESSION_NAME="${1:-Claude Remote}"
EXTRA_FLAGS="${EXTRA_FLAGS:-}"

echo "═══════════════════════════════════════════════"
echo "  Claude Code Remote Control — Restart"
echo "═══════════════════════════════════════════════"

# Para o servidor
echo "  → Parando servidor..."
if "$SCRIPT_DIR/stop.sh" 2>/dev/null; then
    echo "  ✓ Servidor parado"
else
    echo "  ⚠ Nenhum servidor rodando (seguindo mesmo assim)"
fi

# Pequena pausa
sleep 2

# Inicia novamente
echo "  → Iniciando servidor: $SESSION_NAME"
echo ""
SESSION_NAME="$SESSION_NAME" EXTRA_FLAGS="$EXTRA_FLAGS" exec "$SCRIPT_DIR/start.sh" "$SESSION_NAME"