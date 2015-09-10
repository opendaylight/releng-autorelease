The Release Engineering - [Autorelease project](https://wiki.opendaylight.org/view/RelEng/Autorelease)
is targeted at building the artifacts that are used in the release candidates
and final full release.

* [Open Gerrit Patches](https://git.opendaylight.org/gerrit/#/q/project:releng/autorelease+status:open)
* [Jenkins Jobs](https://jenkins.opendaylight.org/autorelease/)

Sections:

* [Cloning Autorelease](#cloning_autorelease)
* [Building Release Builds](#building_release_builds)
* [Adding staging repo settings](#staging_settings)

# <a href="cloning_autorelease">Cloning Autorelease</a>

To clone all the autorelease repo including it's submodules simply run the
clone command with the '''--recursive''' parameter.

    git clone --recursive https://git.opendaylight.org/gerrit/releng/autorelease

If you forgot to add the --recursive parameter to your git clone you can pull
the submodules after with the following commands.

    git submodule init
    git submodule update


# <a name="building_release_builds">Creating Autorelease - Release and RC build</a>

An autorelease release build comes from the autorelease-release-\<branch\> job
which can be found on the autorelease tab in the releng master:

  * https://jenkins.opendaylight.org/releng/view/autorelease/

For example to create a Lithium release candidate build launch a build from the
autorelease-release-lithium job by clicking the '''Build with Parameters'''
button on the left hand menu:

  * https://jenkins.opendaylight.org/releng/view/autorelease/job/autorelease-release-lithium/

The only field that needs to be filled in is the '''RELEASE_TAG''', leave all
other fields to their default setting. Set this to Lithium, Lithium-RC0,
Lithium-RC1, etc... depending on the build you'd like to create.

***

![image](autorelease-release-lithium-build.png "Parameters for Lithium-RC1 build")

***

# <a name="staging_settings">Adding Autorelease staging repo to settings.xml</a>

If you are building or testing this release in such a way that requires pulling
some of the artifacts from the Nexus repo you may need to modify your
settings.xml to include the staging repo URL as this URL is not part of ODL
Nexus' public or snapshot groups. If you've already cloned the recommended
settings.xml for building ODL you will need to add an additional profile and
activate it by adding these sections to the "\<profiles\>" and
"\<activeProfiles\>" sections (please adjust accordingly).

Note:

* This is an example and you need to "Add" these example sections to your
  settings.xml do not delete your existing sections.
* The URLs in the \<repository\> and \<pluginRepository\> sections will also
  need to be updated with the staging repo you want to test.


    <profiles>
      <profile>
        <id>opendaylight-staging</id>
        <repositories>
          <repository>
            <id>opendaylight-staging</id>
            <name>opendaylight-staging</name>
            <url>https://nexus.opendaylight.org/content/repositories/automatedweeklyreleases-1062</url>
            <releases>
              <enabled>true</enabled>
              <updatePolicy>never</updatePolicy>
            </releases>
            <snapshots>
              <enabled>false</enabled>
            </snapshots>
          </repository>
        </repositories>
        <pluginRepositories>
          <pluginRepository>
            <id>opendaylight-staging</id>
            <name>opendaylight-staging</name>
            <url>https://nexus.opendaylight.org/content/repositories/automatedweeklyreleases-1062</url>
            <releases>
              <enabled>true</enabled>
              <updatePolicy>never</updatePolicy>
            </releases>
            <snapshots>
              <enabled>false</enabled>
            </snapshots>
          </pluginRepository>
        </pluginRepositories>
      </profile>
    </profiles>

    <activeProfiles>
      <activeProfile>opendaylight-staging</activeProfile>
    </activeProfiles>
