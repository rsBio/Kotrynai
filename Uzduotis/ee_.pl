#!/usr/bin/perl

use warnings;
use strict;

my $data = "47s 157s 27a 
27s 47a 157a 
106s 178a 
48s 158s 26a 
21s 163a 
107s 177a 
104s 180a 
112s 172a 
49s 159s 25a 
23s 51a 161a 
103s 181a 
111s 173a 
22s 52a 162a 
102s 182a 
177s 107a 
108s 176a 
163s 21a 
180s 104a 
173s 111a 
105s 179a 
182s 102a 
113s 171a 
176s 108a 
179s 105a 
175s 109a 
178s 106a 
25s 49a 159a 
109s 175a 
171s 113a 
50s 160s 24a 
46s 156s 
26s 48a 158a 
110s 174a 
52s 162s 22a 
172s 112a 
181s 103a 
174s 110a 
24s 50a 160a 
51s 161s 23a
";
my %used_v;
my @not_used;

for (@coords){
#%	print join ' ', map { "[$_] -> [$used_v{ $_ }]" } sort keys %used_v;
	print "i[$_]";
	print "<".$used_v{ $_ }.">" if $used_v{ $_ };
	print "+" if $used_v{ $_ };
	next if $used_v{ $_ };
	my $used = join ' ',
	( map { s/a/s/r } grep m/a/, split ),
	( map { s/s/a/r } grep m/s/, split );
	print "u[$used\n]";
	$used_v{ "$used\n" } = 1;
	push @not_used, $_;
};

print $/ x 2;
@coords = @not_used;
print %used_v;

my @s_coords = sort 
	{ $a =~ m/\d+/; my $A = $&; $b =~ m/\d+/; my $B = $&; $A <=> $B } @coords;
print @s_coords;
print $/;
