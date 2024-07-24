#!/bin/bash

LOG_FILE="/var/log/devopsfetch.log"

log_event() {
    local message="$1"
    sudo echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
}

display_help() {
    echo "Usage: $0 [option...]"
    echo
    echo "Options:"
    echo "  -p, --port [port_number]       Display all active ports and services or detailed info about a specific port"
    echo "  -d, --docker [container_name]  List all Docker images and containers or detailed info about a specific container"
    echo "  -n, --nginx [domain]           Display all Nginx domains and their ports or detailed configuration info about a specific domain"
    echo "  -u, --users [username]         List all users and their last login times or detailed info about a specific user"
    echo "  -t, --time [start] [end]       Display activities within a specified time range or for a single date"
    echo "  -m, --monitor                  Enable continuous monitoring mode"
    echo "  -h, --help                     Display this help message"
    exit 1
}

list_ports() {
    netstat -tuln | format_output "Proto Local_Address Foreign_Address State PID/Program_name"
    log_event "Listed all active ports and services"
}

port_details() {
    local port=$1
    netstat -tulnp | grep ":$port" | format_output "Proto Local_Address Foreign_Address State PID/Program_name"
    log_event "Displayed details for port $port"
}

list_docker() {
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | format_output "CONTAINER_ID NAME IMAGE STATUS PORTS"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | format_output "REPOSITORY TAG IMAGE_ID CREATED SIZE"
    log_event "Listed all Docker images and containers"
}

docker_details() {
    local container_name=$1
    docker inspect $container_name | jq '.' | format_output
    log_event "Displayed details for Docker container $container_name"
}

list_nginx() {
    grep "server_name" /etc/nginx/sites-available/* -R | format_output "File Line"
    log_event "Listed all Nginx domains and their ports"
}

nginx_details() {
    local domain=$1
    grep "server_name $domain" /etc/nginx/sites-available/* -R -A 20 | format_output "File Line"
    log_event "Displayed details for Nginx domain $domain"
}

list_users() {
    lastlog | format_output "Username Port From Latest"
    log_event "Listed all users and their last login times"
}

user_details() {
    local username=$1
    lastlog | grep $username | format_output "Username Port From Latest"
    log_event "Displayed details for user $username"
}

time_range() {
    local start=$1
    local end=$2

    if [ -z "$end" ]; then
        journalctl --since="$start 00:00:00" --until="$start 23:59:59" | format_output "Time Source Message"
    else
        journalctl --since="$start" --until="$end" | format_output "Time Source Message"
    fi
}

format_output() {
    local columns="$1"
    awk -v cols="$columns" '
    BEGIN {
        split(cols, colArray, " ");
        for (i in colArray) {
            printf "%-20s", colArray[i]
        }
        print ""
        for (i in colArray) {
            for (j=1; j<=20; j++) {
                printf "-"
            }
            printf " "
        }
        print ""
    }
    {
        for (i=1; i<=NF; i++) {
            printf "%-20s", $i
        }
        print ""
    }'
}

monitor_system() {
    while true; do
        list_ports
        list_docker
        list_nginx
        list_users
        sleep 60 # Monitor every 60 seconds
    done
}

main() {
    if [ $# -eq 0 ]; then
        display_help
    fi

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -p|--port)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                port_details $2
                shift
            else
                list_ports
            fi
            shift
            ;;
            -d|--docker)
            if [ -n "$2" ]; then
                docker_details $2
                shift
            else
                list_docker
            fi
            shift
            ;;
            -n|--nginx)
            if [ -n "$2" ]; then
                nginx_details $2
                shift
            else
                list_nginx
            fi
            shift
            ;;
            -u|--users)
            if [ -n "$2" ]; then
                user_details $2
                shift
            else
                list_users
            fi
            shift
            ;;
            -t|--time)
            if [ -n "$2" ]; then
                if [ -n "$3" ]; then
                    time_range $2 $3
                    shift 2
                else
                    time_range $2
                    shift 1
                fi
            else
                echo "Invalid time range"
                exit 1
            fi
            shift
            ;;
            -m|--monitor)
            monitor_system
            ;;
            -h|--help)
            display_help
            ;;
            *)
            echo "Unknown option: $key"
            display_help
            ;;
        esac
    done
}

main "$@"
