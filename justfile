# Default: list all recipes
default:
    @just --list

# Stop all services
stop:
    #!/usr/bin/env bash
    docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) down --remove-orphans

# Start all services
start:
    #!/usr/bin/env bash
    docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) up -d

# Restart all services
restart: stop start

# Pull latest images + restart + remove dangling images
update:
    #!/usr/bin/env bash
    set -e
    for f in compose/*.yaml; do
        docker-compose -p media-server -f "$f" pull
    done
    just start
    docker image prune -f

# Tail logs for a service
logs service:
    docker-compose -p media-server -f compose/{{ service }}.yaml logs -f

# Show status of all services
status:
    #!/usr/bin/env bash
    docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) ps

# Clean up dangling images
clean:
    docker image prune -f