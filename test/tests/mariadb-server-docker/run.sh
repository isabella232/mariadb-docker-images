#!/bin/bash
set -eo pipefail

image="$1"

export MYSQL_ROOT_PASSWORD='IamGr00t!'

# should return a pid of 1
get_mysqld_pid="ps waux|  grep mysqld| grep -v grep| awk '{print $2}'"

# simple test which should return nothing
mysql_check='mysql -u root -p$MYSQL_ROOT_PASSWORD mysql -e "select * from host;"'

testOutput="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "$get_mysqld_pid" 2>/dev/null)"
# test that mysqld is running
if ! $testOutput; then
	echo >&2 'Mysqld not running. $get_mysqld_pid returned $testOutput'
	exit
fi
[ "$testOutput" = "1" ]

# query test
output="$(docker run --rm -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" "$image" "$mysql_check")"
if ! output; then
	echo >&2 'Mysqld query error. $mysql_check returned $output'
	exit
fi
echo "Passed"
[ "$output" = "" ]
