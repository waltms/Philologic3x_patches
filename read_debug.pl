#!/usr/bin/perl

#my $debug = $ARGV[2];
my $debug = $ARGV[1];

#my $hitsize = $ARGV[0] * 2 + $ARGV[1] * 4;
#$unpack = "s" . $ARGV[0] . "i" . $ARGV[1];
my $hitsize = $ARGV[0] * 4;
$unpack = "i" . $ARGV[0];

open ($fh, "<:raw", $debug) || die "$0: cannot open $hitlist for reading: $!";
seek ($fh, 0 * $hitsize, 0);

my $i = 0;
my $hit;

while (read($fh, $hit, $hitsize)) {
	@o = unpack($unpack, $hit);
	printf "%d ", $_ for @o;
	print "\n";
}
close($fh);
print "\n";
