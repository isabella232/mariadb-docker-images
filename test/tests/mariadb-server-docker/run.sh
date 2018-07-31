#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

export MYSQL_ROOT_PASSWORD='TestPassw0rd!'
export MYSQL_USER='MarDeebs' # "ERROR: 1470  String 'my cool mysql user' is too long for user name (should be no longer than 16)"
export MYSQL_PASSWORD='MarDeebsPa$$'
export MYSQL_DATABASE='MarDeeBee'

cname="mysql-container-$RANDOM-$RANDOM"
cid="$(
	docker run -d \
		-e MYSQL_ROOT_PASSWORD \
		-e MYSQL_USER \
		-e MYSQL_PASSWORD \
		-e MYSQL_DATABASE \
		--name "$cname" \
		"$image"
)"
trap "docker rm -vf $cid > /dev/null" EXIT

mysql() {
	docker run --rm -i \
		--link "$cname":mysql \
		--entrypoint mysql \
		-e MYSQL_PWD="$MYSQL_PASSWORD" \
		"$image" \
		-hmysql \
		-u"$MYSQL_USER" \
		--silent \
		"$@" \
		"$MYSQL_DATABASE"
}

. "$dir/../../retry.sh" --tries 20 "echo 'SELECT 1' | mysql"

# yay, must be OK
