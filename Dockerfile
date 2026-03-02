FROM moodlehq/moodle-php-apache:8.1

# Install necessary tools and MySQL client
RUN apt-get update && apt-get install -y \
    wget \
    git \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Set Moodle version
ARG MOODLE_VERSION=404
ENV MOODLE_VERSION=${MOODLE_VERSION}

# Download and extract Moodle to temporary location
RUN cd /tmp && \
    wget -q https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz && \
    tar -xzf moodle-latest-${MOODLE_VERSION}.tgz && \
    mv moodle /tmp/moodle-install && \
    rm -f moodle-latest-${MOODLE_VERSION}.tgz

# Create moodledata directory with correct permissions
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod -R 777 /var/www/moodledata

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
