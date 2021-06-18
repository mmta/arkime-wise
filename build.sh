#!/bin/sh
app=arkime-wise
ver=$1

# couldnt find a better source for moloch version info beside this
source=https://raw.githubusercontent.com/arkime/arkime/master/release/makeDockerBuild.sh
[ -z "$ver" ] && ver=$(wget -q $source -O - | grep ' VER' | cut -d= -f2)

[ -z "$ver" ] && \
  echo cannot find version info from $source. please supply a version tag as 1st argument && exit 1
[ "$(echo $ver | wc -c)" -gt "10" ] && \
  echo "version tag length greater than 10 ($ver), aborting due to possible error" && exit 1

echo building $app version $ver ..

docker build -f Dockerfile -t $app:$ver -t $app:latest .
