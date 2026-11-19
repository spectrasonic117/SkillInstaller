#!/usr/bin/env bash
#
# install.sh — instala el CLI skill-installer en ~/bin
#
# Uso: ./install.sh [--dir <ruta>] [--deps] [--force]
#
set -euo pipefail

SCRIPT_NAME="skill-installer"
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$REPO_DIR/$SCRIPT_NAME"
INSTALL_DIR="${INSTALL_DIR:-$HOME/bin}"
INSTALL_DEPS=0
FORCE=0

# ---------------------------------------------------------------------------
# Salida con color (solo si stdout es una terminal)
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
    BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
    YELLOW=$'\033[33m'; CYAN=$'\033[36m'; RESET=$'\033[0m'
else
    BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; RESET=""
fi

info() { printf '%s\n' "${CYAN}::${RESET} $*"; }
ok()   { printf '%s\n' "${GREEN}✔${RESET} $*"; }
warn() { printf '%s\n' "${YELLOW}⚠${RESET} $*" >&2; }
die()  { printf '%s\n' "${RED}✘${RESET} $*" >&2; exit 1; }

usage() {
    cat <<EOF
${BOLD}skill-installer — instalador${RESET}

Uso: ./install.sh [opciones]

Opciones:
  -d, --dir <ruta>   Directorio de instalación (por defecto: \$HOME/bin)
      --deps         Instalar dependencias de Python (rich, questionary) con pip
  -f, --force        Continuar aunque no se detecte python3
  -h, --help         Mostrar esta ayuda

Variables de entorno:
  INSTALL_DIR        Equivale a --dir
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            [[ $# -ge 2 ]] || die "Falta la ruta para $1"
            INSTALL_DIR="$2"
            shift 2
            ;;
        --deps)    INSTALL_DEPS=1; shift ;;
        -f|--force) FORCE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *)         die "Opción desconocida: $1 (usa --help)" ;;
    esac
done

# ---------------------------------------------------------------------------
# Comprobaciones previas
# ---------------------------------------------------------------------------
[[ -f "$SOURCE_FILE" ]] || die "No se encontró '$SCRIPT_NAME' junto a este instalador ($REPO_DIR)."
[[ -r "$SOURCE_FILE" ]] || die "Sin permiso de lectura sobre '$SOURCE_FILE'."

# El "binario" es en realidad un script Python: sin python3 no puede ejecutarse.
if command -v python3 >/dev/null 2>&1; then
    PY_VERSION="$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
    ok "python3 detectado ($PY_VERSION)"
else
    if [[ "$FORCE" -eq 0 ]]; then
        die "python3 no está instalado. Instálalo (p. ej. 'brew install python') o usa --force."
    fi
    warn "python3 no encontrado: se instalará el script, pero no podrá ejecutarse."
fi

# ---------------------------------------------------------------------------
# Instalación
# ---------------------------------------------------------------------------
mkdir -p "$INSTALL_DIR"
DEST_FILE="$INSTALL_DIR/$SCRIPT_NAME"

if [[ -e "$DEST_FILE" ]] && ! cmp -s "$SOURCE_FILE" "$DEST_FILE"; then
    BACKUP="$DEST_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp -p "$DEST_FILE" "$BACKUP"
    warn "Versión anterior respaldada en $BACKUP"
fi

install -m 0755 "$SOURCE_FILE" "$DEST_FILE"
ok "Instalado en ${BOLD}$DEST_FILE${RESET}"

# ---------------------------------------------------------------------------
# Dependencias de Python
# ---------------------------------------------------------------------------
DEPS_OK=0
if command -v python3 >/dev/null 2>&1; then
    if python3 -c 'import rich, questionary' >/dev/null 2>&1; then
        ok "Dependencias presentes (rich, questionary)"
        DEPS_OK=1
    else
        warn "Faltan dependencias de Python: rich y/o questionary."
        if [[ "$INSTALL_DEPS" -eq 1 ]]; then
            info "Instalando dependencias con pip…"
            if python3 -m pip install --user rich questionary; then
                ok "Dependencias instaladas"
                DEPS_OK=1
            else
                warn "pip falló. Instálalas manualmente: python3 -m pip install --user rich questionary"
            fi
        else
            printf '   Instálalas con:\n     %spython3 -m pip install --user rich questionary%s\n' "$BOLD" "$RESET"
            printf '   o reejecuta este instalador con %s--deps%s.\n' "$BOLD" "$RESET"
        fi
    fi
fi

# ---------------------------------------------------------------------------
# PATH
# ---------------------------------------------------------------------------
case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        ok "$INSTALL_DIR ya está en tu PATH"
        ;;
    *)
        warn "$INSTALL_DIR no está en tu PATH."
        case "$(basename "${SHELL:-zsh}")" in
            zsh)  RC_FILE="$HOME/.zshrc" ;;
            bash) RC_FILE="$HOME/.bashrc" ;;
            *)    RC_FILE="tu archivo de configuración del shell" ;;
        esac
        printf '   Añade esta línea a %s:\n     %sexport PATH="%s:$PATH"%s\n' \
            "$RC_FILE" "$BOLD" "$INSTALL_DIR" "$RESET"
        printf '   Luego recarga el shell: %ssource %s%s\n' "$BOLD" "$RC_FILE" "$RESET"
        ;;
esac

# ---------------------------------------------------------------------------
# Verificación final
# ---------------------------------------------------------------------------
if [[ "$DEPS_OK" -eq 1 ]]; then
    if "$DEST_FILE" --help >/dev/null 2>&1; then
        ok "Verificación correcta: 'skill-installer --help' funciona"
    else
        warn "El script se instaló, pero 'skill-installer --help' falló. Ejecútalo manualmente para ver el error."
    fi
fi

printf '\n%s⚡ Instalación completa.%s Ejecuta %sskill-installer%s dentro de un proyecto.\n' \
    "$GREEN" "$RESET" "$BOLD" "$RESET"
