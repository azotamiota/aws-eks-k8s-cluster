#!/bin/bash

## Installing TFEnv
git clone https://github.com/kamatama41/tfenv.git /usr/share/.tfenv &&
ln -s /usr/share/.tfenv/bin/* /usr/local/bin/

tfenv install latest
# tfenv install 0.12.21 
# tfenv use 0.12.21