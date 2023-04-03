#!/binbash

find -name "*.dm" -exec sed -i "s|\([a-zA-Z_/0-9]\+\)\.proc/\([a-zA-Z0-9_]\+\)\([,)]\)|TYPE_PROC_REF(\1, \2)\3|g" {} \;
