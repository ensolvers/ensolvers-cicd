# Use Amazon Corretto 17 as the base image
FROM amazoncorretto:21

# Install the New Relic agent
RUN yum update -y && \
    yum install -y wget unzip awscli && \
    wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /opt && \
    rm newrelic-java.zip

# Set the timezone to UTC
ARG timezone
ENV zoneinfo=/usr/share/zoneinfo/${timezone}
RUN [ -f $zoneinfo ] || (echo "zoneinfo not found for timezone: $timezone" && exit 1) && \ 
    ln -snf $zoneinfo /etc/localtime && \ 
    echo $timezone > /etc/timezone

COPY docker-entrypoint.sh /docker-entrypoint.sh
    
# Expose the application port (modify as needed)
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]