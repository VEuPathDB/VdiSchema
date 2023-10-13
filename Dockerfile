FROM ???

COPY bin/ /opt/veupathdb/bin
COPY lib/ /opt/veupathdb/lib

RUN export LIB_GIT_COMMIT_SHA=d7738c682fcafeec14b430d52fe2b43920eabe8e\
    && git clone https://github.com/VEuPathDB/lib-schema-install-utils.git \
    && cd lib-schema-install-utils\
    && git checkout $LIB_GIT_COMMIT_SHA \
    && cp lib/perl/SchemaInstallUtils.pm /opt/veupathdb/lib/perl

RUN chmod +x /opt/veupathdb/bin/*


