# minecraft-pe-server-docker
Docker container for running a Minecraft Pocket Edition server in a docker container

## To build...
```
docker build -t minecraft-docker:1.0.0 .
```

## To debug...
```
docker run --tty --entrypoint /bin/bash -i --mount source=minecraft-worlds,target=/opt/bedrock/worlds minecraft-docker:1.0.0
```

## To run locally...
```
     docker volume create minecraft-worlds
     docker run -p 19132:19132/udp -i --mount source=minecraft-worlds,target=/opt/bedrock/worlds minecraft-docker:1.0.0
```

## To save for export to NAS (~180MB)...
Tested running on a Synology NAS.
```
docker save -o minecraft-docker.tar minecraft-docker:1.0.0
```