#!/bin/bash
# restart.sh - Restart Fluent Bit container to load updated configuration

echo "Restarting Fluent Bit container..."
docker-compose restart fluentbit
echo "Fluent Bit container restarted. New configuration loaded."