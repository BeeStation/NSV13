#!/bin/bash
set -euo pipefail

tools/deploy.sh travis_test
mkdir travis_test/config

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

cd travis_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
<<<<<<< HEAD
DreamDaemon beestation.dmb -close -trusted -verbose -params "test-run&log-directory=travis"
=======
DreamDaemon nsv13.dmb -close -trusted -verbose -params "test-run&log-directory=travis"
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
cd ..
cat travis_test/data/logs/travis/clean_run.lk
