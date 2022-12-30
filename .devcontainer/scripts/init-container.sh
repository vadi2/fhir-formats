#!/usr/bin/env bash

set -e

sudo luarocks install argparse
sudo luarocks install lua-cjson
sudo luarocks install rapidjson
sudo luarocks install lunajson
sudo luarocks install lua-resty-prettycjson
sudo luarocks install datafile
sudo luarocks install xml
sudo luarocks install busted
sudo luarocks install inspect

exit
