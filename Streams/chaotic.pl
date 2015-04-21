use Stream ':all';

sub henon {
	my ($a, $b, $y0, $t0) = @_;
	$y0 //= 0;
	$t0 //= 0;

	iterate {
		my ($y, $t) = @{$_[0]};
		[1 - $a * $y * $y + $z, $b * $y];
	} [$y0, $t0];
}

my $s = henon(1.4, 0.3);

{
	local $" = "\n";
	local $/ = "";
	show($s, 1000, sub {"$_[0][0] $_[0][1]"});
}
