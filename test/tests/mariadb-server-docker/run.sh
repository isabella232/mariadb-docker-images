#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD="r00t_passw0rd"

# verify mysql client is installed
if ! testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" --entrypoint mysql "$image" "--version" 2>/dev/null)"; then
	echo >&2 'Mysql not installed.'
	exit
fi
[ "$testOutput" = "Mysql is installed" ]
