#/usr/bin/env bash
# Copyright (c) 2015-2016, NVIDIA CORPORATION.  All rights reserved.

set -e
set -x

if [ "$#" -ne 1 ];
then
    echo "Usage: $0 INSTALL_DIR"
    exit 1
fi
INSTALL_DIR=$1
mkdir -p $INSTALL_DIR

# install Torch7
# instructions from: http://torch.ch/docs/getting-started.html
curl -s https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
git clone https://github.com/torch/distro.git $INSTALL_DIR --recursive
cd $INSTALL_DIR; ./install.sh -b