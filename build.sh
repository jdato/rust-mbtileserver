#!/bin/bash
# Build script for mbtile server

if [ -z "$SCRIPT" ]
then 
    /usr/bin/script mbtile_server_build.log /bin/bash -c "$0 $*"
    exit 0
fi

# Remove unused / stopped container and dangling untagged images
docker rm $(docker ps -a -q) &>> mbtile_server_build.log
if [ $? -ne 0 ]; then
    echo 'No dangling containers found.'
fi
docker rmi $(docker images | grep '^<none>' | awk '{print $3}') &>> mbtile_server_build.log
if [ $? -ne 0 ]; then
    echo 'No dangling images found.'
fi

# Build germany mbtiles file
./~/openmaptiles/quickstart.sh berlin # europe/germany
if [ $? -ne 0 ]
then
    echo 'ERROR: openmaptiles quickstart script exited with error.'
    exit 1
fi

# Copy mbtiles file to mbtile server, build and deploy it
cp ~/openmaptiles/data/tiles.mbtiles ~/rust-mbtileserver/germany.mbtiles
if [ $? -ne 0 ]
then
    echo 'Error occurred copying file.'
    exit 1
fi
docker build -t dr-flex/mbtile-server ~/rust-mbtileserver
if [ $? -ne 0 ]; then
    echo 'ERROR: Docker build of mbtile server failed.'
    exit 1
fi

./~/rust-mbtileserver/deploy.sh
if [ $? -ne 0 ]; then
    echo 'ERROR: Deployment of mbtile server unsuccessful.'
    exit 1
fi

exit 0