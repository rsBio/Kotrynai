#!/usr/bin/perl

use warnings;
use strict;

my $file = shift @ARGV;

open my $fh, '<', "$file" or die "$0: can't: $!!\n";

$_ = do { local $/; <$fh> };
s/>.*\n//;
s/\n//g;

my @lett = qw/ a c g t /;
my %bin_to_lett = map { (sprintf "%02b", $_) => $lett[ $_ ] } 0 .. 4 -1;

my $shl = 2 * 3;

for my $i (0 .. (1 << $shl) -1 ){
	my $bin = sprintf "%0${shl}b", $i;
	my $seq = $bin =~ s/../ $bin_to_lett{ $& } /egr;
	print $seq, $/;
	my $qrseq = qr/$seq/i;
	print scalar( () = /$qrseq/g ), $/;
}
