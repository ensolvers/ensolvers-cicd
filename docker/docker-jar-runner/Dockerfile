FROM newrelic/infrastructure:latest
# SET CONTAINER TIMEZONE
ARG timezone
ENV TZ=${timezone}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# UPDATE AND INSTALL JDK
RUN apk update
RUN apk add openjdk17 wget
RUN rm -rf /var/cache/apk/*

# COPY FILES
COPY docker-entrypoint.sh /docker-entrypoint.sh
# CONFIG FOR NEW RELIC INFRAESTRUCTURE AGENT
COPY newrelic-infra.yml /etc/newrelic-infra.yml

# DOWNLOAD LAST NEW RELIC VERSION
RUN wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-agent.jar -O /newrelic.jar

CMD ["./docker-entrypoint.sh"]