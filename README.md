Geant4 Docker Images scripts and utilities
==========================================


Author: Andrea Dotti (adotti@slac.stanford.edu)  
Copyright: Andrea Dotti (adotti@slac.stanford.edu) and the Geant4 Collaboration
 http://www.geant4.org 2016   
License: Geant4 License http://www.geant4.org/geant4/license/LICENSE.html

This set of scripts and utilities is designed to 
help and (partially) automatize the creation of 
docker images for Geant4 applications.

Images built using these set of scripts are
published on docker hub under andreadotti repositories.

The scripts allow to create everything from scratch since official Geant4 images 
are available you probably are interested only in the scripts to build your 
applications into images (Step 4).

Prebuild images
--------------------
Images managed and built by the Geant4 collaboraiton can be found on docker 
hub at: https://hub.docker.com/u/andreadotti/

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
+--geant4-dev : scripts to create images containing G4 SDK
|                (to be used to build your own application)
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
`docker pull andreadotti/geant4:10.2.p02` will download  the docker image
containing Geant4 Version 10.2.p02 runtime.  
**Note 2:** Geant4 Databases are in general not included in docker 
images to keep their 
size small. You should provide databases via a docker volume. Images expect
files to be accessible at: */usr/local/geant4/data*. So:
`docker run -v "/where/dbs/are/on/host:/usr/local/geant4/data:ro" [...]`. 
Variants with database files are also produced. See: https://hub.docker.com/u/andreadotti/
**Note 3:** docker tag *latest* is the last available G4 release. Note that this could
be a reference tag. It is best to specify the Geant4 public release to run production 
ready images.  
**Note 4:** docker labels are used to add metadata about image configuration. See
the labels associated to an image with: `docker inspect --format='{{.Config.Labels}}' <imageid>`

Images layout and use cases:
-------------------------------------
We distinguish between runtime images and development images. The latter contain G4 SDK and
tools to compile Geant4 applications. Using pre-built images you can compile your application for a docker image: 
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
https://hub.docker.com/r/andreadotti, you probably do not need to perform Step 1, 2, 3 below
and only apply step 4.

### Step 0: Get the code
```
git clone <thisrepo>
cd docker-geant4
```

### Step 1: (Optional) Build base images 
```
cd geant4-base
docker build -t geant4-base .
cd ../geant4-base-dev
docker build -t geant4-base-dev .
cd ..
```

### Step 2: (Optional) Build Geant4 SDK image
```
cd geant4-dev
./build-binaries.sh /geant4-src /geant4-data
docker build -t geant4-env .
cd ..
```
**Note**: Provinding a location for databases is optional, see `README.md` file
in geant4-dev dirctory for details.

### Step 3: (Optional) Build Geant4 runtime image 
Copy tarball `geant4.tgz` from `geant4-dev/binaries` to 
`geant4/binaries` and build the image:
```
cd geant4
cp ../geant4-dev/binaries/geant4.tgz binaries/
docker build -t geant4:X.Y.Z .
```

### Step 4: Build application
In the vast majority of the cases, since we provide images for all the steps above
this is the only thing you need to do to create an image containing Geant4 run-time
and your application.  
The directory *applications* contains scripts to build automatically the image.  
First you need to compile the application against a given version of Geant4 and thus use a 
*-dev* image, then copy the obtained binaries to a new image based on the correct version
of Geant4.  
For simplicity we assume the application code is located on the host under `/usr/app-src` 
and Geant4 databases are located under `/usr/geant4/data` on the host. We want to develop
against official images at https://hub.docker.com/r/andreadotti for G4 version 10.2.p02.  
**Note**: Database files provided as volume is optional, provided that the image 
contains G4 databases. See Step 2 notes.
```
cd applications
./build-binaries.sh /usr/geant4/data /usr/app-src andreadotti/geant4-dev:10.2.p02
```
This will create tarballs using the official dev container specified on the command line
 and compile the application creating a tarball called `Application.tgz` that can be found under
the `binaries` sub-directory. Type `./build-binaries.sh` without options for a quick help.  
Options can be passed including selecting a different name for the tarball. In this way it is 
possible to create several tarballs of different applications that will all be combined in 
a single executable image.

Now you are ready to create your own image with the applications and the Geant4 environment:
```
./build-images.sh [-y] andreadotti/geant4:10.2.p02 myself/myApp
```
This will generate a Dockerfile for your new image called *myself/myApp* with all applications
 tarballs found locally under *binaries*. If you do not need to change any default you can 
 add the *-y* parameter to avoid the manual step of issuing the `docker buld` command.  
The new image will use the script `runme.sh` script as the default command executed when the 
new image is started. By default this script is empty.  
If you need to tune the Dockerfile or the runme.sh do not use the *-y* option and edit the files 
before issuing `docker build`.  
For an example of a more realistic application image see: https://github.com/andreadotti/docker-geant4-val
 
### Use of Labels
 For images that are distributed and used by others we stronly encouraged to add docker labels
 that identify metadata associated with the application image. The following labels are encouraged
 (you can replace `org.geant4` with your prefix):
 
 * `org.geant4.<appname>.installation_dir` : Absolute path where binaries are installed.
 * `org.geant4.<appname>.readme` : Path to the main README file
 * `org.geant4.<appname>.license` : Path to the LICENSE file
 * `org.geant4.<appname>.docs` : Additional documentation paths, files
 * `org.geant4.<appname>.url` : Web-page/git repo/whatever
 * `org.geant4.<appname>.default_macro_name` : Path of an example default macro
 * `org.geant4.<appname>.bins` : List of G4 binaries
 * `org.geant4.<appname>.macro_dirs` : List of paths where to find macros to execute the application
 * `org.geant4.<appname>.output` : Where and how output is stored
 
 List should be space separated, paths can be absolute or relative, whenever the latter it is
 assumed they are relative to `org.geant4.<appname>.installation_dir`.
