#!/bin/bash

## Installing TFEnv
git clone https://github.com/kamatama41/tfenv.git /usr/share/.tfenv &&
ln -s /usr/share/.tfenv/bin/* /usr/local/bin/

# tfenv install latest
tfenv install 1.10.5
tfenv use 1.10.5
