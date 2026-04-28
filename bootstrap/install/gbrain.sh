#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"

repo_root="$(repo_root_dir)"

GBRAIN_REPO_URL="${GBRAIN_REPO_URL:-git@github.com:aklmans/gbrain.git}"
GBRAIN_DIR="${GBRAIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/gbrain}"
GBRAIN_BIN_DIR="${GBRAIN_BIN_DIR:-$HOME/.local/bin}"
GBRAIN_CONFIG_DIR="${GBRAIN_CONFIG_DIR:-$HOME/.gbrain}"
GBRAIN_POSTGRES_CONTAINER="${GBRAIN_POSTGRES_CONTAINER:-gbrain-postgres}"
GBRAIN_POSTGRES_IMAGE="${GBRAIN_POSTGRES_IMAGE:-pgvector/pgvector:pg17}"
GBRAIN_POSTGRES_PORT="${GBRAIN_POSTGRES_PORT:-5436}"
GBRAIN_POSTGRES_USER="${GBRAIN_POSTGRES_USER:-postgres}"
GBRAIN_POSTGRES_PASSWORD="${GBRAIN_POSTGRES_PASSWORD:-postgres}"
GBRAIN_POSTGRES_DB="${GBRAIN_POSTGRES_DB:-gbrain}"
GBRAIN_DATABASE_URL="${GBRAIN_DATABASE_URL:-postgresql://${GBRAIN_POSTGRES_USER}:${GBRAIN_POSTGRES_PASSWORD}@localhost:${GBRAIN_POSTGRES_PORT}/${GBRAIN_POSTGRES_DB}}"

run_bun_install=1
run_postgres=1
run_migrations=1
run_bun_link=0
configure_codex=0

usage() {
  cat <<'EOF'
Usage: ./bootstrap/install/gbrain.sh [options]

Installs the local GBrain workflow without storing secrets in this repository.

Options:
  --skip-bun-install     Do not run `bun install` in the GBrain repo.
  --skip-postgres        Do not create/start the Docker Postgres + pgvector container.
  --skip-migrations      Do not run `gbrain apply-migrations`.
  --bun-link             Also run `bun link` inside the GBrain repo.
  --configure-codex      Register the GBrain MCP server with `codex mcp add`.
  -h, --help             Show this help.

Environment overrides:
  GBRAIN_REPO_URL
  GBRAIN_DIR
  GBRAIN_BIN_DIR
  GBRAIN_CONFIG_DIR
  GBRAIN_DATABASE_URL
  GBRAIN_POSTGRES_CONTAINER
  GBRAIN_POSTGRES_IMAGE
  GBRAIN_POSTGRES_PORT
  GBRAIN_POSTGRES_USER
  GBRAIN_POSTGRES_PASSWORD
  GBRAIN_POSTGRES_DB
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --skip-bun-install)
      run_bun_install=0
      ;;
    --skip-postgres)
      run_postgres=0
      ;;
    --skip-migrations)
      run_migrations=0
      ;;
    --bun-link)
      run_bun_link=1
      ;;
    --configure-codex)
      configure_codex=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
}

ensure_gbrain_repo() {
  mkdir -p "$(dirname "$GBRAIN_DIR")"

  if [[ -d "$GBRAIN_DIR/.git" ]]; then
    printf 'Using existing GBrain repo: %s\n' "$GBRAIN_DIR"
    return 0
  fi

  if [[ -e "$GBRAIN_DIR" ]]; then
    printf 'GBRAIN_DIR exists but is not a git repo: %s\n' "$GBRAIN_DIR" >&2
    exit 1
  fi

  git clone "$GBRAIN_REPO_URL" "$GBRAIN_DIR"
}

install_gbrain_dependencies() {
  if [[ "$run_bun_install" -eq 0 ]]; then
    return 0
  fi

  (cd "$GBRAIN_DIR" && bun install)

  if [[ "$run_bun_link" -eq 1 ]]; then
    (cd "$GBRAIN_DIR" && bun link)
  fi
}

write_executable() {
  local target="$1"
  local mode="${2:-755}"

  chmod "$mode" "$target"
}

install_wrappers() {
  mkdir -p "$GBRAIN_BIN_DIR"

cat >"$GBRAIN_BIN_DIR/gbrain" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

GBRAIN_DIR="${GBRAIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/gbrain}"
cd "$GBRAIN_DIR"
exec bun --bun "$GBRAIN_DIR/src/cli.ts" "$@"
EOF
  write_executable "$GBRAIN_BIN_DIR/gbrain"

cat >"$GBRAIN_BIN_DIR/gb" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

GBRAIN_BIN="${GBRAIN_BIN:-${GBRAIN_BIN_DIR:-$HOME/.local/bin}/gbrain}"
exec "${GBRAIN_BIN}" "$@"
EOF
  write_executable "$GBRAIN_BIN_DIR/gb"

cat >"$GBRAIN_BIN_DIR/gg" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

GBRAIN_BIN="${GBRAIN_BIN:-${GBRAIN_BIN_DIR:-$HOME/.local/bin}/gbrain}"
exec "${GBRAIN_BIN}" jobs submit subagent --follow "$@"
EOF
  write_executable "$GBRAIN_BIN_DIR/gg"
}

