use Stream ':all';

my $s = iterate {
	my ($a, $b) = @{$_[0]};
	$b++ if (rand() < 0.2);
	$a = rand() * 5 - 2 + $b * 10;
	[$a, $b];
} [0, 0];

my $t = cut_sort($s, sub {$_[0][0] <=> $_[1][0]}, sub { $_[1]->[1] > $_[0]->[1] + 5 });
$t = transform {"$_[0][0]\t$_[0][1]"} $t;

{
	local $"= "\n";
	show($t, 500);
}
