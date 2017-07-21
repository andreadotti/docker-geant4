#!/bin/bash

function usage() {
   echo "Usage: $0 [-d DOCKERCONF=VAL] [-c CMAKECONF=VAL ] geant4-data-dir app-source-dir [dockerimage]"
   echo "   geant4-data-dir: location on host of Geant4 DB filles"
   echo "   apps-source-dir: location of source of application"
   echo "   dockerimage: Geant4 DEVELOPMENT image (def: andreadotti/geant4-dev)"
   echo "   DOCKERCONF=VAL: one or more configuration parameters to pass to docker"
   echo "             for building of binaries. Can be one of:"
   echo "             APPTARNAME=OutputTarballName.tgz (def: Application.tgz)"
   echo "             APPINSDIR=/docker/location/for/installation"
   echo "                  (def: /usr/local/geant4/applications)" 
   echo "   CMAKECONF=VAL: one opr more configuration parameters to be passed to cmake"
   echo "            it will expand to: cmake -DCMAKECONF=VAL .."
   exit 1
}

dxo=""
cxo=""
while getopts ":hd:c:" o;do
    case "${o}" in
     h)
        usage
        ;;
     d)
        dxo="${dxo} -e ${OPTARG}"
        ;;
     c)
        cxo="${cxo} -D${OPTARG}"
        ;;
     *)
        usage
        ;;
    esac
done
shift $((OPTIND-1))

[ $# -lt 2 ] && usage
g4data=$1
g4src=$2
shift 2

img="andreadotti/geant4-dev"
if [ $# -ge 1 ];then 
      	img=$1
  shift 1
fi

echo "Databases from: $g4data"
echo "Source code: $g4src"
echo "Docker building image: $img"
echo "Docker extra options: ${dxo}"
echo "CMake extra options: ${cxo}"

#If additional parameters have to be passed to cmake to 
#compile the application, you should add them at the end of this
#line, e.g. docker [...] /build/buildme.sh -DSOMEPAR=ON [...]

docker run --rm ${dxo} \
       -v "${g4src}:/App-src:ro" \
       -v "${g4data}:/usr/local/geant4/data" -v "$PWD:/build" \
       -w "/tmp" $img /build/buildme.sh ${cxo} 
