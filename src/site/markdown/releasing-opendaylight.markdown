Steps:
- Nexus: click release for staging repo (may need to allow redeploy on release repo)
- Send email to TSC and Release mailing lists

- Checkout autorelease and switch to release branch eg stable/lithium
- Make sure your git repo is setup to push (use git-review):

    git review -s

- Download patches from Jenkins build page:

    cd /tmp
    wget https://jenkins.opendaylight.org/releng/view/autorelease/job/autorelease-release-lithium/58/artifact/patches/*zip*/patches.zip
    unzip patches.zip
    cd patches
    wget https://jenkins.opendaylight.org/releng/view/autorelease/job/autorelease-release-lithium/58/artifact/taglist.log

# TODO move taglist.log in patches directory so that it's only a single download.

Run the following commands for every project in the release:

    ../scripts/patch-odl-release.sh /tmp/patches Lithium-SR3
    git review -y -t Lithium-SR3
    git push gerrit release/lithium-sr3


Tag autorelease too:

    git submodule foreach git checkout release/lithium-sr3
    git add <add each project individually to not pull in extra>
    git commit -sm "Release Lithium-SR3"
    git tag
    ...


- Generate release notes




- Build cycles

controller <-> aaa

Patch 1 (Version bump patch):
- Don't bump aaa.version
- Disable features-test in netconf-connector
- Disable features-test in restconf

Patch 2 (Post bump patch) - This patch needs to be merged after aaa merges:
- Bump aaa.version
- Re-enable features-test in netconf-connector
- Re-enable features-test in restconf

openflowplugin <-> dlux

Patch 1 (Version bump patch):
- Disable features-dlux in features and features.xml

Patch 2 (Post bump patch) - Needs to be merged after dlux merges
- Re-enable features-dlux

dlux

Patch 1 (Version bump patch):
- Disable dlux-distribution

Patch 2 (Post bump patch) -
- Re-enable dlux-distribution
