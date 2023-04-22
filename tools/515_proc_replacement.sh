# Run this from the top directory of the repo
find -name "*.dm" -exec sed -i "s|\([a-zA-Z_/0-9]\+\)\.proc/\([a-zA-Z0-9_]\+\)\([,)]\)|TYPE_PROC_REF(\1, \2)\3|g" {} \;
find -name "*.dm" -exec sed -i "s|\.proc/\([a-zA-Z0-9_]\+\)\([,)]\)|PROC_REF(\1)\2|g" {} \;
find -name "*.dm" -exec sed -i "s|, /proc/\([a-zA-Z0-9_]\+\)\([,)]\)|, GLOBAL_PROC_REF(\1)\2|g" {} \;
