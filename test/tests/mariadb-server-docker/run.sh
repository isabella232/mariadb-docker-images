#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD="IamGr00t!"

# test that mysql is running
if ! testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" --entrypoint cat "$image" "/var/run/mysqld/mysqld.pid" 2>/dev/null)"; then
	echo >&2 'Mysqld not running.'
	exit
fi
[ "$testOutput" = "Mysqld is running" ]

# query test
output="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "mysql" "--version")"
[ "$output" = "Mysql query successful" ]
