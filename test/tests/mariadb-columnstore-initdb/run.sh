#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

serverImage="$("$dir/../image-name.sh" librarytest/mariadb-columnstore-initdb "$image")"
"$dir/../docker-build.sh" "$dir" "$serverImage" <<EOD
FROM $image
COPY dir/initdb.sql /docker-entrypoint-initdb.d/
EOD

export MARIADB_ROOT_PASSWORD='this is an example test password'
export MARIADB_USER='0123456789012345' # "ERROR: 1470  String 'my cool mysql user' is too long for user name (should be no longer than 16)"
export MARIADB_PASSWORD='my cool mariadb password'
export MARIADB_DATABASE='my cool mariadb database'

cname="mariadb-container-$RANDOM-$RANDOM"
cid="$(
	docker run -d \
		-e MARIADB_ROOT_PASSWORD \
		-e MARIADB_USER \
		-e MARIADB_PASSWORD \
		-e MARIADB_DATABASE \
		--name "$cname" \
		"$serverImage"
)"
trap "docker rm -vf $cid > /dev/null" EXIT

mysql() {
	docker run --rm -i \
		--link "$cname":mysql \
		--entrypoint mysql \
		-e MYSQL_PWD="$MARIADB_PASSWORD" \
		"$image" \
		-hmysql \
		-u"$MARIADB_USER" \
		--silent \
		"$@" \
		"$MARIADB_DATABASE"
}

# if this is columnstore then mysqld will start before cs is fully active so wait
case "$image" in
	*columnstore*) docker exec -i $cname /usr/sbin/wait_for_columnstore_active -v -p"$MARIADB_ROOT_PASSWORD";;
esac

. "$dir/../../retry.sh" --tries 20 "echo 'SELECT 1' | mysql"

# check initdb scripts ran
[ "$(echo 'SELECT COUNT(*) FROM test' | mysql)" = 1 ]
[ "$(echo 'SELECT c FROM test' | mysql)" = 'goodbye!' ]

# check columnstore is logging
[ "$(docker exec -i $cname wc -l /var/log/mariadb/columnstore/info.log | cut -d ' ' -f 1)" -gt 0 ]
