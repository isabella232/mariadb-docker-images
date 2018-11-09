#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

cname="maxscale-container-$RANDOM-$RANDOM"
cid="$(
	docker run -d \
		--name "$cname" \
		"$image"
)"
trap "docker rm -vf $cid > /dev/null" EXIT

. "$dir/../../retry.sh" --tries 20 "docker exec -it $cname maxadmin show services"

docker exec -it $cname maxadmin show services |  grep "State:[[:space:]]*Started"
[ $? = 0 ]
docker exec -it $cname maxadmin show sessions |  grep "State:[[:space:]]*Session ready for routing"
[ $? = 0 ]
