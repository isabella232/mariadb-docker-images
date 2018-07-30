#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD='IamGr00t!'

# Should return a pid of 1
get_mysqld_pid="ps waux|  grep mysqld| grep -v grep| awk '{print $2}'"

# simple test which should return nothing
mysql_check="mysql -u root -p$MYSQL_ROOT_PASSWORD --execute 'use mysql; select * from host\G'"

# test that mysqld is running
if ! testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "$get_mysqld_pid" 2>/dev/null)"; then
	echo >&2 'Mysqld is not running'
	exit
fi
[ "$testOutput" = "1" ]

# Query test
output="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "$mysql_check")"
[ "$output" = "" ]
