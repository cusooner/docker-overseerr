Experimental image for my personal learning project.

[![Actions Status](https://github.com/thebungler/docker-overseerr/workflows/Docker%20Build/badge.svg)](https://github.com/thebungler/overseerr/actions)

## Usage

```shell
docker run -d \
    -p 5055:5055 \
    -v /blahblah/config:/config \
    thebungler/overseerr
```

## Environment

- `$SUID`         - User ID to run as. 
- `$SGID`         - Group ID to run as. 
- `$TZ`           - Timezone

## Volume

- `/config`       - where config is stored

## Network

- `5055/tcp`      - web interface
