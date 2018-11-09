#!/bin/bash
set -e

globalTests+=(
	utc
	cve-2014--shellshock
	no-hard-coded-passwords
	override-cmd
)

# for "explicit" images, only run tests that are explicitly specified for that image/variant
explicitTests+=(
	[:onbuild]=1
)
imageTests[:onbuild]+='
	override-cmd
'

testAlias+=(
  [mariadb/server]='mariadb-server-docker'
  [mariadb/columnstore]='mariadb-columnstore-docker'
  [mariadb/maxscale]='maxscale-docker'
)

imageTests+=(
	[mariadb-server-docker]='
		mariadb-server-docker
		mariadb-basics
		mariadb-initdb
		mariadb-log-bin
		mariadb-env-back-compat
	'
	[mariadb-columnstore-docker]='
		mariadb-server-docker
		mariadb-basics
		mariadb-initdb
		mariadb-columnstore-initdb
	'
	[maxscale-docker]='
		maxscale-basics
	'
)

globalExcludeTests+=(
)
