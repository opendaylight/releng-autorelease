#!/usr/bin/perl -w

use strict;

# TODOs:
#  * Move to use Getopt::Long;
#    * GetOptions( 'no-cd' => \$nocd, 'fake' => \$fake, 'verbose' => \$verbose );
#    * new options to add:
#        -f for fake
#        -v for verbose to print command
#  * Add support for reading <file> from stdin in addition to specifying the file
#  * Provide tools that automatically get all repos?

my $cd = "1";

my $num_args = $#ARGV + 1;
if ($num_args < 2 or ($num_args == 3 and $ARGV[0] ne "--no-cd") or $num_args > 3) {
	print "args: [--no-cd] <file> <command>\n\n";
	print "   by default runs \"cd <line> && <command>\" for each <line> in <file>\n";
	print "     if you would like to not cd first, use the --no-cd flag\n\n";
	print "   any occurance of {} in <command> will be replaced by the text after the last '/' in <line>\n";
	print "   any occurance of {f} in <command> will be replaced by <line>\n\n";
	print "   lines in <file> with '#' as the first non-whitespace character are ignored\n";
	exit;
}

if ($num_args == 3 && $ARGV[0] eq "--no-cd") {
	$cd = "0";
	$ARGV[0] = $ARGV[1];
	$ARGV[1] = $ARGV[2];
}

open my $file, "<$ARGV[0]" or die "Couldn't open file $ARGV[0], $!";

while(<$file>){
	chomp;
	if($_ =~ /^\s*#/) {
		next;
	}
	my $command = $ARGV[1]; #the command is the second argument
	$command =~ s/{f}/$_/g; #replace {f} with the full line
	my @words = split('/',$_); #parse out the stuff after the last '/'
	$_ = $words[$#words];
	$command =~ s/{}/$_/g; #repace {} the stuff after the last '/'
	if($cd) {
		$command = "cd $_ && $command";
	}
	print $_."\n";
	# print $command."\n";
	system($command);
}
