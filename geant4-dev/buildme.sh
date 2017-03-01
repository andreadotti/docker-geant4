#!/bin/bash
if [ "$1" == "-h" ];then
   echo "Usage: $0 [--withdata]"
   echo " This script should be run in a container containing"
   echo " tools to compile G4 (e.g. docker hub: andreadotti/geant4-base-dev" 
   echo " builds G4 and creates a tarball (in /build/binaries)"
   echo " containing G4 sdk."
   echo " If option --withdata is passed include in tarball G4 databases"
fi
set -e
cmake -DGEANT4_INSTALL_DATA=ON \
      -DGEANT4_INSTALL_DATADIR=/usr/local/geant4/data \
      -DGEANT4_BUILD_MULTITHREADED=ON \
      -DGEANT4_USE_GDML=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local/geant4 \
	/geant4-src
make -j`nproc` 
make install/fast
cd /usr/local/geant4
if [ "$1" == "--withdata" ];then 
   tar -czf /build/binaries/geant4.tgz .
else
   tar --exclude='./data' -czf /build/binaries/geant4.tgz .
fi
