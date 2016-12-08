###################################
# Base image from which derive    #
# all other Geant4 derived images #
###################################
FROM ubuntu:16.04 

MAINTAINER Andrea Dotti (adotti@slac.stanford.edu)

LABEL org.geant4.website="http://www.geant4.org"
LABEL org.geant4.license_url="http://www.geant4.org/geant4/license/index.shtml"
LABEL org.geant4.xerces-c_version="3.1"

RUN apt -y update && apt -y upgrade
RUN apt install -y libxerces-c3.1 libexpat1 


