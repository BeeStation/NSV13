#!/usr/bin/env python3

# Literally just makes a backup of every dmm file

import glob, os, shutil
for root, dirs, files in os.walk(os.getcwd()):
    for file in files:
        if file.endswith(".dmm"):
            # print(os.path.join(root, file))
            fullpath = os.path.join(root, file)
            try:
                shutil.copy(fullpath, fullpath + ".backup")
            except Exception as e:
                print(e)
