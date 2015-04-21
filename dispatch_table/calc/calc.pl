use Calc;

my $calculator = Calc::create_calculator();

while(<>) {
	print $calculator->($_), "\n";
}
