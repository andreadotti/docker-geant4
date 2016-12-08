#!/bin/bash
set -e
#Name of the output tarball
[ "$APPTARNAME" == "" ] && export APPTARNAME=Application.tgz
#By default install in this location so we stup PATH
#and LD_LIBRARY_PATH automatically
[ "$APPINSTDIR" == "" ] && export APPINSTDIR=/usr/local/geant4/applications
#Pass extra options
xopts=""
[ "$APPINSTDIR" != "" ] && xopts="${xopts} -DCMAKE_INSTALL_PREFIX=${APPINSTDIR}"
for val in "$@";do
  xopts="${xopts} ${val}"
done
echo "Geant4 version: "`geant4-config --version`
echo "Application tarball output name: "${APPTARNAME}
echo "Application image installation area: "${APPINSTDIR}

cmake -DGeant4_DIR=/usr/local/geant4/lib/Geant4-* \
      ${xopts} /App-src 

make -j`nproc` 
make install/fast
tar -czf /build/binaries/${APPTARNAME} ${APPINSTDIR}

