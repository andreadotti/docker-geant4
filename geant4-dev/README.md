Create docker image with Geant4 SDK
=================================================

Author: Andrea Dotti (adotti@slac.stanford.edu)  
Copyright: Andrea Dotti (adotti@slac.stanford.edu) and the Geant4 Collaboration <http://www.geant4.org>  
License: Geant4 License <http://www.geant4.org/geant4/license/LICENSE.html>  

This directory contains scripts to 
create a docker image with the Geant4 libraries and development 
environment. The image can then be used to create containers
that can compile and run a Geant4 application.

For a descripion of the overview of the Geant4 docker images and instructions on how to build
applications against a pre-build Geant4 image see:
<https://github.com/andreadotti/docker-geant4>


Usage:
------
Assuming Geant4 source code and Geant4 DB are installed on the host
respectively under */geant4-src* and */geant4-data*

```
$ git clone git@github.com:andreadotti/docker-geant4.git
$ cd docker-geant4/geant4-dev
$ ./build-binaries.sh /geant4-src /geant4-data
$ docker build -t geant4-dev:X.Y.Z .
```
Where `X.Y.Z` is the G4 version, used as tag for the image.

Data files (Geant4 DBs) are not included in the container images if a location
of database files is passed to the `build-binaries.sh` script (as in the
previous example). This helps in reducing container image size. If you want
to achieve maximum portability (i.e. running container on a host w/o access
to Geant4 DB) run the script omitting the database directory.  
**NOTE**: Verify you have the rights and permissions to distribute Geant4
data-bases if image is going to be public!  

The Geant4 binaries can be found in the tarball in the *binaries* subdirectory.
You may want to adapt the *buildme.sh* script to your particular
configuration.

To test the new image:
```
$ docker run --rm -v "/geant4-data:/usr/local/geant4/data:ro" \
	geant4-env geant4-config --version
```  

To add to the container your application:
```
$ docker run -t -i -v "/geant4-data:/usr/local/geant4/data:ro" geant4-env
root@....:/# #Get your project somehow, e.g. apt install git && git clone ...
root@....:/# mkdir build && cd build
root@....:/# cmake -DGeant4_DIR=/usr/local/geant4/lib/Geant4-* <app-src>
root@....:/# make -j`nproc`
root@....:/# #Test your application
root@....:/# exit
$ docker ps -l
#Get the ID
$ docker commit -m"Adding my application and Geant4 ver x.y.z" -a "MyName" ID repo/name:tag
```

Containers with pre-built Geant4 images are available at <https://hub.docker.com/r/andreadotti/geant4-dev/>:
```
docker pull andreadotti/geant4-dev:version
```

Push to registry
----------------
To publish image in the registry with username `abc`:

```
docker tag geant4-dev:X.Y.Z abc/geant4-dev:X.Y.Z
docker push abc/geant4-dev:X.Y.Z
```
 
