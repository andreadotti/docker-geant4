#!/bin/bash

if [ $# -lt 2 ];then 
   echo "Usage: "$0 geant4-data-dir app-source-dir [dockerimage] [DOCKERENVVAR=VAL] 
   echo "   geant4-data-dir: location on host of Geant4 DB filles"
   echo "   apps-source-dir: location of source of application"
   echo "   dockerimage: Geant4 DEVELOPMENT image (def: andreadotti/geant4-dev)"
   echo "   DOCKERENVVAR=VAL: one or more env variables to pass to docker"
   echo "             for building of binaries. "
   echo "             APPTARNAME=OutputTarballName.tgz (def: Application.tgz)"
   echo "             APPINSDIR=/docker/location/for/installation"
   echo "                  (def: /usr/local/geant4/applications)"         
   exit 1
fi
g4data=$1
g4src=$2
shift 2
img="andreadotti/geant4-dev"
if [ $# -ge 1 ];then 
      	img=$1
  shift 1
fi

xopts=""
for val in "$@";do
   xopts="${xopts} -e ${val}"
done

#If additional parameters have to be passed to cmake to 
#compile the application, you should add them at the end of this
#line, e.g. docker [...] /build/buildme.sh -DSOMEPAR=ON [...]

docker run --rm ${xopts} \
       -v "${g4src}:/App-src:ro" \
       -v "${g4data}:/usr/local/geant4/data" -v "$PWD:/build" \
       -w "/tmp" $img /build/buildme.sh 
