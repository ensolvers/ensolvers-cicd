FROM ubuntu:22.04
ARG timezone
ENV TZ=${timezone}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "LICENSE_KEY" | tee -a /etc/newrelic-infra.yml && \
    curl -fsSL https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/newrelic-infra.gpg && \
    echo "deb https://download.newrelic.com/infrastructure_agent/linux/apt/ jammy main" | tee -a /etc/apt/sources.list.d/newrelic-infra.list

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/8.0.1/newrelic-agent-8.0.1.jar -O /newrelic.jar

RUN apt update && \
    apt install -y openjdk-17-jdk awscli mysql-client wget curl gnupg newrelic-infra

CMD ["./docker-entrypoint.sh"]