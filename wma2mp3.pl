#!/usr/bin/perl -w
#
# The Original Perl Script is from http://www.linuxquestions.org/questions/linux-software-2/convert-wma-mp3-77093/page2.html#post593562
#
# Modify by Jonathan Tsai <tryweb@ichiayi.com>
# 16:47 2012/1/12
#
use strict;
use File::Find;

print "Starting Conversion\n";

my $rootdir = $ARGV[0]; #Root directory
my @files;

(-d $rootdir) or die "Invalid Root Directory\n";

find (\&parse, $rootdir);

foreach my $file (@files) {
	my $base= $file; $base =~ s/\.wma$//i;
	system "mplayer \"$file\" -ao pcm:file=\"$base.wav\"";
	system "lame -h \"$base.wav\" \"$base.mp3\"";
	unlink("$base.wav");
	print "$base.wma converted to mp3.\n";
}

print "Conversion Finished";


sub parse {
	my $raw = $File::Find::name;
	if ($raw =~ m/\.wma$/i) {
		push (@files, $File::Find::name);
	}
}
