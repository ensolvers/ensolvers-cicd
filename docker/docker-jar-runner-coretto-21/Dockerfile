# Use Amazon Corretto 17 as the base image
FROM amazoncorretto:21

# Install the New Relic agent
RUN yum update -y && \
    yum install -y wget unzip awscli && \
    wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /opt && \
    rm newrelic-java.zip

# Set the timezone to UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY docker-entrypoint.sh /docker-entrypoint.sh
    
# Expose the application port (modify as needed)
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]