autorelease/scripts/forall/for-all.py --pom autorelease --no-cd "git clone https://git.opendaylight.org/gerrit/{f}.git {} 2>/dev/null"
autorelease/scripts/forall/for-all.py --pom autorelease "git checkout $1 2>/dev/null" 
