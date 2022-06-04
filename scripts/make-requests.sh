#!/bin/bash

URL=${1:-localhost:8000}
HEADER=${2:-name:value}

while true;
do
    response=$(curl -s -H "$HEADER" -w "%{http_code}" $URL)
    http_code=$(tail -n1 <<< "$response")
    content=$(sed '$ d' <<< "$response")
    if [[ $http_code == *"500"* ]]; then
        echo "\033[0;31m$content"
    else
        if [[ "$content" == *"1.0.0"* ]] || [[ "$content" = *"0.1.0"* ]] ; then
            echo "$content"
        else
            echo "$content" | lolcat
        fi
    fi
    sleep 1; echo
done
