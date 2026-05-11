# Default: list all recipes
default:
    @just --list

# Run docker-compose command for each compose file
compose-all cmd:
    #!/usr/bin/env bash
    for f in compose/*.yaml; do
        docker-compose -p media-server -f $f {{ cmd }}
    done

# Stop all services
stop:
    just compose-all "down --remove-orphans"

# Start all services
start:
    just compose-all "up -d"

# Restart all services
restart: stop start

# Pull latest images + restart + remove dangling images
update:
    #!/usr/bin/env bash
    set -e
    for f in compose/*.yaml; do
        docker-compose -p media-server -f $f pull
    done
    just compose-all "up -d"
    docker image prune -f

# Tail logs for a service
logs service:
    docker-compose -p media-server -f compose/{{ service }}.yaml logs -f

# Show status of all services
status:
    #!/usr/bin/env bash
    for f in compose/*.yaml; do
        echo "=== $(basename $f) ==="
        docker-compose -p media-server -f $f ps
        echo ""
    done

# Clean up dangling images
clean:
    docker image prune -f