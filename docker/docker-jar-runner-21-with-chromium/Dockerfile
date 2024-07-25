# Use Ubuntu
FROM amazoncorretto:21-alpine3.20

# Install the New Relic agent and AWS CLI
RUN apk add --no-cache wget unzip tzdata && \
    wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
    unzip newrelic-java.zip -d /opt && \
    rm newrelic-java.zip && \
    wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/

# Ensure AWS CLI is in the PATH
ENV PATH="/usr/local/bin:$PATH"

# Install dependencies for Chromium
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver

# Set the path to Chrome Driver in your code
ENV PATH="/usr/lib/chromium:$PATH"

# Clean up
RUN rm -rf /var/cache/apk/*

# Configures the timezone passed via the `timezone` arg
ARG timezone
ENV zoneinfo=/usr/share/zoneinfo/${timezone}
RUN [ -f $zoneinfo ] || (echo "zoneinfo not found for timezone: $timezone" && exit 1) && \
    ln -snf $zoneinfo /etc/localtime && \
    echo $timezone > /etc/timezone

COPY docker-entrypoint.sh /docker-entrypoint.sh
    
# Expose the application port (modify as needed)
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]