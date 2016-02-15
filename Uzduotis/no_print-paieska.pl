#!/usr/bin/perl

use warnings;
use strict;
use Term::ANSIColor;

my $file = shift @ARGV;

open my $fh, '<', "$file" or die "$0: can't: $!!\n";

$_ = do { local $/; <$fh> };
s/>.*\n//;
s/\n//g;

sub _get_anti{
	my ($sense) = shift;
	return scalar reverse $sense =~ y/ACGT/TGCA/r;
}

my @lett = qw/ a c g t /;

my $substr_len = 10;
print "Įveskite ieškomo fragmento ilgį. (numatytasis: 10)\n";
<> =~ m/^\d+$/ and $substr_len = $& ;

my %coords_s;
my %coords_a;

while( m/(?= (.{$substr_len}) )/gx ){
	my $sense = $1;
	$coords_s{ $sense } //= []; ###/
	push @{ $coords_s{ $sense } }, pos . 's';
	my $anti = _get_anti( $sense );
	$coords_a{ $sense } //= []; ###/
	push @{ $coords_a{ $sense } }, pos . 'a';
#%	print "S: $sense\nA: $anti\n";
}

#^	print map { "$_ -> @{ $coords_s{ $_ } }\n" } sort keys %coords_s;
#^	print $/;
#^	print map { "$_ -> @{ $coords_a{ $_ } }\n" } sort keys %coords_a;
#^	print $/;

#^	print map {
#^			my $anti = _get_anti( $_ );
#^			"$_ -> @{ $coords_s{ $_ } }", " ",
#^			( $coords_a{ $anti } ? "@{ $coords_a{ $anti } }" : "" ),
#^			"\n"
#^		} sort keys %coords_s;
#^	print $/;

#	Išrenku įrašus, turinčius daugiau kaip vieną koordinatę.
my @coords = grep { 1 < split } map {
		my $anti = _get_anti( $_ );
		( join " ", ## $_, "->",
		@{ $coords_s{ $_ } },
		( $coords_a{ $anti } ? @{ $coords_a{ $anti } } : () ) ) .
		"\n"
	} sort keys %coords_s;

#^	print @coords;
#^	print $/;

#	Surikiuoju pagal pirmąją (visada 's') koordinatę.
my @s_coords = sort 
	{ $a =~ m/\d+/; my $A = $&; $b =~ m/\d+/; my $B = $&; $A <=> $B } @coords;
#^	print @s_coords;
#^	print $/;

my %used_v;
my @not_used;

#	Masyve @not_used liks tik s...a... kooordinatės, vengiant simetrinių pasikartojimų.
for (@s_coords){
#%	print join ' ', map { "[$_] -> [$used_v{ $_ }]" } sort keys %used_v;
#%	print "i[$_]";
#%	print "<".$used_v{ $_ }.">" if $used_v{ $_ };
#%	print "+" if $used_v{ $_ };
	next if $used_v{ $_ };
	my $used = join ' ',
	( map { s/a/s/r } grep m/a/, split ),
	( map { s/s/a/r } grep m/s/, split );
#%	print "u[$used\n]";
	$used_v{ "$used\n" } = 1;
	push @not_used, $_;
};

#^	print $/ x 2;
@s_coords = @not_used;
#%	print %used_v;

my @f_coords = map { m/\d+/; $& } @s_coords;
#^	print join "\n", @f_coords;
#^	print $/;
#^	print $/;


#	Į blokus sudedamos koordinatės, pagal pirmosios koordinatės ištisines sekas.
my @blocks;
my @block = ();
my $last = -2;
for (@s_coords, -5){	# -5: nereikšmingas elementas papildomam ciklui
	m/\d+/;
	$& == $last + 1 ? 
		do {
			push @block, $_;
		}
	:
		do {
			@block and push @blocks, [ @block ];
			@block = ($_);
		};
	$last = $&;
}

#^	print join "\n", map { "[@$_]" } @blocks;
#^	print $/ x 2;

#%	my @blocks2 = map { my @arr = @$_; 
#%	[ @arr > 1 ? @arr[0, -1] : (@arr) x 2 ] } @blocks;

#%	print join "\n", map { "[@$_]" } @blocks2;
#%	print $/ x 2;

#	Kiekviename bloke pasirenkamas didžiausias indeksų rinkinys.
for (@blocks){
	my @block_v2 = @$_;
	my $max = ( sort {$b <=> $a} map { scalar split } @block_v2 )[ 0 ];
#^	print $max, $/;
	my @new;
##	my $once = 0;
	for my $coords_v2 (@block_v2){
		(split ' ', $coords_v2) == $max and do { push @new, $coords_v2; last };
	}
	$_ = [ @new ];
}

	print join "\n", map { "[@$_]" } @blocks;
	print $/ x 2;

my %used;
my @u_blocks;

@_ = split //;

my $COMMENT = <<'END'
#	Nepamenu, kas čia:
FOR:
for (@blocks){
	my $f_line = @{$_}[0];
	my $l_line = @{$_}[-1];
	print "[$f_line|$l_line]";
	next if grep $used{ $_ }, split ' ', $l_line;
	$f_line =~ m/\d+\w/;
	my $f_coord = $&;
	$f_coord =~ y/as/sa/;
	print $f_coord;
	$used{ $f_coord } = 1;
	push @u_blocks, join ' ', scalar @$_, $f_line;
}

## HACK??
	@u_blocks = grep ! m/^1\b/, @u_blocks;

#	print @u_blocks;
	print $/;

for (@u_blocks){
	my ($wide, @c) = split;
	
	for my $c (@c){
		my $u_c;
		$u_c = $c + ($c =~ /s/ ? 0 : -$wide);
		my $arrows = join '', ($c =~ m!s! ? '>':'<') x 4;
		$_[ $u_c ] =~ s/^/ ' <' . ($substr_len + $wide -1) 
						. '>[' . $arrows /e;
		$_[ $u_c + $substr_len + $wide -1] =~ s/^/ $arrows . '] ' /e;
	}
	
}

END
;

#	open my $out, '>', "$file.out" or die "$0: Can't: $!!\n";

#	Spausdinamos sekos su ANSIColor žymėjimu (s - yellow, a - red).
for my $block (@blocks){
	my $from = 0;
	my $to_print;
	for my $start (sort 
		{ $a =~ m/\d+/; my $A = $&; $b =~ m/\d+/; my $B = $&; $A <=> $B } 
		split ' ', @$block[0]){
		my $start_n = $start;
		$start_n =~ s/[sa]//;
		my $direction = $&;
		$to_print .= substr $_, $from, $start_n - $from;
		$to_print .= colored( (substr $_, $start_n, $substr_len), $direction eq 's' ? 'yellow' : 'red');
		$from = $start_n + $substr_len;
	}
	$to_print .= substr $_, $from;
	$to_print .= $/;
#^	print $to_print;

#	Būdas spausdinti ale FASTA formatu:
#%	for (my $i = 0; $i < length; $i += 10){
#%		print ' ' x (8 - length $i) . $i . ' ' if not $i % 60;
#%		print substr $to_print, $i, 10;
#%		print $i % 60 ? ' ' : "\n";
#%	}
#	END Būdas;

#	Būdas spausdinti kas 10 po viena ilga sekos eilute:
#^	for (my $i = 0; $i < length; $i += 10){
#^		print '|' . $i . ' ' x (10 - 1 - length $i);
#^	}
#	END Būdas;

#^	print $/;
}

#^	print "Originali seka:\n";
#^	print join "", @_;
#^	print $/;

