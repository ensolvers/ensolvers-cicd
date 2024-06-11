# Use Amazon Corretto 17 as the base image
FROM amazoncorretto:21

# Install the New Relic agent
RUN yum update -y && \
    yum install -y wget unzip && \
    wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /opt && \
    rm newrelic-java.zip
    
# Expose the application port (modify as needed)
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]