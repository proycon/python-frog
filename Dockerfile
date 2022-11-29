FROM proycon/frog
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Frog - A Tagger-Lemmatizer-Morphological-Analyzer-Dependency-Parser for Dutch, container image with the Python binding"


COPY . /usr/src/python-frog
RUN BUILD_PACKAGES="build-base libtool libtar-dev bzip2-dev icu-dev libxml2-dev libexttextcat-dev python3-dev" &&\
    mkdir -p /usr/src/python-frog &&\
    apk add python3 py3-wheel py3-pip cython $BUILD_PACKAGES &&\
    cd /usr/src/python-frog && pip install . && apk del $BUILD_PACKAGES && rm -Rf /usr/src/python-frog

ENTRYPOINT [ "python3" ]
