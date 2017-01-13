#!/bin/bash
set -e
cmake -DGEANT4_INSTALL_DATA=ON \
      -DGEANT4_INSTALL_DATADIR=/usr/local/geant4/data \
      -DGEANT4_BUILD_MULTITHREADED=ON \
      -DGEANT4_USE_GDML=ON \
      -DCMAKE_INSTALL_PREFIX=/usr/local/geant4 \
	/geant4-src
make -j`nproc` 
make install/fast
cd /usr/local/geant4
tar --exclude='./data' -czf /build/binaries/geant4.tgz .

