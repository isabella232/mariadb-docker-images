#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD='IamGr00t!'

# simple test which should return nothing
export mysql_check='mysql -u root -p$MYSQL_ROOT_PASSWORD mysql -e "select * from host;"'
echo $mysql_check

# test that mysql client is installed
if ! testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" --entrypoint mysql "$image" "--version" 2>/dev/null)"; then
	echo >&2 'Mysqld not running.'
	exit
fi
[ "$testOutput" = "Mysqld is running" ]

# query test
output="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "$mysql_check")"
[ "$output" = "Mysql query successful" ]
