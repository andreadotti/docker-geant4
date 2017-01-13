#!/bin/bash
if [ $# -ne 2 ];then 
   echo "Usage: "$0 geant4sourcedir geant4datadir
   exit 1
fi
g4src=$1
g4data=$2

docker run --rm -v "${g4src}:/geant4-src:ro" -v "${g4data}:/usr/local/geant4/data" -v "$PWD:/build" -w "/tmp" andreadotti/geant4-base-dev /build/buildme.sh  
