Geant4 Docker Images scripts and utilities
==========================================


Author: Andrea Dotti (adotti@slac.stanford.edu)  
Copyright: Andrea Dotti (adotti@slac.stanford.edu) and the Geant4 Collaboration <http://www.geant4.org> 2016   
License: Geant4 License <http://www.geant4.org/geant4/license/LICENSE.html>

This set of scripts and utilities is designed to 
help and (partially) automatize the creation of 
docker images for Geant4 applications.

Images built using these set of scripts are
published on docker hub under andreadotti repositories.

The scripts allow to create everything from scratch since official Geant4 images are available you
probably are interested only in the scripts to build your applications into images.

Directory Content:
-----------------

```
|
+--applications : scripts to create images
|     |           containing G4 applications
|     |
|     +--binaries : Geant4 application tarballs
|                   compiled for docker images
|                   are kept here during building
|
+--geant4 : scripts to create images containing G4 runtime
|    |
|    +--binaries : Geant4 installation area tarball compiled
|                  for docker images are kept here during building
|
+--geant4-base : scripts of the minimal runtime system for G4
|                (No G4 installation is present here)
|
+--geant-base-dev : image with minimal runtime system and development
                    tools
```

Important Notes:
---------------

**Note 1:** Docker tags are used to identify Geant4 releases. So for example
`docker run -i -t andreadotti/geant4:10.2.p02` will run  the docker image
containing Geant4 Version 10.2.p02 runtime.  
**Note 2:** Geant4 Databases are never included in docker images to keep the 
size small. You should provide databases via a docker volume. Images expect
files to be accessible at: */usr/local/geant4/data*. So:
`docker run -i -v "/where/dbs/are/on/host:/usr/local/geant4/data:ro" -t andreadotti:geant4`  
**Note 3:** docker tag *latest* is the last available G4 release. Note that this could
be a reference tag. It is best to specify the Geant4 public release to run production 
ready images.

Images layout and use cases:
---------------------------
We distinguish between runtime images and development images. The latter contain G4 SDK and
tools to compile Geant4 applications. Thus to compile your application in a docker image 
you may need to:  
```
docker run -i -t -v "/where/dbs/area:/usr/local/geant4/data:ro" -t andreadotti:geant4-dev
root@....:/# #Get your code
root@....:/# cmake -DGeant4_DIR=/usr/local/geant4/lib/Geant4-* [...] && make -j`nproc` install
```

The image layout is as following:  
```
     baseImage (currently ubuntu:16.04)
         |
     genat4-base (add runtime for Xerces-C and Expat)
      /        \
      |       geant4-base-dev
      |         (add dev tools)
      |                 |
 geant4:X.Y.Z   <-- geant4-dev:X.Y.Z 
(G4-runtime)        (G4 SDK for Version X.Y.Z)
      |                |
  Application   <--  application-dev
```
The `<--` arrow means that binaries are created on the `*-dev` images and copied over to 
the run-time images.

Work flow:
---------
Note that Dockerfile contain references to the explicit and official images located at:
<https://hub.docker.com/r/andreadotti>, you probably do not need to perform Step 1, 2, 3 below
and only apply step 4.

### Step 0: Get the code
```
git clone <thisrepo>
```
Note that the scripts to create images with Geant4 SDK (`geant4-dev`) is kept in a separate
git repository. 

### Step 1: Build base images 
This is probably not necessary since it is done centrally.

```
cd geant4-base
docker build -t myself/geant4-base .
cd ../geant4-base-dev
docker build -t myself/geant4-base-dev .
```

### Step 2: Build Geant4 SDK 
Again this is probably not necessary since it is done centrally
See: <https://github.com/andreadotti/docker-geant4-dev>

### Step 3: Build Geant4 runtime image 
If you have performed Step 2, copy tarball *geant4.tgz* from *docker-geant4-dev/binaries* to 
*geant4/binaries* and:
```
cd geant4
docker build -t muself/geant4:X.Y.Z .
```

### Step 4: Build Application and Application runtime
In the vast majority of the cases, since we provide images for all the steps above
this is the only thing you need to do to create an image containing Geant4 run-time
and your application.  
The directory *applications* contains scripts to build automatically the image.  
First you need to compile the application against a given version of Geant4 and thus use a 
*-dev* image, then copy the obtained binaries to a new image based on the runtime version
of Geant4.    
For simplicity we assume the application code is located on the host under */usr/app-src* 
and Geant4 databases are located under */usr/geant4/data* on the host. We want to develop
against official images at <<https://hub.docker.com/r/andreadotti> for version 10.2.p02.  
```
cd applications
./build-binaries.sh /usr/geant4/data /usr/app-src andreadotti/geant4-dev:10.2.p02
```
This will create tarballs using the official dev container specified on the command line
 and compile the application creating a resulting called *Application.tgz* that can be found under
*binaries* sub-directory. Issue `./build-binaries.sh` without options for a quick help.  
Options can be passed including selecting a different name for the tarball. In this way it is 
possible to create several tarballs of different applications that will all be combined in 
a single executable image.

Now you are ready to create your own image with the applications and the Geant4 environment
you need:
```
./build-images.sh [-y] andreadotti/geant4:10.2.p02 myself/myApp
```
This will generate a Dockerfile for your new image called *myself/myApp* with all applications tarballs found locally
under *binaries*. If you do not need to change any default you can add the *-y* parameter to avoid
the manual step of issuing the `docker buld` command.  
The new image will use the script *runme.sh* script as the default command executed when the new image is started. 
By default this script is empty.  
If you need to tune the Dockerfile or the runme.sh do not use the *-y* option and edit the files before issuing `docker build`.
 
