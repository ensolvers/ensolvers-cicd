FROM ubuntu:22.04
ARG timezone
ENV TZ=${timezone}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update
RUN apt install -y openjdk-17-jdk awscli mysql-client wget

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-agent.jar -O /newrelic.jar

CMD ["./docker-entrypoint.sh"]