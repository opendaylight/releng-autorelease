#!/usr/bin/perl -w

use strict;

#use Getopt::Long;
#GetOptions( 'no-cd' => \$nocd, 'fake' => \$fake, 'verbose' => \$verbose );

my $cd = "1";

# other options:
#   -f for fake
#   -v for verbose to print command

my $num_args = $#ARGV + 1;
if ($num_args < 2 or ($num_args == 3 and $ARGV[0] ne "--no-cd") or $num_args > 3) {
	print "args: [--no-cd] <file> <command>\n\n";
	print "   by default runs \"cd <line> && <command>\" for each <line> in <file>\n";
	print "     if you would like to not cd first, use the --no-cd flag\n\n";
	print "   any occurance of {} in <command> will be replaced by <line>\n";
	exit;
}

if ($num_args == 3 && $ARGV[0] eq "--no-cd") {
	$cd = "0";
	$ARGV[0] = $ARGV[1];
	$ARGV[1] = $ARGV[2];
}

open my $file, "<$ARGV[0]" or die "Couldn't open file ARGV[0], $!";

while(<$file>){
	chomp;
	if($_ =~ /^\s*#/) {
		next;
	}
	my $command = $ARGV[1];
	$command =~ s/{}/$_/g;
	if($cd) {
		$command = "cd $_ && $command";
	}
	print $_."\n";
	# print $command."\n";
	system($command);
}
