Experimental image for my personal learning project.


## Usage

```shell
docker run -d \
    -p 5055:5055 \
    -v $PWD/config:/config \
    thebungler/overseerr
```

## Environment

- `$SUID`         - User ID to run as. _default: `952`_
- `$SGID`         - Group ID to run as. _default: `952`_
- `$TZ`           - Timezone. _optional_

## Volume

- `/config`       - Server configuration file location.

## Network

- `5055/tcp`      - WebUI