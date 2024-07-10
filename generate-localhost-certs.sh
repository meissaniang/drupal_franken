#!/usr/bin/env bash
rm -rf ./config/docker/certs
mkdir ./config/docker/certs
cd ./config/docker/certs
brew install mkcert
mkcert -install;
mkcert --cert-file ./localhost.crt --key-file ./localhost.key localhost "vesper.docker.localhost" 127.0.0.1 ::1;
cp "$(mkcert -CAROOT)/rootCA.pem" ./localCA.crt;
