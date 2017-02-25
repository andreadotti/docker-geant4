#!/bin/bash
if [ $# -lt 1  ];then 
   echo "Usage: $0 geant4sourcedir [geant4datadir]"
   echo "   Where: geant4sourcedir is the directory containing the Geant4 source code on the host"
   echo "          geant4datadir is the directory containing Geant4 Databases on the host"
   echo "              1. if a specific database is missing it will be installed"
   echo "               (e.g. -DGEANT4_INSTALL_DATA=ON is used)"
   echo "              2. if this directory is specified, data will be EXCLUDED from"
   echo "                 final container image tarball, if this is not specified, data will be "
   echo "                 INCLUDED."
   exit 1
fi
g4src=$1
[ $# -ge 2 ] && g4data=$2

if [ -z "$g4data" ];then
   #No datadirectoryu specified, will 
   docker run --rm -v "${g4src}:/geant4-src:ro" -v "$PWD:/build" -w "/tmp" \
	      andreadotti/geant4-base-dev /build/buildme.sh --withdata
else
   docker run --rm -v "${g4src}:/geant4-src:ro" -v "${g4data}:/usr/local/geant4/data" \
	      -v "$PWD:/build" -w "/tmp" andreadotti/geant4-base-dev /build/buildme.sh 
fi 
