Home Alarm with an IR motion sensor, Raspberry Pi and Nerves
=======================================

This repository contains the software running on a raspberry pi working as a
home made alarm.

The raspberry pi has an WiFi antenna and an IR motion sensor. It uses the
motion sensor to detect movement and the antenna to know what devices are
connected. If there is movement and none of the authorized devices are
connected, it makes a POST request to an IFTTT endpoint, creating a push
notification on a mobile device. If the device is not connected to the
internet, it will retry the notification until it works. This is a standalone
application, it doesn't require any central server.

In this repository there is a [nerves project](./fw), a [phoenix ui](./ui) and
[custom firmware](./custom_rpi). The custom firmware is necessary because the
application uses [arp-scan](https://linux.die.net/man/1/arp-scan).

How to deploy
-------------

The setup and organisation is similar [to this example](https://github.com/nerves-project/nerves_examples/tree/master/hello_phoenix).
To setup and run you should follow the instructions on [nerve's documentation](https://hexdocs.pm/nerves/getting-started.html).
For this application in particular, you need the following environment variables.

```
export NERVES_NETWORK_SSID="..."
export NERVES_NETWORK_PSK="..."
export SECRET_KEY_BASE="..."
export MIX_TARGET=custom_rpi
export MIX_ENV=prod
export PORT=4000
```
