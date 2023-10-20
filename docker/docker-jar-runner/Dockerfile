FROM ubuntu:22.04
ARG timezone
ENV TZ=${timezone}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update
RUN apt install -y openjdk-17-jdk awscli mysql-client wget tini

COPY test.sh /test.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/8.0.1/newrelic-agent-8.0.1.jar -O /newrelic.jar

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["./docker-entrypoint.sh"]