#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD="IamGr00t!"

# check mysql version
if ! testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" --entrypoint mysql "$image" "--version" 2>/dev/null)"; then
	echo >&2 'Mysql not installed.'
	exit
fi
[ "$testOutput" = "Mysql is installed" ]

# pid check
output="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "cat" "/var/run/mysqld/mysqld.pid")"
[ "$output" = "Mysqld is running" ]
