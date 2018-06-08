#!/bin/bash
# enable the Node.js v8 repository
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum install nodejs
sudo npm install -g truffle
sudo npm install -g ganache-cli
# required for SafeMath test
sudo npm install --save-dev chai
sudo npm install --save-dev chai-bignumber