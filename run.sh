#!/bin/bash

docker build -t ubuntu-xfce-rdp .
docker run -it -p 3389:3389 --name ubuntu-xrdp ubuntu-xfce-rdp
