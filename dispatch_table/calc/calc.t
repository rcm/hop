use Test::More;

BEGIN {
	use_ok('Calc');
}

ok(my $calc = Calc::create_calculator(), 'create calculator' );

my @tests = (
	['1 + 2',		3, 'simple addition'],
	['1 - 2',		-1, 'simple subtraction'],
	['2 * 3',		6, 'simple multiplication'],
	['3 / 2',		1.5, 'simple division'],
	['1 + 2 + 3',	6, 'adding three numbers'],
	['(-7) * 6',	-42, 'multiplication with negative numbers'],
	['7 * (-6)',	-42, 'multiplication with negative numbers'],
	['(-7) * (-6)',	42, 'multiplication with negative numbers'],
	['1 + (2 + 3)',	6, 'associativity'],
	['3 * (2 + 3)',	15, 'associativity'],
	['min(12, -2, 25, -4, 19, 5)',	-4, 'min'],
	['18*17*16*15*14*13*12*11*10*9*8*7*6*5*4*3*2*1', 6402373705728000, 'multiplying a lot of numbers'],
	['18!/((18-6)!*6!)',	18564, 'C(n, p)'],
	['mdc(45, 120, 180)', 15, 'mdc de vários números'],
	['(-19+3)/(-11+3)', 2, 'mais testes com parentesis e sinais negativos'],
);

for my $test (@tests) {
	is($calc->($test->[0]), $test->[1], $test->[2]);
}

done_testing();
