#!/usr/bin/perl

my $hitlist = $ARGV[2];
print $hitlist;

my $hitsize = $ARGV[0] * 2 + $ARGV[1] * 8;
$unpack = "s" . $ARGV[0] . "i" . $ARGV[1];

open ($fh, "<:raw", $hitlist) || die "$0: cannot open $hitlist for reading: $!";
seek ($fh, 0 * $hitsize, 0);

my $i = 0;
my $hit;

print "\n";
while (read($fh, $hit, $hitsize)) {
	@o = unpack($unpack, $hit);
	printf "%d ", $_ for @o;
	print "\n";
}
close($fh);
print "\n";
