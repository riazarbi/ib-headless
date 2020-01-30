# Interactive Brokers Gateway Docker

IB Gateway running in Docker with [IB Controller](https://github.com/ib-controller/ib-controller/) and VNC

* TWS Gateway: TODO
* IB Controller: TODO

### Docker Hub image



### Getting Started

```bash
docker run --name ib -it --rm -p 5901:5900 -p 4003:4003 -e VNC_PASSWORD=1235 -e  TRADING_MODE=paper -e TWSUSERID=username -e TWSPASSWORD=password riazarbi/ib
```

You will now have the IB Gateway app running on port 4003 and VNC on 5901.

Please do not open your box to the internet.

### Testing VNC

* localhost:5901

