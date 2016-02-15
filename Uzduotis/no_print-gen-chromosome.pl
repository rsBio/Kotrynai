#!/usr/bin/perl

use warnings;
use strict;

my $str_width;
my @substrs;

while(1){
	print "Įveskite galutinės eilutės ilgį.\n";
	$_ = <>; chomp;
	/^\d+$/ and do{
		$str_width = $_; last
	}
}

print "Jei norite įvesti substringą, kuris dubliuosis"
	. " galutinėje eilutėje, įveskite tris skaičius:"
	. " substringo ilgį, pasikartojimų pirmyn kiekį,"
	. " pasikartojimų atgal (anti-sense) skaičių."
	. " Kitu atveju įveskite ne skaičius.\n";

while(<>){
	/^(\d+)\s+(\d+)\s(\d+)$/ ?
		do { push @substrs, [ $1, $2, $3 ] }
	:
		last;
}

srand( time ^ $$ );

my @dict = split //, 'ACGT';

sub _gen_line{
    my ($length) = shift;
    return join '', map { $dict[ rand(@dict) ] } 1 .. $length;
}

my $len_not_substrs = $str_width - eval join '+', 
	map { $_->[0] * ($_->[1] + $_->[2]) } @substrs;
#	print "[$len_not_substrs]\n";

my $not_substr = _gen_line( $len_not_substrs );
my @not_substr = split //, $not_substr;

my %places;

for (@substrs){
	
	my ($len, $x_sense, $x_anti) = @$_;
	my $substr = _gen_line( $len );
	my $anti = reverse( $substr =~ y/ACGT/TGCA/r );
	splice @not_substr, rand(@not_substr), 0, $substr for 1 .. $x_sense;
	splice @not_substr, rand(@not_substr), 0, $anti for 1 .. $x_anti;
	$places{ $substr }{'s'} = [];
	$places{ $substr }{'s->a'} = $anti;
	$places{ $anti }{'a<-s'} = $substr;
	$places{ $anti   }{'a'} = [];
#	print "[[sense: $substr, anti: $anti]]\n";

}

my $i = -1;
for (@not_substr){
	++ $i;
	next if 1 == length;
#%	print "<$_>\n";
	$places{ $_ }{'s'} and push @{ $places{ $_ }{'s'} }, $i . "s" or
	$places{ $_ }{'a'} and push @{ $places{ $_ }{'a'} }, $i . "a";
	$i += -1 + length;
}

#	print map "[$_]", map { "<$_>"
#		, ( defined $places{$_}{'s'} ? "@{ $places{$_}{'s'} }" : '')
#		. ( defined $places{$_}{'a'} ? "@{ $places{$_}{'a'} }" : '')
#	} sort keys %places;
#	print $/;

my $coords = join "\n", map { $_ . " " .
	join " ", ( 
	 @{ $places{$_}{'s'} }
	, @{ $places{ $places{$_}{'s->a'} }{'a'} } 
	)
} grep { defined $places{$_}{'s'} } sort keys %places;

#	print $coords;

#	print $/;
#	print "[@not_substr]\n";

my $str = join '', @not_substr;

#	print $str;
#	print "\n";

print "Sukurti failus: STR ir COORDS?\n";
<> =~ /y/i and
	do {
		print "Įveskite failo pavadinimą.\n";
		<> =~ /^.*$/;
		open my $out_str, '>', "$&.str" or die "$0: can't: $!!\n";
		print { $out_str } $str, $/;
		open my $out_coords, '>', "$&.coords" or die "$0: can't: $!!\n";
		print { $out_coords } $coords, $/;
	};


