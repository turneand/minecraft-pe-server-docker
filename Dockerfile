##
# Initial docker image, prepares all of the content
# downloads the server, unzips and sets up.  We then
# utilise the multistage builds to extract just the
# files from this image (avoids installing curl/unzip
# on the main image).
##
FROM ubuntu:latest as downloader

# Install the required dependencies for downloading the server
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y install unzip curl \
    && rm -rf /var/lib/apt/lists/*

# Download the official minecraft server
RUN curl --output /tmp/bedrock-server.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-1.9.0.15.zip
RUN mkdir /opt/bedrock
RUN unzip /tmp/bedrock-server.zip -d /opt/bedrock
# replace with our own properties
COPY server.properties /opt/bedrock/server.properties

##
# Our final docker image.
##
FROM ubuntu:latest

# Install the required dependencies of our final image
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get -y install libcurl4 \
    && rm -rf /var/lib/apt/lists/*

# Create our runtime user and switch to it
RUN useradd --uid 1026 --no-create-home bedrock 
USER bedrock

# Copy the download from our previous image and set as working directory
COPY --chown=bedrock --from=downloader /opt/bedrock /opt/bedrock
WORKDIR /opt/bedrock

# Setup the worlds volume for persistence
RUN mkdir /opt/bedrock/worlds
VOLUME /opt/bedrock/worlds

# Finally, prepare execution commands
ENV LD_LIBRARY_PATH=.
EXPOSE 19132/udp 19133/udp
ENTRYPOINT ["/opt/bedrock/bedrock_server"]
