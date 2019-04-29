##
# Initial docker image, prepares all of the content downloads the server, unzips and sets up.  We then utilise the
# multistage builds to extract just the files from this image (avoids installing curl/unzip on the main image).
##
FROM ubuntu:latest as downloader

ENV DEBIAN_FRONTEND noninteractive
ENV BEDROCK_SERVER_VERSION 1.11.1.2

# Install the required dependencies for downloading the server
RUN apt-get update \
    && apt-get -y install unzip curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/bedrock

# Download the official minecraft server
RUN curl --output /tmp/bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-${BEDROCK_SERVER_VERSION}.zip
RUN unzip /tmp/bedrock-server.zip -d /opt/bedrock

# Create a backup of the server.properties file (allows us to easily compare values later)
RUN cp /opt/bedrock/server.properties /opt/bedrock/server.properties.original



##
# Our final docker image.
##
FROM ubuntu:latest

# Install the required dependencies of our final image
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y install libcurl4 \
    && rm -rf /var/lib/apt/lists/*

# Copy the download from our previous image
COPY --from=downloader /opt/bedrock /opt/bedrock

# Create our runtime user.  If running on a Synology NAS, the BEDROCK_UID passed must match that of the
# Synology user account that has write access to the volume
ARG BEDROCK_UID=1026
RUN useradd --uid ${BEDROCK_UID} --no-create-home bedrock 

# Create the worlds directory, which is the ONLY one writable by our runtime account!
RUN mkdir /opt/bedrock/worlds && chown bedrock:bedrock /opt/bedrock/worlds
# Create the log file, and allow our runtime account to modify it
RUN touch /opt/bedrock/Debug_Log.txt && chown bedrock:bedrock /opt/bedrock/Debug_Log.txt

# Setup the worlds volume for long term persistence
VOLUME /opt/bedrock/worlds

# overwrite the server.properties file with our customisations
COPY server.properties /opt/bedrock/server.properties

# Switch to out runtime user account and prepare for the final execution commands
USER bedrock
WORKDIR /opt/bedrock
ENV LD_LIBRARY_PATH=.
EXPOSE 19132/udp 19133/udp
ENTRYPOINT ["/opt/bedrock/bedrock_server"]
