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

. "$dir/../../retry.sh" --tries 20 "docker exec -it $cname maxctrl show maxscale"

docker exec -it $cname maxctrl list commands |  grep "qc_sqlite"
[ $? = 0 ]
docker exec -it $cname maxctrl list users |  grep "admin"
[ $? = 0 ]