install_env_example() {
  local source_path="$repo_root/templates/gbrain/.env.local.example"

  require_repo_path "$source_path"

  if [[ ! -f "$GBRAIN_DIR/.env.local" ]]; then
    cat <<EOF

GBrain API config is not created yet.
Copy and edit this file with your private keys:

  cp "$source_path" "$GBRAIN_DIR/.env.local"
  \$EDITOR "$GBRAIN_DIR/.env.local"

EOF
  fi
}

container_exists() {
  docker ps -a --format '{{.Names}}' | grep -Fx "$GBRAIN_POSTGRES_CONTAINER" >/dev/null
}

container_running() {
  docker ps --format '{{.Names}}' | grep -Fx "$GBRAIN_POSTGRES_CONTAINER" >/dev/null
}

ensure_postgres() {
  if [[ "$run_postgres" -eq 0 ]]; then
    return 0
  fi

  require_command docker

  if ! docker info >/dev/null 2>&1; then
    printf 'Docker is not running. Start Docker, then rerun this script.\n' >&2
    exit 1
  fi

  if container_running; then
    printf 'Postgres container already running: %s\n' "$GBRAIN_POSTGRES_CONTAINER"
    return 0
  fi

  if container_exists; then
    docker start "$GBRAIN_POSTGRES_CONTAINER" >/dev/null
    docker update --restart unless-stopped "$GBRAIN_POSTGRES_CONTAINER" >/dev/null
    return 0
  fi

  docker run -d \
    --name "$GBRAIN_POSTGRES_CONTAINER" \
    --restart unless-stopped \
    -e POSTGRES_USER="$GBRAIN_POSTGRES_USER" \
    -e POSTGRES_PASSWORD="$GBRAIN_POSTGRES_PASSWORD" \
    -e POSTGRES_DB="$GBRAIN_POSTGRES_DB" \
    -p "$GBRAIN_POSTGRES_PORT:5432" \
    "$GBRAIN_POSTGRES_IMAGE" >/dev/null
}


wait_for_postgres() {
  if [[ "$run_postgres" -eq 0 ]]; then
    return 0
  fi

  local attempts=30
  local attempt
  for attempt in $(seq 1 "$attempts"); do
    if docker exec "$GBRAIN_POSTGRES_CONTAINER" pg_isready -U "$GBRAIN_POSTGRES_USER" -d "$GBRAIN_POSTGRES_DB" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  printf 'Postgres container did not become ready: %s\n' "$GBRAIN_POSTGRES_CONTAINER" >&2
  exit 1
}

write_gbrain_config() {
  mkdir -p "$GBRAIN_CONFIG_DIR"

  cat >"$GBRAIN_CONFIG_DIR/config.json" <<EOF
{
  "engine": "postgres",
  "database_url": "$GBRAIN_DATABASE_URL"
}
EOF
}

apply_migrations() {
  if [[ "$run_migrations" -eq 0 ]]; then
    return 0
  fi

  "$GBRAIN_BIN_DIR/gbrain" apply-migrations --yes --non-interactive
}

configure_codex_mcp() {
  if [[ "$configure_codex" -eq 0 ]]; then
    return 0
  fi

  require_command codex
  codex mcp add gbrain -- "$GBRAIN_BIN_DIR/gbrain" serve
}

print_next_steps() {
  cat <<EOF

GBrain bootstrap complete.

Repo:
  $GBRAIN_DIR

Commands:
  $GBRAIN_BIN_DIR/gbrain
  $GBRAIN_BIN_DIR/gb
  $GBRAIN_BIN_DIR/gg

Database:
  $GBRAIN_DATABASE_URL

Private API config:
  $GBRAIN_DIR/.env.local

Codex MCP example:
  $repo_root/templates/gbrain/codex-config.example.toml

Validate:
  gbrain doctor --json
  gb search "OpenAI o1"

Optional import:
  gbrain import "$HOME/Documents"
  gbrain embed --stale
EOF
}

require_command git
require_command bun

ensure_gbrain_repo
install_gbrain_dependencies
install_wrappers
install_env_example
ensure_postgres
wait_for_postgres
write_gbrain_config
apply_migrations
configure_codex_mcp
print_next_steps
