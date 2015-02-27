# odlutils

Currently the dominant script here is for-all.pl which does a given
command for each line in a corresponding file with the idea that you
will pass a file of ODL project repositories.

This repo also contains a list of the all current ODL project repos
as well as all the repos participating in the Lithium release.

An example use would be something like this:

./for-all.pl odl-repos.txt "grep --include=pom.xml -r org.opendaylight.yangtools:features-test ."