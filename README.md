Experimental image for my personal learning project.

[![Actions Status](https://github.com/thebungler/docker-overseerr/workflows/Docker%20Build/badge.svg)](https://github.com/thebungler/overseerr/actions)

## Usage

```shell
docker run -d \
    -p 5055:5055 \
    -v /blahblah/config:/config \
    thebungler/overseerr
```

```docker-compose
  overseerr:
    image: thebungler/overseerr:latest
    container_name: overseerr
    environment:
      - PUID=1001
      - PGID=100
      - TZ=Europe/Berlin
    volumes:
      - /mydockervol/overseerr:/config
    ports:
      - 5055:5055
    restart: unless-stopped
```

## Environment

- `$SUID`         - User ID to run as. 
- `$SGID`         - Group ID to run as. 
- `$TZ`           - Timezone

## Volume

- `/config`       - where config is stored

## Network

- `5055/tcp`      - web interface
