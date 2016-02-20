This page explains how the OpenDaylight release process works once the TSC has
approved a release.

## Preparations

After release candidate is built gpg sign artifacts using odlrelease script in
**releng/builder/scripts**.

## Releasing OpenDaylight

- Nexus: click release for staging repo **(Helpdesk)**
- Send email to Helpdesk with binary URL to update website **(Helpdesk)**
- Send email to TSC and Release mailing lists announcing release binaries location **(Release Engineering Team)**
- Checkout autorelease and switch to release branch eg stable/lithium
  **(Release Engineering Team)**
- Make sure your git repo is setup to push (use git-review)

  git review -s

- Download patches from Jenkins build page

<pre>
    cd /tmp
    wget https://jenkins.opendaylight.org/releng/view/autorelease/job/autorelease-release-beryllium/58/artifact/patches/*zip*/patches.zip
    unzip patches.zip
</pre>

- Run the following commands for every project in the release

<pre>
    ../scripts/patch-odl-release.sh /tmp/patches Beryllium
    git review -y -t Beryllium
    git push gerrit release/beryllium
</pre>

- Tag autorelease too

<pre>
    git submodule foreach git checkout release/beryllium
    git add [add each project individually to not pull in extra]
    git commit -sm "Release Beryllium"
    git tag -asm "OpenDaylight Beryllium release" release/beryllium
    git review -y -t Beryllium
    git push gerrit release/beryllium
</pre>

- Generate release notes (???)
- Send email to release/tsc/dev notifying tagging and version bump complete **(Release Engineering Team)**

## Build cycles

ovsdb <-> sfc

Patch 1 (Version bump patch):
- Disable net-virt-sfc from modules list in openstack/pom.xml

Patch 2 (Post bump patch) - This patch needs to be merged after sfc merges:
- Re-enable net-virt-sfc
