# Interactive Brokers Gateway Docker Image

Interactive Brokers Gateway running in Docker. Ships with VNC via a NoVNC web page for debugging. 

Running an environment for API access to Interactive Brokers is notoriously difficult. This docker image aims to make it possible to spin up an accessible IB API with a single docker command.

# Releases and Packages

Every time Interactive Brokers release a new stable version of the Gateway, we download it and save it under releases. You can use this repo releases page to install a particular verion of the Gateway. 

When we detect a new release, we also build a new docker image, and tag it with the release version. Check out the tags under the 'packages' section of this repo.

## Ports

These are the services that will run when you spin up this container.

- An unauthenticated VNC server is running at port 5900, but it will only accept connections from the docker container localhost.
- NoVNC will expose an unauthenticated web page at port 6080 that shows the VNC desktop of the `broker` user. You can use this to debug the gateway.
- Regardless of whether you are using a live or paper account, the API will be accessible on port 4003.

**!!IF YOU EXPOSE PORT 6080 ANYONE CAN ACCESS YOUR USER. ONLY EXPOSE PORT 6080 IF YOU ARE A SECURE ENVIRONMENT.!!**

## Flags

- `USERNAME`: IB username
- `PASSWORD`: IB password
- `TRADINGMODE`: paper or live


## Intended Usage

### Launch the container and enter your credentials in the prompt

```
docker run -it --rm --name broker  -p 4003:4003 ghcr.io/riazarbi/ib-headless:10.30.1t
```


### Launch the container and log in with no user input

```
docker run -it --rm --name broker  -p 4003:4003 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=paper ghcr.io/riazarbi/ib-headless:10.30.1t
```

### Insecure, for debugging: Expose the VNC web page for interacting with gateway manually

```
docker run -it --rm --name broker  -p 4003:4003 -p 6080:6080 -e USERNAME=ibuser -e PASSWORD=ibpasswd -e TRADINGMODE=paper ghcr.io/riazarbi/ib-headless:10.30.1t
```

After launch, navigate to http://localhost:6080 to view the IB login window


## What runs in this container?

- The base image is `debian:stable`.
- On top of that we install `openbox` and `tint2`. 
- We run `tigervnc` on top of that.
- We use `websockify` to link `NoVNC` to the VNC server.
- We install IB `gateway` stable version directly from Interactive Brokers' website.
- We install `ibc` from [IBCAlpha](https://github.com/IbcAlpha/IBC) to control gateway.
- We use `socat` to relay external calls to the IB API to the gateway. This circumvents the localhost restriction on API access and allows any IP address to access the API.

It is all run by unprivileged user `broker` via `supervisord`. 
