find . -name *.yang | grep "src/main" | grep -v test | grep -v samples | grep -v "__" | while read line; do pyang -f name $line 2>/dev/null; done 
