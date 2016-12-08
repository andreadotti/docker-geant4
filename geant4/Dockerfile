FROM andreadotti/geant4-base 

MAINTAINER Andrea Dotti (adotti@slac.stanford.edu)

#Install Geant4
RUN mkdir -p /usr/local/geant4
ADD binaries/geant4.tgz /usr/local/geant4/

#Remove G4 SDK: save some space
RUN rm -rf /usr/local/geant4/include /usr/local/geant4/share/Geant4-*/examples
RUN apt -y autoremove && apt -y clean
RUN rm -rf /var/lib/{apt,dpkg}

#Copy Entry point 
COPY entry-point.sh /entry-point.sh
ENTRYPOINT ["/entry-point.sh"]
CMD [ "/bin/bash" ]


