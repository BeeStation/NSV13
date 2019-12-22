#!/bin/bash
set -euo pipefail

source dependencies.sh

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
<<<<<<< HEAD
nvm use $NODE_VERSION
npm install --global yarn
=======
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36

pip3 install --user PyYaml
pip3 install --user beautifulsoup4

phpenv global $PHP_VERSION
