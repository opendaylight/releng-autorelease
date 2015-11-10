#Example: ./generate-release-notes.sh lithium.repo stable/lithium remotes/origin/stable/lithium release/lithium-sr1..release/lithium-sr2
#{1} lithium.repo
#{2} stable/lithium
#{3} remotes/origin/stable/lithium
#{4} release/helium-sr1..release/helium-sr2

./iterate.pl --no-cd ${1} "git clone https://git.opendaylight.org/gerrit/{f}.git"
./iterate.pl ${1} "git checkout -b ${2} ${3}"
./iterate.pl ${1} "git log ${4} --pretty=oneline | cat" > release-notes.txt
cp release-notes.txt release-notes.wiki
perl -i.1 -pe 's/bug[- :]*(\d+) ?[:-]? ?/[https:\/\/bugs.opendaylight.org\/show_bug.cgi?id=$1 BUG-$1]: /gi' release-notes.wiki
perl -i.2 -pe 's/([0-9a-f]{6})([0-9a-f]+)/* [https:\/\/git.opendaylight.org\/gerrit\/#\/q\/$1$2 $1]/' release-notes.wiki
cp release-notes.txt release-notes.adoc
perl -i.1 -pe 's/bug[- :]*(\d+) ?[:-]? ?/https:\/\/bugs.opendaylight.org\/show_bug.cgi?id=$1\[BUG-$1\]: /gi' release-notes.adoc
perl -i.2 -pe 's/([0-9a-f]{6})([0-9a-f]+)/* https:\/\/git.opendaylight.org\/gerrit\/#\/q\/$1$2\[$1\]/' release-notes.adoc
mv release-notes.wiki release-notes.wiki.3
sed -e '/\] Applying the Lithium SR2/d' release-notes.wiki.3 > release-notes.wiki.4
sed -e '/\] Bumping versions /d' release-notes.wiki.4 > release-notes.wiki.5
sed -e '/\] Revert /d' release-notes.wiki.5 > release-notes.wiki.6
sed -e '/\] Merge /d' release-notes.wiki.6 > release-notes.wiki
mv release-notes.adoc release-notes.adoc.3
sed -e '/\] Applying the Lithium SR2/d' release-notes.adoc.3 > release-notes.adoc.4
sed -e '/\] Bumping versions /d' release-notes.adoc.4 > release-notes.adoc.5
sed -e '/\] Revert /d' release-notes.adoc.5 > release-notes.adoc.6
sed -e '/\] Merge /d' release-notes.adoc.6 > release-notes.adoc
