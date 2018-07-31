#!/bin/bash
set -eo pipefail

export MYSQL_DATABASE='mysql'
export MYSQL_USER='root'
export MYSQL_ROOT_PASSWORD="IamGr00t!"


dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

cname="mariadb-server-$RANDOM-$RANDOM"
cid="$(
	docker run -d \
		-e MYSQL_ROOT_PASSWORD \
		--name "$cname" \
		"$image"
)"
trap "docker rm -vf $cid > /dev/null" EXIT

mysql() {
	docker run --rm -i \
		--link "$cname":mysql \
		--entrypoint mysql \
		-e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
		"$image" \
		-hmysql \
		-u"$MYSQL_USER" \
		--silent \
		"$@" \
		"$MYSQL_DATABASE"
}

. "$dir/../../retry.sh" --tries 20 "echo 'SELECT * from host' | mysql"

# yay, must be OK
