# Interactive Brokers Gateway Docker

Interactive Brokers Gateway running in Docker. Ships with VNC over ssh for debugging.

Running an environment for API access to Interactive Brokers is notoriously difficult. This docker image aims to make it possible to spin up an accessible IB API with a single docker command.

## NOTICE ##

HEAD of this repo is in active development. At the moment, HEAD works great, but if you expose the VNC port it is unsecured. Exposing the VNC port is not needed, and discouraged. But it can be used for debugging purposes in a secure environment.

The last working commit with ssh protection of VNC was https://github.com/riazarbi/ib-headless/tree/4416746e31afe55443de672686991820b0ef9bc8 , but the user running everything is root.

## Ports

These are the services that will run when you spin up this container.

- vnc runs on port 5900

## Flags

- `USERNAME`: IB username
- `PASSWORD`: IB password
- `TRADINGMODE`: paper or live

You can either use the flags above to authenticate with IB, or you can mount in your own IBC `config.ini` file (example [here](https://github.com/IbcAlpha/IBC/blob/master/resources/config.ini)) at `/root/ibc/config.ini` in the container. The flags will overwrite anything in that location so use either the flags or the mount, not both.

## Intended Usage

### Method 1: Expose the IB API but NOT ssh or VNC

```
docker run -it --rm --name broker  -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live riazarbi/ib-headless:latest
```

### Method 2: Expose the VNC  for interacting with gateway manually

**!!IF YOU EXPOSE PORT 5900 ANYONE CAN ACCESS YOUR USER. ONLY EXPOSE PORT 5900 IF YOU ARE A SECURE ENVIRONMENT.!!**

```
docker run -it --rm --name broker  -p 5900:5900 -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live riazarbi/ib-headless:latest
```

From your laptop: 

```bash
# in another terminal window
vncviewer server-ip:5900
```

## What runs in this container?

The base image is `debian:buster`.

On top of that we install `openbox` and `tint2`. 

We run `tigervnc` on top of that.

We install IB `gateway` stable version directly from Interactive Brokers' website.

We install `ibc` from [IBCAlpha](https://github.com/IbcAlpha/IBC) to control gateway.

It is all run by unprivileged user `broker`  via `supervisord`. 
