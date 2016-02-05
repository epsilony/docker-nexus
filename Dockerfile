# Derived from
# https://github.com/sonatype/docker-nexus

FROM epsilony/java:armhf-openjdk-8

MAINTAINER Man YUAN <epsilony@epsilony.net>

ENV SONATYPE_WORK /sonatype-work
ENV NEXUS_VERSION 2.12.0-01

RUN mkdir -p /opt/sonatype/nexus \
  && wget -O - \
    https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz \
  | gunzip \
  | tar x -C /tmp nexus-${NEXUS_VERSION} \
  && mv /tmp/nexus-${NEXUS_VERSION}/* /opt/sonatype/nexus/ \
  && rm -rf /tmp/nexus-${NEXUS_VERSION}

RUN useradd -r -u 200 -m -c "nexus role account" -d ${SONATYPE_WORK} -s /bin/false nexus

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

VOLUME /var/log

ENV CONTEXT_PATH /nexus
ENV MAX_HEAP 512m
ENV MIN_HEAP 125m
ENV JAVA_OPTS -server -Djava.net.preferIPv4Stack=true
ENV LAUNCHER_CONF ./conf/jetty.xml ./conf/jetty-requestlog.xml

ADD nexus-run /etc/service/nexus/run
RUN chmod +x /etc/service/nexus/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

VOLUME ${SONATYPE_WORK}

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
