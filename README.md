# apjt-minecraft-pe-server-docker
Docker container for running a Minecraft Pocket Edition server in a docker container
This was primarily developed so we could run a private family server running on a Synology NAS.

## To build...
```
docker build -t minecraft-docker:1.0.0 .
```

## To debug...
```
docker run --tty --entrypoint /bin/bash -i --mount source=minecraft-worlds,target=/opt/bedrock/worlds minecraft-docker:1.0.0
```

## To run locally on a windows ...
```
docker volume create minecraft-worlds
docker run -p 19132:19132/udp -i --mount source=minecraft-worlds,target=/opt/bedrock/worlds minecraft-docker:1.0.0
```

## To connect to a running instance

To connect to an already running instance:
1. Use "docker ps" to get the CONTAINER ID of the image you want to connect to
2. Run the following command where <CONTAINER ID> is from the above step
```
docker exec -it <CONTAINER ID>  /bin/bash
```

## To save for export to NAS (~200MB)...
Tested running on a Synology NAS.
```
docker save -o minecraft-docker.tar minecraft-docker:1.0.0
```

## Source URLs
Links to the external documentation that was used as additional content to this codebase

| URL                                                      | Description                                          |
| -------------------------------------------------------- | ---------------------------------------------------- |
| https://www.minecraft.net/en-us/download/server/bedrock/ | Where to download the server images from             |
| bedrock_server_how_to.html                               | Located in the server image, the main documentation  |
