# Use Amazon Corretto 17 as the base image
FROM amazoncorretto:17

# Install the New Relic agent
RUN yum update -y && \
    yum install -y wget && \
    wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /opt && \
    rm newrelic-java.zip

# Set the environment variable for New Relic configuration
ENV NEW_RELIC_HOME /opt/newrelic
ENV NEW_RELIC_CONFIG_FILE $NEW_RELIC_HOME/newrelic.yml

# Expose the application port (modify as needed)
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]










