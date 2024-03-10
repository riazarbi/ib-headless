# Interactive Brokers Gateway Docker Image

Interactive Brokers Gateway running in Docker. Ships with VNC over ssh for debugging.

Running an environment for API access to Interactive Brokers is notoriously difficult. This docker image aims to make it possible to spin up an accessible IB API with a single docker command.

# Releases and Packages

Every time Interactive Brokers release a new stable version of the Gateway, we download it and save it under releases. SO you can use this repo's releases to install a particular verion of the Gateway. 

When we detect a new release, we also build a new docker image, and tag it with the release version. Check outt he tags under the 'packages' section of this repo.

## Ports

These are the services that will run when you spin up this container.

- vnc runs on port 5900
- 

## Flags

- `USERNAME`: IB username
- `PASSWORD`: IB password
- `TRADINGMODE`: paper or live

You can either use the flags above to authenticate with IB, or you can mount in your own IBC `config.ini` file (example [here](https://github.com/IbcAlpha/IBC/blob/master/resources/config.ini)) at `/root/ibc/config.ini` in the container. The flags will overwrite anything in that location so use either the flags or the mount, not both.

## Intended Usage

### In day to day use: Expose the IB API but NOT ssh or VNC

```
docker run -it --rm --name broker  -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live ghcr.io/riazarbi/ib-headless:10.19.2j
```

### Insecure, for debugging: Expose the VNC  for interacting with gateway manually

**!!IF YOU EXPOSE PORT 5900 ANYONE CAN ACCESS YOUR USER. ONLY EXPOSE PORT 5900 IF YOU ARE A SECURE ENVIRONMENT.!!**

```
docker run -it --rm --name broker  -p 5900:5900 -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live  ghcr.io/riazarbi/ib-headless:10.19.2j
```

From your laptop: 

```bash
# in another terminal window
vncviewer server-ip:5900
```

## What runs in this container?

The base image is `debian:stable`.

On top of that we install `openbox` and `tint2`. 

We run `tigervnc` on top of that.

We install IB `gateway` stable version directly from Interactive Brokers' website.

We install `ibc` from [IBCAlpha](https://github.com/IbcAlpha/IBC) to control gateway.

It is all run by unprivileged user `broker`  via `supervisord`. 
