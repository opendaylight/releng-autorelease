
## Preparations

After release candidate is built gpg sign artifacts using odlrelease script in
**releng/builder/scripts**.

## Releasing OpenDaylight

- Nexus: click release for staging repo **(Helpdesk)**
- Send email to TSC and Release mailing lists **(Release Engineering Team)**
- Checkout autorelease and switch to release branch eg stable/lithium
  **(Release Engineering Team)**
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


## Build cycles

ovsdb <-> sfc

Patch 1 (Version bump patch):
- Disable net-virt-sfc from modules list in openstack/pom.xml

Patch 2 (Post bump patch) - This patch needs to be merged after sfc merges:
- Re-enable net-virt-sfc
