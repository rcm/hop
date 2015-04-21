use Stream ':all';

sub primos {
	my ($s) = @_;
	my $p = head($s);

	node($p, promise { primos( filter { $_[0] % $p > 0 } tail($s) ) } );
}


$primos = primos(node(2, iterate {$_[0] + 2} 3 ));

{
	local $" = "\n";
	show($primos, 10000);
}
