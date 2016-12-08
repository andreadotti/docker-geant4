#!/bin/bash
IMG="andreadotti/geant4"
OUT="testme"
BINLOC="/usr/local/geant4/applications/bin"
LIBLOC="/usr/local/geant4/applications/lib"
ANS=0
if [ "$1" == "-h" ];then
   echo "Usage: $0 [-y] [fromimage] [outputimage] [binloc] [libloc]"
   echo "     -y: build docker image immediately, otherwise just "
   echo "         generate Dockerfile for manual editing"
   echo "     fromimage: Docker image to start from (def: $IMG)"
   echo "     outputimage: Docker output image name (def: $OUT)"
   echo "     binloc: Location of binaries (def: $BINLOC)"
   echo "     libloc: Location of libraries (def: $LIBLOC)"
   exit 1
fi
if [ "$1" == "-y" ];then
   ANS=1
   shift 1
fi
[ $# -ge 1 ] && IMG=$1
[ $# -ge 2 ] && OUT=$2
[ $# -ge 3 ] && BINLOC=$3
[ $# -ge 4 ] && LIBLOC=$4
[ -z Dockerfile ] && mv Dockerfile Dockerfile.OLD
cat << EOF > Dockerfile
#Auto-generated, changes will be lost if $0 is re-run
FROM $IMG
MAINTAINER Andrea Dotti (adotti@slac.stanford.edu)
ADD binaries/*.tgz /
ENV PATH="$BINLOC:\$PATH"
ENV LD_LIBRARY_PATH="$LIBLOC:\$LD_LIBRARY_PATH"
COPY runme.sh /runme.sh
CMD [ "/runme.sh" ]
EOF
if [ $ANS -eq 1 ];then 
   docker build -t $OUT .
else
   echo "Generation of Dockerfile, manually adjust it if needed, and then run:"
   echo "Manually modify run.sh script if needed"
   echo docker build -t $OUT .
fi 
