# Interactive Brokers Gateway Docker

Interactive Brokers Gateway running in Docker. Ships with VNC over ssh for debugging.

Running an environment for API access to Interactive Brokers is notoriously difficult. This docker image aims to make it possible to spin up an accessible IB API with a single docker command.

## Ports

These are the services that will run when you spin up this container.

- ssh runs on port 22
- vnc runs on port 5900
- Interactive Brokers API port runs on 4003 _no matter whether it's running in paper mode or live mode_.

## Flags

- `SSH`: github handle to import ssh keys from
- `USERNAME`: IB username
- `PASSWORD`: IB password
- `TRADINGMODE`: paper or live

You can either use the flags above to authenticate with IB, or you can mount in your own IBC `config.ini` file (example [here](https://github.com/IbcAlpha/IBC/blob/master/resources/config.ini)) at `/root/ibc/config.ini` in the container. The flags will overwrite anything in that location so use either the flags or the mount, not both.

## Intended Usage

### Expose the IB API but NOT ssh or VNC

```
docker run -it --rm --name broker  -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live ib
```

### Expose the VNC over ssh for interacting with gateway manually

**DO NOT EXPOSE PORT 5900. IT IS NOT SECURED.**

```
docker run -it --rm --name broker  -p 2222:22 -p 4003:4003 -e SSH=riazarbi -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=live ib
```

From your laptop: 

```bash
ssh -C -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 5900:localhost:5900 root@server -p 2222 &
sleep 1
vncviewer localhost:5900
```

## What runs in this container?

The base image is `ubuntu:focal`.

On top of that we install `openbox` and `tint2`. 

We run `tigervnc` on top of that.

We install IB `gateway` stable version directly from Interactive Brokers' website.

We install `ibc` from [IBCAlpha](https://github.com/IbcAlpha/IBC) to control gateway.

It all runs via `supervisor`.
