#!/usr/bin/perl -w

use strict;

my $usage = <<END;
args: [--diff|--stat] <git-commit-tag-or-branch>

  By default, this will print what .yang files were added, deleted, or
  changed between the specified commit tag or branch and HEAD.

  If you speficify --diff or --stat, it will also provide output of the
  'git diff' or 'git diff --stat' command for files that changed,
  comparing the file in HEAD and in the specified commit tag or branch.

END

my $git_args = ""; # no args to git diff
my $show_diff = ""; # false

my $num_args = $#ARGV + 1;
if ($num_args < 1 || $num_args > 2) {
    print $usage;
    exit;
}

if ($num_args == 2) {
    if ($ARGV[0] eq "--diff") {
        # intentionally blank
    } elsif ($ARGV[0] eq "--stat") {
        $git_args = "--stat";
    } else {
        print $usage;
        exit;
    }
    $show_diff = "1";
    $ARGV[0] = $ARGV[1]; # copy the second arg to the first arg
}

my $old_git = $ARGV[0];
my $new_git = "HEAD";

# check if $old_git and $new_git exists
`git show $old_git >& /dev/null`;
if ($? != 0) {
    print "tag, commit or branch $old_git couldn't be found\n";
    exit;
}
`git show $new_git >& /dev/null`;
if ($? != 0) {
    print "tag, commit or branch $new_git couldn't be found";
    exit;
}

# get the git hashes for both $old_git and $new_git
my $old_hash = substr(`git rev-parse $old_git`, 0, 8);
my $new_hash = substr(`git rev-parse $new_git`, 0, 8);

# build a list of the yang files both in HEAD and the specified commit/tag/branch
my @new_yangfiles = `git ls-tree $new_git --name-only -r | grep \\.yang\$ | grep -v src/test`;
my @old_yangfiles = `git ls-tree $old_git --name-only -r | grep \\.yang\$ | grep -v src/test`;
push(@new_yangfiles, @old_yangfiles); # combine the lists
my %yangfiles_hash = map {$_, 1} @new_yangfiles; # make them they keys of hash to remove dupes
my @yangfiles = keys %yangfiles_hash; # get the list of keys

print "comparing YANG models between $old_git ($old_hash) and $new_git ($new_hash)\n";

foreach my $yangfile (@yangfiles) {

    chomp $yangfile; #remove the trailing "\n", if any

    # figure out if the file was present in the old commit
    my $is_in_old = `git ls-tree -r --name-only $old_git | grep -c $yangfile` != 0;

    # figure out if the file was present in the new commit
    my $is_in_new = `git ls-tree -r --name-only $new_git | grep -c $yangfile` != 0;

    if ($is_in_new and $is_in_old) {
        my $diff = `git diff $git_args $old_git..$new_git -- $yangfile`;
        if ($diff ne "") {
            print "model changed: $yangfile\n";
            if ($show_diff) {
                print $diff;
            }
        }
    } elsif ( !$is_in_new ) {
        print "model deleted: $yangfile\n";
    } elsif ( !$is_in_old ) {
        print "model added: $yangfile\n";
    }
}
