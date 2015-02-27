# odlutils

Currently the dominant script here is for-all.pl which does a given
command for each line in a corresponding file with the idea that you
will pass a file of ODL project repositories.

This repo also contains a list of the all current ODL project repos
as well as all the repos participating in the Lithium release.

## Repo Lists

There are two repo lists at the moment
* `odl-repos.txt` which contains all current ODL repos.
* `li-repos.txt` which contains all OLD repos that are currently
                 participating in the Lithium release.

Note that `odl-repos.txt` has two lines commented out for projects
that I believe are not currently updating their repos. They are still
technically currently projects in good standing.

## using for-all.pl
The general syntax is

```
./for-all.pl [--no-cd] <file> <command>
```

By default, it runs `cd <line> && <command>` for each `<line>` in
`<file>` where and occurrence of `{}` in `<command>` is replaced by
`<line>`. If you pass `--no-cd` as an option it will skip the cd before
running the command.

It ignores lines in `<file>` where the first non-whitespace character
is a `#`.

### Examples

For example, to clone all of the repos in Lithium, you would do
something like:

```
./odlutils/for-all.pl --no-cd odlutils/li-repos.txt "git clone https://git.opendaylight.org/gerrit/{}.git" 
```

This will work for everything, but the releng repos (releng/builder and
releng/autorelease) because those repos have a different "name" for
their origin repo than they wind up for with a directory. _Note: I want
to fix it so that you can have a line like_ `releng/builder` _and it
will do the right thing and cd to builder, but you can reference
either_ `builder` _or_ `releng/builder` _using either_ `{}` _or_
`{full}`, _respectively._

An example of working with existing cloned repos would be something
like this:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "grep --include=pom.xml -r org.opendaylight.yangtools:features-test ."
```

### Making sure your cloned repos are up-to-date

Note that it's useful to make sure your repos are on the right branch
and up-to-date before doing things. You can do that by running:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git co master"
```

and making sure the output from each line looks like `Already on
'master'`.

You should then make sure they are up-to-date with master by doing:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git pull"
```

and making sure that each line looks like `Already up-to-date.`

#### Periodic cloned repo maintenance

**WARNING:** This will destroy any files you haven't checked in and
pushed to the server! **Do them with caution!**

It's good to periodically make sure that you're not keeping any random
untracked files around by doing something like this:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git clean -df"
```

You might also have to makes sure your branch hasn't gotten ahead of
the server by doing something like:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git reset --hard origin/master"
```
