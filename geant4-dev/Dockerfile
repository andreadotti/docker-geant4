FROM andreadotti/geant4-base-dev

MAINTAINER Andrea Dotti (adotti@slac.stanford.edu)
RUN mkdir /usr/local/geant4
COPY entry-point.sh /entry-point.sh
ADD binaries/geant4.tgz /usr/local/geant4/

ENTRYPOINT ["/entry-point.sh"]
CMD [ "/bin/bash" ]


