# Default: list all recipes
default:
    @just --list

# Stop all services, or only those in a group
stop group="":
    #!/usr/bin/env bash
    if [ -z "{{group}}" ]; then
        docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) down --remove-orphans
    else
        ids=$(docker ps -q --filter "label=group={{group}}")
        if [ -z "$ids" ]; then
            echo "no running containers in group '{{group}}'"
            exit 0
        fi
        docker stop $ids
    fi

# Start all services
start:
    #!/usr/bin/env bash
    docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) up -d

# Restart all services, or only those in a group
restart group="":
    #!/usr/bin/env bash
    if [ -z "{{group}}" ]; then
        docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) restart
    else
        ids=$(docker ps -q --filter "label=group={{group}}")
        if [ -z "$ids" ]; then
            echo "no running containers in group '{{group}}'"
            exit 0
        fi
        docker restart $ids
    fi

# Pull latest images + restart + remove dangling images
update:
    #!/usr/bin/env bash
    set -e
    for f in compose/*.yaml; do
        docker-compose -p media-server -f "$f" pull
    done
    just start
    docker image prune -f

# Tail logs: a single service name (e.g. `just logs cyberchef`) or a group (e.g. `just logs monitor`)
logs target="":
    #!/usr/bin/env bash
    if [ -z "{{target}}" ]; then
        echo "usage: just logs <service-name|group>"
        exit 1
    fi
    if [ -f "compose/{{target}}.yaml" ]; then
        docker-compose -p media-server -f compose/{{target}}.yaml logs -f
    else
        ids=$(docker ps -q --filter "label=group={{target}}")
        if [ -z "$ids" ]; then
            echo "no running containers in group '{{target}}'"
            exit 0
        fi
        docker logs -f $ids
    fi

# Show status of all services, or only those in a group
status group="":
    #!/usr/bin/env bash
    if [ -z "{{group}}" ]; then
        docker-compose -p media-server $(printf -- '-f %s ' compose/*.yaml) ps
    else
        ids=$(docker ps -q --filter "label=group={{group}}")
        if [ -z "$ids" ]; then
            echo "no running containers in group '{{group}}'"
            exit 0
        fi
        docker ps --filter "label=group={{group}}"
    fi

# Clean up dangling images
clean:
    docker image prune -f
