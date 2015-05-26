# odlutils

Currently the dominant script here is for-all.pl which does a given
command for each line in a corresponding file with the idea that you
will pass a file of ODL project repositories.

This repo also contains a list of the all current ODL project repos
as well as all the repos participating in the Lithium release.

## Repo Lists

There are two repo lists at the moment
* `odl-repos.txt` which contains all current ODL repos.
* `li-repos.txt` which contains all ODL repos that are currently
                 participating in the Lithium release.
* `he-repos.txt` which contains all ODL repost that participated in
                 the Helium release.
* `h-repos.txt` which contains all ODL repost that participated in
                the Hydrogen release.

Note that `odl-repos.txt` has two lines commented out for projects
that I believe are not currently updating their repos. They are still
technically currently projects in good standing.

The fastest way to produce a list of all projects in OpenDaylight that
I've found is:

```
ssh git.opendaylight.org -p 29418 gerrit ls-projects
```

That requires having an OpenDaylight account and having your public key
set up on the current machine. A way that uses the REST API and a bit
of grep-fu, but will work from any machine for any person is:

```
curl https://git.opendaylight.org/gerrit/projects/?d | grep :.*{ | egrep -o [-a-z0-9/]+
```

## using for-all.pl
The general syntax is

```
./for-all.pl [--no-cd] <file> <command>
```

By default, it runs `cd <line> && <command>` for each `<line>` in
`<file>` where any occurrence of `{}` in `<command>` is replaced by
the text in `<line>` after the last `/`. Any occurrence of `{f}` is
replaced by `<line>`. This is useful for using the different parts of a 
repository name when it is hierarchical, e.g., `releng/builder`.

If you pass `--no-cd` as an option it will skip the cd before
running the command.

It ignores lines in `<file>` where the first non-whitespace character
is a `#`.

### Examples

For example, to clone all of the repos in Lithium, you would do
something like:

```
./odlutils/for-all.pl --no-cd odlutils/li-repos.txt "git clone https://git.opendaylight.org/gerrit/{f}.git" 
```

An example of working with existing cloned repos would be something
like this:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "grep --include=pom.xml -r org.opendaylight.yangtools:features-test ."
```

You can produce a list of patches between two releases of Helium with
something like this:

```
./odlutils/for-all.pl odlutils/he-repos.txt "git log release/helium-sr1..release/helium-sr2 --pretty=oneline | cat"
```

### Making sure your cloned repos are up-to-date

Note that it's useful to make sure your repos are on the right branch
and up-to-date before doing things. You can do that by running:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git checkout master"
```

and making sure the output from each line looks like `Already on
'master'`.

You should then make sure they are up-to-date with master by doing:

```
./odlutils/for-all.pl odlutils/odl-repos.txt "git pull"
```

and making sure that each line looks like `Already up-to-date.`

### Checking out a remote branch

Modern versions of git no longer allow you to check out remote branches
easily when you have multiple remotes, which is common when using
git-review like we do in OpenDaylight. To checkout a remote branch, use
syntax like this:

```
git checkout -b <local-branch-name> <remote-branch-name>
```

For example:

```
git checkout -b stable/lithium remotes/origin/stable/lithium
```

Or in the context of this script something like:

```
./odlutils/for-all.pl odlutils/li-repos.txt "git checkout -b stable/lithium remotes/origin/stable/lithium"
```

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
