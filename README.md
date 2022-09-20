# Interactive Brokers Gateway Docker

IB Gateway running in Docker with VNC over ssh


## Usage

The basic idea is that you run a standalone container running the IB gateway, and then interact with the IB API via a docker private network. 

## Example

### Build Image

```bash
docker build --tag riazarbi/ib-headless:no-controller .
```

### Create network and run container

```bash
docker network create ib
docker run -it --rm --name broker --network ib -p 2222:22 -e SSH=<GITHUB_HANDLE> riazarbi/ib-headless:no-controller
```

### VNC in to container to log in

From your laptop: 

```bash
ssh -C -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -L 5900:localhost:5900 root@server -p 2222 &
sleep 1
vncviewer localhost:5900
```

This should launch a VNC session where you can log in to IB. Note that you've only exposed ssh on the `broker` docker container, and that you need to have a private key to log in. 

### Launch a container on the server to interact with the API

```bash
docker run -it --rm --network ib random_container
```


